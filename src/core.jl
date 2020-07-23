export start_berl, print_metrics

using UUIDs

function start_berl(algo_name::String, env_name::String; env_params...)
    cfg_path = "./src/algorithms/$algo_name/$env_name.yaml"

    if algo_name in ["NEAT", "HyperNEAT", "CPPN"]
        cfg = NeuroEvolution.get_config(cfg_path)
    else
        cfg = CartesianGeneticProgramming.get_config(cfg_path)
    end

    for (k, v) in pairs(env_params)
        cfg[string(k)] = v
    end

    # Create and setup the environment
    env::BERLenv = environments[env_name](cfg)
    cfg["id"] = "$(algo_name)_$(env.name)_$(string(UUIDs.uuid4()))"
    println(cfg["id"])
    # Fitness function
    fit::Function = i::Cambrian.Individual -> fitness(i, env)

    # Create evolution
    e::Cambrian.Evolution = algorithms[algo_name](cfg, fit)
    # e.logger = CambrianLogger(string("logs/", e.id, ".log"))

    val, t, bytes, gctime, memallocs = @timed BERL.run!(e, env)
    best = sort(e.population)[end]

    metrics = Dict()
    metrics["id"]=cfg["id"]
    metrics["Algorithm"]=algo_name
    metrics["Environment"]= get(cfg, "gym_env", get(cfg, "atari_game", env_name))
    metrics["Best fitness"]=best.fitness[1]
    metrics["Best indiv"]=best
    metrics["Run time"]=t
    metrics["Memory allocated"]=bytes

    metrics
end

function print_metrics(m)
    println("> ", m["Algorithm"], " | ", m["Environment"])
    println(" - Final fitness: ", m["Best fitness"])
    println(" - Run time: ", m["Run time"], "s")
    println(" - Memory allocated: ", m["Memory allocated"], " bytes")
end
