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
    fit,
    read_jagsfiles,
    
    # From fileutils.jl
    update_model_file,
    update_R_file
  
  #### Deprecated ####
  
  include("deprecated.jl")

end # module
