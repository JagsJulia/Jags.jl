######### Stan batch program example  ###########

#using DataFrames, Distributions, MCMC, Gadfly

old = pwd()

# Probably better to enclose in try...catch construct, ';' sequencing a bit cumbersome

try
  cd("/Users/rob/.julia/v0.3/Jags/Examples/Line/")
  @time run(`jags line.jags`)
catch e
  println(e)
end

cd(old)