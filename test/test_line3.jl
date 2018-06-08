ProjDir = joinpath(dirname(@__FILE__), "..", "Examples", "Line3")
cd(ProjDir) do

  println("Moving to directory: $(ProjDir)")

  isdir("tmp") &&
    rm("tmp", recursive=true);

  include(joinpath(ProjDir, "jline3.jl"))

  isdir("tmp") &&
    rm("tmp", recursive=true);

end
