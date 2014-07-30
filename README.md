# Jags

[![Build Status](https://travis-ci.org/goedman/Jags.jl.svg?branch=master)](https://travis-ci.org/goedman/Jags.jl)

## Purpose

This is a very preliminary (basically a template) package to use Jags from Julia. Right now the template has been tested on Mac OSX 10.9.3 and Julia 0.3-rc1

Version 0.0.1 contains an example template in the directory "Pkg_dir"/Examples/Line.

For more info on Jags, please go to <http://mcmc-jags.sourceforge.net>.

## Usage

This version of the package assumes that Jags is installed and the jags binary is on $PATH.

A possible way to get started is to copy all of the "Pkg_dir"/Examples/Line files to a project directory, adjust the ProjDir (line 6 in ./Examples/Line/line.jl) and try it out.

## To do

More features will be added as requested by users and as time permits. Please file an issue/comment/request.

On my list are:

1.  The ability to convert the Jags output files into the MCMCChain format
2.  A jags() method, a resume() method?

