######### Jags batch program example  ###########

using Mamba, Jags

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

(idx, sim1) = jags(jagsmodel, ProjDir, updatejagsfile=true)

println()
idx |> display
println()

## Brooks, Gelman and Rubin Convergence Diagnostic
gelmandiag(sim1, mpsrf=true, transform=true) |> display

## Geweke Convergence Diagnostic
gewekediag(sim1) |> display

## Summary Statistics
describe(sim1)

## Highest Posterior Density Intervals
hpd(sim1) |> display

## Cross-Correlations
cor(sim1) |> display

## Lag-Autocorrelations
autocor(sim1) |> display

## Deviance Information Criterion
#dic(sim1) |> display

println()
if jagsmodel.dic
  (idx0, chain0) = Jags.read_pDfile()
  idx0 |> display
  println()
  chain0[1]["samples"] |> display
end
  
if jagsmodel.dic || jagsmodel.popt
  println()
  pDmeanAndpopt = Jags.read_table_file(jagsmodel, data["n"])
  pDmeanAndpopt |> display
end

## Plotting

## Default summary plot (trace and density plots)
p = plot(sim1[:, ["alpha", "beta",  "sigma"], :], legend=true)

## Write plot to file
draw(p, filename="jlinesummaryplot.svg")
#draw(p, filename="jlinesummaryplot", fmt=:pdf)

## Autocorrelation and running mean plots
p = [plot(sim1[:, ["alpha", "beta",  "sigma"], :], :autocor) plot(sim1[:, ["alpha", "beta",  "sigma"], :], :mean, legend=true)].'
draw(p, nrow=3, ncol=2, filename="jlineautocormeanplot.svg")

run(`open -a "Google Chrome.app" "jlinesummaryplot.svg"`)
run(`open -a "Google Chrome.app" "jlineautocormeanplot.svg"`)

## Default summary plot (deviance and sigma)
p = plot(sim1[:, ["deviance", "sigma"], :], legend=true)

## Write plot to file
draw(p, filename="jlinesummaryplot2.svg")
run(`open -a "Google Chrome.app" "jlinesummaryplot2.svg"`)

cd(old)