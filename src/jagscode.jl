function jags(model::Jagsmodel, ProjDir=pwd(); data=Nothing, updatejagsfile::Bool=true)
  
  old = pwd()
  
  idx = Dict()
  chains = Dict[]
  try
    cd(ProjDir)
    for i in 0:model.chains
      isfile("CODAchain$(i).txt") && rm("CODAchain$(i).txt")
    end
    isfile("CODAindex0.txt") && rm("CODAindex0.txt")
    isfile("CODAtable0.txt") && rm("CODAtable0.txt")
    
    updatejagsfile && update_jags_file(model)
    
    jfile = "$(model.jags_file)"
    cmd = @windows ? `cmd /c jags $(jfile)` : `jags $(jfile)`
    
    @time run(cmd)
    (idx, chains) = read_jagsfiles(model.chains)
    
  catch e
    println(e)
    cd(old)
  end
  cd(old)
  (idx, chains)
end

#### use readdlm to read in all chains and create a Dict

function read_jagsfiles(nochains::Int64)
  index = readdlm("CODAindex.txt", header=false)
  idxdct = Dict()
  for row in 1:size(index)[1]
    if length(keys(idxdct)) == 0
      idxdct = [convert(Symbol, index[row, 1]) => [int(index[row, 2]), int(index[row, 3])]]
    else
      merge!(idxdct, [convert(Symbol, index[row, 1]) => [int(index[row, 2]), int(index[row, 3])]])
    end
  end

  ## Collect the results of a chain in an array ##
  
  chainarray = Dict[]
  
  ## Each chain dictionary can contain up to 4 types of results ##
  
  result_type_files = ["samples"]
  rtdict = Dict()
  res_type = result_type_files[1]
  
  ## tdict contains the arrays of values ##
  tdict = Dict()
  
  println()
  for i in 1:nochains
    tdict = Dict()
    if isfile("CODAchain$(i).txt")
      println("Reading CODAchain$(i).txt")
      res = readdlm("CODAchain$(i).txt", header=false)
      for key in index[:, 1]
        s = convert(Symbol, key)
        indx1 = idxdct[s][1]
        indx2 = idxdct[s][2]
        if length(keys(tdict)) == 0
          tdict = [s => res[indx1:indx2, 2]]
        else
          tdict = merge(tdict, [s => res[indx1:indx2, 2]])
        end
      end
      ## End of processing result type file ##
      ## If any keys were found, merge it in the rtdict ##
      
      if length(keys(tdict)) > 0
        #println("Merging $(convert(Symbol, res_type)) with keys $(keys(tdict))")
        rtdict = merge(rtdict, [convert(Symbol, res_type) => tdict])
        tdict = Dict()
      end
    end
    
    ## If rtdict has keys, push it to the chain array ##
    
    if length(keys(rtdict)) > 0
      #println("Pushing the rtdict with keys $(keys(rtdict))")
      push!(chainarray, rtdict)
      rtdict = Dict()
    end
  end
  (idxdct, chainarray)
end

function read_pDfile()
  index = readdlm("CODAindex0.txt", header=false)
  idxdct = Dict()
  for row in 1:size(index)[1]
    if length(keys(idxdct)) == 0
      idxdct = [convert(Symbol, index[row, 1]) => [int(index[row, 2]), int(index[row, 3])]]
    else
      merge!(idxdct, [convert(Symbol, index[row, 1]) => [int(index[row, 2]), int(index[row, 3])]])
    end
  end

  ## Collect the results of a chain in an array ##
  
  chainarray = Dict[]
  
  ## Each chain dictionary can contain up to 4 types of results ##
  
  result_type_files = ["samples"]
  rtdict = Dict()
  res_type = result_type_files[1]
  
  ## tdict contains the arrays of values ##
  tdict = Dict()
  
  for i in 0:0
    tdict = Dict()
    if isfile("CODAchain$(i).txt")
      println("Reading CODAchain$(i).txt")
      res = readdlm("CODAchain$(i).txt", header=false)
      for key in index[:, 1]
        s = convert(Symbol, key)
        indx1 = idxdct[s][1]
        indx2 = idxdct[s][2]
        if length(keys(tdict)) == 0
          tdict = [s => res[indx1:indx2, 2]]
        else
          tdict = merge(tdict, [s => res[indx1:indx2, 2]])
        end
      end
      ## End of processing result type file ##
      ## If any keys were found, merge it in the rtdict ##
      
      if length(keys(tdict)) > 0
        #println("Merging $(convert(Symbol, res_type)) with keys $(keys(tdict))")
        rtdict = merge(rtdict, [convert(Symbol, res_type) => tdict])
        tdict = Dict()
      end
    end
    
    ## If rtdict has keys, push it to the chain array ##
    
    if length(keys(rtdict)) > 0
      #println("Pushing the rtdict with keys $(keys(rtdict))")
      push!(chainarray, rtdict)
      rtdict = Dict()
    end
  end
  (idxdct, chainarray)
end

function read_table_file(model::Jagsmodel, len::Int64)
  pdpopt = Dict[]
  res = readdlm("CODAtable0.txt", header=false)
  if model.dic && model.popt
    pdpopt = [:pD_mean => res[1:len, 2]]
    pdpopt = merge(pdpopt, [:popt => res[len+1:2len, 2]])
  else
    if model.dic
      pdpopt = [:pD_mean => res[1:len, 2]]
    else
      pdpopt = [:popt => res[1:len, 2]]
    end
  end
  pdpopt
end