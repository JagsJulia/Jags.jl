ProjDir = joinpath(dirname(@__FILE__), "..", "Examples", "Dyes")
tmpdir = joinpath(ProjDir, "tmp")
  isdir(tmpdir) &&
    rm(tmpdir, recursive=true);

  include(joinpath(ProjDir, "jdyes.jl"))

  isdir(tmpdir) &&
    rm(tmpdir, recursive=true);
