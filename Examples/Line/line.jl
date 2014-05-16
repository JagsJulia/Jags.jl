######### Jags batch program example  ###########

#using DataFrames, Distributions, MCMC, Gadfly

old = pwd()
ProjDir = homedir()*"/.julia/v0.3/Jags/Examples/Line"

try
  cd(ProjDir)
  isfile("CODAchain1.txt") && rm("CODAchain1.txt")
  isfile("CODAchain2.txt") && rm("CODAchain2.txt")
  isfile("CODAindex.txt") && rm("CODAindex.txt")
  
  @time run(`jags line.jags`)
catch e
  println(e)
  cd(old)
end

cd(old)