using Jags
using Base.Test

old = pwd()
path = @windows ? "\\Examples\\Dyes" : "/Examples/Dyes"
ProjDir = Pkg.dir("Jags")*path
cd(ProjDir)
println("Moving to directory: $(ProjDir)")

isfile("dyes-run.log") && rm("dyes-run.log")
isfile("dyes.bugs") && rm("dyes.bugs")
isfile("dyes-data.R") && rm("dyes-data.R")

include(ProjDir*@windows ? "\\" : "/"*"jdyes.jl")

isfile("dyes-run.log") && rm("dyes-run.log")
isfile("dyes.bugs") && rm("dyes.bugs")
isfile("dyes-data.R") && rm("dyes-data.R")

cd(old)
