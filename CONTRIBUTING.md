# BERL Framework: How to contribute

## Adding an algorithm

Each algorithm is expected to be contained in a directory named after itself.   
As an example, adding an algorithm called NAME from the NAMEPACKAGE package will require a `NAME` repository containing:

### 1. A `_setup.jl` file

This file should include:
- A Cambrian.Evolution creation function
```
function BERL_NAME(cfg::Dict, fitness::Function)::Cambrian.Evolution
```
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

### 2. Config files

A YAML configuration file should be included for each benchmark environment, bearing the name of the environment as defined in the global environments dictionary.

## Adding an environment
