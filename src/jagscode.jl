function jags(model::Jagsmodel, ProjDir=pwd();
  updatejagsfile::Bool=true)
  
  old = pwd()
  
  try
    cd(ProjDir)

    for i in 1:model.ncommands
      updatejagsfile && update_jags_file(model, i)
    end
    
    println()
    @time run(par(model.command) >> "$(model.name)-run.log")
    #run(par(model.command[1], 1) >> "$(model.name)-run.log")
    #(index, chns) = read_jagsfiles(model)
    sim = mchain(model)
    cd(old)
    #return((index, chns))
    return(sim)  
  catch e
    println(e)
    cd(old)
  end
end

#### Function to update the jags file

function update_jags_file(model::Jagsmodel, cmd::Int)
  jagsstr = "/*\n\tGenerated $(model.name).jags command file\n*/\n"
  if model.deviance || model.dic || model.popt
    jagsstr = jagsstr*"load dic\n"
  end
  jagsstr = jagsstr*"model in $(model.model_file)\n"
  jagsstr = jagsstr*"data in $(model.data_file)\n"
  jagsstr = jagsstr*"compile, nchains($(model.nchains))\n"
  for i in 1:model.nchains
    fname = "$(model.name)-inits$(i).R"
    jagsstr = jagsstr*"parameters in $(fname), chain($(i))\n"
  end
  jagsstr = jagsstr*"initialize\n"
  jagsstr = jagsstr*"update $(model.adapt)\n"
  if model.deviance
    jagsstr = jagsstr*"monitor deviance\n"
  end
  if model.dic
    jagsstr = jagsstr*"monitor pD\n"
    jagsstr = jagsstr*"monitor pD, type(mean)\n"
  end
  if model.popt
    jagsstr = jagsstr*"monitor popt, type(mean)\n"
  end
  for entry in model.monitor
    if entry[2]
      jagsstr = jagsstr*"monitor $(string(entry[1])), thin(1)\n"
    end
  end
  jagsstr = jagsstr*"update $(model.update)\n"
  jagsstr = jagsstr*"coda *, stem($(model.name)-cmd$(cmd)-)\n"
  jagsstr = jagsstr*"exit\n"
  check_jags_file("$(model.name)-cmd$(cmd).jags", jagsstr)
end

function check_jags_file(file::String, str::String)
  str2 = ""
  if isfile(file)
    str2 = open(readall, file, "r")
    str != str2 && rm(file)
  end
  if str != str2
    println("File $(file) will be updated.")
    strmout = open(file, "w")
    write(strmout, str)
    close(strmout)
  else
    println("File $(file) not updated.")
  end
end

#### use readdlm to read in all chains and create a Dict

function read_jagsfiles(model::Jagsmodel)
  index = readdlm("$(model.name)-cmd1-index.txt", header=false)
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
  for i in 1:model.ncommands
    tdict = Dict{ASCIIString, Any}()
    for j in 1:model.nchains
      if isfile("$(model.name)-cmd$(i)-chain$(j).txt")
        println("Reading $(model.name)-cmd$(i)-chain$(j).txt")
        res = readdlm("$(model.name)-cmd$(i)-chain$(j).txt", header=false)
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
  end
  (idxdct, chainarray)
end

#### Create a Mamba::Chains result

function mchain(m::Jagsmodel)
  local totalnchains, curchain
  index = readdlm("$(m.name)-cmd1-index.txt", header=false)

  cnames = String[]
  for i in 1:size(index)[1]
    append!(cnames, [index[i]])
  end
  
  totalnchains = m.nchains * m.ncommands
  a3d = fill(0.0, int(index[1, 3]), size(index, 1), totalnchains)
  for i in 1:m.ncommands
    for j in 1:m.nchains
      if isfile("$(m.name)-cmd$(i)-chain$(j).txt")
        println("Reading $(m.name)-cmd$(i)-chain$(j).txt")
        res = readdlm("$(m.name)-cmd$(i)-chain$(j).txt", header=false)
        curchain = (i-1)*m.nchains + j
        #println(curchain)
        k = 0
        for key in cnames
          k += 1
          a3d[:, k, curchain] = res[index[k, 2]:index[k, 3], 2]
        end
      end
    end
  end
  sr = getindex(a3d, [m.adapt:m.thin:size(a3d)[1]], [1:size(a3d)[2]], [1:size(a3d)[3]])
  Chains(sr, start=m.adapt, thin=m.thin, names=cnames, chains=[i for i in 1:totalnchains])
end


#### Read DIC related results

function read_pDfile(model::Jagsmodel)
  index = readdlm("$(model.name)-cmd1-index0.txt", header=false)
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
    if isfile("$(model.name)-cmd1-chain$(i).txt")
      println("Reading $(model.name)-cmd1-chain$(i).txt")
      res = readdlm("$(model.name)-cmd1-chain$(i).txt", header=false)
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
  res = readdlm("$(model.name)-cmd1-table0.txt", header=false)
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