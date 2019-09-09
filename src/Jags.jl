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
`set_JAGS_HOME!` to modify."""
JAGS_HOME=""

function __init__()
    global JAGS_HOME = if isdefined(Main, :JAGS_HOME)
        eval(Main, :JAGS_HOME)
    elseif haskey(ENV, "JAGS_HOME")
        ENV["JAGS_HOME"]
    else
        println("Environment variable JAGS_HOME not found. Use set_JAGS_HOME!.")
        ""
    end
end

"""Set the path for `Jags`.

Example: `set_JAGS_HOME!(homedir() * "/src/src/cmdstan-2.11.0/")`
"""
set_JAGS_HOME!(path) = global JAGS_HOME=path

if !isdefined(Main, :JULIA_SVG_BROWSER)
  global JULIA_SVG_BROWSER = ""
  try
    global JULIA_SVG_BROWSER = ENV["JULIA_SVG_BROWSER"]
  catch e
    println("Environment variable JULIA_SVG_BROWSER not found.")
    global JULIA_SVG_BROWSER = ""
  end
end

#### Exports ####

export
# From this file
  set_JAGS_HOME!,
# From Jags.jl
  JAGS_HOME,
  JULIA_SVG_BROWSER,

# From jagsmodel.jl
  Jagsmodel,

# From jagscode.jl
  jags

end # module
