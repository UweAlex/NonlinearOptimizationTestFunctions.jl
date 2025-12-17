using Test
using NonlinearOptimizationTestFunctions
using Optim

# ===================================================================
# Helper: Shifted Sphere f(x) = ||x - c||²
# Optimized: Validation, raw math, source field, default_n removed
# ===================================================================

function make_shifted_sphere(;
    n::Int=2,
    shift::Vector{Float64}=ones(n),
    lb::Float64=-5.0,
    ub::Float64=10.0,
    bounded::Bool=true,
    name::String="shifted_sphere_test"
)
    if bounded && lb >= ub
        throw(ArgumentError("Lower bound must be strictly less than upper bound: lb=$lb, ub=$ub"))
    end

    c = Float64.(shift)

    f(x) = sum(abs2, x .- c)
    grad(x) = 2.0 .* (x .- c)

    meta = Dict{Symbol,Any}(
        :name => name,
        :description => "Shifted sphere f(x) = ||x - c||², minimum at c = $c",
        :properties => Set(["convex", "unimodal", "separable", "differentiable", "continuous"]),
        :math => raw"f(\mathbf{x}) = \sum_{i=1}^n (x_i - c_i)^2",  # raw string
        :source => "Synthetic test function for L1 penalty wrapper testing",
        :start => () -> zeros(n),
        :min_position => () -> copy(c),
        :min_value => () -> 0.0,
    )

    if bounded
        push!(meta[:properties], "bounded")
        meta[:lb] = () -> fill(lb, n)
        meta[:ub] = () -> fill(ub, n)
    else
        meta[:lb] = () -> fill(-Inf, n)
        meta[:ub] = () -> fill(+Inf, n)
    end

    return TestFunction(f, grad, meta)  # Main constructor
end

# ===================================================================
# Tests for the L1 Penalty Wrapper
# ===================================================================

