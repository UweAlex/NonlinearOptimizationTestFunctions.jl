import Pkg; Pkg.add("NLopt")
# examples/benchmark_with_wrapper.jl
# Fairer Benchmark mit deinem mathematisch exakten Wrapper
# Keine DomainErrors mehr – 100 % fair und robust

using NonlinearOptimizationTestFunctions, Optim, NLopt
using Printf

# Tolerance für "erfolgreich"
const MIN_TOL = 1e-6

# ======================================================================
# 1. Simple Nelder-Mead (pure Julia)
# ======================================================================
function simple_nm(f, x0; maxiter = 50_000, tol = 1e-12)
    n  = length(x0)
    xs = [copy(x0) for _ in 1:n+1]
    fx = f.(xs)

    for _ in 1:maxiter
        best, worst = argmin(fx), argmax(fx)
        centroid = sum(j -> j == worst ? zero(x0) : xs[j], 1:n+1) / n

        xr = 2*centroid - xs[worst]
        fr = f(xr)

        if fr < fx[best]
            xe = 3*centroid - 2*xs[worst]
            fe = f(xe)
            xs[worst], fx[worst] = fe < fr ? (xe, fe) : (xr, fr)
        elseif fr < fx[worst]
            xs[worst], fx[worst] = xr, fr
        else
            for j in 1:n+1
                j == best && continue
                xs[j] = (xs[j] + xs[best]) / 2
                fx[j] = f(xs[j])
            end
        end
        maximum(fx) - minimum(fx) < tol && break
    end
    return minimum(fx)
end

# Ergebnis-Struktur
mutable struct BenchmarkResult
    name::String
    target_min::Float64
    s_min::Float64;  s_calls::Int
    o_min::Float64;  o_calls::Int
    nl_min::Float64; nl_calls::Int
end

benchmark_results = BenchmarkResult[]
optimizer_names = ["SimpleNM", "Optim.jl", "NLopt"]

# ======================================================================
# 2. Benchmark mit deinem Wrapper!
# ======================================================================
for tf in values(TEST_FUNCTIONS)
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
    n_temp     = get_n(tf)                     # ← dein korrekter Weg!

    if n_temp == -1  # scalable
        n = get(tf.meta, :default_n, 2)
        n < 1 && (n = 2)
    else
        n = n_temp
    end

    x0 = start(tf, n)
    length(x0) != n && continue

    # ──────── DEIN WRAPPER ────────
    ctf = with_box_constraints(tf)

    # ------------------- 3 Optimierer -------------------
    reset_counts!(ctf)
    s_min   = simple_nm(ctf.f, x0)
    s_calls = get_f_count(ctf)

    reset_counts!(ctf)
    o_res   = Optim.optimize(ctf.f, x0, NelderMead(),
                            Optim.Options(iterations=50_000, show_trace=false))
    o_min   = o_res.minimum
    o_calls = get_f_count(ctf)

    reset_counts!(ctf)
    opt = Opt(:LN_NELDERMEAD, n)
    min_objective!(opt, (x,g) -> ctf.f(x))
    maxeval!(opt, 50_000)
    nl_min, _, _ = NLopt.optimize(opt, copy(x0))
    nl_calls = get_f_count(ctf)

    push!(benchmark_results,
          BenchmarkResult(name * "_constrained", target_min, s_min, s_calls,
                          o_min, o_calls, nl_min, nl_calls))
end

# ======================================================================
# 3. Analyse & Ausgabe
# ======================================================================
successful_results = filter(benchmark_results) do r
    abs(r.s_min   - r.target_min) <= MIN_TOL &&
    abs(r.o_min   - r.target_min) <= MIN_TOL &&
    abs(r.nl_min  - r.target_min) <= MIN_TOL
end

total_calls = Dict(name => 0 for name in optimizer_names)
n_successful = length(successful_results)

for r in successful_results
    total_calls["SimpleNM"] += r.s_calls
    total_calls["Optim.jl"] += r.o_calls
    total_calls["NLopt"]    += r.nl_calls
end

println("\n" * "="^82)
println("FAIR BENCHMARK MIT with_box_constraints (L1 Exact Penalty)")
println("Total Funktionen getestet:      $(length(benchmark_results))")
println("Gemeinsam erfolgreich:          $n_successful")
println("="^82)

println("\n### Effizienz (nur bei gemeinsamem Erfolg)")
println("-"^80)
@printf("%-15s | %-25s | %-25s\n", "Methode", "Gesamt-Aufrufe", "Durchschnitt")
println("-"^80)

if n_successful > 0
    for name in optimizer_names
        total = total_calls[name]
        avg   = total / n_successful
        @printf("%-15s | %-25s | %-25.1f\n",
                name, @sprintf("%8d", total), avg)
    end
else
    println("Keine Funktion, bei der alle drei konvergierten.")
end

println("\n" * "="^82)