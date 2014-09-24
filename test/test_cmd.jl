using Jags
using Base.Test

old = pwd()
path = @windows ? "\\Examples\\Line" : "/Examples/Line"
ProjDir = Pkg.dir("Jags")*path
cd(ProjDir)

inits1 = [
  ["alpha" => 0,"beta" => 0,"tau" => 1],
  ["alpha" => 1,"beta" => 2,"tau" => 1],
  ["alpha" => 3,"beta" => 3,"tau" => 2],
  #["alpha" => 3,"beta" => 3.0,"tau" => 2],
  ["alpha" => 5,"beta" => 2,"tau" => 5]
]

function test(init::Array{Dict{ASCIIString, Int64},1})
  res = map((x)->convert(Dict{ASCIIString, Any}, x), init)
end

function test(init::Array{Dict{ASCIIString, Float64},1})
  res = map((x)->convert(Dict{ASCIIString, Any}, x), init)
end

function test(init::Array{Dict{ASCIIString, Number},1})
  res = map((x)->convert(Dict{ASCIIString, Any}, x), init)
end

function test(init::Array{Dict{ASCIIString, Any},1})
  res = map((x)->convert(Dict{ASCIIString, Any}, x), init)
end

line = "
model {
  for (i in 1:n) {
        mu[i] <- alpha + beta*(x[i] - x.bar);
        y[i]   ~ dnorm(mu[i],tau);
  }
  x.bar   <- mean(x[]);
  alpha    ~ dnorm(0.0,1.0E-4);
  beta     ~ dnorm(0.0,1.0E-4);
  tau      ~ dgamma(1.0E-3,1.0E-3);
  sigma   <- 1.0/sqrt(tau);
}
"

data = Dict{ASCIIString, Any}()
data["x"] = [1, 2, 3, 4, 5]
data["y"] = [1, 3, 3, 3, 5]
data["n"] = 5

inits = test(inits1)

monitors = (ASCIIString => Bool)[
  "alpha" => true,
  "beta" => true,
  "tau" => true,
  "sigma" => true,
]

jagsmodel = Jagsmodel(name="line", model=line,
  data=data, init=inits, monitor=monitors,
  ncommands=3, nchains=3, adapt=1000, update=10000, thin=1,
  deviance=true, dic=true, popt=true,
  updatedatafile=true, updateinitfiles=true,
  pdir=ProjDir);

println("\nJagsmodel that will be used:")
jagsmodel |> display
println("Input observed data dictionary:")
data |> display
println("\nInput initial values dictionary:")
inits |> display

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
