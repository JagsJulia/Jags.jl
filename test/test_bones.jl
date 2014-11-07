using Jags
using Base.Test

include(Pkg.dir("Jags", "test", "test_utils.jl"))

old = pwd()
ProjDir = Pkg.dir("Jags", "Examples", "Bones1")
cd(ProjDir)
println("Moving to directory: $(ProjDir)")

isfile("tmp") &&
  rm("tmp");

include(Pkg.dir(ProjDir, "jbones1.jl"))
clean_dir(jagsmodel)

isfile("tmp") &&
  rm("tmp");

ProjDir = Pkg.dir("Jags", "Examples", "Bones2")
cd(ProjDir)
println("Moving to directory: $(ProjDir)")

isfile("tmp") &&
  rm("tmp");

include(Pkg.dir(ProjDir, "jbones2.jl"))
clean_dir(jagsmodel)

isfile("tmp") &&
  rm("tmp");

cd(old)

