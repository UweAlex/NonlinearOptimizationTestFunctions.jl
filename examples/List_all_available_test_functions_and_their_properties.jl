# examples/List_all_available_test_functions_and_their_properties.jl
# Purpose: Lists all test functions with their start points, minima, and properties.
# Context: Part of NonlinearOptimizationTestFunctionsInJulia, enabling inspection of function characteristics.
# Last modified: 11. Juli 2025, 14:10 PM CEST
using NonlinearOptimizationTestFunctionsInJulia
n = 2
for tf in values(NonlinearOptimizationTestFunctionsInJulia.TEST_FUNCTIONS)
    println("$(tf.meta[:name]): Start at $(tf.meta[:start](n)), Minimum at $(tf.meta[:min_position](n)), Value $(tf.meta[:min_value]), Properties: $(join(tf.meta[:properties], ", "))")
end