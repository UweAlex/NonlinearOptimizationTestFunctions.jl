# Demos

## Overview
The package includes five example scripts in examples/ (10-15 lines each), showcasing integration with Optim.jl, NLopt, and Zygote.

## Optimize All Functions
Optimizes all test functions with L-BFGS:

    using NonlinearOptimizationTestFunctionsInJulia, Optim
    n = 2
    for tf in values(NonlinearOptimizationTestFunctionsInJulia.TEST_FUNCTIONS)
        result = optimize(tf.f, tf.gradient!, tf.meta[:start](n), LBFGS(), Optim.Options(f_reltol=1e-6))
        println("$(tf.meta[:name]): $(Optim.minimizer(result)), $(Optim.minimum(result))")
    end

## Compare Optimization Methods
Compares Gradient Descent and L-BFGS on Rosenbrock. See examples/Compare_optimization_methods.jl.

## List Test Functions
Lists all functions, start points, minima, and properties. See examples/List_all_available_test_functions_and_their_properties.jl.

## Optimize with NLopt
Optimizes Rosenbrock with NLopt's LD_LBFGS. See examples/Optimize_with_nlopt.jl.

## Compute Hessian with Zygote
Performs 3 Newton steps on Rosenbrock using Zygote's Hessian. See examples/Compute_hessian_with_zygote.jl.