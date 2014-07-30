######### Jags batch program example  ###########

using Jags

old = pwd()
ProjDir = homedir()*"/.julia/v0.3/Jags/Examples/Line"

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

data = Dict{Symbol, Any}()
data[:x] = [1, 2, 3, 4, 5]
data[:y] = [1, 3, 3, 3, 5]
data[:n] = 5

inits = (Symbol => Any)[
  :alpha => 0,
  :beta => 0,
  :tau => 1
]

jagsmodel = Jagsmodel(name="line", model=line, data=data, init=inits)
(idx, chains) = jags(jagsmodel, ProjDir)

println()
data |> display
println()
inits |> display
println()
idx |> display
println()
jagsmodel |> display
println()
chains[1][:samples] |> display

cd(old)