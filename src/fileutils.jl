ProjDir = homedir()*"/.julia/v0.3/Jags/Examples/Line2"

function update_file(file::String, str::String)
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

str = "
This is a model
with several lines
in it
"

update_file(ProjDir*"/test.bugs", str)

