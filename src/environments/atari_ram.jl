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

environments["atari_ram"]=AtariEnv
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
function fitness(indiv::Cambrian.Individual, env::AtariEnv; seed=0, max_frames=18000)
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
