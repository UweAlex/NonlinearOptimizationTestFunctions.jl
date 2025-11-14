# src/functions/weierstrass.jl
# Purpose: Implementation of the Weierstrass test function (f_166 from Jamil & Yang, 2013).
# Parameters a=0.5, b=3, k_max=20 are standard in literature but not specified in Jamil & Yang.
# This is an adapted implementation for practical use.

export WEIERSTRASS_FUNCTION, weierstrass, weierstrass_gradient

function weierstrass(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("weierstrass requires at least 1 dimension"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    if T <: BigFloat
        setprecision(256)
    end
    
    a = T(0.5)
    b = T(3.0)
    kmax = 20
    sum1 = zero(T)
    sum2 = zero(T)
    @inbounds for k in 0:kmax
        ak = a^k
        bk = b^k
        sum2 += ak * cos(pi * bk)
        for i in 1:n
            sum1 += ak * cos(2 * pi * bk * (x[i] + T(0.5)))
        end
    end
    sum1 - n * sum2
end

function weierstrass_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual, BigFloat}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n < 1 && throw(ArgumentError("weierstrass requires at least 1 dimension"))
    any(isnan.(x)) && return fill(T(NaN), n)
    any(isinf.(x)) && return fill(T(Inf), n)
    
    if T <: BigFloat
        setprecision(256)
    end
    
    grad = zeros(T, n)
    a = T(0.5)
    b = T(3.0)
    kmax = 20
    @inbounds for i in 1:n
        for k in 0:kmax
            ak = a^k
            bk = b^k
            arg = 2 * pi * bk * (x[i] + T(0.5))
            grad[i] -= 2 * pi * bk * ak * sin(arg)
        end
    end
    grad
end

const WEIERSTRASS_FUNCTION = TestFunction(
    weierstrass,
    weierstrass_gradient,
    Dict{Symbol, Any}(
        :name => "weierstrass",
        :description => """
        Weierstrass function (f_166). Formula from Jamil & Yang (2013, p. 38).
        Parameters a=0.5, b=3, k_max=20 are standard in literature (e.g. Al-Roomi, 2015; Surjanovic & Bingham) 
        but not specified in Jamil & Yang. This is an adapted implementation for practical use.
        The function is continuous and differentiable (finite sum). 
        Theoretical global minimum: 0 at x=zeros(n); in practice f(0) ≈ 0.0 (exact with finite precision).
        """,
        :math => raw"""f(\mathbf{x}) = \sum_{i=1}^{n} \left[ \sum_{k=0}^{20} a^k \cos(2 \pi b^k (x_i + 0.5)) \right] - n \sum_{k=0}^{20} a^k \cos(\pi b^k), \quad a=0.5, b=3.""",
        :start => (n::Int) -> (n < 1 && throw(ArgumentError("weierstrass requires at least 1 dimension")); fill(0.4, n)),
        :min_position => (n::Int) -> (n < 1 && throw(ArgumentError("weierstrass requires at least 1 dimension")); zeros(n)),
        :min_value => (n::Int) -> 0.0,  # Theoretical and practical
        :default_n => 2,
        :properties => ["continuous", "differentiable", "separable", "scalable", "multimodal", "bounded"],
        :source => "Jamil & Yang (2013, p. 38); parameters adapted from Al-Roomi (2015)",
        :lb => (n::Int) -> (n < 1 && throw(ArgumentError("weierstrass requires at least 1 dimension")); fill(-0.5, n)),
        :ub => (n::Int) -> (n < 1 && throw(ArgumentError("weierstrass requires at least 1 dimension")); fill(0.5, n)),
    )
)

@assert "weierstrass" == basename(@__FILE__)[1:end-3] "weierstrass: Dateiname mismatch!"