# test/griewank_tests.jl
# Purpose: Specific tests for the Griewank test function.
# Context: Part of NonlinearOptimizationTestFunctionsInJulia test suite.
# Last modified: 17. Juli 2025

using Test, NonlinearOptimizationTestFunctionsInJulia, ForwardDiff, Optim

@testset "Griewank Tests" begin
    @test griewank([0.0, 0.0]) ≈ 0.0 atol=1e-6
    @test griewank([1.0, 1.0]) ≈ 0.590177012 atol=5e-4
    @test griewank_gradient([0.0]) ≈ [0.0] atol=1e-6
    @test griewank_gradient([1.0, 1.0]) ≈ [0.6402237698, 0.250694] atol=2e-3
    @test griewank_gradient([1.0, 1.0]) ≈ ForwardDiff.gradient(griewank, [1.0, 1.0]) atol=5e-4
    @testset "Optimization Tests" begin
        start = GRIEWANK_FUNCTION.meta[:start](2)
        result = optimize(GRIEWANK_FUNCTION.f, GRIEWANK_FUNCTION.gradient!, start, LBFGS(), Optim.Options(f_reltol=1e-6, iterations=10000))
        @test Optim.minimum(result) < 1e-3
        @test Optim.minimizer(result) ≈ GRIEWANK_FUNCTION.meta[:min_position](2) atol=1e-3
    end
end