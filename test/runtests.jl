using Jags
using Base.Test

old = pwd()
ProjDir = Pkg.dir("Jags")*"/Examples/Line/"
cd(ProjDir)
println("Moving to directory: $(dir)")

for i in 1:8
  isfile("CODAchain$(i).txt") && rm("CODAchain$(i).txt")
end
isfile("CODAindex.txt") && rm("CODAindex.txt")

include(ProjDir*"line.jl")

for i in 1:8
  isfile("CODAchain$(i).txt") && rm("CODAchain$(i).txt")
end
isfile("CODAindex.txt") && rm("CODAindex.txt")

