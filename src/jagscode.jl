function mis2str(x::Missing) return "NA" end
function mis2str(x::Char) return x end
function mis2str(x) return string(x) end

function jags(
  model::Jagsmodel,
  data = Dict{String, Any}(),
  init = Dict{String, Any}(),
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
        @time update_R_file(joinpath(model.tmpdir, "$(model.name)-data.R"), data)
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
    @time update_R_file(joinpath(model.tmpdir, "$(model.name)-inits$(i).R"), init[indx[i]])
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
        if true in isnan.(entry[2])
          val = convert(Array{Union{Float64,Missing}},entry[2])
          for i in 1:length(val)
            if isnan(val[i])
              val[i] = NA
            end
          end
        end
      end
      if typeof(entry[2]) == Array{Float64, 2}
        if true in isnan.(entry[2])
          val = convert(Array{Union{Float64,Missing}},entry[2])
          k,l = size(val)
          for i in 1:k
            for j in 1:l
              if isnan(val[i, j])
                val[i, j] = missing
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
      str = str * mis2str(val) * "\n"
    elseif length(val)>=1 && length(size(val))==1
      # Vector
      str = str*"structure(c("
      for i in 1:length(val)
        str = str*"$(mis2str(val[i]))"
        if i < length(val)
          str = str*", "
        end
      end
      str = str*"), .Dim=c($(length(val))))\n"
    elseif length(val)>1 && length(size(val))>1
      # Array
      str = str*"structure(c("
      for i in 1:length(val)
        str = str*"$(mis2str(val[i]))"
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
  index = readdlm(joinpath(model.tmpdir, "$(model.name)-cmd1-index.txt"), header=false)
  idxdct = Dict{String, Any}()
  for row in 1:size(index)[1]
    idxdct[index[row, 1]]=[Int(index[row, 2]), Int(index[row, 3])]
  end

  ## Collect the results of a chain in an array ##

  chainarray = Dict{String, Any}[]

  ## Each chain dictionary can contain up to 4 types of results ##

  result_type_files = ["samples"]
  rtdict = Dict{String, Any}()
  res_type = result_type_files[1]

  ## tdict contains the arrays of values ##
  tdict = Dict{String, Any}()

  println()
  for i in 1:model.ncommands
    tdict = Dict{String, Any}()
    for j in 1:model.nchains
      if isfile(joinpath(model.tmpdir, "$(model.name)-cmd$(i)-chain$(j).txt"))
        println("Reading $(model.name)-cmd$(i)-chain$(j).txt")
        res = readdlm(joinpath(model.tmpdir, "$(model.name)-cmd$(i)-chain$(j).txt"), header=false, dims=(index[end,end],2));
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
          rtdict[res_type]=tdict
          tdict = Dict{String, Any}()
        end
      end

      ## If rtdict has keys, push it to the chain array ##

      if length(keys(rtdict)) > 0
        #println("Pushing the rtdict with keys $(keys(rtdict))")
        push!(chainarray, rtdict)
        rtdict = Dict{String, Any}()
      end
    end
  end
  (idxdct, chainarray)
end

#### Create a MCMCChains::Chains result

function mchain(model::Jagsmodel)
  println()
  local totalnchains, curchain
  index = readdlm(joinpath(model.tmpdir, "$(model.name)-cmd1-index.txt"),
    header=false)

  # Correct model.adapt for jagsthin != 1
  # if jagsthin != 1, adaptation samples are not included.

  if model.jagsthin != 1
    model.adapt = 1
  end

  cnames = String[]
  for i in 1:size(index)[1]
    append!(cnames, [index[i]])
  end

  totalnchains = model.nchains * model.ncommands
  a3d = fill(0.0, Int(index[1, 3]),
    size(index, 1), totalnchains);
  for i in 1:model.ncommands
    for j in 1:model.nchains
      if isfile(joinpath(model.tmpdir, "$(model.name)-cmd$(i)-chain$(j).txt"))
        println("Reading $(model.name)-cmd$(i)-chain$(j).txt")
        res = readdlm(joinpath(model.tmpdir, "$(model.name)-cmd$(i)-chain$(j).txt"),
          header=false, dims=(index[end],2))
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
  MCMCChains.Chains(a3d,cnames)
end


#### Read DIC related results

function read_pDfile(model::Jagsmodel)
  index = readdlm(joinpath(model.tmpdir, "$(model.name)-cmd1-index0.txt"), header=false);
  idxdct = Dict{String, Any}()
  for row in 1:size(index)[1]
    idxdct[index[row, 1]]=[Int(index[row, 2]), Int(index[row, 3])]
  end

  ## Collect the results of a chain in an array ##

  chainarray = Dict{String, Any}[]

  ## Each chain dictionary can contain up to 4 types of results ##

  result_type_files = ["samples"]
  rtdict = Dict{String, Any}()
  res_type = result_type_files[1]

  ## tdict contains the arrays of values ##
  tdict = Dict{String, Any}()

  for i in 0:0
    tdict = Dict{String, Any}()
    if isfile(joinpath(model.tmpdir, "$(model.name)-cmd1-chain$(i).txt"))
      println("Reading $(model.name)-cmd1-chain$(i).txt")
      res = readdlm(joinpath(model.tmpdir, "$(model.name)-cmd1-chain$(i).txt"), header=false, dims=(index[end],2));
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
        tdict = Dict{String, Any}()
      end
    end

    ## If rtdict has keys, push it to the chain array ##

    if length(keys(rtdict)) > 0
      #println("Pushing the rtdict with keys $(keys(rtdict))")
      push!(chainarray, rtdict)
      rtdict = Dict{String, Any}()
    end
  end
  (idxdct, chainarray)
end

function read_table_file(model::Jagsmodel, len::Int)
  pdpopt = Dict{String, Any}[]
  if model.dic && model.popt
      numrows = 2len
  else
      numrows = len
  end
  res = readdlm(joinpath(model.tmpdir, "$(model.name)-cmd1-table0.txt"), header=false, dims=(numrows,2))
  if model.dic && model.popt
    pdpopt = Dict("pD.mean" => res[1:len, 2])
    pdpopt = merge(pdpopt, Dict("popt" => res[len+1:2len, 2]))
  else
    if model.dic
      pdpopt = Dict("pD.mean" => res[1:len, 2])
    else
      pdpopt = Dict("popt" => res[1:len, 2])
    end
  end
  pdpopt
end
