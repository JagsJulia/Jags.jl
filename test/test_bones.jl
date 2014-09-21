using Jags
using Base.Test

old = pwd()
path = @windows ? "\\Examples\\Bones" : "/Examples/Bones"
ProjDir = Pkg.dir("Jags")*path
cd(ProjDir)
println("Moving to directory: $(ProjDir)")

for i in 0:8
  isfile("CODAchain$(i).txt") && rm("CODAchain$(i).txt")
  isfile("bones-inits$(i).R") && rm("bones-inits$(i).R")
end
isfile("CODAindex.txt") && rm("CODAindex.txt")
isfile("CODAindex0.txt") && rm("CODAindex0.txt")
isfile("CODAtable0.txt") && rm("CODAtable0.txt")
isfile("bones-data.R") && rm("bones-data.R")
isfile("bones.bugs") && rm("bones.bugs")
isfile("bones.jags") && rm("bones.jags")

include(ProjDir*@windows ? "\\" : "/"*"jbones.jl")

for i in 0:8
  isfile("CODAchain$(i).txt") && rm("CODAchain$(i).txt")
  isfile("bones-inits$(i).R") && rm("bones-inits$(i).R")
end
isfile("CODAindex.txt") && rm("CODAindex.txt")
isfile("CODAindex0.txt") && rm("CODAindex0.txt")
isfile("CODAtable0.txt") && rm("CODAtable0.txt")
isfile("bones-data.R") && rm("bones-data.R")
isfile("bones.bugs") && rm("bones.bugs")
isfile("bones.jags") && rm("bones.jags")

cd(old)
