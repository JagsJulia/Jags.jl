using Jags
using Base.Test

old = pwd()
ProjDir = Pkg.dir("Jags", "Examples", "Bones1")
cd(ProjDir)
println("Moving to directory: $(ProjDir)")

cd(ProjDir)
isdir("tmp") &&
  rm("tmp", recursive=true);

include(Pkg.dir(ProjDir, "jbones1.jl"))

cd(ProjDir)
isdir("tmp") &&
  rm("tmp", recursive=true);

ProjDir = Pkg.dir("Jags", "Examples", "Bones2")
cd(ProjDir)
println("Moving to directory: $(ProjDir)")

isfile("tmp") &&
  rm("tmp");

include(Pkg.dir(ProjDir, "jbones2.jl"))

cd(ProjDir)
isdir("tmp") &&
  rm("tmp", recursive=true);

cd(old)

