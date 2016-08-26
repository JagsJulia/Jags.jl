using Jags
using Base.Test

ProjDir = joinpath(dirname(@__FILE__), "..", "Examples", "Bones2")
cd(ProjDir) do
  
  println("Moving to directory: $(ProjDir)")

  isfile("tmp") &&
    rm("tmp");

  include(Pkg.dir(ProjDir, "jbones2.jl"))

  isdir("tmp") &&
    rm("tmp", recursive=true);

end

