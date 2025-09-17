# src/functions/bohachevsky3.jl
# Bohachevsky 3 Function
# Described in Jamil & Yang (2013), f19
# Properties: continuous, differentiable, non-separable, non-scalable, multimodal, bounded
# Global minimum: f(0.0, 0.0) = 0.0
# Bounds: [-100.0, 100.0]^2
# Not in Molga & Smutnicki (2005)

using ForwardDiff

function bohachevsky3(x::AbstractVector)
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Bohachevsky 3 requires exactly 2 dimensions"))
    
    # Handle NaN or infinite inputs
    if any(isnan, x)
        return NaN
    elseif any(!isfinite, x)  # Covers Inf and -Inf
        return Inf
    end
    
    return x[1]^2 + 2 * x[2]^2 - 0.3 * cos(3 * π * x[1] + 4 * π * x[2]) + 0.3
end

function bohachevsky3_gradient(x::AbstractVector)
    n = length(x)
    n == 0 && throw(ArgumentError("Input vector cannot be empty"))
    n != 2 && throw(ArgumentError("Bohachevsky 3 requires exactly 2 dimensions"))
    
    # Handle NaN or infinite inputs
    if any(isnan, x)
        return [NaN, NaN]
    elseif any(!isfinite, x)  # Covers Inf and -Inf
        return [Inf, Inf]
    end
    
    sin_term = sin(3 * π * x[1] + 4 * π * x[2])
    return [2 * x[1] + 0.3 * 3 * π * sin_term, 4 * x[2] + 0.3 * 4 * π * sin_term]
end

meta = Dict(
    :name => "bohachevsky3",
    :start => () -> [0.01, 0.01],
    :min_position => () -> [0.0, 0.0],
    :min_value => () -> 0.0,
    :properties => Set(["continuous", "differentiable", "multimodal", "non-convex", "non-separable", "bounded"]),
    :lb => () -> [-100.0, -100.0],
    :ub => () -> [100.0, 100.0],
    :in_molga_smutnicki_2005 => false,
    :description => "Bohachevsky 3 Function from Jamil & Yang (2013), f19.",
    :math => raw"$f(x) = x_1^2 + 2x_2^2 - 0.3 \cos(3\pi x_1 + 4\pi x_2) + 0.3$"
)

const BOHACHEVSKY3_FUNCTION = TestFunction(bohachevsky3, bohachevsky3_gradient, meta)

export BOHACHEVSKY3_FUNCTION, bohachevsky3, bohachevsky3_gradient
