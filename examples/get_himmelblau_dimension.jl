# examples/get_himmelblau_dimension.jl
# Purpose: Prints the dimension of the Himmelblau test function.
# Context: Uses get_n from NonlinearOptimizationTestFunctions to determine dimension.
# Last modified: 04 September 2025

using NonlinearOptimizationTestFunctions

# Print dimension of Himmelblau function
function get_himmelblau_dimension()
    # Access Himmelblau function from TEST_FUNCTIONS (a Dict{String, TestFunction})
    tf = TEST_FUNCTIONS["himmelblau"]
    
    # Get dimension using get_n:
    # 1. Checks if 'scalable' is in tf.meta[:properties] via has_property
    # 2. Returns -1 for scalable functions
    # 3. For non-scalable (like Himmelblau), returns length(tf.meta[:min_position]())
    # 4. Throws ArgumentError if :min_position fails
    dim = get_n(tf)
    
    println("Dimension of Himmelblau function: $dim")
end

# Run the function
get_himmelblau_dimension()