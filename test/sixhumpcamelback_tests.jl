# test/sixhumpcamelback_tests.jl
using Test
using NonlinearOptimizationTestFunctions
using Optim

tf = SIXHUMPCAMELBACK_FUNCTION

@testset "Six-Hump Camelback Tests" begin
    @testset "Basic Tests" begin
        @test tf.meta[:name] == "sixhumpcamelback"
        @test tf.meta[:min_value] ≈ -1.031628453489877 atol=1e-6
        @test sixhumpcamelback(tf.meta[:min_position]()) ≈ tf.meta[:min_value] atol=1e-6
        @test tf.meta[:start]() == [0.0, 0.0]
        @test tf.meta[:min_position]() ≈ [-0.08984201368301331, 0.7126564032704135] atol=1e-6
        @test tf.meta[:properties] == Set(["differentiable", "multimodal", "non-convex", "non-separable", "bounded", "continuous"])
        @test tf.meta[:lb]() == [-3.0, -2.0]
        @test tf.meta[:ub]() == [3.0, 2.0]
    end

    @testset "Optimization Tests" begin
        res = optimize(tf.f, tf.meta[:start](), NelderMead(), Optim.Options(iterations=1000))
        @test Optim.minimum(res) ≈ tf.meta[:min_value] atol=1e-3
        @test Optim.minimizer(res) ≈ tf.meta[:min_position]() atol=1e-3
    end
end