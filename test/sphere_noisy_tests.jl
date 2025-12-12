# test/sphere_noisy_tests.jl

using Test, NonlinearOptimizationTestFunctions
@testset "sphere_noisy" begin
    tf = SPHERE_NOISY_FUNCTION
    @test tf.meta[:name] == basename("src/functions/sphere_noisy.jl")[1:end-3]
    @test has_property(tf, "continuous")
    @test has_property(tf, "separable")
    @test has_property(tf, "scalable")
    @test has_property(tf, "convex")
    @test has_property(tf, "has_noise")

    n = tf.meta[:default_n]
    @test n >= 2

    start_point = tf.meta[:start](n)
    @test length(start_point) == n
    @test all(start_point .== 0)

    min_pos = tf.meta[:min_position](n)
    f_min = tf.f(min_pos)
    @test f_min >= 0 && f_min < 1  # Für [0,1)-Noise
end