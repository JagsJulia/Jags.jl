using Jags, Mamba, Gadfly

ProjDir = dirname(@__FILE__)
cd(ProjDir) do

  ## Data
  rats = Dict{String, Any}(
    "Y" => 
      [151 199 246 283 320;
       145 199 249 293 354; 
       147 214 263 312 328; 
       155 200 237 272 297; 
       135 188 230 280 323; 
       159 210 252 298 331; 
       141 189 231 275 305; 
       159 201 248 297 338; 
       177 236 285 350 376; 
       134 182 220 260 296; 
       160 208 261 313 352; 
       143 188 220 273 314; 
       154 200 244 289 325; 
       171 221 270 326 358; 
       163 216 242 281 312; 
       160 207 248 288 324; 
       142 187 234 280 316; 
       156 203 243 283 317; 
       157 212 259 307 336; 
       152 203 246 286 321; 
       154 205 253 298 334; 
       139 190 225 267 302; 
       146 191 229 272 302; 
       157 211 250 285 323; 
       132 185 237 286 331; 
       160 207 257 303 345; 
       169 216 261 295 333; 
       157 205 248 289 316; 
       137 180 219 258 291; 
       153 200 244 286 324],
    "x" => [8.0, 15.0, 22.0, 29.0, 36.0]
  )
  rats["N"] = size(rats["Y"], 1)
  rats["T"] = size(rats["Y"], 2)
  rats["x.bar"] = mean(rats["x"])

  ratsmodel = "
  model {
      for (i in 1:N) {
         for (j in 1:T) {
            mu[i,j] <- alpha[i] + beta[i]*(x[j] - x.bar);
            Y[i,j]   ~ dnorm(mu[i,j], tau.c)
         }
         alpha[i] ~ dnorm(alpha.c, tau.alpha);
         beta[i]  ~ dnorm(beta.c, tau.beta);
      }
      alpha.c   ~ dnorm(0, 1.0E-4);
      beta.c    ~ dnorm(0, 1.0E-4);
      tau.c     ~ dgamma(1.0E-3, 1.0E-3);
      tau.alpha ~ dgamma(1.0E-3, 1.0E-3);
      tau.beta  ~ dgamma(1.0E-3, 1.0E-3);
      sigma    <- 1.0/sqrt(tau.c);
      alpha0   <- alpha.c - beta.c*x.bar;
  }
  "

  ## Initial Values
  inits = [
    Dict{String,Any}("alpha" => fill(250, 30), "beta" => fill(6, 30),
    "alpha.c" => 100, "beta.c" => 2, "tau.c" => 1, "tau.alpha" => 1, "tau.beta" => 1),
    Dict{String,Any}("alpha" => fill(150, 30), "beta" => fill(3, 30),
    "alpha.c" => 150, "beta.c" => 2, "tau.c" => 1, "tau.alpha" => 1, "tau.beta" => 1),
    Dict{String,Any}("alpha" => fill(200, 30), "beta" => fill(6, 30),
    "alpha.c" => 200, "beta.c" => 1, "tau.c" => 1, "tau.alpha" => 1, "tau.beta" => 1),
    Dict{String,Any}("alpha" => fill(150, 30), "beta" => fill(3, 30),
    "alpha.c" => 250, "beta.c" => 1, "tau.c" => 1, "tau.alpha" => 1,"tau.beta" => 1)
  ]

  monitors = Dict{String, Bool}(
    "alpha0" => true,
    "beta.c" => true,
    "sigma" =>true
  )

  jagsmodel = Jagsmodel(
    name="rats",
    model=ratsmodel,
    monitor=monitors,
    #ncommands=4, nchains=1,
    adapt=1000, update=10000, thin=10,
    #deviance=true, dic=true, popt=true,
    pdir=ProjDir);
  
  println("Jagsmodel that will be used:")
  jagsmodel |> display
  println("Input observed data dictionary:")
  rats |> display
  println("\nInput initial values dictionary:")
  inits |> display
  println()

  @time sim = jags(jagsmodel, rats, inits, ProjDir)
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