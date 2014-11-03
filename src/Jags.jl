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

  JAGSDIR = ""
  try
    JAGSDIR = getenv("JAGS_HOME");
  catch e
    println("Environment variable JAGS_HOME not found, assuming Jags is on PATH.")
  end
  JULIASVGBROWSER = ""
  try
    JULIASVGBROWSER = getenv("JULIA_SVG_BROWSER");
  catch e
    println("Environment variable JULIA_SVG_BROWSER not found.")
    println("Produced .svg files in examples will not be automatically displaye.")
  end

  #### Exports ####
  
  export
  
  # From Jags.jl
    JULIASVGBROWSER,
    JAGSDIR,
    
  # From jagsmodel.jl
    Jagsmodel,
    
  # From jagscode.jl
    jags
  
  #### Deprecated ####
  
  include("deprecated.jl")

end # module
