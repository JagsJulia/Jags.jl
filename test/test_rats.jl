using Jags
using Base.Test

ProjDir = joinpath(dirname(@__FILE__), "..", "Examples", "Rats")
cd(ProjDir) do
  
  println("Moving to directory: $(ProjDir)")

  isdir("tmp") &&
    rm("tmp", recursive=true);

  include(Pkg.dir(ProjDir, "jrats.jl"))

  isdir("tmp") &&
    rm("tmp", recursive=true);

end
