using Jags, StatsPlots, Random, Distributions

cd(@__DIR__)
ProjDir = pwd()
Random.seed!(3431)

y = rand(Normal(0,1),50)

Model = "
model {
      for (i in 1:length(y)) {
            y[i] ~ dnorm(mu[i],sigma);
      }
      for(i in 1:length(y)){
            mu[i]  ~ dnorm(0, 1/sqrt(10));
        }

      sigma  ~ dt(0,1,1) T(0, );
  }
"

monitors = Dict(
  "mu" => true,
  "sigma" => true,
  )

inits = [
  Dict("mu"=>.0,"sigma"=>1.0)
]


jagsmodel = Jagsmodel(
  name="Gaussian",
  model=Model ,
  monitor=monitors,
  ncommands=1, nchains=4
  ,
  #deviance=true, dic=true, popt=true,
  pdir=ProjDir
  )

println("\nJagsmodel that will be used:")
jagsmodel |> display

data = Dict{String, Any}(
  "y" => y,
)

inits = [
  Dict("mu" => 0.0,"sigma" => 1.0,
  ".RNG.name" => "base::Mersenne-Twister")
]

println("Input observed data dictionary:")
data |> display
println("\nInput initial values dictionary:")
inits |> display
println()
#######################################################################################
#                                 Estimate Parameters
#######################################################################################
sim = jags(jagsmodel, data, inits, ProjDir)
sim = sim[5001:end,:,:]
