using Mamba

old = pwd()
path = @windows ? "\\Examples\\Dyes\\Mamba" : "/Examples/Dyes/Mamba"
ProjDir = Pkg.dir("Jags")*path
cd(ProjDir)

## Data
dyes = (Symbol => Any)[
  :y =>
    [1545, 1440, 1440, 1520, 1580,
     1540, 1555, 1490, 1560, 1495,
     1595, 1550, 1605, 1510, 1560,
     1445, 1440, 1595, 1465, 1545,
     1595, 1630, 1515, 1635, 1625,
     1520, 1455, 1450, 1480, 1445],
  :batches => 6,
  :samples => 5
]

dyes[:batch] = vcat([fill(i, dyes[:samples]) for i in 1:dyes[:batches]]...)
dyes[:sample] = vcat(fill([1:dyes[:samples]], dyes[:batches])...)


## Model Specification

model = Model(

  y = Stochastic(1,
    @modelexpr(mu, batch, s2_within,
      IsoNormal(mu[batch], sqrt(s2_within))
    ),
    false
  ),

  mu = Stochastic(1,
    @modelexpr(theta, batches, s2_between,
      Normal(theta, sqrt(s2_between))
    ),
    false
  ),

  theta = Stochastic(
    :(Normal(0, 1000))
  ),

  s2_within = Stochastic(
    :(InverseGamma(0.001, 0.001))
  ),

  s2_between = Stochastic(
    :(InverseGamma(0.001, 0.001))
  )

)


## Initial Values
inits = [
  [:y => dyes[:y], :theta => 1500, :s2_within => 1, :s2_between => 1,
   :mu => fill(1500, dyes[:batches])],
  [:y => dyes[:y], :theta => 3000, :s2_within => 10, :s2_between => 10,
   :mu => fill(3000, dyes[:batches])],
  [:y => dyes[:y], :theta => 1500, :s2_within => 1, :s2_between => 1,
   :mu => fill(1500, dyes[:batches])],
  [:y => dyes[:y], :theta => 3000, :s2_within => 10, :s2_between => 10,
   :mu => fill(3000, dyes[:batches])]
]


## Sampling Scheme
scheme = [NUTS([:mu, :theta]),
          Slice([:s2_within, :s2_between], [1000.0, 1000.0], :univar)]
setsamplers!(model, scheme)


## MCMC Simulations
sim1 = mcmc(model, dyes, inits, 10000, burnin=2500, thin=2, chains=2)
describe(sim1)

## Plot results
myplot1 = plot(sim1, legend=true);
draw(myplot1, nrow=3, ncol=2, filename="dyes_1.svg")
run(`open -a "Google Chrome.app" "dyes_1.svg"`)

myplot2 = [plot(sim1, :autocor) plot(sim1, :mean, legend=true)];
draw(myplot2, nrow=2, ncol=3, filename="dyes_2.svg")
run(`open -a "Google Chrome.app" "dyes_2.svg"`)

println("Continue sampling")
sim2 = mcmc(sim1, 10000)
describe(sim2)

## Plot results
myplot3 = plot(sim2, legend=true);
draw(myplot3, nrow=3, ncol=2, filename="dyes_3.svg")
run(`open -a "Google Chrome.app" "dyes_3.svg"`)

myplot4 = [plot(sim2, :autocor) plot(sim2, :mean, legend=true)];
draw(myplot4, nrow=2, ncol=3, filename="dyes_4.svg")
run(`open -a "Google Chrome.app" "dyes_4.svg"`)

## MCMC Simulations, 4 chains
sim3 = mcmc(model, dyes, inits, 10000, burnin=2500, thin=2, chains=4)
describe(sim3)

## Plot results
myplot5 = plot(sim3, legend=true);
draw(myplot5, nrow=3, ncol=2, filename="dyes_5.svg")
run(`open -a "Google Chrome.app" "dyes_5.svg"`)

myplot6 = [plot(sim3, :autocor) plot(sim3, :mean, legend=true)];
draw(myplot6, nrow=2, ncol=3, filename="dyes_6.svg")
run(`open -a "Google Chrome.app" "dyes_6.svg"`)

println("Continue sampling")
sim4 = mcmc(sim3, 10000)
describe(sim4)

## Plot results
myplot7 = plot(sim4, legend=true);
draw(myplot7, nrow=3, ncol=2, filename="dyes_7.svg")
run(`open -a "Google Chrome.app" "dyes_7.svg"`)

myplot8 = [plot(sim4, :autocor) plot(sim4, :mean, legend=true)];
draw(myplot8, nrow=2, ncol=3, filename="dyes_8.svg")
run(`open -a "Google Chrome.app" "dyes_8.svg"`)

cd(old)