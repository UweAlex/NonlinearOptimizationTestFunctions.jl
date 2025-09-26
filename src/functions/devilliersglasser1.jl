# src/functions/devilliersglasser1.jl
# Purpose: Implementation of the De Villiers-Glasser 1 test function.
# Context: Non-scalable (n=4), from De Villiers and Glasser (1981).
# Global minimum: f(x*)=0 at x*=[60.137, 1.371, 3.112, 1.761].
# Bounds: -500 ≤ x_i ≤ 500.
# Last modified: September 25, 2025.
# Wichtig: Halte Code sauber – keine Erklärungen inline ohne #; validiere Mapping/Gradient separat.

export DEVILLIERSGLASSER1_FUNCTION, devilliersglasser1, devilliersglasser1_gradient

function devilliersglasser1(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 4 && throw(ArgumentError("devilliersglasser1 requires exactly 4 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    if x[2] < zero(T)
        return T(NaN)
    end
    
    # Local constants (no global redefinition)
    let
        local_tis = 0.1 * collect(0:23)
        local_yis = 60.137 * 1.371 .^ local_tis .* sin.(3.112 * local_tis .+ 1.761)
        
        sum_sq = zero(T)
        @inbounds for i in 1:24
            ti = local_tis[i]
            model = x[1] * x[2]^ti * sin(x[3] * ti + x[4])
            res = model - local_yis[i]
            sum_sq += res^2
        end
        sum_sq
    end
end

function devilliersglasser1_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 4 && throw(ArgumentError("devilliersglasser1 requires exactly 4 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), 4)
    any(isinf.(x)) && return fill(T(Inf), 4)
    if x[2] < zero(T)
        return fill(T(NaN), 4)
    end
    
    # Local constants
    let
        local_tis = 0.1 * collect(0:23)
        local_yis = 60.137 * 1.371 .^ local_tis .* sin.(3.112 * local_tis .+ 1.761)
        
        grad = zeros(T, 4)
        @inbounds for i in 1:24
            ti = local_tis[i]
            pow = x[2]^ti
            sin_term = sin(x[3] * ti + x[4])
            cos_term = cos(x[3] * ti + x[4])
            model = x[1] * pow * sin_term
            res = model - local_yis[i]
            factor = 2 * res
            
            grad[1] += factor * (pow * sin_term)
            if ti > 0
                grad[2] += factor * (x[1] * ti * x[2]^(ti - 1) * sin_term)
            else
                grad[2] += zero(T)
            end
            grad[3] += factor * (x[1] * pow * cos_term * ti)
            grad[4] += factor * (x[1] * pow * cos_term)
        end
        grad
    end
end

const DEVILLIERSGLASSER1_FUNCTION = TestFunction(
    devilliersglasser1,
    devilliersglasser1_gradient,
    Dict(
        :name => "devilliersglasser1",
        :description => "De Villiers-Glasser Function 1, from De Villiers and Glasser (1981). Returns NaN if x2 < 0 to avoid complex exponentiation; literature bounds -500 ≤ x ≤ 500. Properties based on Jamil & Yang (2013).",
        :math => raw"""f(\mathbf{x}) = \sum_{i=1}^{24} \left[ x_1 x_2^{t_i} \sin(x_3 t_i + x_4) - y_i \right]^2, \quad t_i = 0.1(i-1), \quad y_i = 60.137 \times 1.371^{t_i} \sin(3.112 t_i + 1.761).""",
        :start => () -> [1.0, 1.0, 1.0, 1.0],
        :min_position => () -> [60.137, 1.371, 3.112, 1.761],
        :min_value => () -> 0.0,
        :properties => ["bounded", "continuous", "differentiable", "non-separable", "multimodal"],
        :properties_source => "Jamil & Yang (2013)",
        :lb => () -> [0.0, 0.0, 0.0, 0.0],
        :ub => () -> [500.0, 500.0, 500.0, 500.0],
    )
)