using CartesianGeneticProgramming
using Cambrian
using ArcadeLearningEnvironment
using ArgParse
import Random

export AtariEnv, fitness, new_gen!, atari_envs

include("game.jl")

```
Playing Atari games on RAM values

This uses a single Game seed, meaning an unfair deterministic Atari
environment. To evolve using a different game seed per generation, uncomment code in new_gen!
```

"Atari BERL environment"
mutable struct AtariEnv <: BERLenv
    name::String
    memory::Array # Array of storable data
    env_name
    seed
end

environments["atari"]=AtariEnv
atari_envs=["centipede"]

function AtariEnv(cfg::Dict)
    env_name = get!(cfg, "atari_game", "centipede")
    cfg["env"]="Atari - $env_name"
    game = Game(env_name, 0)
    cfg["n_in"] = length(get_ram(game))
    cfg["n_out"] = length(game.actions)
    close!(game)

    AtariEnv(cfg["env"],  [], env_name, 0)
end

"Returns the fitness of one Cambrian Individual in this environment"
function fitness(indiv::Cambrian.Individual, env::AtariEnv)
    game = Game(env.env_name, env.seed)
    reward = 0.0
    frames = 0
    while ~game_over(game.ale)
        output = process(indiv, get_ram(game))
        action = game.actions[argmax(output)]
        reward += act(game.ale, action)
        frames += 1
        if frames > max_frames
            break
        end
    end
    close!(game)
    [reward]
end

"Sets up the env for the next generation"
function new_gen!(env::AtariEnv, cfg::Dict=nothing)
    # env.seed += 1
end






s = ArgParseSettings()
@add_arg_table s begin
    "--cfg"
    help = "configuration script"
    default = "cfg/atari_ram.yaml"
    "--game"
    help = "game rom name"
    default = "centipede"
    "--seed"
    help = "random seed for evolution"
    arg_type = Int
    default = 0
end
args = parse_args(ARGS, s)

cfg = get_config(args["cfg"])
cfg["game"] = args["game"]
Random.seed!(args["seed"])

function play_atari(ind::CGPInd; seed=0, max_frames=18000)
    game = Game(cfg["game"], seed)
    reward = 0.0
    frames = 0
    while ~game_over(game.ale)
        output = process(ind, get_ram(game))
        action = game.actions[argmax(output)]
        reward += act(game.ale, action)
        frames += 1
        if frames > max_frames
            break
        end
    end
    close!(game)
    [reward]
end

function get_params()
    game = Game(cfg["game"], 0)
    nin = length(get_ram(game))
    nout = length(game.actions)
    close!(game)
    nin, nout
end

function populate(evo::Cambrian.Evolution)
    mutation = i::CGPInd->goldman_mutate(cfg, i)
    Cambrian.oneplus_populate!(evo; mutation=mutation, reset_expert=false)
end

function evaluate(evo::Cambrian.Evolution)
    fit = i::CGPInd->play_atari(i; seed=0) # max_frames=min(10*evo.gen, 18000)) #seed=evo.gen,
    Cambrian.fitness_evaluate!(evo; fitness=fit)
end

cfg["n_in"], cfg["n_out"] = get_params()

e = Cambrian.Evolution(CGPInd, cfg; id=string(cfg["game"], "_ram_", args["seed"]),
                       populate=populate,
                       evaluate=evaluate)
Cambrian.run!(e)
best = sort(e.population)[end]
println("Final fitness: ", best.fitness[1])
