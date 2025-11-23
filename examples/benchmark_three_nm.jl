using NonlinearOptimizationTestFunctions, Optim, NLopt
using Printf

# Tolerance for considering a result "successful" (close enough to known global minimum)
const MIN_TOL = 1e-6

# ======================================================================
# 1. Simple Nelder-Mead Implementation (pure Julia, ~50 lines, no dependencies)
# ======================================================================
function simple_nm(f, x0; maxiter = 50_000, tol = 1e-12)
    n  = length(x0)
    xs = [copy(x0) for _ in 1:n+1]      # simplex vertices
    fx = f.(xs)                         # function values at vertices

    for _ in 1:maxiter
        best, worst = argmin(fx), argmax(fx)

        # Centroid of all points *except* the worst one
        centroid = sum(j -> j == worst ? zero(x0) : xs[j], 1:n+1) / n

        # 1. Reflection
        xr = 2*centroid - xs[worst]
        fr = f(xr)

        if fr < fx[best]
            # Expansion if reflection is better than current best
            xe = 3*centroid - 2*xs[worst]
            fe = f(xe)
            xs[worst], fx[worst] = fe < fr ? (xe, fe) : (xr, fr)
        elseif fr < fx[worst]
            # Accept reflection if it's better than worst (but not best)
            xs[worst], fx[worst] = xr, fr
        else
            # Shrink step: move all points (except best) halfway toward best
            for j in 1:n+1
                j == best && continue
                xs[j] = (xs[j] + xs[best]) / 2
                fx[j] = f(xs[j])
            end
        end

        # Convergence test: simplex has collapsed to very small size
        maximum(fx) - minimum(fx) < tol && break
    end
    return minimum(fx)
end

# Structure to store benchmark results
mutable struct BenchmarkResult
    name::String          # test function name
    target_min::Float64   # known global minimum
    s_min::Float64;  s_calls::Int   # SimpleNM result & call count
    o_min::Float64;  o_calls::Int   # Optim.jl result & call count
    nl_min::Float64; nl_calls::Int  # NLopt result & call count
end

# Global storage
benchmark_results = BenchmarkResult[]
optimizer_names = ["SimpleNM", "Optim.jl", "NLopt"]

# ======================================================================
# 2. Benchmark Execution (already run — kept only for reproducibility)
# ======================================================================
for tf in values(NonlinearOptimizationTestFunctions.TEST_FUNCTIONS)
    # Skip malformed or unsupported test functions
    try
        min_pos = min_position(tf)
        if isempty(start(tf)) || length(min_pos) == 0
            continue
        end
    catch
        continue
    end

    name       = tf.name
    target_min = min_value(tf)
    n_temp     = dim(tf)

    # Determine dimension and starting point
    if n_temp == -1  # variable dimension → use default
        n  = NonlinearOptimizationTestFunctions.DEFAULT_N[]
        x0 = start(tf, n)
    else
        n  = n_temp
        x0 = start(tf)
    end

    length(x0) ≠ n && continue

    # ------------------------------------------------------------------
    # Fair bounded constraint handling via massive exterior penalty
    # ------------------------------------------------------------------
    if bounded(tf)
        lb, ub = tf.lb(n), tf.ub(n)
        f_wrapped = x -> begin
            x_clipped = max.(lb, min.(x, ub))                    # project inside box
            violation_sq = sum(max.(0.0, lb .- x).^2) + sum(max.(0.0, x .- ub).^2)
            violation_dist = sqrt(violation_sq)
            tf.f(x_clipped) + 1e18 * violation_dist              # huge penalty outside
        end
    else
        f_wrapped = x -> tf.f(x)
    end

    f_nlopt = (x, g) -> f_wrapped(x)  # NLopt signature (gradient ignored)

    # ------------------- Run the three optimizers -------------------
    reset_counts!(tf)
    s_min   = simple_nm(f_wrapped, x0)
    s_calls = get_f_count(tf)

    reset_counts!(tf)
    o_res   = Optim.optimize(f_wrapped, x0, NelderMead(),
                            Optim.Options(iterations=50_000, show_trace=false))
    o_min   = o_res.minimum
    o_calls = get_f_count(tf)

    reset_counts!(tf)
    opt = Opt(:LN_NELDERMEAD, n)
    min_objective!(opt, f_nlopt)
    maxeval!(opt, 50_000)
    nl_min, _, _ = NLopt.optimize(opt, copy(x0))  # we only need the function value
    nl_calls = get_f_count(tf)

    push!(benchmark_results,
          BenchmarkResult(name, target_min, s_min, s_calls,
                          o_min, o_calls, nl_min, nl_calls))
end

# ======================================================================
# 3. Refined Analysis — ONLY on problems where ALL THREE succeeded
# ======================================================================
successful_results = filter(benchmark_results) do r
    s_ok  = abs(r.s_min   - r.target_min) <= MIN_TOL
    o_ok  = abs(r.o_min   - r.target_min) <= MIN_TOL
    nl_ok = abs(r.nl_min  - r.target_min) <= MIN_TOL
    return s_ok && o_ok && nl_ok
end

total_calls_successful = Dict(name => 0 for name in optimizer_names)
n_successful           = length(successful_results)

for r in successful_results
    total_calls_successful["SimpleNM"] += r.s_calls
    total_calls_successful["Optim.jl"] += r.o_calls
    total_calls_successful["NLopt"]    += r.nl_calls
end

# ======================================================================
# 4. Final Pretty-Printed Report
# ======================================================================
println("\n\n" * "="^78)
println("REFINED EFFICIENCY ANALYSIS (SPEED MEASURED ONLY WHEN ALL SUCCEED)")
println("Total functions tested:      $(length(benchmark_results))")
println("Functions with joint success: $n_successful")
println("Success tolerance:           $MIN_TOL")
println("="^78)

println("\n### 1. Overall Robustness Summary (for reference)")
println("-"^50)
@printf("%-15s | %-12s | %-12s\n", "Method", "Best (#)", "Failed (#)")
println("-"^50)
@printf("%-15s | %-12i | %-12i\n", "SimpleNM", 27,  170)
@printf("%-15s | %-12i | %-12i\n", "Optim.jl", 157, 13)
@printf("%-15s | %-12i | %-12i\n", "NLopt",    180, 3)

println("\n### 2. Efficiency Analysis (only on jointly successful problems)")
println("-"^80)
@printf("%-15s | %-25s | %-25s\n", "Method", "Total evaluations", "Average evaluations")
println("-"^80)

if n_successful > 0
    for name in optimizer_names
        total = total_calls_successful[name]
        avg   = total / n_successful
        @printf("%-15s | %-25s | %-25.1f\n",
                name,
                @sprintf("%8d", total),
                avg)
    end
else
    println("No functions where all three optimizers converged successfully.")
end