@testset "L1 Penalty Wrapper - Shifted Sphere Tests" begin

    ρ = 1e6  # Fixed ρ value as now defined in the wrapper

    @testset "Bounds Validation in Helper" begin
        @test_throws ArgumentError make_shifted_sphere(n=2, lb=10.0, ub=-5.0, bounded=true)
        @test_throws ArgumentError make_shifted_sphere(n=2, lb=5.0, ub=5.0, bounded=true)
        # Valid bounds → no error
        @test make_shifted_sphere(n=2, lb=-10.0, ub=10.0, bounded=true) isa TestFunction
    end

    @testset "Non-bounded: Early Return" begin
        tf = make_shifted_sphere(bounded=false)
        ctf = with_box_constraints(tf)
        @test ctf === tf
    end

    @testset "Counter Mechanism - Separate Inside/Outside Calls" begin
        tf = make_shifted_sphere(n=2, shift=[0.0, 0.0], lb=-5.0, ub=10.0)
        ctf = with_box_constraints(tf)

        reset_counts!(tf)

        num_inside_f = 8
        num_inside_grad = 12
        num_outside_f = 7
        num_outside_grad = 10

        total_f = num_inside_f + num_outside_f
        total_grad = num_inside_grad + num_outside_grad

        # Inside
        for i in 1:num_inside_f
            ctf.f([2.0, 3.0] .+ i / 100)
        end
        for i in 1:num_inside_grad
            ctf.grad([1.0, 4.0] .+ i / 100)
        end

        # Outside
        for i in 1:num_outside_f
            ctf.f([-10.0 - i, 15.0 + i])
        end
        for i in 1:num_outside_grad
            ctf.grad([20.0 + i, -8.0 - i])
        end

        @test get_f_count(ctf) == total_f
        @test get_grad_count(ctf) == total_grad

        if tf.f_count === ctf.f_count
            @test get_f_count(tf) == total_f
        end
        if tf.grad_count === ctf.grad_count
            @test get_grad_count(tf) == total_grad
        end
    end

    @testset "Exact Function and Gradient Values" begin
        tf = make_shifted_sphere(n=2, shift=[12.0, 12.0], lb=-5.0, ub=10.0)
        ctf = with_box_constraints(tf)

        x = [15.0, 20.0]
        x_clamped = clamp.(x, -5.0, 10.0)

        violation = sum(max.(x .- 10.0, 0.0)) + sum(max.(-5.0 .- x, 0.0))
        f_inner = sum(abs2, x_clamped .- [12.0, 12.0])
        f_expected = f_inner + ρ * violation

        @test ctf.f(x) ≈ f_expected rtol = 1e-12

        # Corrected: Due to chain rule, inner gradient contribution is 0 when outside (x_clamped constant w.r.t x)
        g_inner = zeros(2)  # Effective contribution is 0
        g_penalty = [ρ, ρ]
        g_expected = g_inner + g_penalty

        @test ctf.grad(x) ≈ g_expected rtol = 1e-12
    end

    @testset "Only one dimension violated" begin
        tf = make_shifted_sphere(n=2, shift=[0.0, 12.0], lb=-5.0, ub=10.0)
        ctf = with_box_constraints(tf)

        x = [0.0, 15.0]
        g = ctf.grad(x)

        @test g[1] ≈ 2.0 * (0.0 - 0.0)  # Inside, full inner grad
        @test g[2] ≈ 0.0 + ρ  # Outside, inner contrib 0 + penalty
    end

    @testset "Point inside bounds" begin
        tf = make_shifted_sphere(n=2, shift=[3.0, 4.0], lb=-10.0, ub=20.0)
        ctf = with_box_constraints(tf)

        x = [5.0, 6.0]
        @test ctf.f(x) ≈ sum(abs2, x .- [3.0, 4.0])
        @test ctf.grad(x) ≈ 2.0 .* (x .- [3.0, 4.0])
    end

    @testset "In-place gradient!" begin
        tf = make_shifted_sphere(n=2, shift=[0.0, 0.0], lb=-5.0, ub=10.0)
        ctf = with_box_constraints(tf)

        x = [15.0, -10.0]  # both outside
        g = zeros(2)
        ctf.gradient!(g, x)

        x_clamped = [10.0, -5.0]
        g_expected = zeros(2) .+ [ρ, -ρ]  # Inner contrib 0 due to chain rule

        @test g ≈ g_expected rtol = 1e-12
    end

    @testset "Degenerate input handling (NaN/Inf)" begin
        tf = make_shifted_sphere(n=2, bounded=true)
        ctf = with_box_constraints(tf)

        @test isnan(ctf.f([NaN, 0.0]))
        @test isinf(ctf.f([Inf, 0.0]))

        g_nan = ctf.grad([NaN, 0.0])
        @test all(isnan, g_nan)

        g_inf = ctf.grad([Inf, 0.0])
        @test all(isinf, g_inf)
    end

    @testset "Metadata Correctness" begin
        tf = make_shifted_sphere(n=2, shift=[1.0, 2.0], bounded=true)
        ctf = with_box_constraints(tf)

        @test ctf !== tf
        @test endswith(ctf.meta[:name], "_constrained")
        @test "bounded" ∉ ctf.meta[:properties]
        @test haskey(ctf.meta, :constraint_method)
        @test ctf.meta[:constraint_method] == "L1 exact penalty"
        @test haskey(ctf.meta, :penalty_coefficient)
        @test ctf.meta[:penalty_coefficient] == ρ
        @test haskey(ctf.meta, :original_bounds)
    end

    @testset "Optimization doesn't crash and respects bounds" begin
        tf = make_shifted_sphere(n=2, shift=[15.0, 15.0], lb=-5.0, ub=10.0)
        ctf = with_box_constraints(tf)
        reset_counts!(ctf)

        result = optimize(
            ctf.f,
            ctf.gradient!,
            start(ctf),
            LBFGS(),
            Optim.Options(iterations=1000)
        )

        @test isfinite(Optim.minimum(result))
        @test all(-5.0 .≤ Optim.minimizer(result) .≤ 10.0)
        @test get_f_count(ctf) > 0
    end
end