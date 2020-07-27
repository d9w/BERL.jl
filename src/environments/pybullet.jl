using CartesianGeneticProgramming
using PyCall
using Cambrian
using ArgParse
import Distances
import Random
import Formatting
import Base.GC


```
Continuous gym problems using pybullet
```

"Gym BERL environment"
mutable struct BulletEnv <: BERLenv
    name::String
    memory::Array # Array of storable data
    gym
    pybullet
    env_name
    gen
    n_steps::Int64
end

environments["pybullet"]=BulletEnv

function BulletEnv(cfg::Dict)
    pybullet_envs = pyimport("pybullet_envs")
    gym = pyimport("gym")
    cfg["env"] = get!(cfg, "gym_env", "AntBulletEnv-v0")
    env = gym.make(cfg["env"])
    cfg["n_out"] = length(env.action_space.sample())
    cfg["n_in"] = length(env.observation_space.sample())
    gen = get!(cfg, "seed", 0)
    Random.seed!(gen)
    cfg["nsteps"] = 0

    cfg["env"]=

    BulletEnv(cfg["env"], [], gym, pybullet_envs, cfg["env"], gen, 0)
end

"Returns the fitness of one Cambrian Individual in this environment"
function fitness(indiv::Cambrian.Individual, env::GymEnv)
    game = env.gym.make(env.env_name)
    game.seed(env.gen)
    obs = game.reset()
    total_reward = 0.0
    done = false

    max_obs = 2*pi

    while ~done
        action = process(indiv, obs ./ max_obs)
        obs, reward, done, _ = game.step(action)
        newmax = maximum(abs.(obs))
        if newmax > max_obs
            println("Increased max_obs from ", max_obs, " to ", newmax)
            max_obs = newmax
        end
        total_reward += reward
        env.n_steps += 1
    end

    game.close()
    game = nothing
    Base.GC.gc()
    [total_reward]
end

"Sets up the env for the next generation"
function new_gen!(env::GymEnv, cfg::Dict=nothing)
    env.gen += 1
end
