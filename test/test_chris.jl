using Jags, StatsPlots, Random, Distributions

ProjDir = @__DIR__
Random.seed!(3431)

y = rand(Normal(0,1),50)

Model = "
model {
      for (i in 1:length(y)) {
            y[i] ~ dnorm(mu,sigma);
      }
      mu  ~ dnorm(0, 1/sqrt(10));
      sigma  ~ dt(0,1,1) T(0, );
  }
"

monitors = Dict(
  "mu" => true,
  "sigma" => true,
  )

jagsmodel = Jagsmodel(
  name="Gaussian",
  model=Model ,
  monitor=monitors,
  ncommands=2, 
  nchains=2,
  nsamples=2000,
  #deviance=true, dic=true, popt=true,
  pdir=ProjDir
  )

data = Dict{String, Any}(
  "y" => y,
)

inits = [
  Dict("mu" => 0.0,"sigma" => 1.0,
    ".RNG.name" => "base::Mersenne-Twister",
    ".RNG.seed" => 314159,
  )
]


sim = jags(jagsmodel, data, inits, ProjDir)
show(sim)
println()

#plot(sim)
