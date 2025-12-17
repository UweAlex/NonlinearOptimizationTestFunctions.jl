# src/l1_penalty_wrapper.jl
# Hard box-constraints via L1 exact penalty – allocation-free, domain-safe
# Stand: 16. Dezember 2025 – ✅ Funktioniert mit alternativem Konstruktor

const BOUND_PENALTY = 1e6
"""
    with_box_constraints(tf::TestFunction) -> TestFunction

Wraps a bounded test function with L1 exact penalty constraints.

This function converts hard box constraints into a penalty-based formulation
that can be used with unconstrained optimizers. The returned TestFunction
shares evaluation counters with the original function.

# Key Features
- **Domain-safe**: Automatically projects infeasible points onto bounds
- **Allocation-free**: Uses pre-allocated buffers for projections
- **Shared counters**: Both original and constrained functions count into same Ref{Int}
- **Exact penalty**: Violations are penalized with coefficient 1e21

# Arguments
- `tf::TestFunction`: A bounded test function (must have "bounded" property)

# Returns
- `TestFunction`: New function with penalty constraints, or original if not bounded

# Example

    using NonlinearOptimizationTestFunctions, Optim

    tf = fixed(ROSENBROCK_FUNCTION; n=2)
    ctf = with_box_constraints(tf)
    
    reset_counts!(tf)
    result = optimize(ctf.f, ctf.gradient!, start(ctf), LBFGS())
    
    println("Evaluations: ", get_f_count(tf))  # Same as get_f_count(ctf)

# Notes
- Non-bounded functions are returned unchanged
- Scalable functions are automatically fixed using :default_n
- The "bounded" property is removed from the returned function
- Bounds information (:lb, :ub) is removed from metadata
"""
function with_box_constraints(tf::TestFunction)
    # ══════════════════════════════════════════════════════════════════════
    # 1. Early return for non-bounded functions
    # ══════════════════════════════════════════════════════════════════════
    "bounded" ∉ tf.meta[:properties] && return tf

    # ══════════════════════════════════════════════════════════════════════
    # 2. Ensure fixed dimension (convert scalable → fixed)
    # ══════════════════════════════════════════════════════════════════════
    tf_fixed = fixed(tf)
    n = dim(tf_fixed)

    if n < 1
        error("Invalid dimension $n for function $(tf_fixed.name)")
    end

    # ══════════════════════════════════════════════════════════════════════
    # 3. Extract and validate bounds
    # ══════════════════════════════════════════════════════════════════════
    lb_vec = tf_fixed.meta[:lb]()
    ub_vec = tf_fixed.meta[:ub]()

    if length(lb_vec) != n || length(ub_vec) != n
        error("Bounds dimension mismatch for $(tf_fixed.name): n=$n, lb=$(length(lb_vec)), ub=$(length(ub_vec))")
    end

    if any(lb_vec .>= ub_vec)
        error("Invalid bounds for $(tf_fixed.name): lower bounds must be strictly less than upper bounds")
    end

    # ══════════════════════════════════════════════════════════════════════
    # 4. Pre-allocate projection buffer
    # ══════════════════════════════════════════════════════════════════════
    x_buffer = Vector{Float64}(undef, n)

    # ══════════════════════════════════════════════════════════════════════
    # 5. Get shared counter references
    # ══════════════════════════════════════════════════════════════════════
    shared_f_count = tf_fixed.f_count
    shared_grad_count = tf_fixed.grad_count

    # ══════════════════════════════════════════════════════════════════════
    # 6. Define objective function with L1 exact penalty
    # ══════════════════════════════════════════════════════════════════════
    f_wrap = let x_buffer = x_buffer,
        lb_vec = lb_vec,
        ub_vec = ub_vec,
        tf_inner = tf_fixed,
        f_count_ref = shared_f_count

        function penalty_objective(x::AbstractVector{T}) where T
            any(isnan, x) && return T(NaN)
            any(isinf, x) && return T(Inf)

            violation = zero(T)
            @inbounds @simd for i in eachindex(x)
                xi = x[i]
                if xi < lb_vec[i]
                    violation += lb_vec[i] - xi
                    x_buffer[i] = lb_vec[i]
                elseif xi > ub_vec[i]
                    violation += xi - ub_vec[i]
                    x_buffer[i] = ub_vec[i]
                else
                    x_buffer[i] = xi
                end
            end

            # Manual counter increment
            f_count_ref[] += 1
            f_val = tf_inner.f_original(x_buffer)

            return f_val + T(BOUND_PENALTY) * violation
        end
    end

    # ══════════════════════════════════════════════════════════════════════
    # 7. Define in-place gradient
    # ══════════════════════════════════════════════════════════════════════
    grad_wrap! = let x_buffer = x_buffer,
        lb_vec = lb_vec,
        ub_vec = ub_vec,
        tf_inner = tf_fixed,
        grad_count_ref = shared_grad_count

        function penalty_gradient!(g::AbstractVector{T}, x::AbstractVector{T}) where T
            if any(isnan, x)
                fill!(g, T(NaN))
                return nothing
            end

            if any(isinf, x)
                fill!(g, T(Inf))
                return nothing
            end

            @inbounds @simd for i in eachindex(x)
                x_buffer[i] = clamp(x[i], lb_vec[i], ub_vec[i])
            end

            grad_count_ref[] += 1
            grad_temp = tf_inner.grad_original(x_buffer)
            copyto!(g, grad_temp)

            @inbounds @simd for i in eachindex(g, x)
                if x[i] < lb_vec[i]
                    g[i] = -T(BOUND_PENALTY)
                elseif x[i] > ub_vec[i]
                    g[i] = T(BOUND_PENALTY)
                end
            end

            return nothing
        end
    end

    # ══════════════════════════════════════════════════════════════════════
    # 8. Define out-of-place gradient wrapper
    # ══════════════════════════════════════════════════════════════════════
    grad_wrap = let grad_wrap! = grad_wrap!
        function penalty_gradient(x::AbstractVector{T}) where T
            g = similar(x)
            grad_wrap!(g, x)
            return g
        end
    end

    # ══════════════════════════════════════════════════════════════════════
    # 9. Construct metadata
    # ══════════════════════════════════════════════════════════════════════
    new_meta = deepcopy(tf_fixed.meta)

    new_meta[:name] = string(tf_fixed.meta[:name], "_constrained")

    original_desc = get(new_meta, :description, "")
    new_meta[:description] = if isempty(original_desc)
        "Hard box constraints via L1 exact penalty (ρ = $(BOUND_PENALTY))"
    else
        original_desc * " [Hard box constraints via L1 exact penalty (ρ = $(BOUND_PENALTY))]"
    end

    filter!(p -> p ≠ "bounded", new_meta[:properties])

    new_meta[:lb] = nothing
    new_meta[:ub] = nothing
    new_meta[:constraint_method] = "L1 exact penalty"
    new_meta[:penalty_coefficient] = BOUND_PENALTY
    new_meta[:original_bounds] = (lb=lb_vec, ub=ub_vec)

    # ══════════════════════════════════════════════════════════════════════
    # 10. Create TestFunction with shared counters using alternative constructor
    # ══════════════════════════════════════════════════════════════════════
    # This now uses the alternative constructor that accepts counter Refs
    return TestFunction(
        f_wrap,
        grad_wrap,
        new_meta,
        shared_f_count,      # Shared Ref{Int}
        shared_grad_count    # Shared Ref{Int}
    )
end

export with_box_constraints