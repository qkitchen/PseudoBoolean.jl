using PseudoBoolean
using Test


include("variable_utils.jl")
include("qubo.jl")

@testset "Testing Test" begin
   @test 2 + 2 == 4
   @test checked()
end
