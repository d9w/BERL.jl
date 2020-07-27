using BERL
using YAML
using Test
using Cambrian
using CartesianGeneticProgramming
using NeuroEvolution
using UUIDs
cd("..")

"Tests an environment with CGP"
function test_env(env_name::String; env_params...)
    if env_name == "gym"
        name = string("Gym_", env_params[:gym_env])
    elseif env_name == "atari"
        name = string("Atari_", env_params[:atari_game])
    else
        name = env_name
    end
    @testset "$name" begin
        @test env_name in keys(environments)
        cfg_path = "./src/algorithms/CGP/$env_name.yaml"
        cfg = CartesianGeneticProgramming.get_config(cfg_path)
        cfg["n_population"]=10
        cfg["n_gen"]=10
        for (k, v) in pairs(env_params)
            cfg[string(k)] = v
        end

        # Create and setup the environment
        env::BERLenv = environments[env_name](cfg)
        @test env.name != ""

        ind = CGPInd(cfg)
        f = fitness(ind, env)

        if env_name in ["iris"]
            @test 0 <= f[1] <= 1
        end
        @test typeof(f)==Array{Float64, 1}

        new_gen!(env, cfg)
    end
end

"Tests an algo on XOR"
function test_algo(algo_name::String)
    @testset "$algo_name" begin
        cfg_path = "./src/algorithms/$algo_name/xor.yaml"

        if algo_name in ["NEAT", "HyperNEAT", "CPPN"]
            cfg = NeuroEvolution.get_config(cfg_path)
        else
            cfg = CartesianGeneticProgramming.get_config(cfg_path)
        end
        cfg["n_gen"]=10
        cfg["n_population"]=10

        # Create and setup the environment
        env::BERLenv = environments["xor"](cfg)

        # Fitness function
        fit::Function = i::Cambrian.Individual -> fitness(i, env)
        cfg["id"] = "TestAlgo_$(algo_name)_$(env.name)_$(string(UUIDs.uuid4()))"
        evo = algorithms[algo_name](cfg, fit)
        @test typeof(evo)==Cambrian.Evolution
        @test length(evo.population)>0
    end
end


function test_berl()
    # Algorithms
    algs = []
    for (a, v) in pairs(YAML.load_file("./run_config/algorithms.yaml"))
        if a != "runs"
            test_algo(a)
        end
    end

    # Environments
    envs=[]
    for (e, v) in pairs(YAML.load_file("./run_config/environments.yaml"))
        if e in gym_envs
            d = test_env("gym"; gym_env=e)
        elseif e in atari_envs
            d = test_env("atari"; atari_game=e)
        else
            d = test_env(e)
        end
    end

    # Start BERL
    @testset "Start BERL" begin
        m = start_berl("NEAT", "iris")
        @test typeof(m)==Dict{Any,Any}
        @test m["Best fitness"]>0
        @test m["Run time"]>0
        @test m["Memory allocated"]>0
        print_metrics(m)
    end
end

println("Starting tests")

test_berl()

# run_berl()

# @testset "plot" begin
#     BERLplot("CGP_XOR_f7739035-ba96-4400-b9bf-0492f6ec1da0")
#     BERLplot(["CGP_XOR_f7739035-ba96-4400-b9bf-0492f6ec1da0",
#     "CGP_XOR_ea455af9-9423-452c-8946-f67bf39a7da4"]; name="test.svg")
# end
