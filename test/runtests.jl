println("Running tests for Jags-j1.2-v3.0")

using Compat, Jags
using Test

code_tests = ["test_cmd.jl"]

println("Run execution_tests only if Jags is available")
execution_tests = [
  "test_line1.jl",
  "test_line2.jl",
  "test_line3.jl",
  "test_line4.jl",
  "test_rats.jl",
  "test_bones1.jl",
  "test_bones2.jl",
  "test_dyes.jl"
]

for my_test in code_tests
    println("\n  * $(my_test) *")
    include(my_test)
end

if isdefined(Main, :JAGS_HOME) && length(JAGS_HOME) > 0
  @testset "Jags.jl" begin
    
    for my_test in code_tests
        println("\n\n\n  * $(my_test) *")
        include(my_test)
    end
    
    for my_test in execution_tests
        println("\n\n\n  * $(my_test) *")
        include(my_test)
    end
    
    println("\n")
    
  end
else
  println("\n\nJAGS_HOME not found.")
  println("Skipping all tests that depend on the Jags executable!\n")  
end
  
