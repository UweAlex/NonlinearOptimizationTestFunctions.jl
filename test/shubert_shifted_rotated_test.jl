# test/functions/shubert_shifted_rotated_test.jl
# Purpose: Unit tests for shubert_shifted_rotated.jl (Shifted Rotated Shubert, CEC 2014 variant).
# Run with: julia --project=. test/runtests.jl (assuming include in runtests.jl)

using Test
using LinearAlgebra  # Für eventuelle Hilfsfunktionen
using Random         # Für Seed in Tests

# Include the function under test (adjust path as needed)
include("../src/functions/shubert_shifted_rotated.jl")

@testset "Shubert Shifted Rotated" begin
    func_name = "shubert_shifted_rotated"
    
    # Test 1: Error handling for invalid inputs
    @testset "Error Handling" begin
        @test_throws ArgumentError shubert_shifted_rotated(Float64[])  # Empty vector
        @test_throws ArgumentError shubert_shifted_rotated(rand(3))     # Wrong dimension (n=3)
        
        x_nan = [NaN, 0.0]
        @test isnan(shubert_shifted_rotated(x_nan))
        
        x_inf = [Inf, 0.0]
        @test isinf(shubert_shifted_rotated(x_inf))
    end
    
    # Test 2: Basic evaluation (finite value in bounds)
    @testset "Basic Evaluation" begin
        Random.seed!(42)  # Match function's seed for reprod.
        x_valid = randn(2) * 50  # Within [-100,100] approx
        val = shubert_shifted_rotated(x_valid)
        @test !isnan(val)
        @test !isinf(val)
        @test val isa Real
    end
    
    # Test 3: Global minimum verification (at transformed classic position)
    @testset "Global Minimum" begin
        # Dynamically compute transformed position (seed=42, classic x=[4.85805687, 5.48286421])
        tf = SHUBERT_SHIFTED_ROTATED_FUNCTION
        x_min_transformed = tf.meta[:min_position]()  # Uses dynamic calculation
        expected_min = tf.meta[:min_value]()
        
        val = shubert_shifted_rotated(x_min_transformed)
        @test val ≈ expected_min atol=1e-4  # Toleranz für FP-Rundung
        
        # Check bounds compliance
        @test all(-100 .≤ x_min_transformed .≤ 100)
    end
    
    # Test 4: Gradient computation
    @testset "Gradient" begin
        x_test = [0.0, 0.0]
        grad = shubert_shifted_rotated_gradient(x_test)
        @test length(grad) == 2
        @test !any(isnan.(grad))
        @test !any(isinf.(grad))
        @test all(isa.(grad, Real))  # Fixed: isa.(grad, Real) for element-wise check
        
        # Optional: Finite difference approximation check (simple)
        h = 1e-6
        x_fd = x_test .+ [h, 0.0]
        approx_deriv1 = (shubert_shifted_rotated(x_fd) - shubert_shifted_rotated(x_test)) / h
        @test grad[1] ≈ approx_deriv1 atol=1e-3  # Rough check
    end
    
    # Test 5: Properties from TestFunction meta-data
    @testset "Meta-Data Properties" begin
        tf = SHUBERT_SHIFTED_ROTATED_FUNCTION
        @test tf.meta[:name] == "shubert_shifted_rotated"
        @test occursin("non-separable", tf.meta[:description])
        @test tf.meta[:default_n] == 2
        @test all(tf.meta[:lb]() .== -100.0)
        @test all(tf.meta[:ub]() .== 100.0)
        @test tf.meta[:min_value]() ≈ -186.7309088313 atol=1e-6
    end
end

# Optional: Run a quick optimization snippet (requires Optim.jl, comment out if not installed)
# using Optim
# @testset "Quick Optimization" begin
#     bounds = BoxConstraints(tf.meta[:lb](), tf.meta[:ub]())
#     res = optimize(tf.f, bounds, LBFGS(), Optim.Options(iterations=1000); autodiff=:forward)
#     @test res.minimum ≈ tf.meta[:min_value]() atol=1e-2  # Loose, due to multimodality
# end