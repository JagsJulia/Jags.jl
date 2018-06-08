ProjDir = joinpath(dirname(@__FILE__), "..", "Examples", "Dyes")
cd(ProjDir) do

  println("Moving to directory: $(ProjDir)")

  isdir("tmp") &&
    rm("tmp", recursive=true);

  include(joinpath(ProjDir, "jdyes.jl"))

  isdir("tmp") &&
    rm("tmp", recursive=true);

end
