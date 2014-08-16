using Jags
using Base.Test

old = pwd()
path = @windows ? "\\Examples\\Line" : "/Examples/Line"
ProjDir = Pkg.dir("Jags")*path
cd(ProjDir)

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

inits = [
  (ASCIIString => Any)["alpha" => 0,"beta" => 0,"tau" => 1],
  (ASCIIString => Any)["alpha" => 1,"beta" => 2,"tau" => 1],
  (ASCIIString => Any)["alpha" => 3,"beta" => 3,"tau" => 2],
  (ASCIIString => Any)["alpha" => 5,"beta" => 2,"tau" => 5],
]

monitors = (ASCIIString => Bool)[
  "alpha" => true,
  "beta" => true,
  "tau" => true,
  "sigma" => true,
]

jagsmodel = Jagsmodel(name="line", model=line, data=data,
  init=inits, monitor=monitors, deviance=true, dic=true, popt=true);

println("\nJagsmodel that will be used:")
jagsmodel |> display
println("Input observed data dictionary:")
data |> display
println("\nInput initial values dictionary:")
inits |> display
println()

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

cd(old)