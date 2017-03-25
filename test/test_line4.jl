using Jags
using Base.Test

ProjDir = joinpath(dirname(@__FILE__), "..", "Examples", "Line4")
cd(ProjDir) do

  println("Moving to directory: $(ProjDir)")

  isdir("tmp") &&
    rm("tmp", recursive=true);

  include(Pkg.dir(ProjDir, "jline4.jl"))

  isdir("tmp") &&
    rm("tmp", recursive=true);

end
