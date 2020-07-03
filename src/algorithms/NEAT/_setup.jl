export BERL_NEAT, process

function BERL_NEAT(cfg::Dict, fitness::Function)::Cambrian.Evolution
    evaluate!::Function = e::Evolution -> NEAT_evaluate!(e, fitness)
    selection::Function = i::Array{NEATIndiv} -> i[1]

    if cfg["selection_type"] == "tournament"
        selection =
            i::Array{NEATIndiv} -> NEAT_tournament(i, cfg["tournament_size"])
    elseif cfg["selection_type"] == "random_top"
        selection =
            i::Array{NEATIndiv} -> NEAT_random_top(i, cfg["survival_threshold"])
    else
        throw(ArgumentError("Wrong selection type: " + cfg["selection_type"]))
    end

    populate!::Function = e::Evolution -> NEAT_populate!(e, selection)
    Evolution(NEATIndividual, cfg; evaluate = evaluate!, populate = populate!)
end

function process(i::NEATIndiv, X)
    NeuroEvolution.process(i, X)
end

algorithms["NEAT"]=BERL_NEAT
