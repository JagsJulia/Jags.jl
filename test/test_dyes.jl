using Jags
using Base.Test

old = pwd()
ProjDir = Pkg.dir("Jags")*"/Examples/Dyes/Jags/"
cd(ProjDir)
println("Moving to directory: $(ProjDir)")

for i in 0:8
  isfile("CODAchain$(i).txt") && rm("CODAchain$(i).txt")
  isfile("dyes-inits$(i).R") && rm("dyes-inits$(i).R")
end
isfile("CODAindex.txt") && rm("CODAindex.txt")
isfile("CODAindex0.txt") && rm("CODAindex0.txt")
isfile("CODAtable0.txt") && rm("CODAtable0.txt")
isfile("dyes-data.R") && rm("dyes-data.R")
isfile("dyes.bugs") && rm("dyes.bugs")
isfile("dyes.jags") && rm("dyes.jags")

include(ProjDir*"jdyes.jl")

for i in 0:8
  isfile("CODAchain$(i).txt") && rm("CODAchain$(i).txt")
  isfile("dyes-inits$(i).R") && rm("dyes-inits$(i).R")
end
isfile("CODAindex.txt") && rm("CODAindex.txt")
isfile("CODAindex0.txt") && rm("CODAindex0.txt")
isfile("CODAtable0.txt") && rm("CODAtable0.txt")
isfile("dyes-data.R") && rm("dyes-data.R")
isfile("dyes.bugs") && rm("dyes.bugs")
isfile("dyes.jags") && rm("dyes.jags")

cd(old)
