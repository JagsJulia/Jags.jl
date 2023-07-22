ProjDir = joinpath(dirname(@__FILE__), "..", "Examples", "Bones1")
tmpdir = joinpath(ProjDir, "tmp")
isdir(tmpdir) &&
  rm(tmpdir, recursive=true);

include(joinpath(ProjDir, "jbones1.jl"))

isdir(tmpdir) &&
  rm(tmpdir, recursive=true);
