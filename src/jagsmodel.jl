importall Base

type Jagsmodel
  name::String
  nchains::Int
  adapt::Int
  update::Int
  thin::Int
  monitor::Dict
  deviance::Bool
  dic::Bool
  popt::Bool
  jags_file::String
  model::String
  model_file::String
  data::Dict
  data_file::String
  init::Dict
  init_file_array::Array{String, 1}
end

function Jagsmodel(;name::String="Noname", nchains::Number=4,
  adapt::Number=1000, update::Number=10000, thin::Number=10,
  monitor::Dict=Dict(), deviance::Bool=false,
  dic::Bool=false, popt::Bool=false,
  jags_file::String="",
  model::String="", model_file::String="",
  data::Dict=Dict(), data_file::String="",
  init::Dict=Dict(), init_file_array::Array{String, 1}=String[])
  
  if length(model) > 0
    update_model_file("$(name).bugs", strip(model))
  end
  
  if length(keys(data)) > 0
    update_R_file("$(name)-data.R", data)
  end
  
  for i in 1:nchains
    if length(keys(init)) > 0
      update_R_file("$(name)-inits$(i).R", init, replaceNaNs=false)
    end
  end
  
  if length(monitor) == 0 && length(init) > 0
    for entry in init
      monitor = merge(monitor, [symbol(entry[1]) => true])
    end
  end
  
  model_file = "$(name).bugs";
  jags_file = "$(name).jags"
  data_file = "$(name)-data.R"
  init_file_array = ["$(name)-inits$(i).R" for i in 1:nchains]
  jags_file = "$(name).jags"
  
  Jagsmodel(name, nchains, adapt, update, thin, monitor, deviance, dic, popt,
    jags_file, model, model_file, data, data_file, init, init_file_array);
end

function model_show(io::IO, m::Jagsmodel, compact::Bool=false)
  if compact==true
    println("Jagsmodel(", m.name, m.nchains, m.adapt, m.update,
      m.thin, m.monitor, m.model_file, m.init_file_array, m.data_file)
  else
    println("  name =                    \"$(m.name)\"")
    println("  nchains =                 $(m.nchains)")
    println("  adapt =                   $(m.adapt)")
    println("  update =                  $(m.update)")
    println("  thin =                    $(m.thin)")
    println("  monitor =                 $(m.monitor)")
    println("  deviance =                $(m.deviance)")
    println("  dic =                     $(m.dic)")
    println("  popt =                    $(m.popt)")
    println("  jags_file =               \"$(m.jags_file)\"")
    #println("  model =                   $(model)")
    println("  model_file =              \"$(m.model_file)\"")
    #println("  init =                    $(init)")
    println("  init_file_array =         \"$(m.init_file_array)\"")
    #println("  data =                    $(data)")
    println("  data_file =               \"$(m.data_file)\"")
  end
end

show(io::IO, m::Jagsmodel) = model_show(io, m, false)
showcompact(io::IO, m::Jagsmodel) = model_show(io, m, true)
