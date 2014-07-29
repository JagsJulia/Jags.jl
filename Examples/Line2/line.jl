######### Jags batch program example  ###########

using Jags

old = pwd()
ProjDir = homedir()*"/.julia/v0.3//Jags/Examples/Line2"

str = "
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

update_model_file(ProjDir*"/line.bugs", strip(str))

line = Dict{Symbol, Any}()
line[:x] = [1, 2, 3, 4, 5]
line[:y] = [1, 3, 3, 3, 5]
line[:n] = 5

update_data_file(ProjDir*"/test-data.R", line)

inits = (Symbol => Any)[
  :alpha => 0,
  :beta => 0,
  :tau => 1
]

update_data_file(ProjDir*"/test-inits.R", inits)

idx = 0
samples = 0
try
  cd(ProjDir)
  for i in 1:4
    isfile("CODAchain$(i).txt") && rm("CODAchain$(i).txt")
  end
  isfile("CODAindex.txt") && rm("CODAindex.txt")
  
  @time run(`jags line.jags`)
  (idx, samples) = read_jagsfiles()

catch e
  println(e)
  cd(old)
end

println()
line |> display
println()
inits |> display
println()
samples[1][:samples] |> display
println()

cd(old)