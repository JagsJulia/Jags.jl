using Jags
using Base.Test

include(Pkg.dir("Jags", "test", "test_utils.jl"))

old = pwd()
ProjDir = Pkg.dir("Jags", "Examples", "Dyes")
cd(ProjDir)
println("Moving to directory: $(ProjDir)")

isfile("tmp") &&
  rm("tmp");

include(Pkg.dir(ProjDir, "jdyes.jl"))
clean_dir(jagsmodel)

isfile("tmp") &&
  rm("tmp");

cd(old)
