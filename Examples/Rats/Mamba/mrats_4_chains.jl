using Mamba

old = pwd()
path = @windows ? "\\Examples\\Rats\\Mamba" : "/Examples/Rats/Mamba"
ProjDir = Pkg.dir("Jags")*path
cd(ProjDir)

## Data
rats = (Symbol => Any)[
  :y =>
    [151, 199, 246, 283, 320,
     145, 199, 249, 293, 354,
     147, 214, 263, 312, 328,
     155, 200, 237, 272, 297,
     135, 188, 230, 280, 323,
     159, 210, 252, 298, 331,
     141, 189, 231, 275, 305,
     159, 201, 248, 297, 338,
     177, 236, 285, 350, 376,
     134, 182, 220, 260, 296,
     160, 208, 261, 313, 352,
     143, 188, 220, 273, 314,
     154, 200, 244, 289, 325,
     171, 221, 270, 326, 358,
     163, 216, 242, 281, 312,
     160, 207, 248, 288, 324,
     142, 187, 234, 280, 316,
     156, 203, 243, 283, 317,
     157, 212, 259, 307, 336,
     152, 203, 246, 286, 321,
     154, 205, 253, 298, 334,
     139, 190, 225, 267, 302,
     146, 191, 229, 272, 302,
     157, 211, 250, 285, 323,
     132, 185, 237, 286, 331,
     160, 207, 257, 303, 345,
     169, 216, 261, 295, 333,
     157, 205, 248, 289, 316,
     137, 180, 219, 258, 291,
     153, 200, 244, 286, 324],
  :x => [8.0, 15.0, 22.0, 29.0, 36.0]
]
rats[:xbar] = mean(rats[:x])
rats[:N] = size(rats[:y], 1)
rats[:T] = size(rats[:y], 2)

rats[:rat] = Integer[div(i - 1, 5) + 1 for i in 1:150]
rats[:week] = Integer[(i - 1) % 5 + 1 for i in 1:150]
rats[:X] = rats[:x][rats[:week]]
rats[:Xm] = rats[:X] - rats[:xbar]


## Model Specification

model = Model(

  y = Stochastic(1,
    @modelexpr(alpha, beta, rat, Xm, s2_c,
      begin
        mu = alpha[rat] + beta[rat] .* Xm
        IsoNormal(mu, sqrt(s2_c))
      end
    ),
    false
  ),

  alpha = Stochastic(1,
    @modelexpr(mu_alpha, s2_alpha,
      Normal(mu_alpha, sqrt(s2_alpha))
    ),
    false
  ),

  alpha0 = Logical(
    @modelexpr(mu_alpha, xbar, mu_beta,
      mu_alpha - xbar * mu_beta
    )
  ),

  mu_alpha = Stochastic(
    :(Normal(0.0, 10000)),
    false
  ),

  s2_alpha = Stochastic(
    :(InverseGamma(0.001, 0.001)),
    false
  ),

  beta = Stochastic(1,
    @modelexpr(mu_beta, s2_beta,
      Normal(mu_beta, sqrt(s2_beta))
    ),
    false
  ),

  mu_beta = Stochastic(
    :(Normal(0.0, 10000))
  ),

  s2_beta = Stochastic(
    :(InverseGamma(0.001, 0.001)),
    false
  ),

  s2_c = Stochastic(
    :(InverseGamma(0.001, 0.001))
  )

)


## Initial Values
inits = [
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
]


## Sampling Scheme
scheme = [Slice([:s2_c], [10.0]),
          AMWG([:alpha], fill(100.0, 30)),
          Slice([:mu_alpha, :s2_alpha], [100.0, 10.0], :univar),
          AMWG([:beta], ones(30)),
          Slice([:mu_beta, :s2_beta], [1.0, 1.0], :univar)]
setsamplers!(model, scheme)


## MCMC Simulations, 2 chains
isfile("rats_5.svg") && rm("rats_5.svg")
isfile("rats_6.svg") && rm("rats_6.svg")

## MCMC Simulations, 4 chains
sim3 = mcmc(model, rats, inits, 10000, burnin=2500, thin=2, chains=4)
describe(sim3)

## Plot results
myplot5 = plot(sim3, legend=true);
draw(myplot5, nrow=3, ncol=2, filename="rats_5.svg")
run(`open -a "Google Chrome.app" "rats_5.svg"`)

myplot6 = [plot(sim3, :autocor) plot(sim3, :mean, legend=true)];
draw(myplot6, nrow=2, ncol=3, filename="rats_6.svg")
run(`open -a "Google Chrome.app" "rats_6.svg"`)

#=
println("Continue sampling")
sim4 = mcmc(sim3, 10000)
describe(sim4)

## Plot results
myplot7 = plot(sim4, legend=true);
draw(myplot7, nrow=3, ncol=2, filename="rats_7.svg")
run(`open -a "Google Chrome.app" "rats_7.svg"`)

myplot8 = [plot(sim4, :autocor) plot(sim4, :mean, legend=true)];
draw(myplot8, nrow=2, ncol=3, filename="rats_8.svg")
run(`open -a "Google Chrome.app" "rats_8.svg"`)
=#

cd(old)