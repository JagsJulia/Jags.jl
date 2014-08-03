function jags(model::Jagsmodel, ProjDir=pwd(); data=Nothing, updatejagsfile::Bool=true)
  
  old = pwd()
  
  idx = Dict()
  chains = Dict[]
  try
    cd(ProjDir)
    for i in 1:model.chains
      isfile("CODAchain$(i).txt") && rm("CODAchain$(i).txt")
    end
    isfile("CODAindex.txt") && rm("CODAindex.txt")
    
    updatejagsfile && update_jags_file(model)
    
    jfile = "$(model.jags_file)"
    cmd = @windows ? `cmd /c jags $(jfile)` : `jags $(jfile)`
    
    @time run(cmd)
    (idx, chains) = read_jagsfiles()

  catch e
    println(e)
    cd(old)
  end
  cd(old)
  (idx, chains)
end

#### use readdlm to read in all chains and create a DataFrame

function read_jagsfiles(;chains::Int64=4)
  index = readdlm("CODAindex.txt", header=false)
  idxdct = Dict()
  for row in 1:size(index)[1]
    if length(keys(idxdct)) == 0
      idxdct = [convert(Symbol, index[row, 1]) => [int(index[row, 2]), int(index[row, 3])]]
    else
      merge!(idxdct, [convert(Symbol, index[row, 1]) => [int(index[row, 2]), int(index[row, 3])]])
    end
  end

  ## Collect the results of a chain in an array ##
  
  chainarray = Dict[]
  
  ## Each chain dictionary can contain up to 4 types of results ##
  
  result_type_files = ["samples"]
  rtdict = Dict()
  res_type = result_type_files[1]
  
  ## tdict contains the arrays of values ##
  tdict = Dict()
  
  for i in 1:chains
    tdict = Dict()
    if isfile("CODAchain$(i).txt")
      println("Reading CODAchain$(i).txt")
      res = readdlm("CODAchain$(i).txt", header=false)
      for key in index[:, 1]
        s = convert(Symbol, key)
        indx1 = idxdct[s][1]
        indx2 = idxdct[s][2]
        if length(keys(tdict)) == 0
          tdict = [s => res[indx1:indx2, 2]]
        else
          tdict = merge(tdict, [s => res[indx1:indx2, 2]])
        end
      end
      ## End of processing result type file ##
      ## If any keys were found, merge it in the rtdict ##
      
      if length(keys(tdict)) > 0
        #println("Merging $(convert(Symbol, res_type)) with keys $(keys(tdict))")
        rtdict = merge(rtdict, [convert(Symbol, res_type) => tdict])
        tdict = Dict()
      end
    end
    
    ## If rtdict has keys, push it to the chain array ##
    
    if length(keys(rtdict)) > 0
      #println("Pushing the rtdict with keys $(keys(rtdict))")
      push!(chainarray, rtdict)
      rtdict = Dict()
    end
  end
  (idxdct, chainarray)
end