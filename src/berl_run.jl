export run_berl
using YAML

function run_berl()
    runs::Int64=0
    # Algorithms
    algs = []
    for (k, v) in pairs(YAML.load_file("./run_config/algorithms.yaml"))
        if k=="runs"
            runs = v
        elseif v
            push!(algs, k)
        end
    end

    # Environments
    envs=[]
    for (k, v) in pairs(YAML.load_file("./run_config/environments.yaml"))
        if v
            push!(envs, k)
        end
    end

    println("Algorithms: ", algs)
    println("Environments: ", envs)
    for e in envs
        for a in algs
            ids::Array{String}=[]
            for r in 1:runs
                if e in gym_envs
                    d = start_berl(a, "gym"; gym_env=e)
                elseif e in atari_envs
                    d = start_berl(a, "atari_ram"; atari_game=e)
                else
                    d = start_berl(a, e)
                end
                d["run"]=r
                print_metrics(d)
                push!(ids, d["id"])
            end
            try
                BERLplot(ids; name="benchmark_$(a)_$e.svg")
            catch

            end
        end
    end
end
