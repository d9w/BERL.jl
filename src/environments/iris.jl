export IrisEnv, fitness, new_gen!

import RDatasets

"Iris BERL environment"
mutable struct IrisEnv <: BERLenv
    name::String
    memory::Array # Array of storable data
    X::Array{Float64, 2}
    y::Array{Float64, 2}
end

environments["iris"]=IrisEnv

function IrisEnv(cfg::Dict)
    cfg["env"]="Iris"
    cfg["n_in"]=4
    cfg["n_out"]=3
    iris = RDatasets.dataset("datasets", "iris")
    X = convert(Matrix, iris[:, 1:4])'
    X = X ./ maximum(X; dims=2) # normalize
    r = iris[:, 5].refs # labels
    # 1-hot encoding:
    y = zeros(maximum(r), size(X, 2))
    for i in 1:length(r)
        y[r[i], i] = 1.0
    end
    IrisEnv("iris", [], X, y)
end

"Returns the fitness of one Cambrian Individual in this environment"
function fitness(indiv::Cambrian.Individual, env::IrisEnv)
    accuracy = 0.0
    for i in 1:size(env.X, 2)
        out = process(indiv, env.X[:, i])
        if argmax(out) == argmax(env.y[:, i])
            accuracy += 1
        end
    end
    f = [accuracy / size(env.X, 2)]
    try
        Integer.(round.(f))
    catch
        println(f, accuracy, size(env.X, 2))
    end
    f
end

"Sets up the env for the next generation"
function new_gen!(env::IrisEnv, cfg::Dict=nothing)

end
