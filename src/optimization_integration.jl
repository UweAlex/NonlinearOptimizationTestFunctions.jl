# src/optimization_integration.jl
# Regelkonform + Debug für powellsingular2 (now() entfernt)
# Last modified: 27. November 2025

using Optimization

function optimization_problem(tf::TestFunction; n::Union{Int,Nothing}=nothing, kwargs...)
    
    # ==================== DEBUG NUR FÜR POWELLSINGULAR2 ====================
    if tf.name == "powellsingular2"
        println("\n" * "="^80)
        println("POWELLSINGULAR2 ERKANNT – DEBUG-INFO")
        println("="^80)
        println("   tf.name               : ", tf.name)
        println("   scalable?             : ", "scalable" in tf.meta[:properties])
        println("   haskey(:default_n)    : ", haskey(tf.meta, :default_n))
        println("   tf.meta[:default_n]   : ", get(tf.meta, :default_n, "FEHLEND"))
        println("   übergebenes n         : ", n)
        println("   isnothing(n)          : ", isnothing(n))
        println("   dim(tf)               : ", dim(tf))
        println("="^80 * "\n")
    end
    # =======================================================================

    # -------------------------------------------------
    # 1. Dimension – EXAKT nach [RULE_DEFAULT_N]
    # -------------------------------------------------
    if "scalable" in tf.meta[:properties]
        if isnothing(n)
            if !haskey(tf.meta, :default_n)
                throw(ArgumentError(
                    "Skalierbare Funktion '$(tf.name)' hat kein :default_n – " *
                    "Verstößt gegen [RULE_DEFAULT_N]! Bitte setzen Sie :default_n im Meta-Dict."
                ))
            end
            n = tf.meta[:default_n]
        end
        # n wurde explizit übergeben → Nutzer weiß, was er tut
    else
        n = try
            length(min_position(tf))
        catch err
            throw(ArgumentError("Nicht-skalierbare Funktion '$(tf.name)' hat keine feste Dimension: $err"))
        end
    end

    if tf.name == "powellsingular2"
        println("   → NACH LOGIK: verwendetes n = $n  ← sollte 4 sein")
    end

    # -------------------------------------------------
    # 2. Bounded? → Dein perfekter L1-Wrapper!
    # -------------------------------------------------
    ctf = with_box_constraints(tf)

    # -------------------------------------------------
    # 3. Startpunkt
    # -------------------------------------------------
    x0 = start(ctf, n)

    # -------------------------------------------------
    # 4. Optimization.jl Wrapper
    # -------------------------------------------------
    f_wrap(u, p) = ctf.f(u)
    grad_wrap!(G, u, p) = ctf.gradient!(G, u)

    of = OptimizationFunction{true}(
        f_wrap,
        AutoForwardDiff();
        grad = grad_wrap!,
    )

    return OptimizationProblem(
        of,
        x0,
        nothing;
        lb = nothing,
        ub = nothing,
        sense = MinSense,
        kwargs...
    )
end

optimization_problem(tf_const::Base.RefValue{TestFunction}; kwargs...) =
    optimization_problem(tf_const[], kwargs...)

export optimization_problem, optprob
const optprob = optimization_problem