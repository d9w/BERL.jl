export run_berl
using YAML

function run_berl()
    # Algorithms
    algs = []
    for (k, v) in pairs(YAML.load_file("../run_config/algorithms.yaml"))
        if v
            push!(algs, k)
        end
    end

    # Environments
    envs=[]
    for (k, v) in pairs(YAML.load_file("../run_config/environments.yaml"))
        if v
            push!(envs, k)
        end
    end

    for e in envs
        for a in algs
            if e in ["Acrobot-v1", "CartPole-v1", "MountainCar-v0", "MountainCarContinuous-v0", "Pendulum-v0"]
                d = start_berl(a, "gym"; gym_env=e)
            else
                d = start_berl(a, e)
            end
            print_metrics(d)
        end
    end
end
