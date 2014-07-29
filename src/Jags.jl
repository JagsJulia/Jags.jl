using DataFrames

module Jags

  using DataFrames

  #### Includes ####
  
  include("jagscode.jl")
  include("fileutils.jl")

  #### Exports ####
  
  export
    read_jagsfiles,
    update_model_file,
    update_R_file
  
  #### Deprecated ####
  
  include("deprecated.jl")

end # module
