function precompile_model()
    
    redirect_stdout(devnull) do
    ProjDir = tempdir()
    cd(ProjDir) do

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

        monitors = Dict("alpha" => true, "beta" => true, "tau" => true, "sigma" => true)

        jagsmodel = Jagsmodel(
            name = "line4",
            model = line,
            monitor = monitors,
            deviance = false,
            dic = true,
            popt = true,
            jagsthin = 10,
            thin = 1,
            pdir = ProjDir,
        )

        println("\nJagsmodel that will be used:")
        jagsmodel |> display

        data = Dict("x" => [1, 2, 3, 4, 5], "y" => [1, 3, 3, 3, 5], "n" => 5)

        inits = [
            Dict("alpha" => 0, "beta" => 0, "tau" => 1),
            Dict("alpha" => 1, "beta" => 2, "tau" => 1),
            Dict("alpha" => 3, "beta" => 3, "tau" => 2),
            Dict("alpha" => 5, "beta" => 2, "tau" => 5),
        ];

        sim = jags(jagsmodel, data, inits, ProjDir)
        println(sim)
    end
end
end