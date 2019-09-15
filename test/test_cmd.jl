ProjDir = dirname(@__FILE__)
cd(ProjDir) do

  inits1 = [
    Dict("alpha" => 0,"beta" => 0,"tau" => 1),
    Dict("alpha" => 1,"beta" => 2,"tau" => 1),
    Dict("alpha" => 3,"beta" => 3,"tau" => 2),
    Dict("alpha" => 5,"beta" => 2,"tau" => 5)
  ]

  function test(init::Array{Dict{String, Int64},1})
    res = map((x)->convert(Dict{String, Any}, x), init)
  end

  function test(init::Array{Dict{String, Float64},1})
    res = map((x)->convert(Dict{String, Any}, x), init)
  end

  function test(init::Array{Dict{String, Number},1})
    res = map((x)->convert(Dict{String, Any}, x), init)
  end

  function test(init::Array{Dict{String, Any},1})
    res = map((x)->convert(Dict{String, Any}, x), init)
  end

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

  data = Dict{String, Any}()
  data["x"] = [1, 2, 3, 4, 5]
  data["y"] = [1, 3, 3, 3, 5]
  data["n"] = 5

  inits = test(inits1)

  monitors = Dict{String, Bool}(
    "alpha" => true,
    "beta" => true,
    "tau" => true,
    "sigma" => true,
  )

  jagsmodel = Jagsmodel(name="line1", model=line, monitor=monitors,
    ncommands=1, nchains=4, adapt=1000, nsamples=10000, thin=1,
    deviance=true, dic=true, popt=true, pdir=ProjDir);

  println("\nJagsmodel that will be used:")
  jagsmodel |> display
  println("Input observed data dictionary:")
  data |> display
  println("\nInput initial values dictionary:")
  inits |> display

  cd(ProjDir)
  isdir("tmp") &&
    rm("tmp", recursive=true);

end
