export BERL_CGP, process

function BERL_CGP(cfg::Dict, fitness::Function)::Cambrian.Evolution
    eval = evo -> Cambrian.fitness_evaluate!(evo; fitness=fitness)

    e = Cambrian.Evolution(
        CGPInd,
        cfg;
        populate = cgp_populate!,
        evaluate = eval,
    )
    e
end

function cgp_populate!(evo::Cambrian.Evolution)
    mutation = i::CGPInd -> goldman_mutate(evo.cfg, i)
    Cambrian.oneplus_populate!(evo; mutation = mutation, reset_expert = true)
end

function process(i::CGPInd, X)
    CartesianGeneticProgramming.process(i, X)
end

algorithms["CGP"]=BERL_CGP
