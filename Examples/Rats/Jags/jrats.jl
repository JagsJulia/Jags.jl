using Mamba, Jags

old = pwd()
path = @windows ? "\\Examples\\Rats\\Jags" : "/Examples/Rats/Jags"
ProjDir = Pkg.dir("Jags")*path
cd(ProjDir)

## Data
rats = (ASCIIString => Any)[
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
]
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
#=  # Inits for Mamba
[:y => rats[:y], :alpha => fill(250, 30), :beta => fill(6, 30),
 :mu_alpha => 100, :mu_beta => 2, :s2_c => 1, :s2_alpha => 1,
 :s2_beta => 1],
[:y => rats[:y], :alpha => fill(150, 30), :beta => fill(3, 30),
 :mu_alpha => 150, :mu_beta => 2, :s2_c => 1, :s2_alpha => 1,
 :s2_beta => 1],
[:y => rats[:y], :alpha => fill(200, 30), :beta => fill(6, 30),
 :mu_alpha => 200, :mu_beta => 1, :s2_c => 1, :s2_alpha => 1,
 :s2_beta => 1],
[:y => rats[:y], :alpha => fill(150, 30), :beta => fill(3, 30),
 :mu_alpha => 250, :mu_beta => 1, :s2_c => 1, :s2_alpha => 1,
 :s2_beta => 1]
=#
inits = [
  ["alpha" => fill(250, 30), "beta" => fill(6, 30),
  "alpha.c" => 100, "beta.c" => 2, 
  "tau.c" => 1, "tau.alpha" => 1, "tau.beta" => 1],
  ["alpha" => fill(150, 30), "beta" => fill(3, 30),
  "alpha.c" => 150, "beta.c" => 2, 
  "tau.c" => 1, "tau.alpha" => 1, "tau.beta" => 1],
  ["alpha" => fill(200, 30), "beta" => fill(6, 30),
  "alpha.c" => 200, "beta.c" => 1, 
  "tau.c" => 1, "tau.alpha" => 1, "tau.beta" => 1],
  ["alpha" => fill(150, 30), "beta" => fill(3, 30),
  "alpha.c" => 250, "beta.c" => 1, 
  "tau.c" => 1, "tau.alpha" => 1,"tau.beta" => 1]
]

monitors = (ASCIIString => Bool)[
  "alpha0" => true,
  "beta.c" => true,
  "sigma" =>true
]

jagsmodel = Jagsmodel(name="rats", model=ratsmodel, data=rats, init=inits, nchains=4,
  monitor=monitors, adapt=2500, update=7500, thin=2);
  
println("Jagsmodel that will be used:")
jagsmodel |> display
println("Input observed data dictionary:")
rats |> display
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

## Plotting

## Default summary plot (trace and density plots)
p = plot(sim1)

## Write plot to file
draw(p, filename="ratssummaryplot.svg")
#draw(p, filename="ratssummaryplot", fmt=:pdf)

## Autocorrelation and running mean plots
p = [plot(sim1, :autocor) plot(sim1, :mean, legend=true)].'
draw(p, nrow=3, ncol=2, filename="ratsautocormeanplot.svg")

run(`open -a "Google Chrome.app" "ratssummaryplot.svg"`)
run(`open -a "Google Chrome.app" "ratsautocormeanplot.svg"`)


## Obtain deviance etc.

jagsmodel = Jagsmodel(name="rats", model=ratsmodel, data=rats, init=inits, nchains=4,
  monitor=monitors, adapt=2500, update=7500, thin=1, deviance=true, dic=true, popt=true);

(idx, sim2) = jags(jagsmodel, ProjDir, updatejagsfile=true)

## Summary Statistics
describe(sim2)

println()
if jagsmodel.dic
  (idx0, chain0) = Jags.read_pDfile()
  idx0 |> display
  println()
  chain0[1]["samples"] |> display
end
  
if jagsmodel.dic || jagsmodel.popt
  println()
  pDmeanAndpopt = Jags.read_table_file(jagsmodel, rats["N"])
  pDmeanAndpopt |> display
end

## Default summary plot (trace and density plots)
p = plot(sim2[:, ["deviance", "sigma"], :])

## Write plot to file
draw(p, filename="ratssummaryplot2.svg")
run(`open -a "Google Chrome.app" "ratssummaryplot2.svg"`)


cd(old)