#test/bohachevsky3_tests.jl

using Test
using NonlinearOptimizationTestFunctions: bohachevsky3
using NonlinearOptimizationTestFunctions: bohachevsky3_gradient
using NonlinearOptimizationTestFunctions: BOHACHEVSKY3_FUNCTION

tf = BOHACHEVSKY3_FUNCTION

@testset "bohachevsky3_tests.jl" begin
    @test tf.meta[:name] == "bohachevsky3"
    @test tf.meta[:min_value] == 0.0
    @test tf.meta[:min_position]() == [0.0, 0.0]
    @test "bounded" in tf.meta[:properties]
    @test tf.meta[:in_molga_smutnicki_2005] == false

    # Function value at minimum
    @test isapprox(tf.f(tf.meta[:min_position]()), tf.meta[:min_value], atol=1e-6)

    # Function value at start point
    start = tf.meta[:start]()
    @test isapprox(tf.f(start), 0.0003 - 0.3 * cos(3 * π * 0.01 + 4 * π * 0.01) + 0.3, atol=1e-6)

    # Gradient at minimum (should be near zero)
    @test all(isapprox.(tf.grad(tf.meta[:min_position]()), [0.0, 0.0], atol=1e-3))

    # Edge cases
    @test_throws ArgumentError tf.f(Float64[])
    @test isnan(tf.f([NaN, NaN]))
    @test isinf(tf.f([Inf, Inf]))  # Expect Inf due to quadratic terms
    @test isfinite(tf.f([1e-308, 1e-308]))
    @test_throws ArgumentError tf.f([0.0])  # Wrong dimension
    @test_throws ArgumentError tf.f([0.0, 0.0, 0.0])  # Wrong dimension

    # Optimization test with Optim.jl (using LBFGS, start near minimum to avoid local minima)
    result = optimize(tf.f, tf.gradient!, tf.meta[:lb](), tf.meta[:ub](), start, Fminbox(LBFGS()), Optim.Options(f_reltol=1e-6))
    @test isapprox(Optim.minimum(result), tf.meta[:min_value], atol=1e-6)
    @test all(isapprox.(Optim.minimizer(result), tf.meta[:min_position](), atol=1e-3))
end