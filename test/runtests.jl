using Jags
using Base.Test

old = pwd()

using Base.Test

code_tests = [
  "test_cmd.jl"
]

execution_tests = [
  "test_line.jl",
  "test_rats.jl",
  "test_bones.jl",
  "test_dyes.jl"
]

println("Running tests for Jags-j0.3-v0.1.5:")

for my_test in code_tests
    println("\n  * $(my_test) *")
    include(my_test)
end

if isdefined(Main, :JAGS_HOME) && length(JAGS_HOME) > 0
  try
    for my_test in execution_tests
        println("\n  * $(my_test) *")
        include(my_test)
    end
    println()
  catch e
     println("Is Jags properly installed?")
     println(e)
     println("No simulation runs have been performed.")
  end
else
  println("\n\nJAGS_HOME not found. Skipping all tests that depend on the Jags executable!\n")  
end
  

cd(old)