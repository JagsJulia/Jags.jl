importall Base

type Jagsmodel
  name::String
  ncommands::Int
  nchains::Int
  adapt::Int
  update::Int
  thin::Int
  monitor::Dict
  deviance::Bool
  dic::Bool
  popt::Bool
  model::String
  model_file::String
  data::Dict
  data_file::String
  init::Array{Dict{ASCIIString,Any},1}
  command::Array{Base.AbstractCmd, 1}
end

function Jagsmodel(;name::String="Noname", 
  ncommands::Number=4, nchains::Number=1,
  adapt::Number=1000, update::Number=10000, thin::Number=10,
  deviance::Bool=false, dic::Bool=false, popt::Bool=false,
  model::String="")
  
  monitor=Dict()
  data=Dict{ASCIIString, Any}() 
  init=Array{Dict{ASCIIString,Any},1}[] 
  cmdarray = fill(``, ncommands)
  
  if length(model) > 0
    update_model_file("$(name).bugs", strip(model))
  end
  
  if (dic || popt) && nchains < 3
    nchains = 3
  end
  
  model_file = "$(name).bugs";
  data_file = "$(name)-data.R"
  
  Jagsmodel(name,
    ncommands, nchains,
    adapt, update, thin, 
    monitor,
    deviance, dic, popt,
    model, model_file, 
    data,
    data_file, 
    init, 
    cmdarray);
end

function update_model_file(file::String, str::String)
  str2 = ""
  if isfile(file)
    str2 = open(readall, file, "r")
    str != str2 && rm(file)
  end
  if str != str2
    println("\nFile $(file) will be updated.")
    strmout = open(file, "w")
    write(strmout, str)
    close(strmout)
  end
end

function model_show(io::IO, m::Jagsmodel, compact::Bool=false)
  if compact==true
    println("Jagsmodel(", m.name, m.ncommands, m.nchains,
      m.adapt, m.update, m.thin, 
      m.monitor,
      m.deviance, m.dic, m.popt,
      m.model_file, m.data_file, m.init_stem, m.coda_stem)
  else
    println("  name =                    \"$(m.name)\"")
    println("  ncommands =               $(m.ncommands)")
    println("  nchains =                 $(m.nchains)")
    println("  adapt =                   $(m.adapt)")
    println("  update =                  $(m.update)")
    println("  thin =                    $(m.thin)")
    println("  monitor =                 $(m.monitor)")
    println("  deviance =                $(m.deviance)")
    println("  dic =                     $(m.dic)")
    println("  popt =                    $(m.popt)")
    #println("  model =                   $(model)")
    println("  model_file =              $(m.model_file)")
    #println("  data =                    $(data)")
    println("  data_file =               $(m.data_file)")
    #println("  init =                    $(init)")
  end
end

show(io::IO, m::Jagsmodel) = model_show(io, m, false)
showcompact(io::IO, m::Jagsmodel) = model_show(io, m, true)
