######### Jags program example  ###########

using Mamba, Jags

ProjDir = joinpath(dirname(@__FILE__))
cd(ProjDir) do

  bones = "
  model {
     for (i in 1:nChild) {
        theta[i] ~ dnorm(0.0, 0.001);

        for (j in 1:nInd) { 
           # Cumulative probability of > grade k given theta
           for (k in 1:(ncat[j]-1)) {
              logit(Q[i,j,k]) <- delta[j]*(theta[i] - gamma[j,k]);
           }
           Q[i,j,ncat[j]] <- 0;
        }

        for (j in 1:nInd) {
           # Probability of observing grade k given theta
           p[i,j,1] <- 1 - Q[i,j,1];
           for (k in 2:ncat[j]) {
              p[i,j,k] <- Q[i,j,(k-1)] - Q[i,j,k];
           }
           grade[i,j] ~ dcat(p[i,j,1:ncat[j]]);
        }
     }
  }   
  "

  data = Dict{String, Any}()
  data["nChild"] = 13		
  data["nInd"] = 34
  data["gamma"] = reshape([
    0.7425, 10.267, 10.5215, 9.3877, 0.2593, -0.5998, 
    10.5891, 6.6701, 8.8921, 12.4275, 12.4788, 13.7778, 5.8374, 6.9485, 
    13.7184, 14.3476, 4.8066, 9.1037, 10.7483, 0.3887, 3.2573, 11.6273, 
    15.8842, 14.8926, 15.5487, 15.4091, 3.9216, 15.475, 0.4927, 1.3059, 
    1.5012, 0.8021, 5.0022, 4.0168, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, 
    NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, 1.0153, 7.0421, 14.4242, 
    17.4685, 16.7409, 16.872, 17.0061, 5.2099, 16.9406, 1.3556, 1.8793, 
    1.8902, 2.3873, 6.3704, 5.1537, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, 
    NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, 
    NaN, NaN, NaN, 17.4944, 2.3016, 2.497, 2.3689, 3.9525, 8.2832, 7.1053, 
    NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, 
    NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, 3.2535, 3.2306, 
    2.9495, 5.3198, 10.4988, 10.3038], 34, 4)
  data["delta"] = [
    2.9541, 0.6603, 0.7965, 1.0495, 5.7874, 3.8376, 0.6324, 0.8272, 
    0.6968, 0.8747, 0.8136, 0.8246, 0.6711, 0.978, 1.1528, 1.6923, 
    1.0331, 0.5381, 1.0688, 8.1123, 0.9974, 1.2656, 1.1802, 1.368, 
    1.5435, 1.5006, 1.6766, 1.4297, 3.385, 3.3085, 3.4007, 2.0906, 
    1.0954, 1.5329]
  data["ncat"] = [
    2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 
    3, 3, 3, 3, 3, 3, 3, 4, 5, 5, 5, 5, 5, 5]
  data["grade"] = reshape([
    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1, 1, 1, 1, 
    1, 1, 1, 1, 1, 1, 1, 2, 2, 1, 1, 1, 1, 1, 1, 1, 2, 1, 2, NaN, 
    2, 2, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 1, 2, 2, 2, 2, 2, 
    2, 2, 2, 2, 2, 2, 2, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1, 
    1, 1, 1, 1, 1, 1, 2, 2, 2, NaN, 2, 2, 1, 1, 1, 1, 1, 2, 1, 2, 
    2, 2, 2, 2, 2, 1, 1, 1, 1, 2, 1, 1, 1, 2, 2, 2, 2, 2, 1, 1, 1, 
    1, 1, 1, NaN, NaN, 1, 1, 1, 2, 2, 1, 1, 1, 1, 1, 1, NaN, NaN, 1, 
    1, NaN, 2, NaN, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, NaN, 2, 2, 1, 1, 1, 
    NaN, 1, 1, 1, 2, 2, 2, 2, 2, 2, 1, 1, 1, 1, 1, 2, 1, 2, 1, 2, 
    2, 2, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, NaN, 2, 2, 1, 1, 1, 1, 
    1, 1, 1, 1, 1, 1, NaN, 2, 2, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 
    2, 2, 1, 1, 1, 1, 1, NaN, NaN, 2, 1, NaN, 1, 2, 2, 1, 1, 1, 1, 1, 
    1, 1, 1, 1, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 
    1, 1, 1, 1, 2, 2, 3, 2, 3, 3, 3, 3, 3, 1, 1, 1, 1, 1, 1, 1, 1, 
    1, 1, NaN, 3, 3, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, NaN, 1, 1, 
    1, 1, 1, 1, 1, 1, 1, 1, NaN, NaN, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
    1, 1, 2, NaN, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 
    1, 3, 3, 3, 3, 3, 3, 3, 3, 3, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
    2, 4, 2, 3, 4, 4, 5, 5, 5, 5, 5, 5, 5, 5, 5, 1, 1, 3, 5, 5, 5, 
    5, 5, 5, 5, 5, 5, 5, 1, 1, 3, 4, 5, 5, 5, 5, 5, 5, 5, 5, 5, 2, 
    2, 3, 3, 4, 5, 5, 5, 5, 5, 5, 5, 5, 1, 1, 1, 1, 2, 3, 3, 3, 4, 
    5, 5, 5, 5, 1, 1, 1, 1, 3, 3, 3, 4, 4, 5, 5, 5, 5], 13, 34)

  inits = Dict{String, Any}()
  inits["theta"] = [0.5, 1, 2, 3, 5, 6, 7, 8, 9, 12, 13, 16, 18]
  inits["grade"] = reshape([
    NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, 
    NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, 
    NaN, NaN, NaN, NaN, NaN, NaN, NaN, 1, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, 
    NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, 
    NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, 
    NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, 1, NaN, NaN, NaN, NaN, 
    NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, 
    NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, 1, 1, 
    NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, 1, 1, NaN, NaN, 1, 
    NaN, 1, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, 1, NaN, NaN, NaN, 
    NaN, NaN, 1, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, 
    NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, 
    NaN, NaN, NaN, 1, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, 
    1, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, 
    NaN, NaN, NaN, NaN, NaN, 1, 1, NaN, NaN, 1, NaN, NaN, NaN, NaN, NaN, NaN, 
    NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, 
    NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, 
    NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, 1, NaN, 
    NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, 1, NaN, NaN, 
    NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, 1, 1, NaN, NaN, NaN, NaN, NaN, NaN, 
    NaN, NaN, NaN, NaN, NaN, NaN, NaN, 1, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, 
    NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, 
    NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, 
    NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, 
    NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, 
    NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, 
    NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, 
    NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN], 13, 34)

  monitors = Dict{String, Bool}("theta" => true)

  jagsmodel = Jagsmodel(name="bones1", 
  model=bones,
    monitor=monitors,
    #ncommands=4, nchains=1,
    #adapt=1000, update=10000, thin=1,
    #deviance=true, dic=true, popt=true,
    #updatedatafile=true, updateinitfiles=true,
    #pdir=ProjDir
    );


  println("\nJagsmodel that will be used:")
  jagsmodel |> display

  @time sim = jags(jagsmodel, data, [inits], ProjDir)
  describe(sim)
  println()

  ## Highest Posterior Density Intervals
  hpd(sim) |> display
  println()

  ## Lag-Autocorrelations
  autocor(sim) |> display
  println()


  ## Plotting
  p = plot(sim, [:trace, :mean, :density, :autocor], legend=true);
  draw(p, ncol=4, filename="$(jagsmodel.name)-summaryplot", fmt=:svg)
  # draw(p, ncol=4, filename="$(jagsmodel.name)-summaryplot", fmt=:pdf)

  # Below will only work on OSX, please adjust for your environment.
  # JULIA_SVG_BROWSER is set from environment variable JULIA_SVG_BROWSER
  @static Sys.isapple() ? if isdefined(Main, :JULIA_SVG_BROWSER) && length(JULIA_SVG_BROWSER) > 0
          for i in 1:3
            isfile("$(jagsmodel.name)-summaryplot-$(i).svg") &&
              run(`open -a $(JULIA_SVG_BROWSER) "$(jagsmodel.name)-summaryplot-$(i).svg"`)
          end
        end : println()

end #cd