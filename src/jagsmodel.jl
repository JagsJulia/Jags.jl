import Base: show, showcompact

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
  data::Dict{String,Any}
  data_file::String
  init::Array{Dict{String,Any},1}
  command::Array{Base.AbstractCmd, 1}
  tmpdir::String
end

function Jagsmodel(;
  name::String="Noname", 
  model::String="", 
  model_file::String="",
  ncommands::Int=1,
  nchains::Int=4,
  adapt::Int=1000,
  update::Int=10000,
  thin::Int=10,
  monitor=Dict{String,Any}(), 
  deviance::Bool=false,
  dic::Bool=false,
  popt::Bool=false,
  updatejagsfile::Bool=true,
  pdir::String=pwd())
  
  cd(pdir)
  
  tmpdir = Pkg.dir(pdir, "tmp")
  if !isdir(tmpdir)
    mkdir(tmpdir)
  end
  
  # Check if .bugs file needs to be updated.
  if length(model) > 0
    update_bugs_file(Pkg.dir(tmpdir, "$(name).bugs"), strip(model))
  elseif length(model) == 0 && length(model_file) >0 && isfile(model_file)
    cp(model_file, Pkg.dir(tmpdir, "$(name).bugs"))
  else
    println("No proper model defined.")
  end
  model_file = "$(name).bugs"
  
  # Remove old files created by previous runs
  for i in 1:ncommands
    isfile(Pkg.dir(tmpdir, "$(name)-cmd$(i)-index0.txt")) &&
      rm(Pkg.dir(tmpdir, "$(name)-cmd$(i)-index0.txt"));
    isfile(Pkg.dir(tmpdir, "$(name)-cmd$(i)-table0.txt")) &&
      rm(Pkg.dir(tmpdir, "$(name)-cmd$(i)-table0.txt"));
    for j in 0:nchains
       isfile(Pkg.dir(tmpdir, "$(name)-cmd$(i)-chain$(j).R")) &&
        rm(Pkg.dir(tmpdir, "$(name)-cmd$(i)-chain$(j).R"));
    end
  end
  
  # Create the command array which will be executed in parallel
  cmdarray = fill(``, ncommands)
  for i in 1:ncommands
    jfile = "$(name)-cmd$(i).jags"
    cmdarray[i] = @static is_windows() ? `cmd /c jags $(jfile)` : `jags $(jfile)`
  end

  # DIC needs at least 2 chains
  if (dic || popt) && nchains < 2
    nchains = 2
  end

  data = Dict{String, Any}()
  init = Dict{String, Any}[]

  if length(monitor) == 0
    println("No monitors defined!")
  end
  
  data_file = "$(name)-data.R"
  
  jm = Jagsmodel(name,
    ncommands, nchains,
    adapt, update, thin, 
    monitor,
    deviance, dic, popt,
    model, model_file, 
    data,
    data_file, 
    init, 
    cmdarray,
    tmpdir);

  if ncommands == 1
    updatejagsfile && update_jags_file(jm)
  else
    for i in 1:ncommands
      updatejagsfile && update_jags_file(jm, i)
    end
  end
  
  jm
end

#### Function to update the bugs, init and data files

function update_bugs_file(file::String, str::String)
  str2 = ""
  if isfile(file)
    str2 = open(readstring, file, "r")
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


#### Function to update the jags file for ncommand == 1

function update_jags_file(model::Jagsmodel)
  jagsstr = "/*\n\tGenerated $(model.name).jags command file\n*/\n"
  if model.deviance || model.dic || model.popt
    jagsstr = jagsstr*"load dic\n"
  end
  jagsstr = jagsstr*"model in $(model.model_file)\n"
  jagsstr = jagsstr*"data in $(model.data_file)\n"
  jagsstr = jagsstr*"compile, nchains($(model.nchains))\n"
  for i in 1:model.nchains
    fname = "$(model.name)-inits$(i).R"
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
  jagsstr = jagsstr*"coda *, stem($(model.name)-cmd1-)\n"
  jagsstr = jagsstr*"exit\n"
  check_jags_file(Pkg.dir(model.tmpdir, "$(model.name)-cmd1.jags"), jagsstr)
end

#### Function to update the jags file for ncommand > 1

function update_jags_file(model::Jagsmodel, cmd::Int)
  m = max(model.nchains, model.ncommands)
  indx = filter(x -> x!=0, [%(i, (m+1)) for i in 1:3m])
  indx = indx[cmd:length(indx)]
  jagsstr = "/*\n\tGenerated $(model.name).jags command file\n*/\n"
  if model.deviance || model.dic || model.popt
    jagsstr = jagsstr*"load dic\n"
  end
  jagsstr = jagsstr*"model in $(model.model_file)\n"
  jagsstr = jagsstr*"data in $(model.data_file)\n"
  jagsstr = jagsstr*"compile, nchains($(model.nchains))\n"
  for i in 1:model.nchains
    fname = "$(model.name)-inits$(indx[i]).R"
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
  jagsstr = jagsstr*"coda *, stem($(model.name)-cmd$(cmd)-)\n"
  jagsstr = jagsstr*"exit\n"
  check_jags_file(Pkg.dir(model.tmpdir, "$(model.name)-cmd$(cmd).jags"), jagsstr)
end

function check_jags_file(file::String, str::String)
  str2 = ""
  if isfile(file)
    str2 = open(readstring, file, "r")
    str != str2 && rm(file)
  end
  if str != str2
    println("File $(file) will be updated.")
    strmout = open(file, "w")
    write(strmout, str)
    close(strmout)
  else
    println("File $(file) not updated.")
  end
end

function model_show(io::IO, m::Jagsmodel, compact::Bool=false)
  if compact==true
    println("Jagsmodel(", m.name, ", ",
      m.ncommands, ", ", m.nchains, ", ",
      m.adapt, ", ", m.update, ", ", m.thin, ", ", 
      m.monitor, ", ",
      m.deviance, ", ", m.dic, ", ", m.popt, ", ",
      m.model_file, ", ", m.data_file, ", ", m.tmpdir, ")")
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
    println("  tmpdir =                  $(m.tmpdir)")
  end
end

show(io::IO, m::Jagsmodel) = model_show(io, m, false)
showcompact(io::IO, m::Jagsmodel) = model_show(io, m, true)
