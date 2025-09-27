# src/functions/gulfresearch.jl
# Purpose: Implementation of the Gulf Research Problem test function.
# Context: Non-scalable, 3D, from Jamil & Yang (2013), function 60.
# Global minimum: f(x*)=0 at x*=[50, 25, 1.5].
# Bounds: 0.1 <= x1 <= 100, 0 <= x2 <= 25.6, 0 <= x3 <= 5.
# Last modified: September 26, 2025.
# Properties based on Jamil & Yang (2013).

export GULFRESEARCH_FUNCTION, gulfresearch, gulfresearch_gradient

function gulfresearch(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 3 && throw(ArgumentError("Gulf Research requires exactly 3 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    x1, x2, x3 = x[1], x[2], x[3]
    x1 <= zero(T) && return T(Inf)  # Avoid division by zero or negative
    
    # Local arrays (no global const)
    let
        m = 99
        u = zeros(T, m)
        t = zeros(T, m)
        @inbounds for i in 1:m
            ti = T(0.01 * i)
            log_ti = log(ti)
            u[i] = T(25) + (-T(50) * log_ti)^(T(2)/T(3))
            t[i] = ti
        end
        
        sum_sq = zero(T)
        @inbounds for j in 1:m
            uj = u[j]
            diff = uj - x2
            zj = (diff ^ x3) / x1
            inner = exp(-zj) - t[j]
            sum_sq += inner^2
        end
        sum_sq
    end
end

function gulfresearch_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 3 && throw(ArgumentError("Gulf Research requires exactly 3 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), 3)
    any(isinf.(x)) && return fill(T(Inf), 3)
    
    x1, x2, x3 = x[1], x[2], x[3]
    x1 <= zero(T) && return fill(T(Inf), 3)
    
    # Local arrays
    let
        m = 99
        u = zeros(T, m)
        t = zeros(T, m)
        @inbounds for i in 1:m
            ti = T(0.01 * i)
            log_ti = log(ti)
            u[i] = T(25) + (-T(50) * log_ti)^(T(2)/T(3))
            t[i] = ti
        end
        
        grad = zeros(T, 3)
        one_t = one(T)
        @inbounds for j in 1:m
            uj = u[j]
            diff = uj - x2
            zj = (diff ^ x3) / x1
            exp_z = exp(-zj)
            inner = exp_z - t[j]
            common = -T(2) * inner * exp_z
            
            # dz/dx1 = -zj / x1
            grad[1] += common * (-zj / x1)
            
            # dz/dx2 = - (x3 / x1) * diff^(x3 - 1)
            if x3 == one_t
                pow_diff = one_t / diff  # limit as x3->1, but since x3=1.5 ok
            else
                pow_diff = diff ^ (x3 - one_t)
            end
            dz2 = - (x3 / x1) * pow_diff
            grad[2] += common * dz2
            
            # dz/dx3 = zj * log(diff)
            dz3 = zj * log(diff)
            grad[3] += common * dz3
        end
        grad
    end
end

const GULFRESEARCH_FUNCTION = TestFunction(
    gulfresearch,
    gulfresearch_gradient,
    Dict(
        :name => "gulfresearch",
        :description => "The Gulf Research and Development problem, a 3D multimodal function. Properties based on Jamil & Yang (2013).",
        :math => raw"""f(\mathbf{x}) = \sum_{i=1}^{99} \left[ \exp\left( -\frac{(u_i - x_2)^{x_3}}{x_1} \right) - 0.01 i \right]^2, \quad u_i = 25 + \left[-50 \ln(0.01 i)\right]^{2/3}.""",
        :start => () -> [1.0, 1.0, 1.0],
        :min_position => () -> [50.0, 25.0, 1.5],
        :min_value => () -> 0.0,
        :properties => ["bounded", "continuous", "differentiable", "multimodal", "non-separable"],
        :properties_source => "Jamil & Yang (2013)",
        :source => "Jamil & Yang (2013)",
        :lb => () -> [0.1, 0.0, 0.0],
        :ub => () -> [100.0, 25.6, 5.0],
    )
)