######### Jags program example  ###########

using Jags

old = pwd()
path = @windows ? "\\Examples\\Line" : "/Examples/Line"
ProjDir = Pkg.dir("Jags")*path
cd(ProjDir)

linemodel = "
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

linedata = Dict{ASCIIString, Any}()
linedata["x"] = [1, 2, 3, 4, 5]
linedata["y"] = [1, 3, 3, 3, 5]
linedata["n"] = 5

lineinits = [
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

#jagsmodel = Jagsmodel(name="line", model=linemodel, thin=2,
#  deviance=true, dic=true, popt=true);
jagsmodel = Jagsmodel(name="line", model=linemodel, thin=2);

println("\nJagsmodel that will be used:")
jagsmodel |> display
println("Input observed data dictionary:")
linedata |> display
println("\nInput initial values dictionary:")
lineinits |> display
println()

(index, chains) = jags(jagsmodel, ProjDir, data=linedata, init=lineinits, monitor=monitors)

println()
chains[1]["samples"] |> display

cd(old)