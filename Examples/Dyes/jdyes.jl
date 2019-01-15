######### Jags batch program example  ###########

using Jags

ProjDir = dirname(@__FILE__)
cd(ProjDir) do

  dyes = "
  model {
     for (i in 1:BATCHES) {
        for (j in 1:SAMPLES) {
           y[i,j] ~ dnorm(mu[i], tau.within);
        }
        mu[i] ~ dnorm(theta, tau.between);
     }

     theta ~ dnorm(0.0, 1.0E-10);
     tau.within ~ dgamma(0.001, 0.001);
     s2.within <- 1/tau.within;
     tau.between ~ dgamma(0.001, 0.001);
     s2.between <- 1/tau.between;
     s2.total <- s2.within + s2.between;
     f.within <- s2.within/s2.total;     
     f.between <- s2.between/s2.total;     
  }
  "

  data = Dict{String, Any}()
  data["y"] = reshape([
    1545, 1540, 1595, 1445, 1595,
    1520, 1440, 1555, 1550, 1440,
    1630, 1455, 1440, 1490, 1605,
    1595, 1515, 1450, 1520, 1560, 
    1510, 1465, 1635, 1480, 1580, 
    1495, 1560, 1545, 1625, 1445
  ], 6, 5)
  data["BATCHES"] = 6
  data["SAMPLES"] = 5

  inits = [
    Dict{String, Any}(
      "theta" => 1500,
      "tau.within" => 1,
      "tau.between" => 1
  	)
  ]

  monitors = Dict{String, Any}(
    "theta" => true,
    "s2.within" => true,
    "s2.between" => true
  	)

  jagsmodel = Jagsmodel(name="dyes", model=dyes,
    #ncommands=3, nchains=3,
    monitor=monitors)

  println("\nJagsmodel that will be used:")
  jagsmodel |> display
  println("Input observed data dictionary:")
  data |> display
  println("\nInput initial values dictionary:")
  inits |> display
  println()

  @time sim = jags(jagsmodel, data, inits, ProjDir)
  describe(sim)
  println()

  ## Plotting
  p = plot(sim, [:trace, :mean, :density, :autocor], legend=true);
  draw(p, ncol=4, filename="$(jagsmodel.name)-summaryplot", fmt=:svg)
  # draw(p, ncol=4, filename="$(jagsmodel.name)-summaryplot", fmt=:pdf)

  # Below will only work on OSX, please adjust for your environment.
  # JULIA_SVG_BROWSER is set from environment variable JULIA_SVG_BROWSER
  @static Sys.isapple() ? if isdefined(Main, :JULIA_SVG_BROWSER) && length(JULIA_SVG_BROWSER) > 0
          for i in 1:4
            isfile("$(jagsmodel.name)-summaryplot-$(i).svg") &&
              run(`open -a $(JULIA_SVG_BROWSER) "$(jagsmodel.name)-summaryplot-$(i).svg"`)
          end
        end : println()

end #cd