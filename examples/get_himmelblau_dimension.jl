# examples/get_himmelblau_dimension.jl
# Purpose: Prints the dimension of the Himmelblau test function.
# Context: Uses dim(tf) from NonlinearOptimizationTestFunctions to determine dimension.
# Last modified: 04 September 2025

using NonlinearOptimizationTestFunctions

# Print dimension of Himmelblau function

# Access Himmelblau function from TEST_FUNCTIONS (a Dict{String, TestFunction})
tf = TEST_FUNCTIONS["himmelblau"]

# Get dimension using dim(tf):
# 1. Checks if 'scalable' is in tf.meta[:properties] via has_property
# 2. Returns -1 for scalable functions

himmelblau_dim = dim(tf)

println("Dimension of Himmelblau function: $himmelblau_dim")

