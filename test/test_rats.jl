using Jags
using Base.Test

old = pwd()
ProjDir = Pkg.dir("Jags")*"/Examples/Rats/Jags/"
cd(ProjDir)
println("Moving to directory: $(ProjDir)")

for i in 0:8
  isfile("CODAchain$(i).txt") && rm("CODAchain$(i).txt")
  isfile("rats-inits$(i).R") && rm("rats-inits$(i).R")
end
isfile("CODAindex.txt") && rm("CODAindex.txt")
isfile("CODAindex0.txt") && rm("CODAindex0.txt")
isfile("CODAtable0.txt") && rm("CODAtable0.txt")
isfile("rats-data.R") && rm("rats-data.R")
isfile("rats.bugs") && rm("rats.bugs")
isfile("rats.jags") && rm("rats.jags")

include(ProjDir*"jrats.jl")

for i in 0:8
  isfile("CODAchain$(i).txt") && rm("CODAchain$(i).txt")
  isfile("rats-inits$(i).R") && rm("rats-inits$(i).R")
end
isfile("CODAindex.txt") && rm("CODAindex.txt")
isfile("CODAindex0.txt") && rm("CODAindex0.txt")
isfile("CODAtable0.txt") && rm("CODAtable0.txt")
isfile("rats-data.R") && rm("rats-data.R")
isfile("rats.bugs") && rm("rats.bugs")
isfile("rats.jags") && rm("rats.jags")

cd(old)
