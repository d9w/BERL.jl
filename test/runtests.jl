using BERL
using Test

function test_berl(a, e; env_params...)
    d = start_berl(a, e; env_params...)
    @test d["Best fitness"] != -Inf
    print_metrics(d)
end

for a in ["CGP", "NEAT"]
    test_berl(a, "gym"; gym_env="MountainCar-v0")

    for e in ["xor", "iris"]
        test_berl(a, e)
    end

end
