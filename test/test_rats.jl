using Jags
using Base.Test

old = pwd()
path = @windows ? "\\Examples\\Rats" : "/Examples/Rats"
ProjDir = Pkg.dir("Jags")*path
cd(ProjDir)
println("Moving to directory: $(ProjDir)")

isfile("rats-run.log") && rm("rats-run.log")
isfile("rats.bugs") && rm("rats.bugs")
isfile("rats-data.R") && rm("rats-data.R")

include(ProjDir*@windows ? "\\" : "/"*"jrats.jl")

isfile("rats-run.log") && rm("rats-run.log")
isfile("rats.bugs") && rm("rats.bugs")
isfile("rats-data.R") && rm("rats-data.R")

cd(old)
