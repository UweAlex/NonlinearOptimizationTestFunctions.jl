using NonlinearOptimizationTestFunctions, Optim
# Optimizes all test functions using Optim.jl, with bounds for bounded functions; constrained functions planned for Q1 2026 (see ROADMAP.md).

# Main loop: Iterates over all test functions in the suite, retrieves their dimension and metadata (start point, bounds),
# and optimizes them using NelderMead (unbounded) or Fminbox(NelderMead) (bounded). Outputs the minimizer and minimum value.
for tf in values(NonlinearOptimizationTestFunctions.TEST_FUNCTIONS)
    # Get dimension from metadata or use default_n for scalable functions
    local dim = NonlinearOptimizationTestFunctions.dim(tf)
    local n = dim == -1 ? tf.meta[:default_n] : dim

    # Validate default_n for scalable functions
    if dim == -1 && !haskey(tf.meta, :default_n)
        error("No :default_n defined for scalable function $(tf.meta[:name])")
    end

    # Get start point (use n for scalable functions only)
    local start_point = dim == -1 ? tf.meta[:start](n) : tf.meta[:start]()
    local lb = haskey(tf.meta, :lb) ? (dim == -1 ? tf.meta[:lb](n) : tf.meta[:lb]()) : nothing
    local ub = haskey(tf.meta, :ub) ? (dim == -1 ? tf.meta[:ub](n) : tf.meta[:ub]()) : nothing

    # Validate inputs
    if length(start_point) != n
        error("Start point dimension ($(length(start_point))) does not match function dimension ($n) for $(tf.meta[:name])")
    end

    # Perform optimization
    if has_property(tf, "bounded") && lb !== nothing && ub !== nothing
        # Bounded optimization using Fminbox(NelderMead)
        local clamped_start_point = clamp.(start_point, lb, ub)
        local result = Optim.optimize(tf.f, lb, ub, clamped_start_point, Fminbox(NelderMead()), Optim.Options(f_reltol=1e-6))
    else
        # Unbounded optimization
        local result = Optim.optimize(tf.f, start_point, NelderMead(), Optim.Options(f_reltol=1e-6))
    end

    # Print results
    println("$(tf.meta[:name]): minimizer = $(Optim.minimizer(result)), minimum = $(Optim.minimum(result))")
    println("--------------------------------------------------")
end