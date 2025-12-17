# =============================================================================
# examples/benchmark_box_constraints.jl
# =============================================================================
# Purpose: 
#   Comprehensive benchmark comparing two box-constraint handling methods
#   across ALL bounded functions with MULTIPLE RANDOM START POINTS.
#
#   Comparison:
#     1. Fminbox + LBFGS (standard)
#     2. L1-Penalty-Wrapper (with_box_constraints) + LBFGS with BackTracking
#
#   Assumptions:
#     - rho = 1e6 is fixed as a constant in the package (l1_penalty_wrapper.jl)
#     - Every scalable function has :default_n (MUST rule)
# =============================================================================

using NonlinearOptimizationTestFunctions
using Optim
using LineSearches  # for the more stable BackTracking linesearch with L1 wrapper
using Random

# --- Configuration ---
const NUM_START_POINTS = 50        # <-- CHANGE HERE: Number of random start points per function
const MAX_ITERATIONS = 20_000
const ABS_TOL = 1e-8
const RHO_DOCUMENTED = 1e6       # For documentation only – actual value defined in package
# ---------------------

# Solver configuration
lbfgs_stable = LBFGS(linesearch=LineSearches.BackTracking())  # more stable for non-smooth L1
lbfgs_standard = LBFGS()                                          # standard for fair comparison

# -------------------------------------------------------------------------
# 1. Helper: Generate strictly feasible random start point
# -------------------------------------------------------------------------
function generate_random_start(lower::Vector{Float64}, upper::Vector{Float64}, rng::MersenneTwister)
    n = length(lower)
    x0 = Vector{Float64}(undef, n)
    epsilon = 1e-8

    @inbounds for i in 1:n
        l_eff = lower[i] + epsilon
        u_eff = upper[i] - epsilon
        if u_eff <= l_eff
            x0[i] = (lower[i] + upper[i]) / 2
        else
            x0[i] = l_eff + rand(rng) * (u_eff - l_eff)
        end
    end
    return x0
end

# -------------------------------------------------------------------------
# 2. Benchmark setup
# -------------------------------------------------------------------------
bounded_tfs = filter_testfunctions(bounded)

println("Found $(length(bounded_tfs)) bounded benchmark functions.")
println("Running each with $NUM_START_POINTS random strictly feasible start points ")
println("(L1-Penalty rho = $RHO_DOCUMENTED, BackTracking linesearch for L1).\n")

results = Vector{NamedTuple}(undef, 0)
rng = MersenneTwister(42)

