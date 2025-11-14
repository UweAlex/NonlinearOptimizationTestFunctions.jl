# test/ursem1_tests.jl

using Test, NonlinearOptimizationTestFunctions  # [NEW RULE_TESTFILE_LOADING]
@testset "ursem1" begin
    tf = URSEM1_FUNCTION
    @test tf.meta[:name] == "ursem1"  # [RULE_NAME_CONSISTENCY]
    @test has_property(tf, "bounded")
    @test has_property(tf, "continuous")
    @test has_property(tf, "differentiable")
    @test has_property(tf, "separable")
    @test has_property(tf, "unimodal")
    
    start_point = tf.meta[:start]()
    @test length(start_point) == 2
    @test tf.f(start_point) ≈ -2.0 atol=1e-8  # Exact computed value at [0.0, 0.0]; tight tolerance for deterministic [RULE_ATOL]
    
    min_pos = tf.meta[:min_position]()
    @test length(min_pos) == 2
    @test tf.f(min_pos) ≈ tf.meta[:min_value]() atol=1e-8  # Matches updated min_value; no noise [RULE_TEST_SYNTAX]
end