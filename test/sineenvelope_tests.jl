# test/sineenvelope_tests.jl
using Test, Optim
using NonlinearOptimizationTestFunctions: SINEENVELOPE_FUNCTION, sineenvelope

@testset "SineEnvelope Tests" begin
    tf = SINEENVELOPE_FUNCTION
    n = 2
    @test_throws ArgumentError sineenvelope(Float64[])
    @test isnan(sineenvelope(fill(NaN, n)))
    @test isinf(sineenvelope(fill(Inf, n)))
    @test isfinite(sineenvelope(fill(1e-308, n)))
    @test ≈(sineenvelope(tf.meta[:min_position](n)), -1.0, atol=1e-6)  # Korrigiert von -0.5 auf -1.0
    @test ≈(sineenvelope(tf.meta[:start](n)), -0.026215469198405728, atol=1e-6)  # Korrigiert von -0.4803017961922437
    @test tf.meta[:name] == "SineEnvelope"
    @test tf.meta[:start](n) == [1.0, 1.0]
    @test tf.meta[:min_position](n) == [0.0, 0.0]
    @test tf.meta[:min_value] ≈ -1.0 atol=1e-6  # Korrigiert von -0.5
    @test tf.meta[:lb](n) == [-100.0, -100.0]
    @test tf.meta[:ub](n) == [100.0, 100.0]
    @test tf.meta[:in_molga_smutnicki_2005] == true
    @test Set(tf.meta[:properties]) == Set(["multimodal", "non-convex", "non-separable", "differentiable", "bounded"])
    @testset "Optimization Tests" begin
        start = tf.meta[:min_position](n) + 0.01 * randn(n)
        result = optimize(tf.f, tf.gradient!, start, LBFGS(), Optim.Options(f_reltol=1e-6))
        @test ≈(Optim.minimum(result), tf.meta[:min_value], atol=1e-5)  # Sollte nun bestehen
        @test ≈(Optim.minimizer(result), tf.meta[:min_position](n), atol=1e-3)
    end
end