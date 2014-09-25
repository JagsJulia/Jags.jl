# Jags


[![Jags](http://pkg.julialang.org/badges/Jags_release.svg)](http://pkg.julialang.org/?pkg=Jags&ver=release)

## Purpose

This is a very preliminary package to use Jags from Julia. Right now the package has been tested on Mac OSX 10.9.3 and 10.10beta and Julia versions 0.3 and 0.4-dev+843. Some testing has taken place on Windows.

Version 0.0.4 contains several examples for Jags.

For more info on Jags, please go to <http://mcmc-jags.sourceforge.net>.

Branches on Github will contain Jags-jx.x-vx.x.x

## Usage

This version of the package assumes that Jags is installed and the jags binary is on $PATH.

Parameters to Jagsmodel() and jags() have been updated and are not fully compatible with Jags v0.0.3.

## Dependencies

This version of the package relies on DataArrays (0.2.1) to handle NaNs (in the data and inital dictionaries)

## A walk through example

As the Jags program produces results files in the current directory,
it is useful to control the current working directory and restore
the original directory at the end of the script.

```
using Jags

old = pwd()
path = @windows ? "\\Examples\\Line" : "/Examples/Line"
ProjDir = Pkg.dir("Jags")*path
cd(ProjDir)
```

Variable `line` holds the model which will be writtten to a file
named `model_name.bugs`. model_name is set later on.

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

Input data for the simulation:

```
data = Dict{ASCIIString, Any}()
data["x"] = [1, 2, 3, 4, 5]
data["y"] = [1, 3, 3, 3, 5]
data["n"] = 5

println()
data |> display
```

An array of dictionaries with initial values for parameters. If the array of dictionaries has
not enough elements, only the first element will be used for all chains.

```
inits = [
  (ASCIIString => Any)["alpha" => 0,"beta" => 0,"tau" => 1],
  (ASCIIString => Any)["alpha" => 1,"beta" => 2,"tau" => 1],
  (ASCIIString => Any)["alpha" => 3,"beta" => 3,"tau" => 2],
  (ASCIIString => Any)["alpha" => 5,"beta" => 2,"tau" => 5],
]

println()
inits |> display
```
If inits is a Dictionary, it needs to be passed as init=[inits] to Jagsmodel below (e.g. see the Bones example).

Variables to be monitored (if => true). If monitor is not passed
to jagsmodel, all keys (symbols) in inits will be monitored.

```
monitors = (ASCIIString => Bool)[
  "alpha" => true,
  "beta" => true,
  "tau" => true,
  "sigma" => true,
]
```

A Jagsmodel is created and initialized. Notice that by default 4 commands are created each producing a single chain.

```
jagsmodel = Jagsmodel(name="line", model=line,
  data=data, init=inits, monitor=monitors,
  #ncommands=4, nchains=1,
  adapt=1000, update=10000, thin=1,
  #deviance=true, dic=true, popt=true,
  updatedatafile=true, updateinitfiles=true,
  pdir=ProjDir);

println("\nJagsmodel that will be used:")
jagsmodel |> display
```

Run the mcmc simulation. Four commands are started, each with 2 chains. If nchains is set to 1, this is updated in Jagsmodel if DIC and/or popt is requested. Jags needs minimally 2 chains to compute those.

```
(index, chains) = jags(jagsmodel, ProjDir, updatejagsfile=true)

chains[1]["samples"] |> display

cd(old)
```

By default 4 commands are executed, each producing a single chain. All chains will be returned as the second entry in a tuple. The results of the 1st chains is shown above.

## Some details

Using the Bones example as a testcase, on my machine running 4 (parallel) commands each simulating 1 chain takes about 9 seconds. A single command simulating 4 chains takes about 25 seconds.

## To do

More features will be added as requested by users and as time permits. Please file an issue/comment/request.

The next version (v0.0.5) will take a better look at the handling of all inputs to Jagsmodel and jags.