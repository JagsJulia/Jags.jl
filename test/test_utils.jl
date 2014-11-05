function clean_dir(model::Jagsmodel)
  isfile(Pkg.dir(model.tmpdir, "$(model.name)-data.R")) &&
    rm(Pkg.dir(model.tmpdir, "$(model.name)-data.R"));
  isfile(Pkg.dir(model.tmpdir, "$(model.name)-run.log")) &&
    rm(Pkg.dir(model.tmpdir, "$(model.name)-run.log"));
  isfile(Pkg.dir(model.tmpdir, "$(model.name).bugs")) &&
    rm(Pkg.dir(model.tmpdir, "$(model.name).bugs"));
  for i in 1:model.ncommands
    isfile(Pkg.dir(model.tmpdir, "$(model.name)-data.R")) &&
      rm(Pkg.dir(model.tmpdir, "$(model.name)-cmd$(i)-chain0.txt"));
    isfile(Pkg.dir(model.tmpdir, "$(model.name)-cmd$(i)-index0.txt")) &&
      rm(Pkg.dir(model.tmpdir, "$(model.name)-cmd$(i)-index0.txt"));
    isfile(Pkg.dir(model.tmpdir, "$(model.name)-cmd$(i)-table0.txt")) &&
      rm(Pkg.dir(model.tmpdir, "$(model.name)-cmd$(i)-table0.txt"));
    isfile(Pkg.dir(model.tmpdir, "$(model.name)-cmd$(i)-index.txt")) &&
      rm(Pkg.dir(model.tmpdir, "$(model.name)-cmd$(i)-index.txt"));
    isfile(Pkg.dir(model.tmpdir, "$(model.name)-cmd$(i).jags")) &&
      rm(Pkg.dir(model.tmpdir, "$(model.name)-cmd$(i).jags"));
    for j in 0:max(model.nchains, model.ncommands)
      isfile(Pkg.dir(model.tmpdir, "$(model.name)-inits$(j).R")) &&
        rm(Pkg.dir(model.tmpdir, "$(model.name)-inits$(j).R"));
      isfile(Pkg.dir(model.tmpdir, "$(model.name)-cmd$(i)-chain$(j).txt")) &&
        rm(Pkg.dir(model.tmpdir, "$(model.name)-cmd$(i)-chain$(j).txt"));
    end
  end
end