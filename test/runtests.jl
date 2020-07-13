using PseudoBoolean
using Test

@testset "Testing Test" begin
   @test 2 + 2 == 4
   @test checked()
   
end
