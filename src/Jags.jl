module Jags
  
  using DataArrays

  #### Includes ####
  
  include("jagsmodel.jl")
  include("jagscode.jl")
  include("utilities.jl")
  
  #### Exports ####
  
  export
  
  # From jagsmodel.jl
    Jagsmodel,
    
    # From jagscode.jl
    jags
  
  #### Deprecated ####
  
  include("deprecated.jl")

end # module
