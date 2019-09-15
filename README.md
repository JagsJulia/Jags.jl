# Jags

[![Travis Build Status](https://travis-ci.org/JagsJulia/Jags.jl.svg?branch=master)](https://travis-ci.org/JagsJulia/Jags.jl)

## Purpose

A package to use Jags (as an external program) from Julia. Jags.jl has been moved to JagsJulia.

For more info on Jags, please go to <http://mcmc-jags.sourceforge.net>.

## What's new

### Version 3.0.0

1. MCMCChains for storage and diagnostics (thanks to Chris Fisher)
2. No longer depends on Mamba and Gadfly

### Version 2.0.1 (tagged Jan 2019)

1. Fixed issues with REQUIRE.

### Version 2.0.0 (tagged Jan 2019)

1. Thanks to Hellema Jags.jl has been updated for Julia 1.

### Version 1.0.5 (tagged Jan 2018)

1. Added an option to specify thinning by Jags. Jagsmodel() now accepts a jagsthin arguments. Default is jagsthin=1. Thanks to @hellemo. See examples Line3 and Line4.
2. Further updates by Hellemo (e.g. to improve readdlm performance).
3. Tested on Julia 0.6. Not yet on Julia 0.7-.

### Version 1.0.2

1. Requires Julia v"0.5.0-rc3".
2. Updated .travis.yml to jsut test on Julia 0.5

### Version 1.0.0

1. Updated for Julia 0.5

### Version 0.2.0

1. Added badges for Julia package listing
2. Exported JAGS_HOME in Jags.jl
3. Updated for to also run Julia 0.4 pre-releases

### Version 0.1.5

1. Updated .travis.yml
2. The runtests.jl script now prints package version

### Version 0.1.4

1. Allowed JAGS_HOME and JULIA_SVG_BROWSER to be set from either ~/.juliarc.jl or as an evironment variable. Updated README accordingly.

### Version 0.1.3

1. Removed upper bound on Julia in REQUIRE.

### Version 0.1.2

1. Fix for access to environment variables on Windows.

### Version 0.1.1

1. Stores Jags's input & output files in a subdirectory of the working directory.
2. Added Bones2 example.

### Version 0.1.0

The two most important features introduced in version 0.1.0 are:

1. Using Mamba to display and diagnose simulation results. The call to jags() to sample now returns a Mamba Chains object (previously it returned a dictionary).
2. Added the ability to specify RNGs in the initializations file for running simulations in parallel.

### Version 0.0.4

1. Added the ability to start multiple Jags scripts in parallel.

### Version 0.0.3 and earlier

1. Parsing structure for input arguments to Stan.
2. Single process execution of a Jags simulations.
3. Read created output files by Jags back into Julia.


## Requirements

This version of the Jags.jl package assumes that:

1. Jags is installed and the jags binary is on $PATH. The variable JAGS_HOME is currently initialized either from ~/.juliarc.jl or from an environment variable JAGS_HOME. JAGS_HOME currently only used in runtests.jl to disable attempting to run tests that need the Jags executable on $PATH.

To test and run the examples:

**julia >** ``Pkg.test("Jags")``


## A walk through example

As in the Jags.jl setting, the Jags program consumes and produces files in a 'tmp' subdirectory of the current directory, it is useful to control the current working directory and restore the original directory at the end of the script.
```
using Jags

ProjDir = dirname(@__FILE__)
cd(ProjDir)
```
Variable `line` holds the model which will be writtten to a file named `$(model.name).bugs` in the 'tmp' subdirectory. The value of model.name is set later on, see the call to Jagsmodel() below.
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
Next, define which variables should be monitored (if => true).
```
monitors = (String => Bool)[
  "alpha" => true,
  "beta" => true,
  "tau" => true,
  "sigma" => true,
]
```
The next step is to create and initialize a Jagsmodel:
```
jagsmodel = Jagsmodel(
  name="line1",
  model=line,
  monitor=monitors,
  #ncommands=1, nchains=4,
  #deviance=true, dic=true, popt=true,
  pdir=ProjDir);

println("\nJagsmodel that will be used:")
jagsmodel |> display
```
Notice that by default a single command with 4 chains is created. It is possible to run each of the 4 chains in a separate process which has advantages. Using the Bones example as a testcase, on my machine running 1 command simulating a single chain takes 6 seconds, 4 (parallel) commands each simulating 1 chain takes about 9 seconds and a single command simulating 4 chains takes about 25 seconds. Of course this is dependent on the number of available cores and assumes the drawing of samples takes a reasonable chunk of time vs. running a command in a new shell.

Running chains in separate commands does need additional data to be passed in through the initialization data and is demonstrated in Examples/Line2. Some more details are given below.

If nchains is set to 1, this is updated in Jagsmodel() if dic and/or popt is requested. Jags needs minimally 2 chains to compute those.

The input data for the line example is in below data dictionary:
```
data = Dict(
  "x" => [1, 2, 3, 4, 5],
  "y" => [1, 3, 3, 3, 5],
  "n" => 5
)

println("Input observed data dictionary:")
data |> display
```
Next define an array of dictionaries with initial values for parameters. If the array of dictionaries has not enough elements, the elements will be recycled for chains/commands:
```
inits = [
  Dict("alpha" => 0,"beta" => 0,"tau" => 1),
  Dict("alpha" => 1,"beta" => 2,"tau" => 1),
  Dict("alpha" => 3,"beta" => 3,"tau" => 2),
  Dict("alpha" => 5,"beta" => 2,"tau" => 5)
]

println("\nInput initial values dictionary:")
inits |> display
println()
```
Run the mcmc simulation, passing in the model, the data, the initial values and the working directory. If 'inits' is a single dictionary, it needs to be passed in as '[inits]', see the Bones example.
```
sim = jags(jagsmodel, data, inits, ProjDir)
describe(sim)
println()
```
## Running a Jags script, some details

Jags.jl really only consists of 2 functions, Jagsmodel() and jags().

Jagsmodel() is used to define and set up the basic structure to run a simulation.
The full signature of Jagsmodel() is:
```
function Jagsmodel(;
  name="Noname",
  model="",
  ncommands=1,
  nchains=4,
  adapt=1000,
  nsamples=10000,
  thin=10,
  jagsthin=1,
  monitor=Dict(),
  deviance=false,
  dic=false,
  popt=false,
  updatejagsfile=true,
  pdir=pwd())
```
All arguments are keyword arguments and have default values, although usually at least the name and model arguments will be provided.

After a Jagsmodel has been created, the workhorse function jags() is called to run the simulation, passing in the Jagsmodel, the data and the initialization for the chains.

As Jags needs quite a few input files and produces several output files, these are all stored in a subdirectory of the working directory, typically called 'tmp'.

The full signature of jags() is:
```
function jags(
  model::Jagsmodel,
  data::Dict{String, Any}=Dict{String, Any}(),
  init::Array{Dict{String, Any}, 1} = Dict{String, Any}[],
  ProjDir=pwd();
  updatedatafile::Bool=true,
  updateinitfiles::Bool=true
  )
```
All parameters to compile and run the Jags script are implicitly passed in through the model argument.

The Line2 example shows how to run multiple Jags simulations in parallel. The most simple case, e.g. 4 commands, each with a single chain, can be initialized with an 'inits' like shown below:
```
inits = [
  Dict("alpha" => 0,"beta" => 0,"tau" => 1,".RNG.name" => "base::Wichmann-Hill"),
  Dict("alpha" => 1,"beta" => 2,"tau" => 1,".RNG.name" => "base::Marsaglia-Multicarry"),
  Dict("alpha" => 3,"beta" => 3,"tau" => 2,".RNG.name" => "base::Super-Duper"),
  Dict("alpha" => 5,"beta" => 2,"tau" => 5,".RNG.name" => "base::Mersenne-Twister")
]
```
The first entry in the 'inits' array will be passed into the first chain in the first command process, the second entry to the second process, etc. A second chain in the first command would be initialized with the second entry, etc.


## To do

More features will be added as requested by users and as time permits. Please file an issue/comment/request.

**Note 1:** In order to support platforms other than OS X, help is needed to test on such platforms.
