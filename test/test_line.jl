using Jags
using Base.Test

old = pwd()
ProjDir = Pkg.dir("Jags")*"/Examples/Line/"
cd(ProjDir)
println("Moving to directory: $(ProjDir)")

for i in 0:8
  isfile("CODAchain$(i).txt") && rm("CODAchain$(i).txt")
end
isfile("CODAindex.txt") && rm("CODAindex.txt")
isfile("CODAindex0.txt") && rm("CODAindex0.txt")
isfile("CODAtable0.txt") && rm("CODAtable0.txt")
isfile("line-data.R") && rm("line-data.R")
isfile("line-inits.R") && rm("line-inits.R")
isfile("line.bugs") && rm("line.bugs")
isfile("line.jags") && rm("line.jags")

include(ProjDir*"line.jl")

for i in 0:8
  isfile("CODAchain$(i).txt") && rm("CODAchain$(i).txt")
end
isfile("CODAindex.txt") && rm("CODAindex.txt")
isfile("CODAindex0.txt") && rm("CODAindex0.txt")
isfile("CODAtable0.txt") && rm("CODAtable0.txt")

cd(old)