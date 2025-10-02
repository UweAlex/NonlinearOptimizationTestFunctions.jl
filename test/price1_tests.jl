# test/price1_tests.jl
using Test, NonlinearOptimizationTestFunctions

@testset "price1" begin
    tf = PRICE1_FUNCTION
    
    # Meta-Informationen
    @test tf.meta[:name] == "price1"
    @test tf.meta[:properties_source] == "Jamil & Yang (2013)"
    @test tf.meta[:source] == "Price (1977)"
    
    # Properties
    @test has_property(tf, "continuous")
    @test has_property(tf, "separable")
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
    @test tf.f(start_point) ≈ 32.0 atol=1e-3  # (|1| - 5)^2 + (|1| - 5)^2 = 16 + 16 = 32
    
    # Globale Minima - alle vier Ecken testen
    min_positions = [
        [5.0, 5.0],
        [5.0, -5.0],
        [-5.0, 5.0],
        [-5.0, -5.0]
    ]
    
    for pos in min_positions
        @test tf.f(pos) ≈ 0.0 atol=1e-8
    end
    
    # Minimum aus Meta
    min_pos = tf.meta[:min_position]()
    @test tf.f(min_pos) ≈ tf.meta[:min_value]() atol=1e-8
    @test tf.meta[:min_value]() == 0.0
    
    # Bounds
    lb = tf.meta[:lb]()
    ub = tf.meta[:ub]()
    @test lb == [-500.0, -500.0]
    @test ub == [500.0, 500.0]
    
   grad_test = tf.grad([1.0, 1.0])
grad_test2 = tf.grad([6.0, 6.0])
grad_min = tf.grad([5.0, 5.0])
@test all(isnan.(tf.grad([NaN, 1.0])))
@test all(isinf.(tf.grad([Inf, 1.0])))
    
    # Separabilität prüfen - Funktion ist separabel
    x1, x2 = 3.0, 7.0
    @test tf.f([x1, x2]) ≈ (abs(x1) - 5)^2 + (abs(x2) - 5)^2 atol=1e-8
    
    # Symmetrie prüfen - Funktion ist symmetrisch bzgl. Vorzeichen
    @test tf.f([3.0, 4.0]) ≈ tf.f([-3.0, 4.0]) atol=1e-8
    @test tf.f([3.0, 4.0]) ≈ tf.f([3.0, -4.0]) atol=1e-8
    @test tf.f([3.0, 4.0]) ≈ tf.f([-3.0, -4.0]) atol=1e-8
end