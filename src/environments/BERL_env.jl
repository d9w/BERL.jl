export BERLenv, RandomEnv, setup!, fitness, new_gen!

abstract type BERLenv end

"Random BERL environment: returns random fitness"
mutable struct RandomEnv <: BERLenv
    name::String
    memory::Array # Array of storable data
end

"Sets up the environment (load data etc)"
function RandomEnv(cfg::Dict)
    RandomEnv("Random", [])
end

"Returns the fitness of one Cambrian Individual in this environment"
function fitness(indiv::Cambrian.Individual, env::BERLenv)
    rand(length(indiv.fitness))
end

"Sets up the env for the next generation"
function new_gen!(env::BERLenv, cfg::Dict=nothing)
    push!(env.memory, length(env.memory))
end
