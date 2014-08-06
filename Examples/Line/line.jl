######### Jags batch program example  ###########

using Jags

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

data = Dict{Symbol, Any}()
data[:x] = [1, 2, 3, 4, 5]
data[:y] = [1, 3, 3, 3, 5]
data[:n] = 5

inits = (Symbol => Any)[
  :alpha => 0,
  :beta => 0,
  :tau => 1,
  
]

monitors = (Symbol => Bool)[
  :alpha => true,
  :beta => true,
  :tau => true,
  :sigma => true,
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

(idx, chains) = jags(jagsmodel, ProjDir, updatejagsfile=true)

println()
idx |> display
println()

if (length(chains) > 0)
  chains[1][:samples] |> display
  println()
end

if jagsmodel.dic
  (idx0, chain0) = Jags.read_pDfile()
  idx0 |> display
  println()
  chain0[1][:samples] |> display
end
  
if jagsmodel.dic || jagsmodel.popt
  println()
  pDmeanAndpopt = Jags.read_table_file(jagsmodel, data[:n])
  pDmeanAndpopt |> display
end

cd(old)