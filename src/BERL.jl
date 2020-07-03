module BERL

using Cambrian
using NeuroEvolution
using CartesianGeneticProgramming

algs = ["CGP", "NEAT"]
envs = ["xor", "iris"] # pybullet, atari_ram, gym

include("environments/BERL_env.jl")

environments = Dict()
algorithms = Dict()

for e in envs
    include("environments/$e.jl")
end

for a in algs
    include("algorithms/$a/_setup.jl")
end

include("core.jl")

end # module
