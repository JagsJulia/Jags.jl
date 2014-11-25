using Jags
using Base.Test

include(Pkg.dir("Jags", "test", "test_utils.jl"))

old = pwd()
ProjDir = Pkg.dir("Jags", "Examples", "Line1")
cd(ProjDir)
println("Moving to directory: $(ProjDir)")

cd(ProjDir)
isdir("tmp") &&
  rm("tmp", recursive=true);

include(Pkg.dir(ProjDir, "jline1.jl"))
clean_dir(jagsmodel)

cd(ProjDir)
isdir("tmp") &&
  rm("tmp", recursive=true);

ProjDir = Pkg.dir("Jags", "Examples", "Line2")
cd(ProjDir)
println("Moving to directory: $(ProjDir)")

cd(ProjDir)
isdir("tmp") &&
  rm("tmp", recursive=true);

include(Pkg.dir(ProjDir, "jline2.jl"))
clean_dir(jagsmodel)

cd(ProjDir)
isdir("tmp") &&
  rm("tmp", recursive=true);

cd(old)
