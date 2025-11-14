# test/ursem3_tests.jl

using Test, NonlinearOptimizationTestFunctions  # [NEW RULE_TESTFILE_LOADING]
@testset "ursem3" begin
    tf = URSEM3_FUNCTION
    @test tf.meta[:name] == "ursem3"  # [RULE_NAME_CONSISTENCY]
    @test has_property(tf, "bounded")
    @test has_property(tf, "continuous")
    @test has_property(tf, "multimodal")
    @test has_property(tf, "non-separable")
    @test has_property(tf, "partially differentiable")
    
    start_point = tf.meta[:start]()
    @test length(start_point) == 2
    @test tf.f(start_point) ≈ -0.953 atol=1e-3  # Computed value at [-1.0, -0.5]; loose tolerance for start [RULE_ATOL]
    
    min_pos = tf.meta[:min_position]()
    @test length(min_pos) == 2
    @test tf.f(min_pos) ≈ tf.meta[:min_value]() atol=1e-8  # Exact match; no noise [RULE_TEST_SYNTAX]
end