# src/functions/giunta.jl
# Purpose: Defines the Giunta test function and its gradient.
# Context: Part of NonlinearOptimizationTestFunctions, used for testing optimization algorithms.
# Last modified: 17 August 2025

function giunta(x)
    length(x) == 2 || throw(ArgumentError("Giunta function is defined only for n=2"))
    s = 0.0
    for xi in x
        a = 16/15 * xi - 1
        s += sin(a) + sin(a)^2 + (1/50) * sin(4*a)
    end
    return 0.6 + s
end

function giunta_gradient(x)
    length(x) == 2 || throw(ArgumentError("Giunta function is defined only for n=2"))
    grad = zeros(2)
    for i in 1:2
        a = 16/15 * x[i] - 1
        da_dx = 16/15
        d = cos(a) + 2 * sin(a) * cos(a) + 0.08 * cos(4*a)
        grad[i] = d * da_dx
    end
    return grad
end

const GIUNTA_FUNCTION = TestFunction(
    giunta,
    giunta_gradient,
    Dict(
        :name => "giunta",
        :start => (n) -> fill(0.0, n),
        :min_position => (n) -> [0.4673200277395354, 0.4673200277395354],
        :min_value => 0.06447042053690566,
        :properties => ["multimodal", "non-convex", "separable", "differentiable", "bounded"],
        :lb => (n) -> fill(-1.0, n),
        :ub => (n) -> fill(1.0, n)
    )
)

export giunta, giunta_gradient, GIUNTA_FUNCTION