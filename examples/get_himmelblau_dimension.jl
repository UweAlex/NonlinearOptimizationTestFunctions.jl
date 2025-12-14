# examples/get_himmelblau_dimension.jl
# =============================================================================
# Purpose: 
#   This example demonstrates how to query the dimension of a specific test function
#   from the NonlinearOptimizationTestFunctions.jl package using the built-in dim() function.
#
# Why this example exists:
#   • Many classic benchmark functions are fixed-dimensional (e.g. Himmelblau is always n=2).
#   • Others are scalable (can be used with arbitrary n ≥ some minimum).
#   • The dim(tf) helper automatically handles both cases:
#       - Returns the fixed length of the minimum position vector for non-scalable functions
#       - Returns -1 for scalable functions (by convention, indicating "any dimension")
#   • This makes it easy for users to write generic code that adapts to the function type.
#
# Himmelblau function specifics:
#   • Mathematical form: f(x,y) = (x² + y - 11)² + (x + y² - 7)²
#   • Defined only for n=2 (four global minima at approximately (±3.58, -1.85), etc.)
#   • Non-convex, multimodal, smooth – a classic low-dimensional test problem.
#   • Not scalable → dim() returns 2
#
# Expected output:
#   Dimension of Himmelblau function: 2
#
# Last modified: December 2025
# =============================================================================

using NonlinearOptimizationTestFunctions
# Load the package. Provides the global dictionary TEST_FUNCTIONS containing all
# available benchmark problems as pre-constructed TestFunction objects.

# -------------------------------------------------------------------------
# Retrieve the Himmelblau function from the registry
# -------------------------------------------------------------------------
# TEST_FUNCTIONS is a Dict{String, TestFunction} indexed by the lowercase name.
# Using the string key is safe and explicit – ideal for examples and scripting.
tf = TEST_FUNCTIONS["himmelblau"]

# Alternative (more concise but relies on exported constants):
# tf = HIMMELBLAU_FUNCTION   # uppercase constant exported by the package

# -------------------------------------------------------------------------
# Determine the dimension using the package-provided dim() function
# -------------------------------------------------------------------------
# Implementation summary of dim(tf):
#   • If the function has the "scalable" property → return -1 (convention for variable dimension)
#   • Otherwise → return length(tf.meta[:min_position]())  (fixed dimension inferred from metadata)
#
# This approach is robust because:
#   • It requires no manual hard-coding of dimensions
#   • It automatically reflects any future changes in function definitions
#   • It works uniformly across the entire collection of >200 functions
himmelblau_dim = dim(tf)

# -------------------------------------------------------------------------
# Print the result
# -------------------------------------------------------------------------
println("Dimension of Himmelblau function: $himmelblau_dim")
# Output: Dimension of Himmelblau function: 2

# =============================================================================
# Additional notes for package users
# =============================================================================
# • For scalable functions (e.g. ROSENBROCK_FUNCTION, RASTRIGIN_FUNCTION):
#     dim(tf) → -1
#     Use fixed(tf; n=10) to create a fixed-dimension instance, then dim(fixed_tf) → 10
# • You can list all fixed-dimensional functions with dim > some value using:
#     filter(tf -> dim(tf) > 2, values(TEST_FUNCTIONS))
# • This pattern is useful when writing generic benchmarking loops that need to
#   distinguish between low-dimensional analytical tests and high-dimensional scalable ones.
#
# Feel free to replace "himmelblau" with any other key from TEST_FUNCTIONS
# to explore the dimensionality of other benchmark problems!
# =============================================================================