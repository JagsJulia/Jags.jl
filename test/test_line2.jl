using Jags
using Base.Test

ProjDir = joinpath(dirname(@__FILE__), "..", "Examples", "Line2")
cd(ProjDir) do

  println("Moving to directory: $(ProjDir)")

  isdir("tmp") &&
    rm("tmp", recursive=true);

  include(Pkg.dir(ProjDir, "jline2.jl"))

  isdir("tmp") &&
    rm("tmp", recursive=true);

end
