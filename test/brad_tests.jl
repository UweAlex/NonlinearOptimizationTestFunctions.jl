# test/brad_tests.jl
using Test, NonlinearOptimizationTestFunctions
@testset "brad" begin
tf = BRAD_FUNCTION

@test tf.meta[:name] == "brad"
@test has_property(tf, "bounded")
@test has_property(tf, "continuous")
@test has_property(tf, "differentiable")
@test has_property(tf, "multimodal")
@test has_property(tf, "non-separable")
@test !has_property(tf, "scalable")
@test length(tf.meta[:properties]) == 5

@test_throws ArgumentError tf.f(Float64[])

start_point = tf.meta[:start]()
@test start_point ≈ [0.0, 1.0, 1.0] atol=1e-6
f_start = tf.f(start_point)
@test f_start ≈ 12.916 atol=1e-3  # Korrigierter Wert bei [0,1,1]

min_pos = tf.meta[:min_position]()
@test min_pos ≈  [0.0824105597447766, 1.1330360919212203, 2.343695178745316] atol=1e-6
f_min = tf.f(min_pos)
@test f_min ≈ tf.meta[:min_value]() atol=1e-6

lb, ub = tf.meta[:lb](), tf.meta[:ub]()
@test lb ≈ [-0.25, 0.01, 0.01]
@test ub ≈ [0.25, 2.5, 2.5]

# Extra point
test_pt = [0.1, 1.5, 2.0]
@test tf.f(test_pt) ≈ 0.00959 atol=1e-3  # Korrigierter Wert bei [0.1,1.5,2.0]
end