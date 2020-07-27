module BERL

using Cambrian
using NeuroEvolution
using CartesianGeneticProgramming
export atari_envs, gym_envs, environments, algorithms
atari_envs=[]
gym_envs=[]

algs = ["CGP", "NEAT", "HyperNEAT"]
envs = ["xor", "iris", "gym", "atari_ram"] # pybullet, atari_ram

include("environments/BERL_env.jl")
include("step.jl")

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
# include("plotting.jl")

end # module
