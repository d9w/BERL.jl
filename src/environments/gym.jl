using PyCall
using Cambrian
import Distances
import Random
import Formatting
import Base.GC

export GymEnv, fitness, new_gen!

import RDatasets

"Iris BERL environment"
mutable struct GymEnv <: BERLenv
    name::String
    memory::Array # Array of storable data
    gym
    env_name
    gen
    n_steps::Int64
end

environments["gym"]=GymEnv

function GymEnv(cfg::Dict)
    env_name = get!(cfg, "gym_env", "MountainCar-v0") # Default mountain car
    cfg["env"]="Gym - $env_name"

    gym = pyimport("gym")
    game = gym.make(env_name)
    cfg["n_out"] = game.action_space.n # length(env.action_space.sample())
    cfg["n_in"] = length(game.observation_space.sample())

    gen = get!(cfg, "seed", 0)
    Random.seed!(gen)

    GymEnv(cfg["env"], [], gym, env_name, gen, 0)
end

"Returns the fitness of one Cambrian Individual in this environment"
function fitness(indiv::Cambrian.Individual, env::GymEnv)
    game = env.gym.make(env.env_name)
    game.seed(env.gen)
    obs = game.reset()
    total_reward = 0.0
    done = false

    max_obs = Float64(max(-minimum(game.observation_space.low),
                          maximum(game.observation_space.high)))

    while ~done
        action = argmax(process(indiv, obs ./ max_obs))-1
        obs, reward, done, _ = game.step(action)
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
    println("New generation")
    env.gen += 1
end
