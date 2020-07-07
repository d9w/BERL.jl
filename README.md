# BERL.jl

[![Build Status](https://travis-ci.org/d9w/BERL.jl.svg?branch=master)](https://travis-ci.org/d9w/BERL.jl)

Benchmarking Evolutionary Reinforcement Learning (pronounced "barrel"... sort of)

<p align="center">
  <img height="300" width="auto" src="imgs/logo.png">
</p>

A collaborative project for aggregating benchmarks of evolutionary algorithms on common reinforcement learning benchmarks.   
Contribution guidelines are available [here](https://github.com/d9w/BERL.jl/blob/master/CONTRIBUTING.md).

## Features
### Implemented
**Algorithms**:
+ NEAT
+ CGP

**Environments**:
+ Iris classification
+ XOR
+ Gym classic control
+ Atari on RAM

### Future additions
**Algorithms**
+ HyperNEAT (2xfeedforward & recurrent ANNs)
+ CMA-ES (2xfeedforward & recurrent ANNs)
+ population-based REINFORCE
+ AGRN
+ TPG
+ grammatical evolution

**Environments**:
+ mujoco
+ pybullet
+ mario

## Other ideas to integrate
**Customizable fitness**:
+ sum of reward over an episode
+ Novelty?
+ MAP-Elites

**CLI interaction**
+ Parseable arguments

## Run instructions
To run a selection of algorithms on BERL benchmarks, please:
1. Toggle the algorithms and environments you want in the [YAML config files](https://github.com/d9w/BERL.jl/tree/master/run_config).
2. Run 
```
run_berl()
```

To only run a pair of algorithm and environment, you can also use:
```
start_berl(algo_name::String, env_name::String; env_params...)
```
`env_params` are the specific game names (such as "CartPole-v1") when "atari" or "gym" are selected as `env_name`.
