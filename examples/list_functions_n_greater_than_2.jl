# examples/list_functions_n_greater_than_2.jl
# Purpose: Lists non-scalable test functions with dimension n > 2.
# Context: Uses get_n to filter functions from NonlinearOptimizationTestFunctions.
# Last modified: 04 September 2025

using NonlinearOptimizationTestFunctions

# List non-scalable functions with n > 2
function list_functions_n_greater_than_2()
    println("Non-scalable test functions with dimension n > 2:")
    
    # Iterate over TEST_FUNCTIONS (a Dict{String, TestFunction})
    for tf in values(TEST_FUNCTIONS)
        # Determine dimension using get_n:
        # 1. Checks if 'scalable' is in tf.meta[:properties] via has_property
        # 2. Returns -1 for scalable functions
        # 3. For non-scalable, returns length(tf.meta[:min_position]())
        # 4. Throws ArgumentError if :min_position fails
        dim = get_n(tf)
        
        # Filter non-scalable functions with n > 2
        if dim > 2
            meta = tf.meta
            println("Function: $(meta[:name]), Dimension: $dim, Properties: $(meta[:properties]), Minimum: $(meta[:min_value]) at $(meta[:min_position]()), Bounds: [$(meta[:lb]()), $(meta[:ub]())]")
        end
    end
end

# Run the function
list_functions_n_greater_than_2()