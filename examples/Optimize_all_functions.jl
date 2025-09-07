# examples/Optimize_all_functions.jl
# Purpose: Optimizes all test functions using Optim.jl's L-BFGS algorithm.
# Context: Part of NonlinearOptimizationTestFunctions, showcasing TestFunction integration.
# Last modified: 06 September 2025
using NonlinearOptimizationTestFunctions, Optim

# Default dimension for scalable functions
default_n = 2

for tf in values(NonlinearOptimizationTestFunctions.TEST_FUNCTIONS)
    # Get dimension using get_n
    dim = get_n(tf)
    # Use default_n for scalable functions (where get_n returns -1)
    local n = dim == -1 ? default_n : dim
    
    # Get start point based on scalability
    start_point = dim == -1 ? tf.meta[:start](n) : tf.meta[:start]()
    
    # Perform optimization, using Fminbox for bounded functions
    if "bounded" in tf.meta[:properties]
        lb = dim == -1 ? tf.meta[:lb](n) : tf.meta[:lb]()
        ub = dim == -1 ? tf.meta[:ub](n) : tf.meta[:ub]()
        result = optimize(tf.f, tf.gradient!, lb, ub, start_point, Fminbox(LBFGS()), Optim.Options(f_reltol=1e-6))
    else
        result = optimize(tf.f, tf.gradient!, start_point, LBFGS(), Optim.Options(f_reltol=1e-6))
    end
    
    println("$(tf.meta[:name]): $(Optim.minimizer(result)), $(Optim.minimum(result))")
end