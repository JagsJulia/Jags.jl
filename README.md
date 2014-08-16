# Jags

[![Build Status](https://travis-ci.org/goedman/Jags.jl.svg?branch=master)](https://travis-ci.org/goedman/Jags.jl)

## Purpose

This is a very preliminary (basically a template) package to use Jags from Julia. Right now the template has been tested on Mac OSX 10.9.3 and Julia 0.3-rc1

Version 0.0.1 contains an example template in the directory "Pkg_dir"/Examples/Line.

For more info on Jags, please go to <http://mcmc-jags.sourceforge.net>.

## Usage

This version of the package assumes that Jags is installed and the jags binary is on $PATH.


## Dependencies

This version of the package relies on DataArrays and on Mamba.
Mamba is right now not in METADATA The package can be installed using:

```
Pkg.clone("https://github.com/brian-j-smith/Mamba.jl")
```

## A walk through example

```
######### Jags batch program example  ###########

using Jags

old = pwd()
ProjDir = homedir()*"/.julia/v0.3/Jags/Examples/Line"
cd(ProjDir)
```

As the Jags program produces results file in the current directory,
it is useful to control the current working directory and restore
the original directory at teh end of the script.

```
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
```

Variable `line` holds the model which will be writtten to a file
named `model_name.bugs`. model_name is set later on.

```
data = Dict{ASCIIString, Any}()
data["x"] = [1, 2, 3, 4, 5]
data["y"] = [1, 3, 3, 3, 5]
data["n"] = 5
```

Input data for the simulation.

```
inits = [
  (ASCIIString => Any)["alpha" => 0,"beta" => 0,"tau" => 1],
  (ASCIIString => Any)["alpha" => 1,"beta" => 2,"tau" => 1],
  (ASCIIString => Any)["alpha" => 3,"beta" => 3,"tau" => 2],
  (ASCIIString => Any)["alpha" => 5,"beta" => 2,"tau" => 5],
]
```

Initial values for parameters.

```
monitors = (ASCIIString => Bool)[
  "alpha" => true,
  "beta" => true,
  "tau" => true,
  "sigma" => true,
]
```

Variables to be monitored (if => true). If monitor is not passed
to jagsmodel, all keys (symbols) in inits will be monitored.

```
jagsmodel = Jagsmodel(name="line", model=line, data=data,
  init=inits, monitor=monitors);
```

A Jagsmodel is created and initialized.

```
(idx, chains) = jags(jagsmodel, ProjDir)
```

Results of the mcmc simulation.

```
println("\nJagsmodel:\n")
jagsmodel |> display
println()
data |> display
println()
inits |> display
println()
idx |> display
println()
```

Show input dictionaries and the resulting chain index dictionary.

```
if (length(chains) > 0)
  chains[1]["samples"] |> display
  println()
end
```

If all goes well, by default 4 chains will be returned. Show the contents
of the first chain dictionary.

```
for i in 1:jagsmodel.nchains
  println()
  println("mean(chains[$i][\"samples\"][\"alpha\"]) = ", mean(chains[i]["samples"]["alpha"]))
  println("mean(chains[$i][\"samples\"][\"beta\"]) = ", mean(chains[i]["samples"]["beta"]))
  println("mean(chains[$i][\"samples\"][\"sigma\"]) = ", mean(chains[i]["samples"]["sigma"]))
end

cd(old)
```

## To do

More features will be added as requested by users and as time permits. Please file an issue/comment/request.

