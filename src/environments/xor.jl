export XorEnv, fitness, new_gen!

using NeuroEvolution

"Random BERL environment: returns random fitness"
mutable struct XorEnv <: BERLenv
    name::String
    memory::Array # Array of storable data
    X::Array{Array{Float64}}
    y::Array{Array{Float64}}
end

environments["xor"]=XorEnv

function XorEnv(cfg::Dict)
    cfg["env"]="XOR"
    cfg["n_in"]=2
    cfg["n_out"]=1
    X, y = xor_dataset(2, 100)
    XorEnv("XOR", [], X, y)
end


"Returns the fitness of one Cambrian Individual in this environment"
function fitness(indiv::Cambrian.Individual, env::XorEnv)
    y_pred = []
    for x in env.X
        push!(y_pred, process(indiv, x))
    end
    [sum(log_fitness.(env.y, y_pred)) / length(env.X)]
end

"Sets up the env for the next generation"
function new_gen!(env::XorEnv, cfg::Dict=nothing)
    env.X, env.y = xor_dataset(2, 100) # Generate new data
end


## Utils
function xor(a::Float64, b::Float64)
    if a + b == 1
        1.
    else
        0.
    end
end

"Array to array XOR"
function xor(a::Array{Float64})
    v = a[1]
    for i in 2:length(a)
        v = xor(v, a[i])
    end
    [v]
end

function rand_bin(len::Int64)
    1.0 * rand(0:1, len)
end

function xor_dataset(len::Int64, n_records::Int64)
    X::Array{Array{Float64}}=[]
    y::Array{Array{Float64}}=[]
    for i in 1:n_records
        l = rand_bin(len)
        push!(X, l)
        push!(y, xor(l))
    end
    X, y
end

function log_loss(y_true::Float64, y_pred::Float64)
    y_pred = maximum([minimum([y_pred, 1-10^-15]), 10^-15])
    if y_true == 1.0
        -log(y_pred)
    else
        -log(1-y_pred)
    end
end

function log_loss(y_true::Int64, y_pred::Int64)
    log_loss(float(y_true), float(y_pred))
end

function log_loss(y_true::Array, y_pred::Array)
    log_loss(y_true[1], y_pred[1])
end

function log_fitness(y_true, y_pred)
    max_loss = log_loss(y_true, 1 .- y_true)
    max_loss - log_loss(y_true, y_pred)
end
