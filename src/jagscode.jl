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

  da = Dict[]
  for i in 1:chains
    dict = Dict()
    if isfile("CODAchain$(i).txt")
      println("Reading CODAchain$(i).txt")
      res = readdlm("CODAchain$(i).txt", header=false)
      for key in index[:, 1]
        s = convert(Symbol, key)
        indx1 = idxdct[s][1]
        indx2 = idxdct[s][2]
        if length(keys(dict)) == 0
          dict = [s => res[indx1:indx2, 2]]
        else
          dict = merge(dict, [s => res[indx1:indx2, 2]])
        end
      end
      push!(da, dict)
    end
  end
  (idxdct, da)
end