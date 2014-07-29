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
    update_inits_file,
    update_data_file
  
  #### Deprecated ####
  
  include("deprecated.jl")

end # module