for tf_orig in bounded_tfs
    # Fix dimension (scalable → default_n, otherwise unchanged)
    tf = if scalable(tf_orig)
        fixed(tf_orig; n=tf_orig.meta[:default_n])
    else
        tf_orig
    end

    name = tf.name
    n = dim(tf)

    if n > 50
        println("Skipping $name (n=$n – too large for quick benchmark)")
        continue
    end

    lower = Float64.(lb(tf))
    upper = Float64.(ub(tf))

    # L1 wrapper (rho fixed internally at 1e6)
    tf_l1 = with_box_constraints(tf)

    sum_fminbox_calls = 0
    sum_l1_calls = 0
    fminbox_success = 0
    l1_success = 0

    for _ in 1:NUM_START_POINTS
        x0 = generate_random_start(lower, upper, rng)

        # --- Fminbox + LBFGS (standard) ---
        reset_counts!(tf)
        try
            res = optimize(
                tf.f, tf.gradient!,
                lower, upper,
                x0,
                Fminbox(lbfgs_standard),
                Optim.Options(iterations=MAX_ITERATIONS, f_reltol=ABS_TOL,
                    store_trace=false, show_trace=false)
            )
            calls = get_f_count(tf) + get_grad_count(tf)
            sum_fminbox_calls += calls
            if Optim.converged(res)
                fminbox_success += 1
            end
        catch e
            @warn "Fminbox failed for $name: $e"
        end

        # --- L1 wrapper + LBFGS (BackTracking) ---
        reset_counts!(tf_l1)
        try
            res = optimize(
                tf_l1.f, tf_l1.gradient!,
                x0,
                lbfgs_stable,
                Optim.Options(iterations=MAX_ITERATIONS, f_reltol=ABS_TOL,
                    store_trace=false, show_trace=false)
            )
            calls = get_f_count(tf_l1) + get_grad_count(tf_l1)
            sum_l1_calls += calls
            if Optim.converged(res)
                l1_success += 1
            end
        catch e
            @warn "L1 wrapper failed for $name: $e"
        end
    end

    avg_fminbox = fminbox_success > 0 ? sum_fminbox_calls / fminbox_success : Inf
    avg_l1 = l1_success > 0 ? sum_l1_calls / l1_success : Inf

    succ_rate_fminbox = fminbox_success / NUM_START_POINTS
    succ_rate_l1 = l1_success / NUM_START_POINTS

    push!(results, (
        name=name,
        n=n,
        avg_fminbox=avg_fminbox,
        avg_l1=avg_l1,
        succ_fminbox=succ_rate_fminbox,
        succ_l1=succ_rate_l1
    ))

    # Short status message
    status = if succ_rate_l1 == 0.0 && succ_rate_fminbox == 0.0
        "Both failed"
    elseif succ_rate_l1 > succ_rate_fminbox
        "L1 more robust ($(round(succ_rate_l1*100, digits=1))%)"
    elseif succ_rate_fminbox > succ_rate_l1
        "Fminbox more robust ($(round(succ_rate_fminbox*100, digits=1))%)"
    elseif avg_l1 < avg_fminbox
        "L1 faster (avg calls: $(round(avg_l1; digits=1)) vs $(round(avg_fminbox; digits=1)))"
    else
        "Comparable"
    end
    println("$(lpad(name, 35)) (n=$(lpad(n,2))) → $status")
end

# -------------------------------------------------------------------------
# 5. Final summary (no global mutation → no scope issues)
# -------------------------------------------------------------------------
println("\n\n=== FINAL BENCHMARK SUMMARY ($NUM_START_POINTS start points per function) ===")

# Robustness
robust_l1 = count(r -> r.succ_l1 > r.succ_fminbox, results)
robust_fminbox = count(r -> r.succ_fminbox > r.succ_l1, results)
robust_equal = count(r -> r.succ_l1 == r.succ_fminbox && r.succ_l1 > 0.0, results)

# Efficiency (only when success rates are equal)
equal_success = filter(r -> r.succ_l1 == r.succ_fminbox && r.succ_l1 > 0.0, results)
eff_l1 = count(r -> r.avg_l1 < r.avg_fminbox, equal_success)
eff_fminbox = count(r -> r.avg_fminbox < r.avg_l1, equal_success)

# Estimated savings – functional style (no +=)
total_savings_in_common = sum(results) do r
    if r.succ_l1 > 0.0 && r.succ_fminbox > 0.0
        comparable_runs = min(r.succ_l1, r.succ_fminbox) * NUM_START_POINTS
        (r.avg_fminbox - r.avg_l1) * comparable_runs
    else
        0.0
    end
end

runs_compared = sum(results) do r
    if r.succ_l1 > 0.0 && r.succ_fminbox > 0.0
        min(r.succ_l1, r.succ_fminbox) * NUM_START_POINTS
    else
        0
    end
end

println("\n--- Robustness ---")
println("L1 more robust            : $robust_l1")
println("Fminbox more robust       : $robust_fminbox")
println("Equal robustness (>0%)    : $robust_equal")

println("\n--- Efficiency (equal robustness) ---")
println("L1 more efficient         : $eff_l1")
println("Fminbox more efficient    : $eff_fminbox")

println("\n--- Estimated total savings ---")
println("Calls saved (L1 vs Fminbox) : $(round(Int, total_savings_in_common))")
println("Compared runs               : $runs_compared")

println("\nBenchmark completed.")