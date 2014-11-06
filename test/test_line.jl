using Jags
using Base.Test

include(Pkg.dir("Jags", "test", "test_utils.jl"))

old = pwd()
ProjDir = Pkg.dir("Jags", "Examples", "Line1")
cd(ProjDir)
println("Moving to directory: $(ProjDir)")

isfile("tmp") &&
  rm("tmp");

include(Pkg.dir(ProjDir, "jline1.jl"))
clean_dir(jagsmodel)

ProjDir = Pkg.dir("Jags", "Examples", "Line2")
cd(ProjDir)
println("Moving to directory: $(ProjDir)")

isfile("tmp") &&
  rm("tmp");

include(Pkg.dir(ProjDir, "jline2.jl"))
clean_dir(jagsmodel)

isfile("tmp") &&
  rm("tmp");

cd(old)
