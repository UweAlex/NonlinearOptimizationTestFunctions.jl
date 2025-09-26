# test/griewank_tests.jl
# Purpose: Specific tests for the Griewank test function.
# Context: Part of NonlinearOptimizationTestFunctions test suite.
# Last modified: 17. Juli 2025

using Test, NonlinearOptimizationTestFunctions, ForwardDiff

@testset "Griewank Tests" begin
    @test griewank([0.0, 0.0]) ≈ 0.0 atol=1e-6
    @test griewank([1.0, 1.0]) ≈ 0.590177012 atol=5e-4
    @test griewank_gradient([0.0]) ≈ [0.0] atol=1e-6
    @test griewank_gradient([1.0, 1.0]) ≈ [0.6402237698, 0.250694] atol=2e-3
    @test griewank_gradient([1.0, 1.0]) ≈ ForwardDiff.gradient(griewank, [1.0, 1.0]) atol=5e-4
   
end