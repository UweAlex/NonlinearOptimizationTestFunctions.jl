# tst.jl
# Purpose: Debug the Easom function by computing its values at three points.
# Context: Standalone test for NonlinearOptimizationTestFunctions.
# Last modified: 21 July 2025

using NonlinearOptimizationTestFunctions: easom

# Test points
points = [
    [0.0, 0.0],        # Start point, expected: -0.01831563888873418
    [pi, pi],          # Minimum point, expected: -1.0
    [3.0, 3.0]         # Near minimum, for optimization testing
]

for (i, x) in enumerate(points)
    println("Test $i: Evaluating easom at x = $x")
    result = easom(x)
    println("Function value: $result\n")
end