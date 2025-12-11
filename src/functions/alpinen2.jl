# src/functions/alpinen2.jl
# Purpose: Implementation of the AlpineN2 test function.
# Global minimum: f(x*)= -(2.8081311800070053)^n at x*=fill(7.917052698245946, n).
# Bounds: 0.0 ≤ x_i ≤ 10.0.

export ALPINEN2_FUNCTION, alpinen2, alpinen2_gradient

function alpinen2(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("alpinen2 requires at least 1 dimension"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    if T <: BigFloat
        setprecision(256)
    end
    
    prod = one(T)
    @inbounds for xi in x
        prod *= sqrt(xi) * sin(xi)
    end
    -prod
end

function alpinen2_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("alpinen2 requires at least 1 dimension"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    if T <: BigFloat
        setprecision(256)
    end
    
    grad = zeros(T, n)
    f_val = alpinen2(x)          # = -prod
    @inbounds for i in 1:n
        xi = x[i]
        if xi == 0
            grad[i] = zero(T)
        else
            u_i = sqrt(xi) * sin(xi)
            du_i = sin(xi)/(2*sqrt(xi)) + sqrt(xi)*cos(xi)
            grad[i] = f_val * du_i / u_i   # korrektes Vorzeichen: f_val = -prod
        end
    end
    grad
end

const ALPINEN2_FUNCTION = TestFunction(
    alpinen2,
    alpinen2_gradient,
    Dict{Symbol, Any}(
        :name => "alpinen2",
        :description => "Properties based on Jamil & Yang (2013, p. 5); Fully differentiable on [0,10]^n.",
        :math => raw"""f(\mathbf{x}) = -\prod_{i=1}^n \sqrt{x_i} \sin x_i \quad (x_i \geq 0).""",
        :start => (n::Int) -> begin n < 1 && throw(ArgumentError("alpinen2 requires at least 1 dimension")); fill(7.0, n) end,
        :min_position => (n::Int) -> begin n < 1 && throw(ArgumentError("alpinen2 requires at least 1 dimension")); fill(7.917052698245946, n) end,
        :min_value => (n::Int) -> -(2.8081311800070053)^n,
        :default_n => 2,
        :properties => ["multimodal", "non-convex", "separable", "differentiable", "scalable", "bounded"],
        :source => "Jamil & Yang (2013, p. 5)",
        :lb => (n::Int) -> begin n < 1 && throw(ArgumentError("alpinen2 requires at least 1 dimension")); zeros(n) end,
        :ub => (n::Int) -> begin n < 1 && throw(ArgumentError("alpinen2 requires at least 1 dimension")); fill(10.0, n) end,
    )
)

