# test/biggsexp6_tests.jl
using Test, NonlinearOptimizationTestFunctions
@testset "biggsexp6" begin
tf = BIGGSEXP6_FUNCTION

@test tf.meta[:name] == "biggsexp6"
@test has_property(tf, "bounded")
@test has_property(tf, "continuous")
@test has_property(tf, "differentiable")
@test has_property(tf, "multimodal")
@test has_property(tf, "non-separable")
@test !has_property(tf, "scalable")
@test length(tf.meta[:properties]) == 5

@test_throws ArgumentError tf.f(Float64[])

start_point = tf.meta[:start]()
@test start_point ≈ [1.0, 2.0, 1.0, 1.0, 1.0, 1.0] atol=1e-6
f_start = tf.f(start_point)
@test f_start ≈ 0.779 atol=1e-3

min_pos = tf.meta[:min_position]()
@test min_pos ≈ [1.0, 10.0, 1.0, 5.0, 4.0, 3.0] atol=1e-6
f_min = tf.f(min_pos)
@test f_min ≈ tf.meta[:min_value]() atol=1e-6

lb, ub = tf.meta[:lb](), tf.meta[:ub]()
@test lb ≈ [-20.0, -20.0, -20.0, -20.0, -20.0, -20.0]
@test ub ≈ [20.0, 20.0, 20.0, 20.0, 20.0, 20.0]

# Extra point
test_pt = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
@test tf.f(test_pt) ≈ 9.864 atol=1e-3
end