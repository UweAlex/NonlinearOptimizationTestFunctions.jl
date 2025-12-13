using NonlinearOptimizationTestFunctions, Optim
# Optimizes all test functions using Optim.jl, with bounds for bounded functions.

# Main loop: Iterates over all test functions in the suite.
for tf_orig in values(NonlinearOptimizationTestFunctions.TEST_FUNCTIONS)

    # 1. Fix the dimension.
    # Crucial step: Convert the function into a non-scalable version.
    # The call to fixed(tf_orig) now automatically uses :default_n for scalable functions,
    # adhering to the design philosophy.
    tf_fixed = fixed(tf_orig)

    # 2. Apply sign-safe Box-Constraints.
    # This prepares the function for optimization by incorporating bounds.
    ctf = with_box_constraints(tf_fixed)

    # Get the final fixed dimension for printing (now safe because ctf is not scalable)
    n = dim(ctf)

    # Perform optimization
    # The call to start(ctf) is now safe as ctf is no longer scalable.
    result = Optim.optimize(ctf.f, start(ctf), NelderMead(), Optim.Options(f_reltol=1e-6, iterations=100_000))

    # Print results
    println("$(tf_orig.meta[:name]) (n=$n): minimizer = $(Optim.minimizer(result)), minimum = $(Optim.minimum(result))")
    println("--------------------------------------------------")
end