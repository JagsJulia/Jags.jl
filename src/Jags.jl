using DataFrames

module Jags

  using DataFrames

  #### Includes ####
  
  include("jagscode.jl")

  #### Exports ####
  
  export
    read_jagsfiles
  
  #### Deprecated ####
  
  include("deprecated.jl")

end # module
