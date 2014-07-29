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

function update_inits_file(file::String, init::Dict{Symbol, Any})
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
  
  for entry in init
    println(entry)
    str = "\""*string(key[1])*"\""*" <- "*init[key(entry)]*"\n"
    write(strmout, str)
  end
  close(strmout)
end

function update_data_file(file::String, data::Dict{Symbol, Any})
  isfile(file) && rm(file)
  strmout = open(file, "w")
  for key in data
    println(key)
    str = "\""*string(key[1])*"\""*" <- $(key[2])"*"\n"
    write(strmout, str)
  end
  close(strmout)
end
