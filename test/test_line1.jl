ProjDir = joinpath(dirname(@__FILE__), "..", "Examples", "Line1")
tmpdir = joinpath(ProjDir, "tmp")

  isdir(tmpdir) &&
    rm(tmpdir, recursive=true);

  include(joinpath(ProjDir, "jline1.jl"))

  isdir(tmpdir) &&
    rm(tmpdir, recursive=true);

