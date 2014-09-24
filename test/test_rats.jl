using Jags
using Base.Test

old = pwd()
path = @windows ? "\\Examples\\Rats" : "/Examples/Rats"
ProjDir = Pkg.dir("Jags")*path
cd(ProjDir)
println("Moving to directory: $(ProjDir)")

isfile("$(jagsmodel.name)-data.R") &&
  rm("$(jagsmodel.name)-data.R");
isfile("$(jagsmodel.name)-run.log") &&
  rm("$(jagsmodel.name)-run.log");
isfile("$(jagsmodel.name).bugs") &&
  rm("$(jagsmodel.name).bugs");
for i in 1:8
  isfile("$(jagsmodel.name)-data.R") &&
    rm("$(jagsmodel.name)-cmd$(i)-chain0.txt");
  isfile("$(jagsmodel.name)-cmd$(i)-index0.txt") &&
    rm("$(jagsmodel.name)-cmd$(i)-index0.txt");
  isfile("$(jagsmodel.name)-cmd$(i)-table0.txt") &&
    rm("$(jagsmodel.name)-cmd$(i)-table0.txt");
  isfile("$(jagsmodel.name)-cmd$(i)-index.txt") &&
    rm("$(jagsmodel.name)-cmd$(i)-index.txt");
  isfile("$(jagsmodel.name)-cmd$(i).jags") &&
    rm("$(jagsmodel.name)-cmd$(i).jags");
  isfile("$(jagsmodel.name)-inits$(i).R") &&
    rm("$(jagsmodel.name)-inits$(i).R");
  for j in 0:8
    isfile("$(jagsmodel.name)-cmd$(i)-chain$(j).txt") &&
      rm("$(jagsmodel.name)-cmd$(i)-chain$(j).txt");
  end
end

include(ProjDir*@windows ? "\\" : "/"*"jrats.jl")

isfile("$(jagsmodel.name)-data.R") &&
  rm("$(jagsmodel.name)-data.R");
isfile("$(jagsmodel.name)-run.log") &&
  rm("$(jagsmodel.name)-run.log");
isfile("$(jagsmodel.name).bugs") &&
  rm("$(jagsmodel.name).bugs");
for i in 1:8
  isfile("$(jagsmodel.name)-data.R") &&
    rm("$(jagsmodel.name)-cmd$(i)-chain0.txt");
  isfile("$(jagsmodel.name)-cmd$(i)-index0.txt") &&
    rm("$(jagsmodel.name)-cmd$(i)-index0.txt");
  isfile("$(jagsmodel.name)-cmd$(i)-table0.txt") &&
    rm("$(jagsmodel.name)-cmd$(i)-table0.txt");
  isfile("$(jagsmodel.name)-cmd$(i)-index.txt") &&
    rm("$(jagsmodel.name)-cmd$(i)-index.txt");
  isfile("$(jagsmodel.name)-cmd$(i).jags") &&
    rm("$(jagsmodel.name)-cmd$(i).jags");
  isfile("$(jagsmodel.name)-inits$(i).R") &&
    rm("$(jagsmodel.name)-inits$(i).R");
  for j in 0:8
    isfile("$(jagsmodel.name)-cmd$(i)-chain$(j).txt") &&
      rm("$(jagsmodel.name)-cmd$(i)-chain$(j).txt");
  end
end

cd(old)
