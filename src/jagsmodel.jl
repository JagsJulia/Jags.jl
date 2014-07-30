importall Base

type Jagsmodel
  name::String
  chains::Int
  adapt::Int64
  update::Int64
  thin::Int64
  jags_file::String
  model::String
  model_file::String
  data::Dict
  data_file::String
  init::Dict
  init_file::String
end

function Jagsmodel(;name::String="Noname", chains::Number=4,
  adapt::Number=1000, update::Number=10000, thin::Number=10,
  jags_file::String="",
  model::String="", model_file::String="",
  data::Dict=Dict(), data_file::String="",
  init::Dict=Dict(), init_file::String="")
  
  if length(model) > 0
    update_model_file(ProjDir*"/$(name).bugs", strip(model))
  end
  
  if length(keys(data)) > 0
    update_R_file(ProjDir*"/$(name)-data.R", data)
  end
  
  if length(keys(init)) > 0
    update_R_file(ProjDir*"/$(name)-inits.R", init)
  end
  
  model_file = "$(name).bugs";
  jags_file = "$(name).jags"
  data_file = "$(name)-data.R"
  init_file = "$(name)-inits.R"
  jags_file = "$(name).jags"
  
  Jagsmodel(name, chains, adapt, update, thin, jags_file,
    model, model_file, data, data_file, init, init_file);
end

function model_show(io::IO, m::Jagsmodel, compact::Bool=false)
  if compact==true
    println("Jagsmodel(", m.name, m.chains, m.adapt, m.update,
      m.thin, m.model_file, m.init_file, m.data_file)
  else
    println("  name =                    \"$(m.name)\"")
    println("  chains =                  $(m.chains)")
    println("  adapt =                   $(m.adapt)")
    println("  update =                  $(m.update)")
    println("  thin =                    $(m.thin)")
    println("  jags_file =               \"$(m.jags_file)\"")
    #println("  model =                   $(model)")
    println("  model_file =              \"$(m.model_file)\"")
    #println("  init =                    $(init)")
    println("  init_file =               \"$(m.init_file)\"")
    #println("  data =                    $(data)")
    println("  data_file =               \"$(m.data_file)\"")
  end
end

show(io::IO, m::Jagsmodel) = model_show(io, m, false)
showcompact(io::IO, m::Jagsmodel) = model_show(io, m, true)
