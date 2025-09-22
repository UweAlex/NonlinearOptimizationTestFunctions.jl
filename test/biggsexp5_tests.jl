# test/biggsexp5_tests.jl
# Purpose: Unit tests for the Biggs EXP Function 5 implementation.
# Context: Tests metadata, function values, and edge cases for consistency.
# Last modified: September 22, 2025.

using Test, NonlinearOptimizationTestFunctions

tf = BIGGSEXP5_FUNCTION

@test tf.meta[:name] == "biggsexp5"
@test has_property(tf, "bounded")
@test has_property(tf, "continuous")
@test has_property(tf, "differentiable")
@test has_property(tf, "multimodal")
@test has_property(tf, "non-separable")
@test !has_property(tf, "scalable")
@test length(tf.meta[:properties]) == 5

@test_throws ArgumentError tf.f(Float64[])

start_point = tf.meta[:start]()
@test start_point == [0.01, 0.01, 0.01, 0.01, 0.01]
@test length(start_point) == 5
f_start = tf.f(start_point)
@test isfinite(f_start)
@test f_start ≈ 51.01256044522263 atol=1e-6

min_position = tf.meta[:min_position]()
@test min_position ≈ [1.0, 10.0, 1.0, 5.0, 4.0] atol=1e-6
@test length(min_position) == 5
f_min = tf.f(min_position)
@test f_min ≈ 0.0 atol=1e-6
@test tf.meta[:min_value]() ≈ 0.0 atol=1e-6

lb = tf.meta[:lb]()
@test lb == [0.0, 0.0, 0.0, 0.0, 0.0]
ub = tf.meta[:ub]()
@test ub == [20.0, 20.0, 20.0, 20.0, 20.0]

# Test at another point for consistency
test_point = [1.0, 1.0, 1.0, 1.0, 1.0]
@test tf.f(test_point) ≈ 9.057816568437913 atol=1e-6