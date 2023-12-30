ProjDir = joinpath(dirname(@__FILE__), "..", "Examples", "Line3")
tmpdir = joinpath(ProjDir, "tmp")

  isdir(tmpdir) &&
    rm(tmpdir, recursive=true);

  include(joinpath(ProjDir, "jline3.jl"))

  isdir(tmpdir) &&
    rm(tmpdir, recursive=true);
