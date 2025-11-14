# src/functions/xin_she_yang2.jl
# Purpose: Implementation of the Xin-She Yang Function 2 test function.
# Global minimum: f(x*)=0.0 at x*=zeros(n).
# Bounds: -2π ≤ x_i ≤ 2π.

export XIN_SHE_YANG2_FUNCTION, xin_she_yang2, xin_she_yang2_gradient

function xin_she_yang2(x::AbstractVector{T}) where T <: Union{Real, ForwardDiff.Dual, BigFloat}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("xin_she_yang2 requires at least 1 dimension"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    if T <: BigFloat
        Base.MPFR.setprecision(256)
    end
    
    sum_abs = zero(T)
    sum_sin = zero(T)
    @inbounds for i in 1:n
        sum_abs += abs(x[i])
        sum_sin += sin(x[i])^2
    end
    sum_abs * exp(-sum_sin)
end

function xin_she_yang2_gradient(x::AbstractVector{T}) where T <: Union{Real, ForwardDiff.Dual, BigFloat}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("xin_she_yang2 requires at least 1 dimension"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    if T <: BigFloat
        Base.MPFR.setprecision(256)
    end
    
    grad = zeros(T, n)
    sum_abs = zero(T)
    sum_sin = zero(T)
    @inbounds for i in 1:n
        sum_abs += abs(x[i])
        sum_sin += sin(x[i])^2
    end
    exp_neg = exp(-sum_sin)
    @inbounds for i in 1:n
        xi = x[i]
        sign_xi = xi == zero(T) ? zero(T) : sign(xi)
        grad[i] = sign_xi * exp_neg - sum_abs * exp_neg * sin(2 * xi)
    end
    grad
end

const XIN_SHE_YANG2_FUNCTION = TestFunction(
    xin_she_yang2,
    xin_she_yang2_gradient,
    Dict{Symbol, Any}(
        :name => "xin_she_yang2",
        :description => "Xin-She Yang Function 2; Properties based on Jamil & Yang (2013, p. 30); multimodal non-separable with abs and sin^2; partially differentiable at 0.",
        :math => raw"""f(\mathbf{x}) = \left( \sum_{i=1}^{D} |x_i| \right) \exp \left[ - \sum_{i=1}^{D} \sin^2(x_i) \right].""",
        :start => (n::Int) -> begin n < 1 && throw(ArgumentError("xin_she_yang2 requires at least 1 dimension")); rand(n) .* 4π .- 2π end,
        :min_position => (n::Int) -> begin n < 1 && throw(ArgumentError("xin_she_yang2 requires at least 1 dimension")); zeros(n) end,
        :min_value => (n::Int) -> 0.0,
        :default_n => 2,
        :properties => ["bounded", "continuous", "multimodal", "non-separable", "scalable", "partially differentiable"],
        :source => "Jamil & Yang (2013, p. 30)",
        :lb => (n::Int) -> begin n < 1 && throw(ArgumentError("xin_she_yang2 requires at least 1 dimension")); fill(-2π, n) end,
        :ub => (n::Int) -> begin n < 1 && throw(ArgumentError("xin_she_yang2 requires at least 1 dimension")); fill(2π, n) end,
    )
)

# Optional: Validierung beim Laden
@assert "xin_she_yang2" == basename(@__FILE__)[1:end-3] "xin_she_yang2: Dateiname mismatch!"