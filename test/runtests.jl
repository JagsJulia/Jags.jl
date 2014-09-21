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

println("Running tests:")

for my_test in code_tests
    println("\n  * $(my_test) *")
    include(my_test)
end

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

cd(old)