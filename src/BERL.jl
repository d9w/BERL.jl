module BERL

using Cambrian
using NeuroEvolution
using CartesianGeneticProgramming
atari_envs=[]
gym_envs=[]

algs = ["CGP", "NEAT"]
envs = ["xor", "iris", "gym"] # pybullet, atari_ram

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
include("berl_run.jl")

end # module
