ProjDir = joinpath(dirname(@__FILE__), "..", "Examples", "Rats")
tmpdir = joinpath(ProjDir, "tmp")
  
  isdir(tmpdir) &&
    rm(tmpdir, recursive=true);

  include(joinpath(ProjDir, "jrats.jl"))

  isdir(tmpdir) &&
    rm(tmpdir, recursive=true);

