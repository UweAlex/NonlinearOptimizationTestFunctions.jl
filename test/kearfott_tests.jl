using Test, NonlinearOptimizationTestFunctions, Optim

@testset "Kearfott Function Tests" begin
    tf = NonlinearOptimizationTestFunctions.KEARFOTT_FUNCTION
    n = 2
    start = [1.0, 1.0]  # Alternativer Startpunkt, da [0.0, 0.0] ein stationärer Punkt ist
    min_pos = tf.meta[:min_position](n)
    @test tf.meta[:name] == "kearfott"
    @test "multimodal" in tf.meta[:properties]
    @test "non-separable" in tf.meta[:properties]
    @test isapprox(tf.f(min_pos), tf.meta[:min_value], atol=1e-10)
    @test isnan(tf.f(fill(NaN, n)))
    @test isnan(tf.f(fill(Inf, n)))
    @test isfinite(tf.f(fill(1e-308, n)))
    @test_throws ArgumentError tf.f(Float64[])
    @test_throws ArgumentError tf.f(zeros(3))
    result = optimize(tf.f, tf.gradient!, start, LBFGS(), Optim.Options(f_reltol=1e-6))
    min_found = Optim.minimizer(result)
    @test isapprox(tf.f(min_found), tf.meta[:min_value], atol=1e-6)
end