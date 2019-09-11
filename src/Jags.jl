module Jags

using Compat, Pkg, Documenter, DelimitedFiles, Unicode, MCMCChains, StatsPlots

#### Includes ####

include("jagsmodel.jl")
include("jagscode.jl")

if !isdefined(Main, :Stanmodel)
  include("utilities.jl")
end

"""The directory which contains the executable `bin/stanc`. Inferred
from `Main.JAGS_HOME` or `ENV["JAGS_HOME"]` when available. Use
`set_jags_home!` to modify."""
JAGS_HOME=""

function __init__()
    global JAGS_HOME = if isdefined(Main, :JAGS_HOME)
        eval(Main, :JAGS_HOME)
    elseif haskey(ENV, "JAGS_HOME")
        ENV["JAGS_HOME"]
    else
        println("Environment variable JAGS_HOME not found. Use set_jags_home!.")
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
