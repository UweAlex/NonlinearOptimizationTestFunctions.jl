# test/carromtable_tests.jl
using Test
using NonlinearOptimizationTestFunctions: CARROMTABLE_FUNCTION, carromtable
using Optim
using LinearAlgebra

@testset "CarromTable Tests" begin
    tf = CARROMTABLE_FUNCTION
    n = 2

    # Test Metadaten
    @test tf.meta[:name] == "carromtable"
    @test tf.meta[:properties] == Set(["continuous", "partially differentiable", "non-separable", "multimodal", "non-convex", "bounded"])
   
    @test tf.meta[:start]() == [0.0, 0.0]
    @test tf.meta[:min_position]() ≈ [9.646157266348881, 9.646134286497169]
    @test tf.meta[:min_value]() ≈ -24.156815516506536
    @test tf.meta[:lb]() == [-10.0, -10.0]
    @test tf.meta[:ub]() == [10.0, 10.0]

    # Test Funktionswerte
    @test carromtable(tf.meta[:start]()) ≈ -0.246301869964355 atol=1e-6
    @test carromtable(tf.meta[:min_position]()) ≈ -24.156815516506536 atol=1e-6

    # Test Edge Cases
    @test_throws ArgumentError carromtable(Float64[])
    @test_throws ArgumentError carromtable([1.0, 2.0, 3.0])
    @test isnan(carromtable([NaN, 0.0]))
    @test isfinite(carromtable([-10.0, -10.0]))
    @test isfinite(carromtable([10.0, 10.0]))

    # Optimierungstest mit Fminbox(LBFGS())
    start_point = [9.646, 9.646]
    result = optimize(tf.f, tf.gradient!, tf.meta[:lb](), tf.meta[:ub](), start_point, Fminbox(LBFGS()), Optim.Options(f_reltol=1e-6, g_tol=1e-8, iterations=1000))
    minimizer = Optim.minimizer(result)
    minimum_value = Optim.minimum(result)
    global_minima = [
        [9.646157266348881, 9.646134286497169],
        [9.646157266348881, -9.646134286497169],
        [-9.646157266348881, 9.646134286497169],
        [-9.646157266348881, -9.646134286497169]
    ]
    #println("Minimizer: ", minimizer, ", Minimum value: ", minimum_value)
    @test all(tf.meta[:lb]() .<= minimizer .<= tf.meta[:ub]())  # Check bounds
    @test any(min -> norm(minimizer - min) < 0.5, global_minima)  # Relaxed tolerance
    @test minimum_value ≈ -24.156815516506536 atol=1e-3  # Relaxed tolerance
end