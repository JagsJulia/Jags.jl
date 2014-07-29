ProjDir = homedir()*"/.julia/v0.3/Jags/Examples/Line2"

function update_model_file(file::String, str::String)
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
    println("File $(file) ok.")
  end
end

function update_R_file(file::String, dct::Dict{Symbol, Any})
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
    else
      # Matrix or more
      println(size(val))
    end
    write(strmout, str)
  end
  close(strmout)
end

