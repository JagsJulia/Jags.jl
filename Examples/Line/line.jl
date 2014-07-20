######### Jags batch program example  ###########

using Jags

old = pwd()
ProjDir = homedir()*"/.julia/v0.3/Jags/Examples/Line"

idx = 0
samples = 0
try
  cd(ProjDir)
  for i in 1:4
    isfile("CODAchain$(i).txt") && rm("CODAchain$(i).txt")
  end
  isfile("CODAindex.txt") && rm("CODAindex.txt")
  
  @time run(`jags line.jags`)
  (idx, samples) = read_jagsfiles()

catch e
  println(e)
  cd(old)
end

cd(old)