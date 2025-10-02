# test/price2_tests.jl
using Test, NonlinearOptimizationTestFunctions

@testset "price2" begin
    tf = PRICE2_FUNCTION
    
    # Meta-Informationen
    @test tf.meta[:name] == "price2"
    @test tf.meta[:properties_source] == "Jamil & Yang (2013)"
    @test tf.meta[:source] == "Price (1977)"
    
    # Properties
    @test has_property(tf, "continuous")
    @test has_property(tf, "differentiable")
    @test has_property(tf, "multimodal")
    
    # Dimensionen
    @test_throws ArgumentError tf.f(Float64[])
    @test_throws ArgumentError tf.f([1.0])
    @test_throws ArgumentError tf.f([1.0, 2.0, 3.0])
    
    # NaN/Inf Behandlung
    @test isnan(tf.f([NaN, 1.0]))
    @test isnan(tf.f([1.0, NaN]))
    @test isinf(tf.f([Inf, 1.0]))
    @test isinf(tf.f([1.0, Inf]))
    
    # Startpunkt
    start_point = tf.meta[:start]()
    @test length(start_point) == 2
    # f([1,1]) = 1 + sin²(1) + sin²(1) - 0.1*exp(-2)
    expected_start = 1 + 2*sin(1.0)^2 - 0.1*exp(-2.0)
    @test tf.f(start_point) ≈ expected_start atol=1e-3
    
    # Globales Minimum
    min_pos = tf.meta[:min_position]()
    @test tf.f(min_pos) ≈ tf.meta[:min_value]() atol=1e-8
    @test tf.meta[:min_value]() == 0.9
    
    # Exakte Berechnung: f([0,0]) = 1 + 0 + 0 - 0.1*exp(0) = 1 - 0.1 = 0.9
    @test tf.f([0.0, 0.0]) ≈ 0.9 atol=1e-8
    
    # Bounds
    lb = tf.meta[:lb]()
    ub = tf.meta[:ub]()
    @test lb == [-10.0, -10.0]
    @test ub == [10.0, 10.0]
    
    # Gradient-Tests
    # Bei Minimum [0, 0]: gradient sollte [0, 0] sein
    grad_min = tf.grad([0.0, 0.0])
    @test grad_min ≈ [0.0, 0.0] atol=1e-8
    
    # Bei x = [π/2, 0]: sin(π/2) = 1, cos(π/2) = 0
    # ∂f/∂x₁ = 2*1*0 + 0.2*(π/2)*exp(-(π/2)²) = 0.2*(π/2)*exp(-π²/4)
    # ∂f/∂x₂ = 2*0*1 + 0 = 0
    x_test = [π/2, 0.0]
    grad_test = tf.grad(x_test)
    expected_grad1 = 0.2 * (π/2) * exp(-(π/2)^2)
    @test grad_test[1] ≈ expected_grad1 atol=1e-8
    @test grad_test[2] ≈ 0.0 atol=1e-8
    
    # Gradient NaN/Inf Behandlung
    @test all(isnan.(tf.grad([NaN, 1.0])))
    @test all(isinf.(tf.grad([Inf, 1.0])))
    
    # Symmetrie prüfen - Funktion ist symmetrisch bzgl. Vorzeichen
    @test tf.f([1.0, 2.0]) ≈ tf.f([-1.0, 2.0]) atol=1e-8
    @test tf.f([1.0, 2.0]) ≈ tf.f([1.0, -2.0]) atol=1e-8
    @test tf.f([1.0, 2.0]) ≈ tf.f([-1.0, -2.0]) atol=1e-8
    
   
    # Funktionswerte an verschiedenen Punkten
    # An Grenzen des Suchraums
    @test tf.f([10.0, 10.0]) > 0.9  # Sollte größer als Minimum sein
    @test tf.f([-10.0, -10.0]) > 0.9
end