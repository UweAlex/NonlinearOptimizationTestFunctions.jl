# examples/Optimize_with_nlopt.jl
# =============================================================================
# Purpose: 
#   This example shows how to optimize the classic Rosenbrock function using the
#   NLopt library and its gradient-based LD_LBFGS algorithm.
#   It demonstrates the excellent interoperability of NonlinearOptimizationTestFunctions.jl
#   with external solvers by directly using the package-provided analytical objective
#   and gradient together with NLopt's interface.
#
# Key takeaways for package users:
#   • The same TestFunction works unchanged with Optim.jl, NLopt.jl, GalacticOptim.jl, etc.
#   • Providing exact analytical gradients leads to dramatically faster and more accurate
#     convergence than finite-difference approximations.
#   • Metadata (recommended bounds, start point) makes the setup robust and reproducible.
#
# Requirements:
#   This example requires the optional package NLopt.jl.
#   Install it once with:  julia> using Pkg; Pkg.add("NLopt")
#
# Expected output (Float64 precision):
#   rosenbrock: [≈1.0, ≈1.0], ≈0.0   (residual typically < 1e-15, pure round-off)
#
# Last modified: December 2025
# =============================================================================

using NonlinearOptimizationTestFunctions
# Core package providing >200 rigorously tested benchmark functions with analytical
# gradients and comprehensive metadata.

using NLopt
# External optimization library.
# Note: The first time this script is run in a fresh Julia session you may see a harmless
# warning "WARNING: using NLopt.Result in module Main conflicts with an existing identifier."
# This occurs only when re-running the script in the same session and has no effect on correctness.

# -------------------------------------------------------------------------
# Choose the test function: classic 2D Rosenbrock ("banana") function
# -------------------------------------------------------------------------
# f(x₁,x₂) = 100*(x₂ - x₁²)² + (1 - x₁)²
# Smooth, unimodal, strongly non-convex – historic stress test for gradient methods.
# Exact global minimum: f(1,1) = 0
tf = NonlinearOptimizationTestFunctions.ROSENBROCK_FUNCTION

n = 2                                      # Standard low-dimensional case

# -------------------------------------------------------------------------
# Set up the NLopt optimizer
# -------------------------------------------------------------------------
# Why do we write NLopt.Opt, NLopt.ftol_rel!, NLopt.optimize, etc. everywhere?
# 
# Although `using NLopt` brings names like Opt, optimize, ftol_rel!, etc. into the
# current namespace, we deliberately qualify them with the NLopt. prefix for several
# important reasons:
#
# 1. Avoidance of name conflicts:
#    Many optimization packages export very common function names:
#      • Optim.jl exports `optimize`, `Options`, etc.
#      • GalacticOptim.jl re-exports `optimize` from various backends
#      • Other packages (e.g., JuMP, MathOptInterface) also use similar names
#    In a user session where multiple optimization libraries are loaded simultaneously,
#    unqualified names can shadow each other or cause unexpected behaviour.
#
# 2. Explicitness and readability:
#    Seeing NLopt.optimize immediately tells the reader exactly which library's
#    implementation is being used – crucial in examples that demonstrate interoperability.
#
# 3. Safety when copying code:
#    Users often copy example code into their own projects. Fully qualified names
#    work reliably regardless of which other packages they have loaded.
#
# 4. Consistency across examples:
#    Different examples in this package use different solvers (Optim.jl, NLopt.jl, etc.).
#    Using the module prefix everywhere makes the code style uniform and prevents
#    subtle bugs when switching between examples.
#
# In short: the explicit NLopt. prefix makes the example more robust, clearer,
# and safer for real-world use – especially for users who work with multiple
# optimization libraries at once.
# -------------------------------------------------------------------------

opt = NLopt.Opt(:LD_LBFGS, n)               # Limited-memory BFGS (requires gradients)

NLopt.ftol_rel!(opt, 1e-6)                  # Reasonable relative function tolerance

# Use the package-provided recommended search bounds (keeps evaluations numerically stable)
NLopt.lower_bounds!(opt, tf.meta[:lb](n))
NLopt.upper_bounds!(opt, tf.meta[:ub](n))

# -------------------------------------------------------------------------
# Define the objective callback for NLopt
# -------------------------------------------------------------------------
NLopt.min_objective!(opt, (x, grad) -> begin
    f_val = tf.f(x)                        # Objective evaluation
    if length(grad) > 0
        tf.gradient!(grad, x)              # In-place analytical gradient – exact and fast
    end
    return f_val
end)

# -------------------------------------------------------------------------
# Run the optimization
# -------------------------------------------------------------------------
# Start from the deliberately challenging point suggested by the package metadata.
minf, minx, ret = NLopt.optimize(opt, tf.meta[:start](n))

# -------------------------------------------------------------------------
# Display the result
# -------------------------------------------------------------------------
println("$(tf.meta[:name]): $minx, $minf")
# Typical output:
# rosenbrock: [0.9999999995740739, 0.9999999991616133], 1.9954485597074117e-19
# → Effectively the exact minimum within double-precision floating-point limits.
