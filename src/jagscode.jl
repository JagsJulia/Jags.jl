function jags(model::Jagsmodel, ProjDir=pwd(); 
  data=Nothing, init=Nothing, monitor=Nothing,
  updatejagsfile::Bool=true, 
  updatedatafile::Bool=true,
  updateinitfiles::Bool=true)
  
  old = pwd()
  
  try
    cd(ProjDir)
    
    for i in 1:model.ncommands
      isfile("$(model.name)-cmd$(i).jags") &&  rm("$(model.name)-cmd$(i).jags");
      isfile("$(model.name)-cmd$(i)-index0.txt") &&
        rm("$(model.name)-cmd$(i)-index0.txt");
      isfile("$(model.name)-cmd$(i)-table0.txt") &&
        rm("$(model.name)-cmd$(i)-table0.txt");
      for j in 1:model.nchains
         isfile("$(model.name)-cmd$(i)-chain$(j).R") &&
          rm("$(model.name)-cmd$(i)-chain$(j).R");
      end
    end
    #return
    if data!=Nothing && updatedatafile && length(keys(data)) > 0
      update_R_file("$(model.name)-data.R", data)
    end
  
    if length(monitor) == 0 && length(init) > 0
      for entry in init
        monitor = merge(monitor, [entry[1] => true])
      end
    end
    model.monitor = monitor
    
    if init!=Nothing && updateinitfiles
      for i in 1:model.ncommands
        if length(init) == model.ncommands
          if length(keys(init[i])) > 0
            updatejagsfile && update_jags_file(model, i)
            update_R_file("$(model.name)-cmd$(i).R", init[i])
          end
        else
          if length(keys(init[1])) > 0
            if i == 1
              println("\nLength of init array is not equal to ncommands,")
              println("the first element will used for all chains in all commands.")
            end
            updatejagsfile && update_jags_file(model, i)
            update_R_file("$(model.name)-cmd$(i).R", init[1])
          end
        end
      end
    end
  
    for i in 1:model.ncommands
      jfile = "$(model.name)-cmd$(i).jags"
      model.command[i] = @windows ? `cmd /c jags $(jfile)` : `jags $(jfile)`
    end
    run(par(model.command) >> "$(model.name)-run.log")
    #run(par(model.command[1], 1) >> "$(model.name)-run.log")
    (index, chns) = read_jagsfiles(model)
    
    for i in 1:model.ncommands
      isfile("$(model.name)-cmd$(i).jags") && 
        rm("$(model.name)-cmd$(i).jags");
      isfile("$(model.name)-cmd$(i)-index.txt") &&
        rm("$(model.name)-cmd$(i)-index.txt");
      
      isfile("$(model.name)-cmd$(i).R") &&
       rm("$(model.name)-cmd$(i).R");
      for j in 1:model.nchains
        isfile("$(model.name)-cmd$(i)-chain$(j).txt") &&
         rm("$(model.name)-cmd$(i)-chain$(j).txt");
      end
    end
    
    cd(old)
    return((index, chns))    
  catch e
    println(e)
    cd(old)
  end
end

#### Function to update the jags, init and data files

function update_jags_file(model::Jagsmodel, cmd::Int)
  jagsstr = "/*\n\tGenerated $(model.name).jags command file\n*/\n"
  if model.deviance || model.dic || model.popt
    jagsstr = jagsstr*"load dic\n"
  end
  jagsstr = jagsstr*"model in $(model.model_file)\n"
  jagsstr = jagsstr*"data in $(model.data_file)\n"
  jagsstr = jagsstr*"compile, nchains($(model.nchains))\n"
  for i in 1:model.nchains
    fname = "$(model.name)-cmd$(cmd).R"
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
    strmout = open(file, "w")
    write(strmout, str)
    close(strmout)
  end
end

function update_R_file(file::String, dct::Dict{ASCIIString, Any}; replaceNaNs::Bool=true)
  isfile(file) && rm(file)
  strmout = open(file, "w")
  
  str = ""
  for entry in dct
    str = "\""*entry[1]*"\""*" <- "
    val = entry[2]
    if replaceNaNs && true in isnan(entry[2])
      val = convert(DataArray, entry[2])
      for i in 1:length(val)
        if isnan(val[i])
          val[i] = NA
        end
      end
    end
    if length(val)==1 && length(size(val))==0
      # Scalar
      str = str*"$(val)\n"
    elseif length(val)>1 && length(size(val))==1
      # Vector
      str = str*"structure(c("
      for i in 1:length(val)
        str = str*"$(val[i])"
        if i < length(val)
          str = str*", "
        end
      end
      str = str*"), .Dim=c($(length(val))))\n"
    elseif length(val)>1 && length(size(val))>1
      # Array
      str = str*"structure(c("
      for i in 1:length(val)
        str = str*"$(val[i])"
        if i < length(val)
          str = str*", "
        end
      end
      dimstr = "c"*string(size(val))
      str = str*"), .Dim=$(dimstr))\n"
    end
    write(strmout, str)
  end
  close(strmout)
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
  index = readdlm("CODAindex.txt", header=false)

  cnames = String[]
  for i in 1:size(index)[1]
    append!(cnames, [index[i]])
  end
  
  a3d = fill(0.0, int(index[1, 3]), size(index)[1], m.nchains)
  for i in 1:m.ncommands
    if isfile("$(model.name)-cmd$(i)-chain1.txt")
      println("Reading $(model.name)-cmd$(i)-chain1.txt")
      res = readdlm("$(model.name)-cmd$(i)-chain1.txt", header=false)
      j = 0
      for key in cnames
        j += 1
        a3d[:, j, i] = res[index[j, 2]:index[j, 3], 2]
      end
    end
  end
  sr = getindex(a3d, [m.adapt:m.thin:size(a3d)[1]], [1:size(a3d)[2]], [1:size(a3d)[3]])
  Chains(sr, start=m.adapt, thin=m.thin, names=cnames, chains=[i for i in 1:m.nchains])
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