# src/functions/devilliersglasser2.jl
# Purpose: Implementation of the De Villiers-Glasser 2 test function.
# Context: Non-scalable, 5-dimensional nonlinear least squares problem.
# Source: de Villiers and Glasser (1981), as described in Jamil & Yang (2013).
# Global minimum: f(x*)=0 at x*=[53.81, 1.27, 3.012, 2.13, 0.507].
# Bounds: -500 ≤ x_i ≤ 500.
# Last modified: September 25, 2025.
# Note: Assumes x[2] > 0 for real-valued powers; negative bases with non-integer exponents may lead to complex results.

export DEVILLIERSGLASSER2_FUNCTION, devilliersglasser2, devilliersglasser2_gradient

function devilliersglasser2(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 5 && throw(ArgumentError("devilliersglasser2 requires exactly 5 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    # Local arrays (no global const to avoid redefinition)
    let
        local_t = T(0.1) * collect(T, 0:23)  # t_i = 0.1*(i-1) for i=1:24
        local_y = similar(local_t)
        @inbounds for (j, t) in enumerate(local_t)
            local_y[j] = T(53.81) * (T(1.27) ^ t) * tanh(T(3.012)*t + sin(T(2.13)*t)) * cos(exp(T(0.507))*t)
        end
        
        x1, x2, x3, x4, x5 = x
        sum_sq = zero(T)
        @inbounds for i in eachindex(local_t)
            t = local_t[i]
            y = local_y[i]
            u = x3 * t + sin(x4 * t)
            v = t * exp(x5)
            pow2 = x2 ^ t
            g = x1 * pow2 * tanh(u) * cos(v)
            e = g - y
            sum_sq += e^2
        end
        sum_sq
    end
end

function devilliersglasser2_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 5 && throw(ArgumentError("devilliersglasser2 requires exactly 5 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), 5)
    any(isinf.(x)) && return fill(T(Inf), 5)
    
    # Local arrays
    let
        local_t = T(0.1) * collect(T, 0:23)
        local_y = similar(local_t)
        @inbounds for (j, t) in enumerate(local_t)
            local_y[j] = T(53.81) * (T(1.27) ^ t) * tanh(T(3.012)*t + sin(T(2.13)*t)) * cos(exp(T(0.507))*t)
        end
        
        x1, x2, x3, x4, x5 = x
        grad = zeros(T, 5)
        @inbounds for i in eachindex(local_t)
            t = local_t[i]
            y = local_y[i]
            u = x3 * t + sin(x4 * t)
            v = t * exp(x5)
            pow2 = x2 ^ t
            tanh_u = tanh(u)
            cos_v = cos(v)
            g = x1 * pow2 * tanh_u * cos_v
            e = g - y
            sech2_u = one(T) - tanh_u^2
            sin_v = sin(v)
            
            # Partial derivatives for g w.r.t. each xj
            dg_dx1 = pow2 * tanh_u * cos_v
            dg_dx2 = ifelse(t == zero(T), zero(T), x1 * t * pow2 / x2 * tanh_u * cos_v)  # Handle t=0
            dg_dx3 = x1 * pow2 * sech2_u * t * cos_v
            dg_dx4 = x1 * pow2 * sech2_u * cos(x4 * t) * t * cos_v
            dg_dx5 = x1 * pow2 * tanh_u * (-sin_v * v)
            
            # Accumulate 2 * e * dg_dxj
            grad[1] += 2 * e * dg_dx1
            grad[2] += 2 * e * dg_dx2
            grad[3] += 2 * e * dg_dx3
            grad[4] += 2 * e * dg_dx4
            grad[5] += 2 * e * dg_dx5
        end
        grad
    end
end

const DEVILLIERSGLASSER2_FUNCTION = TestFunction(
    devilliersglasser2,
    devilliersglasser2_gradient,
    Dict(
        :name => "devilliersglasser2",
        :description => "De Villiers-Glasser function no. 2 (de Villiers and Glasser, 1981). A 5-dimensional nonlinear least squares problem for parameter estimation. Global minimum f(x*)=0. Properties based on Jamil & Yang (2013).",
        :math => raw"""f(\mathbf{x}) = \sum_{i=1}^{24} \left[ x_1 x_2^{t_i} \tanh\left(x_3 t_i + \sin(x_4 t_i)\right) \cos\left(t_i e^{x_5}\right) - y_i \right]^2 \\
        \text{where } t_i = 0.1(i-1), \\
        y_i = 53.81 \cdot 1.27^{t_i} \tanh(3.012 t_i + \sin(2.13 t_i)) \cos(e^{0.507} t_i).""",
        :start => () -> [10.0, 1.0, 1.0, 1.0, 1.0],
        :min_position => () -> [53.81, 1.27, 3.012, 2.13, 0.507],
        :min_value => () -> 0.0,
        :properties => ["bounded", "continuous", "differentiable", "multimodal", "non-separable"],
        :properties_source => "Jamil & Yang (2013)",
        :lb => () -> [0.0, 0.0, 0.0, 0.0, 0.0],
        :ub => () -> [500.0, 500.0, 500.0, 500.0, 500.0],
    )
)