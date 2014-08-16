######### Jags batch program example  ###########

using Mamba, Jags

old = pwd()
path = @windows ? "\\Examples\\Dyes\\Jags" : "/Examples/Dyes/Jags"
ProjDir = Pkg.dir("Jags")*path
cd(ProjDir)

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

data = Dict{ASCIIString, Any}()
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
  (ASCIIString => Any)[
    "theta" => 1500,
    "tau.within" => 1,
    "tau.between" => 1
  ]
]

monitors = (ASCIIString => Bool)[
  "theta" => true,
  "s2.within" => true,
  "s2.between" => true
]

jagsmodel = Jagsmodel(name="dyes", model=dyes, data=data,
  init=inits, monitor=monitors, deviance=true, dic=true, popt=true);

println("\nJagsmodel that will be used:")
jagsmodel |> display
println("Input observed data dictionary:")
data |> display
println("\nInput initial values dictionary:")
inits |> display
println()

(idx, chains) = jags(jagsmodel, ProjDir, updatejagsfile=true)

println()
idx |> display
println()

if (length(chains) > 0)
  chains[1]["samples"] |> display
  println()
end

if jagsmodel.dic
  (idx0, chain0) = Jags.read_pDfile()
  idx0 |> display
  println()
  chain0[1]["samples"] |> display
end
  
if jagsmodel.dic || jagsmodel.popt
  println()
  pDmeanAndpopt = Jags.read_table_file(jagsmodel, size(data["BATCHES"], 1))
  pDmeanAndpopt |> display
end

for i in 1:jagsmodel.nchains
  println()
  println("mean(chains[$i][\"samples\"][\"theta\"]) = ",
    mean(chains[i]["samples"]["theta"]))
  println("mean(chains[$i][\"samples\"][\"s2.within\"]) = ",
    mean(chains[i]["samples"]["s2.within"]))
  println("mean(chains[$i][\"samples\"][\"s2.between\"]) = ",
    mean(chains[i]["samples"]["s2.between"]))
end

cd(old)