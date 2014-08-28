importall Base

module Jags
  
  using DataArrays

  #### Includes ####
  
  include("jagsmodel.jl")
  include("jagscode.jl")
  if !isdefined(:Stan)
    include("utilities.jl")
  end
  
  function getenv(var::String)
    val = ccall( (:getenv, "libc"),
      Ptr{Uint8}, (Ptr{Uint8},), bytestring(var))
    if val == C_NULL
     error("getenv: undefined variable: ", var)
    end
    bytestring(val)
  end

  JAGSDIR = ""
  try
    JAGSDIR = getenv("JAGS_HOME");
  catch e
    println("JAGS_HOME not found, assuming Jags is on PATH.")
  end

  #### Exports ####
  
  export
  
  # From jagsmodel.jl
    Jagsmodel,
    
    # From jagscode.jl
    jags
  
  #### Deprecated ####
  
  include("deprecated.jl")

end # module
