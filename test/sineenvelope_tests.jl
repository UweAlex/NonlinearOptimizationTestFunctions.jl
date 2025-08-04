using Test, Optim
using NonlinearOptimizationTestFunctions: SINEENVELOPE_FUNCTION, sineenvelope

@testset "SineEnvelope Tests" begin
    tf = SINEENVELOPE_FUNCTION
    n = 2
    @test_throws ArgumentError sineenvelope(Float64[])
    @test_throws ArgumentError sineenvelope([1.0, 2.0, 3.0])
    @test isnan(sineenvelope([NaN, 1.0]))
    @test isinf(sineenvelope([Inf, 1.0]))
    @test isfinite(sineenvelope([1e-308, 1e-308]))
    @test sineenvelope(tf.meta[:min_position](n)) ≈ tf.meta[:min_value] atol=1e-6
    @test sineenvelope(tf.meta[:start](n)) ≈ -2.907797035532654 atol=1e-3
    @test tf.meta[:name] == "sineenvelope"
    @test tf.meta[:start](n) == [1.0, 1.0]
    @test tf.meta[:min_position](n) == [1.538637632553666, 1.1370027579926583]  # Aktualisiertes Minimum
    @test tf.meta[:min_value] ≈ -3.7379439163636463 atol=1e-6
    @test tf.meta[:lb](n) == [-100.0, -100.0]
    @test tf.meta[:ub](n) == [100.0, 100.0]
    @test tf.meta[:in_molga_smutnicki_2005] == true
    @test Set(tf.meta[:properties]) == Set(["multimodal", "differentiable", "non-separable"])
    @testset "Optimization Tests" begin
        start = tf.meta[:min_position](n) + 0.01 * randn(n)  # Start near minimum
        result = optimize(tf.f, tf.gradient!, start, LBFGS(), Optim.Options(f_reltol=1e-6))
        @test Optim.minimum(result) ≈ tf.meta[:min_value] atol=1e-5
        @test Optim.minimizer(result) ≈ tf.meta[:min_position](n) atol=0.01  # Ursprüngliche Toleranz
    end
end