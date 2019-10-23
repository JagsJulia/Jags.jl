######### Jags line program example  ###########

using StatsPlots, Jags, Statistics, Random

Random.seed!(0)

ProjDir = @__DIR__
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

monitors = Dict(
  "alpha" => true,
  "beta" => true,
  "tau" => true,
  "sigma" => true
  )

jagsmodel = Jagsmodel(
  name="line1",
  model=line,
  ncommands=1,
  nchains=2,
  monitor=monitors,
  deviance=true, dic=true, popt=true,
  pdir=ProjDir
  );

println("\nJagsmodel that will be used:")
jagsmodel |> display

data = Dict(
  "x" => [1, 2, 3, 4, 5],
  "y" => [1, 3, 3, 3, 5],
  "n" => 5
)

inits = [
  Dict("alpha" => 0,"beta" => 0,"tau" => 1),
  #Dict("alpha" => 1,"beta" => 2,"tau" => 1),
  #Dict("alpha" => 3,"beta" => 3,"tau" => 2),
  #Dict("alpha" => 5,"beta" => 2,"tau" => 5)
]

println("Input observed data dictionary:")
data |> display
println("\nInput initial values dictionary:")
inits |> display
println()

sim = jags(jagsmodel, data, inits, ProjDir)
show(sim)
println()

## Plotting
p = plot(sim)
