######### Jags program example  ###########

using Jags

old = pwd()
path = @windows ? "\\Examples\\Line" : "/Examples/Line"
ProjDir = Pkg.dir("Jags")*path
cd(ProjDir)

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

data = Dict{ASCIIString, Any}()
data["x"] = [1, 2, 3, 4, 5]
data["y"] = [1, 3, 3, 3, 5]
data["n"] = 5

inits = [
  (ASCIIString => Any)["alpha" => 0,"beta" => 0,"tau" => 1],
  (ASCIIString => Any)["alpha" => 1,"beta" => 2,"tau" => 1],
  (ASCIIString => Any)["alpha" => 3,"beta" => 3,"tau" => 2],
  (ASCIIString => Any)["alpha" => 5,"beta" => 2,"tau" => 5],
]

monitors = (ASCIIString => Bool)[
  "alpha" => true,
  "beta" => true,
  "tau" => true,
  "sigma" => true,
]

jagsmodel = Jagsmodel(name="line", model=line, ncommands=5, nchains=4, thin=2,
  deviance=true, dic=true, popt=true);

println("\nJagsmodel that will be used:")
jagsmodel |> display
println("Input observed data dictionary:")
data |> display
println("\nInput initial values dictionary:")
inits |> display

(index, chains) = jags(jagsmodel, ProjDir, data=data, init=inits,
  monitor=monitors, updatejagsfile=true)

println()
chains[1]["samples"] |> display
println()
chains[3]["samples"] |> display
println()
chains[20]["samples"] |> display

println()
if jagsmodel.dic
  (idx0, chain0) = Jags.read_pDfile(jagsmodel)
  idx0 |> display
  println()
  chain0[1]["samples"] |> display
end
  
if jagsmodel.dic || jagsmodel.popt
  println()
  pDmeanAndpopt = Jags.read_table_file(jagsmodel, data["n"])
  pDmeanAndpopt |> display
  
  if jagsmodel.dic || jagsmodel.popt
    (idx0, chain0) = Jags.read_pDfile(jagsmodel)
    pDmeanAndpopt = Jags.read_table_file(jagsmodel, data["n"])
  end
  #
  for i in 1:jagsmodel.ncommands
    isfile("$(jagsmodel.name)-cmd$(i)-chain0.txt") &&
      rm("$(jagsmodel.name)-cmd$(i)-chain0.txt");
    isfile("$(jagsmodel.name)-cmd$(i)-index0.txt") &&
      rm("$(jagsmodel.name)-cmd$(i)-index0.txt");
    isfile("$(jagsmodel.name)-cmd$(i)-table0.txt") &&
      rm("$(jagsmodel.name)-cmd$(i)-table0.txt");
  end
  #
end


cd(old)
