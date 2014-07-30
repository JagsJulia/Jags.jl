module Jags

  #### Includes ####
  
  include("jagsmodel.jl")
  include("jagscode.jl")
  include("fileutils.jl")
  
  #### Exports ####
  
  export
  
  # From modeltype.jl
    Jagsmodel,
    
    # From jagscode.jl
    jags
  
  #### Deprecated ####
  
  include("deprecated.jl")

end # module
