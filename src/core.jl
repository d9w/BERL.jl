export start_berl, print_metrics

function start_berl(algo_name::String, env_name::String)
    cfg_path = "../src/algorithms/$algo_name/$env_name.yaml"

    if algo_name in ["NEAT", "HyperNEAT", "CPPN"]
        cfg = NeuroEvolution.get_config(cfg_path)
    else
        cfg = CartesianGeneticProgramming.get_config(cfg_path)
    end

    # Create and setup the environment 
    env::BERLenv = environments[env_name](cfg)

    # Fitness function
    fit::Function = i::Cambrian.Individual -> fitness(i, env)

    # Create evolution
    e::Cambrian.Evolution = algorithms[algo_name](cfg, fit)

    Cambrian.run!(e)
    best = sort(e.population)[end]

    metrics = Dict()
    metrics["Algorithm"]=algo_name
    metrics["Environment"]=env_name
    metrics["Best fitness"]=best.fitness[1]

    metrics
end

function print_metrics(m)
    println("> ", m["Algorithm"], " | ", m["Environment"])
    println(" - Final fitness: ", m["Best fitness"])
end
