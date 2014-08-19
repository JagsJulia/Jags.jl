# Jags

[![Build Status](https://travis-ci.org/goedman/Jags.jl.svg?branch=master)](https://travis-ci.org/goedman/Jags.jl)

## Purpose

This is a very preliminary package to use Jags from Julia. Right now the template has been tested on Mac OSX 10.9.3 and Julia 0.3-rc4. Some testing has taken place on Windows.

Version 0.0.0- contains several examples for Jags (and equivalent Mamba versions).

For more info on Jags, please go to <http://mcmc-jags.sourceforge.net>.

Branches on Github will contain Jags-jx.x-vx.x.x

## Usage

This version of the package assumes that Jags is installed and the jags binary is on $PATH.


## Dependencies

This version of the package relies on DataArrays, Cairo, Gadfly and on Mamba (0.0.0-).
Mamba is right now not in METADATA. The package can be installed using:

```
Pkg.clone("https://github.com/brian-j-smith/Mamba.jl")
```

## A walk through example

As the Jags program produces results file in the current directory,
it is useful to control the current working directory and restore
the original directory at the end of the script.

```
using Cairo, Mamba, Jags

old = pwd()
path = @windows ? "\\Examples\\Line\\Jags" : "/Examples/Line/Jags"
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

Initial values for parameters. If the array of dictionaries has
not enough elements, only the first elemnt is used for all chains.

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

A Jagsmodel is created and initialized:

```
jagsmodel = Jagsmodel(name="line", model=line, data=data,
  init=inits, monitor=monitors, deviance=true, dic=true, popt=true);

println("\nJagsmodel:\n")
jagsmodel |> display
```

Run the mcmc simulation:

```
sim1 = jags(jagsmodel, ProjDir, updatejagsfile=true)
```

If all goes well, by default 4 chains will be returned. Show the results:

```
gelmandiag(sim1, mpsrf=true, transform=true) |> display

gewekediag(sim1) |> display

describe(sim1)

hpd(sim1) |> display

cor(sim1) |> display

autocor(sim1) |> display

println()
if jagsmodel.dic
  (idx0, chain0) = Jags.read_pDfile()
  idx0 |> display
  println()
  chain0[1]["samples"] |> display
end
  
if jagsmodel.dic || jagsmodel.popt
  println()
  pDmeanAndpopt = Jags.read_table_file(jagsmodel, data["n"])
  pDmeanAndpopt |> display
end
```

And the plots, use svg format (default) or 'fmt=:pdf':

```
p = plot(sim1[:, ["alpha", "beta",  "sigma"], :], legend=true)
draw(p, filename="jlinesummaryplot.svg")

p = [plot(sim1[:, ["alpha", "beta",  "sigma"], :], :autocor) plot(sim1[:, ["alpha",     "beta",  "sigma"], :], :mean, legend=true)].'
draw(p, nrow=3, ncol=2, filename="jlineautocormeanplot.svg")
draw(p, nrow=3, ncol=2, filename="mlineautocormeanplot", fmt=:pdf)


p = plot(sim1[:, ["deviance", "sigma"], :], legend=true)
draw(p, filename="jlinesummaryplot2.svg")
```

To display the plots, e.g. on OSX:

```
run(`open -a "Google Chrome.app" "jlinesummaryplot.svg"`)
run(`open -a "Google Chrome.app" "jlineautocormeanplot.svg"`)
run(`open -a "Google Chrome.app" "jlinesummaryplot2.svg"`)

cd(old)
```



## To do

More features will be added as requested by users and as time permits. Please file an issue/comment/request.

