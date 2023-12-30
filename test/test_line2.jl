ProjDir = joinpath(dirname(@__FILE__), "..", "Examples", "Line2")
tmpdir = joinpath(ProjDir, "tmp")
  
  isdir(tmpdir) &&
    rm(tmpdir, recursive=true);

  include(joinpath(ProjDir, "jline2.jl"))

  isdir(tmpdir) &&
    rm(tmpdir, recursive=true);

