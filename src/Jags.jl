module Jags

using Compat, CSV, Pkg, Documenter, DelimitedFiles, Unicode, MCMCChains
using PrecompileTools

#### Includes ####

include("jagsmodel.jl")
include("jagscode.jl")

if !isdefined(Main, :Stanmodel)
  include("utilities.jl")
end

if VERSION >= v"1.9"
    include("precompile.jl")
    @compile_workload begin
        Jags.precompile_model()
    end
end


"""The directory which contains the executable `bin/stanc`. Inferred
from `Main.JAGS_HOME` or `ENV["JAGS_HOME"]` when available. Use
`set_jags_home!` to modify."""
JAGS_HOME=""

function __init__()
    global JAGS_HOME = if isdefined(Main, :JAGS_HOME)
        getproperty(Main, :JAGS_HOME)
    elseif haskey(ENV, "JAGS_HOME")
        ENV["JAGS_HOME"]
    else
        try # finding Jags in path
            jags_home = ""
            if Sys.iswindows()
                jags_home = splitdir(strip(read(`where jags`, String)))[1]
            elseif Sys.isunix()
                jags_home = splitdir(strip(read(`which jags`, String)))[1]
            end
            set_jags_home!(jags_home)
        catch
            warn("Did not find JAGS in the PATH.")
            warn("Environment variable JAGS_HOME not found. Use set_jags_home!.")
        end
        ""
    end
end

"""Set the path for `Jags`.

Example: `set_jags_home!(homedir() * "/src/src/cmdstan-2.11.0/")`
"""
set_jags_home!(path) = global JAGS_HOME=path

#### Exports ####

export
# From this file
  set_jags_home!,
# From Jags.jl
  JAGS_HOME,

# From jagsmodel.jl
  Jagsmodel,

# From jagscode.jl
  jags

end # module
