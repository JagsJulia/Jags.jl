ProjDir = joinpath(dirname(@__FILE__), "..", "Examples", "Bones2")

isfile(tmpdir) &&
    rm(tmpdir);

  include(joinpath(ProjDir, "jbones2.jl"))

  isdir(tmpdir) &&
    rm(tmpdir, recursive=true);

