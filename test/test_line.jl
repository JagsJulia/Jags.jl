using Jags
using Base.Test

old = pwd()
path = @windows ? "\\Examples\\Line" : "/Examples/Line"
ProjDir = Pkg.dir("Jags")*path
cd(ProjDir)
println("Moving to directory: $(ProjDir)")

isfile("line-run.log") && rm("line-run.log")
isfile("line.bugs") && rm("line.bugs")
isfile("line-data.R") && rm("line-data.R")

include(ProjDir*@windows ? "\\" : "/"*"jline.jl")

isfile("line-run.log") && rm("line-run.log")
isfile("line.bugs") && rm("line.bugs")
isfile("line-data.R") && rm("line-data.R")

cd(old)
