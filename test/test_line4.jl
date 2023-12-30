ProjDir = joinpath(dirname(@__FILE__), "..", "Examples", "Line4")
tmpdir = joinpath(ProjDir, "tmp")

  isdir(tmpdir) &&
    rm(tmpdir, recursive=true);

  include(joinpath(ProjDir, "jline4.jl"))

  isdir(tmpdir) &&
    rm(tmpdir, recursive=true);

