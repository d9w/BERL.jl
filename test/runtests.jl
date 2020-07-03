using BERL
using Test

for a in ["CGP", "NEAT"]
    for e in ["xor", "iris"]
        @testset "$a x $e" begin
            d = start_berl(a, e)
            @test d["Best fitness"] != -Inf
        end
    end
end
