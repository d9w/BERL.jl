# BERL Framework: How to contribute

Thank you for using BERL, and for taking the time to contribute!

The following is a set of guidelines to ensure seamless integration of your modules into BERL. 

## Adding an algorithm

Each algorithm is expected to be contained in a directory named after itself.   
As an example, adding an algorithm called NAME from the NAMEPACKAGE package will require a `NAME` directory in [algorithms](https://github.com/d9w/BERL.jl/tree/master/src/algorithms) containing:

### 1. A `_setup.jl` file

This file should include:
- A Cambrian.Evolution creation function
```
function BERL_NAME(cfg::Dict, fitness::Function)::Cambrian.Evolution
```
The `fitness` function passed as parameter has the signature `fitness(indiv::Cambrian.Individual)::Array{Float64}`.

- A process function for the Cambrian.AbstractIndividual used in this algorithm
```
function process(i::NAMEInd, X)
    NAMEPACKAGE.process(i, X)
end
```

- A line adding the creation function to the global algorithms dictionary 
```
algorithms["NAME"]=BERL_NAME
```

- An export of the main parts
```
export BERL_NAME, process
```

### 2. Config files

A YAML configuration file should be included for each benchmark environment, bearing the name of the environment as defined in the global environments dictionary.

The default `get_config` function is the one implemented by the CartesianGeneticProgramming package. If another one should be used, please modify the [`start_berl`](https://github.com/d9w/BERL.jl/blob/master/src/core.jl) function to add an `elseif` condition on your algorithm's name as `algo_name`.

### Adding your algorithm to the build
The list of algorithms used in the build is available as `algs` at [BERL.jl](https://github.com/d9w/BERL.jl/blob/master/src/BERL.jl). Please add the name of your algorithm as defined in the directory name.    
To add it to the main run parameters, add a line
```
NAME: false
```
to the [YAML config file](https://github.com/d9w/BERL.jl/tree/master/run_config/algorithms.yaml), with the name used before. Setting it to `false` avoids adding it to every test by default. 

### Examples

The [CGP](https://github.com/d9w/BERL.jl/tree/master/src/algorithms/CGP) and [NEAT](https://github.com/d9w/BERL.jl/tree/master/src/algorithms/NEAT) directories can be used as examples of integrating an external package to BERL.jl.

## Adding an environment

The BERL benchmarks are defined as classes inheriting from the abstract type [`BERLenv`](https://github.com/d9w/BERL.jl/blob/master/src/environments/BERL_env.jl). Each environment is expected to implement a few blocks, here demonstrated with `XorEnv`. These blocks should be in a Julia file named after the environment, in the [environments directory](). Along with any code needed to make the environment run, the following is necessary for the integration into BERL:

### 1. Class
Inherits from BERLenv.    
Contains the environment name, an array for memory, and custom data depending on the environment needs. 
```
mutable struct XorEnv <: BERLenv
    name::String
    memory::Array # Array of storable data
    X::Array{Array{Float64}}
    y::Array{Array{Float64}}
end
```

### 2. Setup function
Sets up the environment and configures the config dictionary passed as argument to fit the problem.      
Returns the environment object.
```
function XorEnv(cfg::Dict)::XorEnv
    cfg["env"]="XOR"
    cfg["n_in"]=2
    cfg["n_out"]=1
    X, y = xor_dataset(2, 100)
    XorEnv("Random", [], X, y)
end
```

### 3. Fitness function
Computes fitnesses from a Cambrian Individual and the environment defined earlier.    
Returns the list of fitnesses.
```
function fitness(indiv::Cambrian.Individual, env::XorEnv)
    y_pred = []
    for x in env.X
        push!(y_pred, process(indiv, x))
    end
    [sum(log_fitness.(env.y, y_pred)) / length(env.X)]
end
```

This is later used to defined the function passed to the algorithm to create the Evolution: 
```
fit::Function = i::Cambrian.Individual -> fitness(i, env)
```

### 4. New generation
Sets up the env for the next generation using the config dictionary set up earlier.     
This function is called after every Cambrian `step!` in the custom `run!` defined for BERL [here](https://github.com/d9w/BERL.jl/blob/master/src/environments/BERL_env.jl).
```
function new_gen!(env::XorEnv, cfg::Dict=nothing)
    env.X, env.y = xor_dataset(2, 100) # Generate new data
end
```

### 5. Making it available
- A line adding the environment class to the global environments dictionary 
```
environments["xor"]=XorEnv
```

- An export of the main parts
```
export  XorEnv, fitness, new_gen!
```

### Adding your environment to the build
The list of environments used in the build is available as `envs` at [BERL.jl](https://github.com/d9w/BERL.jl/blob/master/src/BERL.jl). Please add the name of your environment as defined in the name of the Julia file.    

To add it to the main run parameters, add a line
```
xor: false
```
to the [YAML config file](https://github.com/d9w/BERL.jl/tree/master/run_config/environments.yaml), with the name used before. Setting it to `false` avoids adding it to every test by default. 
