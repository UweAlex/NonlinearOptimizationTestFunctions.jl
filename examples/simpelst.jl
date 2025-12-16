# examples/simplest.jl
# =============================================================================
# Purpose: 
#   Absolute simplest "getting started" example for NonlinearOptimizationTestFunctions.jl.
#
#   This script:
#     1. Lists all available benchmark function names
#     2. Demonstrates clean, idiomatic access to a function and its metadata
#
# Key principle shown here:
#   Use the provided accessor functions (dim, start, properties, etc.)
#   instead of direct tf.meta[...] access – they are safer, clearer and consistent.
#
# Last modified: December 2025
# =============================================================================

using NonlinearOptimizationTestFunctions

# -------------------------------------------------------------------------
# Step 1: List all available function names
# -------------------------------------------------------------------------
all_names = sort(collect(keys(TEST_FUNCTIONS)))

println("Available benchmark functions ($(length(all_names)) total):")
for name in all_names
    println("  • $name")
end
println()

# -------------------------------------------------------------------------
# Step 2: Explore one function using the clean public API
# -------------------------------------------------------------------------
tf = TEST_FUNCTIONS["eggholder"]

println("Quick info about 'eggholder' (using clean accessors):")
println("  Dimension      : ", dim(tf))                      # 2
println("  Properties     : ", properties(tf))   # bounded, continuous, ...
println("  Global minimum : ", min_value(tf), " at ", min_position(tf))
println("  Bounds         : [", lb(tf), " .. ", ub(tf), "]")
println("  Recommended start: ", start(tf))
println()

x = [0.0, 0.0]

f_val = tf.f(x)
grad_val = tf.grad(x)

println("Evaluation at $x:")
println("  Objective: $f_val")       # ≈ -25.460337185286313
println("  Gradient:  $grad_val")     # ≈ [-1.982, -3.423]