# BERL.jl

[![Build Status](https://travis-ci.org/d9w/BERL.jl.svg?branch=master)](https://travis-ci.org/d9w/BERL.jl)

Benchmarking Evolutionary Reinforcement Learning (pronounced "barrel"... sort of)

<p align="center">
  <img height="300" width="auto" src="imgs/logo.png">
</p>

A collaborative project for aggregating benchmarks of evolutionary algorithms on common reinforcement learning benchmarks.   
Contribution guidelines are available [here](https://github.com/d9w/BERL.jl/blob/master/CONTRIBUTING.md).

Algorithms:
+ NEAT
+ HyperNEAT (2xfeedforward & recurrent ANNs)
+ CMA-ES (2xfeedforward & recurrent ANNs)
+ population-based REINFORCE
+ CGP
+ AGRN
+ TPG
+ grammatical evolution

Environments:
+ Gym classic control
+ mujoco
+ pybullet
+ mario

Fitness:
+ sum of reward over an episode
+ Novelty?
+ MAP-Elites
