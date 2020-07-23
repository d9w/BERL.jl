export step!, run!, log_gen, save_gen

using Logging
using Statistics

function step!(e::Cambrian.Evolution)
    e.gen += 1
    if e.gen > 1
        e.populate(e)
    end
    e.generation(e)
    e.evaluate(e)
    if ((e.cfg["log_gen"] > 0) && mod(e.gen, e.cfg["log_gen"]) == 0)
        BERL.log_gen(e)
    end
    if ((e.cfg["save_gen"] > 0) && mod(e.gen, e.cfg["save_gen"]) == 0)
        save_gen(e)
    end
end

function run!(e::Cambrian.Evolution)
    for i in (e.gen+1):e.cfg["n_gen"]
        BERL.step!(e)
    end
end

function log_gen(e::Cambrian.Evolution)
    maxs = map(i->maximum(i.fitness), e.population)
    evals = e.gen * length(e.population)
    Cambrian.with_logger(e.log) do
        @info Formatting.format("{1} {2:04d} {3} {4:e} {5:e} {6:e} {7:e}",
                                e.id, e.gen, e.text, maximum(maxs),
                                mean(maxs), std(maxs), evals)
    end
    flush(e.log.stream)
end

function save_gen(e::Cambrian.Evolution)
    # save the entire population
    path = Formatting.format("gens/{1}/{2:04d}", e.id, e.gen)
    mkpath(path)
    sort!(e.population)
    for i in eachindex(e.population)
        f = open(Formatting.format("{1}/{2:04d}.dna", path, i), "w+")
        write(f, string(e.population[i]))
        close(f)
    end
end
