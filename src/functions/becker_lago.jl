# src/functions/becker_lago.jl
# Purpose: Implementation of the Becker and Lago test function (Price, 1977).
# Global minimum: f(x*)=0 at x*∈{(5, 5), (5, -5), (-5, 5), (-5, -5)}.
# Bounds: -10 ≤ x_i ≤ 10.
# Properties: continuous, separable, multimodal, bounded; contains absolute value terms (non-differentiable at x_i=0).
# Note: Possibly misidentified as Price 3 (Jamil & Yang, 2013, No. 96) in some contexts.
# Last modified: October 01, 2025.

export BECKER_LAGO_FUNCTION, becker_lago, becker_lago_gradient

function becker_lago(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Becker and Lago requires exactly 2 dimensions"))
    any(isnan.(x)) && return T(NaN)
    any(isinf.(x)) && return T(Inf)
    
    let
        sum_sq = zero(T)
        @inbounds for i in 1:2
            abs_xi = abs(x[i])
            sum_sq += (abs_xi - 5)^2
        end
        sum_sq
    end
end

function becker_lago_gradient(x::AbstractVector{T}) where {T<:Union{Real, ForwardDiff.Dual}}
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Becker and Lago requires exactly 2 dimensions"))
    any(isnan.(x)) && return fill(T(NaN), 2)
    any(isinf.(x)) && return fill(T(Inf), 2)
    
    let
        grad = zeros(T, 2)
        @inbounds for i in 1:2
            abs_xi = abs(x[i])
            grad[i] = 2 * (abs_xi - 5) * sign(x[i])  # sign(0)=0 for x_i=0
        end
        grad
    end
end

const BECKER_LAGO_FUNCTION = TestFunction(
    becker_lago,
    becker_lago_gradient,
    Dict(
        :name => "becker_lago",
        :description => "Becker and Lago function from Price (1977). Properties: continuous, separable, multimodal, bounded. Contains absolute value terms (non-differentiable at x_i=0). Four minima at (5, 5), (5, -5), (-5, 5), (-5, -5). Possibly misidentified as Price 3 (Jamil & Yang, 2013, No. 96) in some contexts.",
        :math => raw"f(\mathbf{x}) = (|x_1| - 5)^2 + (|x_2| - 5)^2",
        :start => () -> [0.0, 0.0],
        :min_position => () -> [5.0, 5.0],  # One of the four minima
        :min_value => () -> 0.0,
        :properties => ["continuous", "separable", "multimodal", "bounded"],
        :properties_source => "Price (1977) via Jamil & Yang (2013, No. 96)",
        :source => "Price (1977); referenced in Jamil & Yang (2013), https://arxiv.org/abs/1308.4008",
        :lb => () -> [-10.0, -10.0],
        :ub => () -> [10.0, 10.0],
    )
)