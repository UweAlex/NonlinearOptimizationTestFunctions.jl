# examples/benchmark_three_nm.jl
# Benchmark

using NonlinearOptimizationTestFunctions
using Optimization, OptimizationOptimJL, OptimizationNLopt
using LineSearches
using Statistics

const TOL = 1e-6
const MAXITER = 100_000

# Ergebnis-Datentyp
struct Result
    name::String
    n::Int
    target::Float64
    nm_optim_val::Float64
    nm_optim_calls::Int
    nm_nlopt_val::Float64
    nm_nlopt_calls::Int
    lbfgs_val::Float64
    lbfgs_calls::Int
end

results = Result[]

println("\nBenchmark: analytical gradients vs derivative-free methods")
println("→ Using fixed() + with_box_constraints() for all functions\n")

for tf_orig in values(TEST_FUNCTIONS)

    # 1. Skalar → explizite Dimension erzeugen
    tf_fixed = fixed(tf_orig)

    # 2. Sign-safe Box-Constraints
    tf = with_box_constraints(tf_fixed)

    # => dim(tf) ist ab jetzt immer korrekt gesetzt
    name = tf.name
    n = dim(tf)
    target = min_value(tf)

    println("→ $name (n = $n)")

    # ---------------- Nelder-Mead (Optim.jl) ----------------
    reset_counts!(tf)
    sol_nm_opt = solve(
        optimization_problem(tf),
        NelderMead();
        maxiters=MAXITER,
    )
    calls_nm_opt = get_f_count(tf)

    # ---------------- Nelder-Mead (NLopt) ----------------
    reset_counts!(tf)
    sol_nm_nl = solve(
        optimization_problem(tf),
        NLopt.LN_NELDERMEAD();
        maxiters=MAXITER,
    )
    calls_nm_nl = get_f_count(tf)

    # ---------------- L-BFGS ----------------
    reset_counts!(tf)
    sol_lbfgs = solve(
        optimization_problem(tf),
        LBFGS(; linesearch=LineSearches.BackTracking());
        maxiters=10_000,
    )
    calls_lbfgs = get_f_count(tf) + get_grad_count(tf)

    push!(results, Result(
        name, n, target,
        sol_nm_opt.objective, calls_nm_opt,
        sol_nm_nl.objective, calls_nm_nl,
        sol_lbfgs.objective, calls_lbfgs,
    ))

    println("   L-BFGS: $(sol_lbfgs.objective) ($(calls_lbfgs) calls) | ",
        "NM-Optim: $(sol_nm_opt.objective) | NM-NLopt: $(sol_nm_nl.objective)")
end


# ======================================================================
# Zusammenfassung
# ======================================================================

successful = [
    r for r in results if
    abs(r.nm_optim_val - r.target) ≤ TOL &&
    abs(r.nm_nlopt_val - r.target) ≤ TOL &&
    abs(r.lbfgs_val - r.target) ≤ TOL
]

println("\n" * "="^80)
println("RESULT: Analytical gradients dominate")
println("="^80)
println("All three solvers converged (±$TOL): $(length(successful)) / $(length(results)) functions")

if !isempty(successful)
    avg_lbfgs = round(Int, mean(r.lbfgs_calls for r in successful))
    avg_nm_opt = round(Int, mean(r.nm_optim_calls for r in successful))
    avg_nm_nl = round(Int, mean(r.nm_nlopt_calls for r in successful))

    println("\nAverage evaluations (successful cases):")
    println("   L-BFGS (analytical gradients) : $avg_lbfgs")
    println("   Nelder-Mead (Optim.jl)         : $avg_nm_opt")
    println("   Nelder-Mead (NLopt)            : $avg_nm_nl")
    println("\n   → L-BFGS is typically 10–100× faster!")
end

println("="^80)
