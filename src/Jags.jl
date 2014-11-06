module Jags

  using DataArrays, Mamba
  
  #### Includes ####
  
  include("jagsmodel.jl")
  include("jagscode.jl")
  
  if !isdefined(Main, :Stanmodel)
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

  JAGS_HOME = ""
  try
    JAGS_HOME = getenv("JAGS_HOME");
  catch e
    println("Environment variable JAGS_HOME not found, assuming Jags is on PATH.")
  end
  JULIA_SVG_BROWSER = ""
  try
    JULIA_SVG_BROWSER = getenv("JULIA_SVG_BROWSER");
  catch e
    println("Environment variable JULIA_SVG_BROWSER not found.")
    println("Produced .svg files in examples will not be automatically displaye.")
  end

  #### Exports ####
  
  export
  
  # From Jags.jl
    JULIA_SVG_BROWSER,
    JAGS_HOME,
    
  # From jagsmodel.jl
    Jagsmodel,
    
  # From jagscode.jl
    jags
  
  #### Deprecated ####
  
  include("deprecated.jl")

end # module
