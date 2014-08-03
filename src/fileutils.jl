function update_jags_file(model::Jagsmodel)
  jagsstr = "/*\n\tGenerated $(model.name).jags command file\n*/\n"
  jagsstr = jagsstr*"model in $(model.model_file)\n"
  jagsstr = jagsstr*"data in $(model.data_file)\n"
  jagsstr = jagsstr*"compile, nchains($(model.chains))\n"
  jagsstr = jagsstr*"inits in $(model.init_file)\n"
  jagsstr = jagsstr*"initialize\n"
  jagsstr = jagsstr*"update $(model.adapt)\n"
  for entry in model.monitor
    if entry[2]
      jagsstr = jagsstr*"monitor $(string(entry[1])), thin($(model.thin))\n"
    end
  end
  jagsstr = jagsstr*"update $(model.update)\n"
  jagsstr = jagsstr*"coda *\n"
  jagsstr = jagsstr*"exit\n"
  update_model_file(model.jags_file, jagsstr)
end

function update_model_file(file::String, str::String)
  str2 = ""
  if isfile(file)
    str2 = open(readall, file, "r")
    str != str2 && rm(file)
  end
  if str != str2
    println("\nFile $(file) will be updated.\n")
    strmout = open(file, "w")
    write(strmout, str)
    close(strmout)
  end
end

function update_R_file(file::String, dct::Dict{Symbol, Any}; replaceNaNs::Bool=true)
  isfile(file) && rm(file)
  strmout = open(file, "w")
  
  #
  # Example of entry in inits.R and data.R files
  #
  # "v" <- structure(c(5), .Dim=c(1))
  # "v" <- structure(c(1, 2, 3), .Dim=c(3))
  # "v" <- structure(c(1, 2, 3, 4, 5, 6), .Dim=c(3, 2))
  #
  # v =[ 1, 2, 3, 4, 5, 6]
  # m = reshape(v, 3, 2)
  # size(m) => (3,2)
  # length(m) => 6
  # m[5] => 5
  #
  
  str = ""
  for entry in dct
    #println(entry)
    #println(symbol(entry[1]))
    #println(entry[2], " => ", typeof(entry[2]))
    str = "\""*string(entry[1])*"\""*" <- "
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
    else
      # Matrix or more
      println(size(val))
    end
    write(strmout, str)
  end
  close(strmout)
end

