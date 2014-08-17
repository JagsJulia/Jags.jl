using Jags
using Base.Test

old = pwd()
path = @windows ? "\\Examples\\Line\\Jags" : "/Examples/Line/Jags"
ProjDir = Pkg.dir("Jags")*path
cd(ProjDir)
println("Moving to directory: $(ProjDir)")

for i in 0:8
  isfile("CODAchain$(i).txt") && rm("CODAchain$(i).txt")
  isfile("line-inits$(i).R") && rm("line-inits$(i).R")
end
isfile("CODAindex.txt") && rm("CODAindex.txt")
isfile("CODAindex0.txt") && rm("CODAindex0.txt")
isfile("CODAtable0.txt") && rm("CODAtable0.txt")
isfile("line-data.R") && rm("line-data.R")
isfile("line.bugs") && rm("line.bugs")
isfile("line.jags") && rm("line.jags")
isfile("jlineautocormeanplot.svg") && rm("jlineautocormeanplot.svg")
isfile("jlinesummaryplot.svg") && rm("jlinesummaryplot.svg")
isfile("jlinesummaryplot2.svg") && rm("jlinesummaryplot2.svg")

include(ProjDir*@windows ? "\\" : "/"*"jline.jl")

for i in 0:8
  isfile("CODAchain$(i).txt") && rm("CODAchain$(i).txt")
  isfile("line-inits$(i).R") && rm("line-inits$(i).R")
end
isfile("CODAindex.txt") && rm("CODAindex.txt")
isfile("CODAindex0.txt") && rm("CODAindex0.txt")
isfile("CODAtable0.txt") && rm("CODAtable0.txt")
isfile("line-data.R") && rm("line-data.R")
isfile("line.bugs") && rm("line.bugs")
isfile("line.jags") && rm("line.jags")
#isfile("jlineautocormeanplot.svg") && rm("jlineautocormeanplot.svg")
#isfile("jlinesummaryplot.svg") && rm("jlinesummaryplot.svg")
#isfile("jlinesummaryplot2.svg") && rm("jlinesummaryplot2.svg")

cd(old)
