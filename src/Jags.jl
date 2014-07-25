using DataFrames

module Jags

  using DataFrames

  #### Includes ####
  
  include("jagscode.jl")
  include("fileutils.jl")

  #### Exports ####
  
  export
    read_jagsfiles
  
  #### Deprecated ####
  
  include("deprecated.jl")

end # module
