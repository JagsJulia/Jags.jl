function jags(
  model::Jagsmodel,
  data = Dict{ASCIIString, Any}(),
  init = Dict{ASCIIString, Any}[],
  ProjDir=pwd();
  updatedatafile::Bool=true,
  updateinitfiles::Bool=true
  )
  
  old = pwd()
  
  try
    cd(ProjDir)
    
    if updatedatafile
      if length(keys(data)) > 0
        print("\nCreating data file $(model.name)-data.R - ")
        @time update_R_file(Pkg.dir(model.tmpdir, "$(model.name)-data.R"), data)
      end
    else
      println("\nData file not updated.")
    end
    
    if updateinitfiles
      if size(init, 1) > 0
        update_init_files(model, init)
      end
    else
      println("\nInit files not updated.")
    end
    
    println()
    curdir = pwd()
    cd(model.tmpdir)
    println("Executing $(model.ncommands) command(s), each with $(model.nchains) chain(s) took:")
    @time run(pipeline(par(model.command), stdout="$(model.name)-run.log"))
    sim = mchain(model)
    cd(old)
    return(sim)  
  catch e
    println(e)
    cd(old)
  end
end

#### Update data and init files

function update_init_files(model::Jagsmodel, init)
  println()
  k = length(init)
  m = max(model.nchains, model.ncommands)
  indx = filter(x -> x!=0, [%(i, (k+1)) for i in 1:2m])
  for i in 1:m
    print("Creating init file $(model.name)-inits$(i).R - ")
    @time update_R_file(Pkg.dir(model.tmpdir, "$(model.name)-inits$(i).R"), init[indx[i]])
  end
end

function update_R_file(file::String, dct; replaceNaNs::Bool=true)
  isfile(file) && rm(file)
  strmout = open(file, "w")
  
  str = ""
  for entry in dct
    
    str = "\""*entry[1]*"\""*" <- "
    val = entry[2]
    if replaceNaNs
      if typeof(entry[2]) == Array{Float64, 1}
        if true in isnan(entry[2])
          val = convert(DataArray, entry[2])
          for i in 1:length(val)
            if isnan(val[i])
              val[i] = NA
            end
          end
        end
      end
      if typeof(entry[2]) == Array{Float64, 2}
        if true in isnan(entry[2])
          val = convert(DataArray, entry[2])
          k,l = size(val)
          for i in 1:k
            for j in 1:l
              if isnan(val[i, j])
                val[i, j] = NA
              end
            end
          end
        end
      end
     end
    if typeof(val) <: String
      str = str*"\"$(val)\"\n"
    elseif length(val)==1 && length(size(val))==0
      # Scalar
      str = str*"$(val)\n"
    elseif length(val)>=1 && length(size(val))==1
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
  index = readdlm(Pkg.dir(model.tmpdir, "$(model.name)-cmd1-index.txt"), header=false)
  idxdct = Dict{ASCIIString, Any}()
  for row in 1:size(index)[1]
    if length(keys(idxdct)) == 0
      idxdct = Dict(index[row, 1] => [int(index[row, 2]), int(index[row, 3])])
    else
      merge!(idxdct, Dict(index[row, 1] => [int(index[row, 2]), int(index[row, 3])]))
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
      if isfile(Pkg.dir(model.tmpdir, "$(model.name)-cmd$(i)-chain$(j).txt"))
        println("Reading $(model.name)-cmd$(i)-chain$(j).txt")
        res = readdlm(Pkg.dir(model.tmpdir, "$(model.name)-cmd$(i)-chain$(j).txt"), header=false)
        for key in index[:, 1]
          indx1 = idxdct[key][1]
          indx2 = idxdct[key][2]
          if length(keys(tdict)) == 0
            tdict = Dict(key => res[indx1:indx2, 2])
          else
            tdict = merge(tdict, Dict(key => res[indx1:indx2, 2]))
          end
        end
        ## End of processing result type file ##
        ## If any keys were found, merge it in the rtdict ##
      
        if length(keys(tdict)) > 0
          #println("Merging $(convert(Symbol, res_type)) with keys $(keys(tdict))")
          rtdict = merge(rtdict, Dict(res_type => tdict))
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

function mchain(model::Jagsmodel)
  println()
  local totalnchains, curchain
  index = readdlm(Pkg.dir(model.tmpdir, "$(model.name)-cmd1-index.txt"), header=false)

  cnames = String[]
  for i in 1:size(index)[1]
    append!(cnames, [index[i]])
  end
  
  totalnchains = model.nchains * model.ncommands
  a3d = fill(0.0, Int(index[1, 3]), size(index, 1), totalnchains)
  for i in 1:model.ncommands
    for j in 1:model.nchains
      if isfile(Pkg.dir(model.tmpdir, "$(model.name)-cmd$(i)-chain$(j).txt"))
        println("Reading $(model.name)-cmd$(i)-chain$(j).txt")
        res = readdlm(Pkg.dir(model.tmpdir, "$(model.name)-cmd$(i)-chain$(j).txt"), header=false)
        curchain = (i-1)*model.nchains + j
        #println(curchain)
        k = 0
        for key in cnames
          k += 1
          a3d[:, k, curchain] = res[index[k, 2]:index[k, 3], 2]
        end
      end
    end
  end
  println()
  sr = getindex(a3d, [model.adapt:model.thin:size(a3d)[1];], [1:size(a3d)[2];], [1:size(a3d)[3];])
  Chains(sr, start=model.adapt, thin=model.thin, names=cnames, chains=[i for i in 1:totalnchains])
end


#### Read DIC related results

function read_pDfile(model::Jagsmodel)
  index = readdlm(Pkg.dir(model.tmpdir, "$(model.name)-cmd1-index0.txt"), header=false)
  idxdct = Dict{ASCIIString, Any}()
  for row in 1:size(index)[1]
    if length(keys(idxdct)) == 0
      idxdct = Dict(index[row, 1] => [int(index[row, 2]), int(index[row, 3])])
    else
      merge!(idxdct, Dict(index[row, 1] => [int(index[row, 2]), int(index[row, 3])]))
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
    if isfile(Pkg.dir(model.tmpdir, "$(model.name)-cmd1-chain$(i).txt"))
      println("Reading $(model.name)-cmd1-chain$(i).txt")
      res = readdlm(Pkg.dir(model.tmpdir, "$(model.name)-cmd1-chain$(i).txt"), header=false)
      for key in index[:, 1]
        indx1 = idxdct[key][1]
        indx2 = idxdct[key][2]
        if length(keys(tdict)) == 0
          tdict = Dict(key => res[indx1:indx2, 2])
        else
          tdict = merge(tdict, Dict(key => res[indx1:indx2, 2]))
        end
      end
      ## End of processing result type file ##
      ## If any keys were found, merge it in the rtdict ##
      
      if length(keys(tdict)) > 0
        #println("Merging $(convert(Symbol, res_type)) with keys $(keys(tdict))")
        rtdict = merge(rtdict, Dict(res_type => tdict))
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
  res = readdlm(Pkg.dir(model.tmpdir, "$(model.name)-cmd1-table0.txt"), header=false)
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