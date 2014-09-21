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
  init::Array{Dict{ASCIIString,Any},1}
  init_file_array::Array{ASCIIString, 1}
end

function Jagsmodel(;name::String="Noname", nchains::Number=4,
  adapt::Number=1000, update::Number=10000, thin::Number=10,
  monitor::Dict=Dict(), deviance::Bool=false,
  dic::Bool=false, popt::Bool=false,
  jags_file::String="",
  model::String="", model_file::String="",
  data::Dict{ASCIIString, Any}=Dict{ASCIIString, Any}(), 
  data_file::String="",
  init::Array{Dict{ASCIIString,Any},1}=[], 
  init_file_array::Vector{String}=String[],
  updatedatafile::Bool=true,
  updateinitfiles::Bool=true)
  
  if length(model) > 0
    update_model_file("$(name).bugs", strip(model))
  end
  
  if (updatedatafile || !isfile("$(name)-data.R")) && length(keys(data)) > 0
    print("\nCreating data file $(name)-data.R: ")
    @time update_R_file("$(name)-data.R", data)
  else
    println("\nData file ($(name)-data.R) not updated.")
  end
  
  for i in 1:nchains
    if length(init) == nchains
      if (updateinitfiles || !isfile("$(name)-inits$(i).R")) && length(keys(init[i])) > 0
        print("Creating init files $(name)-inits$(i).R: ")
        @time update_R_file("$(name)-inits$(i).R", init[i])
      else
        println("Init files ($(name)-init$(i).R) not updated.")
      end
    else
      if (updateinitfiles || !isfile("$(name)-inits$(i).R")) && length(keys(init[1])) > 0
        if i == 1
          println("\nLength of init array is not equal to nchains,")
          println("the first element will used for all chains.\n")
          print("Creating init files $(name)-inits$(i).R: ")
          @time update_R_file("$(name)-inits$(i).R", init[1])
        else
          print("Creating init files $(name)-inits$(i).R: ")
          @time run(`cp "$(name)-inits$(1).R" "$(name)-inits$(i).R"`)
        end
      else
        println("Init files ($(name)-init$(i).R) not updated.")
      end
    end
  end
  
  if length(monitor) == 0 && length(init) > 0
    for entry in init
      monitor = merge(monitor, [entry[1] => true])
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

function update_jags_file(model::Jagsmodel)
  jagsstr = "/*\n\tGenerated $(model.name).jags command file\n*/\n"
    if model.deviance || model.dic || model.popt
      jagsstr = jagsstr*"load dic\n"
    end
  jagsstr = jagsstr*"model in $(model.model_file)\n"
  jagsstr = jagsstr*"data in $(model.data_file)\n"
  jagsstr = jagsstr*"compile, nchains($(model.nchains))\n"
  for i in 1:model.nchains
    fname = model.init_file_array[i]
    jagsstr = jagsstr*"parameters in $(fname), chain($(i))\n"
  end
  jagsstr = jagsstr*"initialize\n"
  jagsstr = jagsstr*"update $(model.adapt)\n"
  if model.deviance
    jagsstr = jagsstr*"monitor deviance\n"
  end
  if model.dic
    jagsstr = jagsstr*"monitor pD\n"
    jagsstr = jagsstr*"monitor pD, type(mean)\n"
  end
  if model.popt
    jagsstr = jagsstr*"monitor popt, type(mean)\n"
  end
  for entry in model.monitor
    if entry[2]
      jagsstr = jagsstr*"monitor $(string(entry[1])), thin(1)\n"
    end
  end
  jagsstr = jagsstr*"update $(model.update)\n"
  jagsstr = jagsstr*"coda *\n"
  jagsstr = jagsstr*"exit\n"
  update_model_file(model.jags_file, jagsstr)
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
  else
    println("\nFile $(file) not updated.")
  end
end

function update_R_file(file::String, dct::Dict{ASCIIString, Any}; replaceNaNs::Bool=true)
  isfile(file) && rm(file)
  strmout = open(file, "w")
  
  str = ""
  for entry in dct
    str = "\""*entry[1]*"\""*" <- "
    val = entry[2]
    if replaceNaNs && true in isnan(entry[2])
      val = convert(DataArray, entry[2])
      for i in 1:length(val)
        if isnan(val[i])
          val[i] = NA
        end
      end
    end
    if length(val)==1 && length(size(val))==0
      # Scalar
      str = str*"$(val)\n"
    elseif length(val)>1 && length(size(val))==1
      # Vector
      str = str*"structure(c("
      for i in 1:length(val)
        str = str*"$(val[i])"
        if i < length(val)
          str = str*", "
        end
      end
      str = str*"), .Dim=c($(length(val))))\n"
    elseif length(val)>1 && length(size(val))>1
      # Array
      str = str*"structure(c("
      for i in 1:length(val)
        str = str*"$(val[i])"
        if i < length(val)
          str = str*", "
        end
      end
      dimstr = "c"*string(size(val))
      str = str*"), .Dim=$(dimstr))\n"
    end
    write(strmout, str)
  end
  close(strmout)
end

function model_show(io::IO, m::Jagsmodel, compact::Bool=false)
  if compact==true
    println("Jagsmodel(", m.name, m.nchains, m.adapt, m.update,
      m.thin, m.monitor, m.model_file, m.init_file_array, m.data_file)
  else
    fstr = "["
    for i in 1:m.nchains
      fstr = fstr*"\""*m.init_file_array[i]*"\""
      if i < m.nchains
        fstr = fstr*", "
      end
    end
    fstr = fstr*"]"
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
    println("  init_file_array =         $(fstr)")
    #println("  data =                    $(data)")
    println("  data_file =               \"$(m.data_file)\"")
  end
end

show(io::IO, m::Jagsmodel) = model_show(io, m, false)
showcompact(io::IO, m::Jagsmodel) = model_show(io, m, true)
