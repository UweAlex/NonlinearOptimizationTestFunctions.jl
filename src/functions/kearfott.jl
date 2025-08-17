# src/functions/kearfott.jl
# Purpose: Defines the Kearfott test function and its gradient.
# Context: Part of NonlinearOptimizationTestFunctions, used for testing optimization algorithms.
# Last modified: 17 August 2025

function kearfott(x)
    length(x) == 2 || throw(ArgumentError("Kearfott function is defined only for n=2"))
    x1, x2 = x
    a = x1^2 + x2^2 - 2
    b = x1^2 - x2^2 - 1
    return a^2 + b^2
end

function kearfott_gradient(x)
    length(x) == 2 || throw(ArgumentError("Kearfott function is defined only for n=2"))
    x1, x2 = x
    a = x1^2 + x2^2 - 2
    b = x1^2 - x2^2 - 1
    g1 = 4 * x1 * (a + b)
    g2 = 4 * x2 * (a - b)
    return [g1, g2]
end

const KEARFOTT_FUNCTION = TestFunction(
    kearfott,
    kearfott_gradient,
    Dict(
        :name => "kearfott",
        :start => (n) -> fill(0.0, n),
        :min_position => (n) -> [sqrt(1.5), sqrt(0.5)],
        :min_value => 0.0,
        :properties => ["multimodal", "non-convex", "non-separable", "differentiable", "bounded"],
        :lb => (n) -> fill(-3.0, n),
        :ub => (n) -> fill(4.0, n)
    )
)

export kearfott, kearfott_gradient, KEARFOTT_FUNCTION