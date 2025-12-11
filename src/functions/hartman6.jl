# src/functions/hartman6.jl
# Purpose: Implementation of the Hartman Function 6 test function.
# Context: Non-scalable, 6D, from Jamil & Yang (2013), function 63.
# Global minimum: f(x*)=-3.32237 at x*=[0.20169, 0.15001, 0.476874, 0.275332, 0.311652, 0.6573].
# Bounds: 0 <= x_i <= 1.
# Last modified: September 26, 2025.
# Properties based on Jamil & Yang (2013).

export HARTMAN6_FUNCTION, hartman6, hartman6_gradient

function hartman6(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 6 && throw(ArgumentError("Hartman 6 requires exactly 6 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    # Local matrices (no global const)
    let
        A = [T(10)   T(3)    T(17)   T(3.5)  T(1.7)  T(8);
             T(0.05) T(10)   T(17)   T(0.1)  T(8)    T(14);
             T(3)    T(3.5)  T(1.7)  T(10)   T(17)   T(8);
             T(17)   T(8)    T(0.05) T(10)   T(0.1)  T(14)]
        
        P = [T(0.1312) T(0.1696) T(0.5569) T(0.0124) T(0.8283) T(0.5886);
             T(0.2329) T(0.4135) T(0.8307) T(0.3736) T(0.1004) T(0.9991);
             T(0.2348) T(0.1451) T(0.3522) T(0.2883) T(0.3047) T(0.6650);
             T(0.4047) T(0.8828) T(0.8732) T(0.5743) T(0.1091) T(0.0381)]
        
        c = [T(1), T(1.2), T(3), T(3.2)]
        
        sum_f = zero(T)
        @inbounds for i in 1:4
            si = zero(T)
            @inbounds for j in 1:6
                si += A[i,j] * (x[j] - P[i,j])^2
            end
            sum_f += c[i] * exp(-si)
        end
        -sum_f
    end
end

function hartman6_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 6 && throw(ArgumentError("Hartman 6 requires exactly 6 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), 6)
    any(isinf.(x)) && return fill(T(Inf), 6)
    
    # Local matrices
    let
        A = [T(10)   T(3)    T(17)   T(3.5)  T(1.7)  T(8);
             T(0.05) T(10)   T(17)   T(0.1)  T(8)    T(14);
             T(3)    T(3.5)  T(1.7)  T(10)   T(17)   T(8);
             T(17)   T(8)    T(0.05) T(10)   T(0.1)  T(14)]
        
        P = [T(0.1312) T(0.1696) T(0.5569) T(0.0124) T(0.8283) T(0.5886);
             T(0.2329) T(0.4135) T(0.8307) T(0.3736) T(0.1004) T(0.9991);
             T(0.2348) T(0.1451) T(0.3522) T(0.2883) T(0.3047) T(0.6650);
             T(0.4047) T(0.8828) T(0.8732) T(0.5743) T(0.1091) T(0.0381)]
        
        c = [T(1), T(1.2), T(3), T(3.2)]
        
        exp_terms = zeros(T, 4)
        @inbounds for i in 1:4
            si = zero(T)
            @inbounds for j in 1:6
                si += A[i,j] * (x[j] - P[i,j])^2
            end
            exp_terms[i] = c[i] * exp(-si)
        end
        
        grad = zeros(T, 6)
        two_t = convert(T, 2)
        @inbounds for k in 1:6
            @inbounds for i in 1:4
                grad[k] += two_t * exp_terms[i] * A[i,k] * (x[k] - P[i,k])
            end
        end
        grad
    end
end

const HARTMAN6_FUNCTION = TestFunction(
    hartman6,
    hartman6_gradient,
    Dict(
        :name => "hartman6",
        :description => "The Hartman Function 6, a 6D multimodal non-separable function. Properties based on Jamil & Yang (2013).",
        :math => raw"""f(\mathbf{x}) = -\sum_{i=1}^{4} c_i \exp\left( -\sum_{j=1}^{6} a_{ij} (x_j - p_{ij})^2 \right).""",
        :start => () -> zeros(6),
        :min_position => () -> [0.20168951265373836, 0.15001069271431358, 0.4768739727643224, 0.2753324306183083, 0.31165161653706114, 0.657300534163256],
        :min_value => () -> -3.3223680114155147,
        :properties => ["bounded", "continuous", "differentiable", "multimodal", "non-separable"],
        :properties_source => "Jamil & Yang (2013)",
        :source => "Jamil & Yang (2013)",
        :lb => () -> zeros(6),
        :ub => () -> ones(6),
    )
)

 
 
