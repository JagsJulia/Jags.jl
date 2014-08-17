function jags(model::Jagsmodel, ProjDir=pwd(); data=Nothing, updatejagsfile::Bool=true)
  
  old = pwd()
  
  idx = Dict()
  chains = Dict[]
  try
    cd(ProjDir)
    for i in 0:model.nchains
      isfile("CODAchain$(i).txt") && rm("CODAchain$(i).txt")
    end
    isfile("CODAindex0.txt") && rm("CODAindex0.txt")
    isfile("CODAtable0.txt") && rm("CODAtable0.txt")
    
    updatejagsfile && update_jags_file(model)
    
    jfile = "$(model.jags_file)"
    cmd = @windows ? `cmd /c jags $(jfile)` : `jags $(jfile)`
    
    @time run(cmd)
    (idx, chains) = read_jagsfiles(model.nchains)
    
  catch e
    println(e)
    cd(old)
  end
  cd(old)
  (idx, mambachain(chains))
end


#### Create a Mamba::Chains result

function mambachain(c::Array{Dict{ASCIIString,Any},1})
  colnames = String[]
  for key in keys(c[1]["samples"])
    append!(colnames, [string(key)])
  end
  iters = length(c[1]["samples"][colnames[1]])
  vars = length(c[1]["samples"])
  chns = length(c)
  a3d = fill(0.0, iters, vars, chns)
  j = 0
  for key in keys(c[1]["samples"])
    j += 1
    for i in 1:chns
      a3d[:, j, i] = c[i]["samples"][key]
    end
  end
  sr = StepRange[1:1:iters]
  Chains(a3d, start=1, thin=1, names=colnames, chains=[i for i in 1:chns])
end


#### use readdlm to read in all chains and create a Dict

function read_jagsfiles(nochains::Int)
  index = readdlm("CODAindex.txt", header=false)
  idxdct = Dict{ASCIIString, Any}()
  for row in 1:size(index)[1]
    if length(keys(idxdct)) == 0
      idxdct = [index[row, 1] => [int(index[row, 2]), int(index[row, 3])]]
    else
      merge!(idxdct, [index[row, 1] => [int(index[row, 2]), int(index[row, 3])]])
    end
  end

  ## Collect the results of a chain in an array ##
  
  chainarray = Dict{ASCIIString, Any}[]
  
  ## Each chain dictionary can contain up to 4 types of results ##
  
  result_type_files = ["samples"]
  rtdict = Dict{ASCIIString, Any}()
  res_type = result_type_files[1]
  
  ## tdict contains the arrays of values ##
  tdict = Dict{ASCIIString, Any}()
  
  println()
  for i in 1:nochains
    tdict = Dict{ASCIIString, Any}()
    if isfile("CODAchain$(i).txt")
      println("Reading CODAchain$(i).txt")
      res = readdlm("CODAchain$(i).txt", header=false)
      for key in index[:, 1]
        indx1 = idxdct[key][1]
        indx2 = idxdct[key][2]
        if length(keys(tdict)) == 0
          tdict = [key => res[indx1:indx2, 2]]
        else
          tdict = merge(tdict, [key => res[indx1:indx2, 2]])
        end
      end
      ## End of processing result type file ##
      ## If any keys were found, merge it in the rtdict ##
      
      if length(keys(tdict)) > 0
        #println("Merging $(convert(Symbol, res_type)) with keys $(keys(tdict))")
        rtdict = merge(rtdict, [res_type => tdict])
        tdict = Dict{ASCIIString, Any}()
      end
    end
    
    ## If rtdict has keys, push it to the chain array ##
    
    if length(keys(rtdict)) > 0
      #println("Pushing the rtdict with keys $(keys(rtdict))")
      push!(chainarray, rtdict)
      rtdict = Dict{ASCIIString, Any}()
    end
  end
  (idxdct, chainarray)
end

function read_pDfile()
  index = readdlm("CODAindex0.txt", header=false)
  idxdct = Dict{ASCIIString, Any}()
  for row in 1:size(index)[1]
    if length(keys(idxdct)) == 0
      idxdct = [index[row, 1] => [int(index[row, 2]), int(index[row, 3])]]
    else
      merge!(idxdct, [index[row, 1] => [int(index[row, 2]), int(index[row, 3])]])
    end
  end

  ## Collect the results of a chain in an array ##
  
  chainarray = Dict{ASCIIString, Any}[]
  
  ## Each chain dictionary can contain up to 4 types of results ##
  
  result_type_files = ["samples"]
  rtdict = Dict{ASCIIString, Any}()
  res_type = result_type_files[1]
  
  ## tdict contains the arrays of values ##
  tdict = Dict{ASCIIString, Any}()
  
  for i in 0:0
    tdict = Dict{ASCIIString, Any}()
    if isfile("CODAchain$(i).txt")
      println("Reading CODAchain$(i).txt")
      res = readdlm("CODAchain$(i).txt", header=false)
      for key in index[:, 1]
        indx1 = idxdct[key][1]
        indx2 = idxdct[key][2]
        if length(keys(tdict)) == 0
          tdict = [key => res[indx1:indx2, 2]]
        else
          tdict = merge(tdict, [key => res[indx1:indx2, 2]])
        end
      end
      ## End of processing result type file ##
      ## If any keys were found, merge it in the rtdict ##
      
      if length(keys(tdict)) > 0
        #println("Merging $(convert(Symbol, res_type)) with keys $(keys(tdict))")
        rtdict = merge(rtdict, [res_type => tdict])
        tdict = Dict{ASCIIString, Any}()
      end
    end
    
    ## If rtdict has keys, push it to the chain array ##
    
    if length(keys(rtdict)) > 0
      #println("Pushing the rtdict with keys $(keys(rtdict))")
      push!(chainarray, rtdict)
      rtdict = Dict{ASCIIString, Any}()
    end
  end
  (idxdct, chainarray)
end

function read_table_file(model::Jagsmodel, len::Int)
  pdpopt = Dict{ASCIIString, Any}[]
  res = readdlm("CODAtable0.txt", header=false)
  if model.dic && model.popt
    pdpopt = ["pD.mean" => res[1:len, 2]]
    pdpopt = merge(pdpopt, ["popt" => res[len+1:2len, 2]])
  else
    if model.dic
      pdpopt = ["pD.mean" => res[1:len, 2]]
    else
      pdpopt = ["popt" => res[1:len, 2]]
    end
  end
  pdpopt
end