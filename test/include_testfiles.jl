# test/include_testfiles.jl
# Purpose: Includes all function-specific test files for NonlinearOptimizationTestFunctionsInJulia.
# Context: Part of the test suite, enables modular test loading for individual test functions.
# Last modified: 18. Juli 2025

using Test, NonlinearOptimizationTestFunctionsInJulia, ForwardDiff, Optim, Zygote

include("rosenbrock_tests.jl")
include("sphere_tests.jl")
include("ackley_tests.jl")
include("axisparallelhyperellipsoid_tests.jl")
include("rastrigin_tests.jl")
include("griewank_tests.jl")
include("schwefel_tests.jl")
include("michalewicz_tests.jl")
include("branin_tests.jl")
include("goldsteinprice_tests.jl") 
include("shubert_tests.jl")
include("sixhumpcamelback_tests.jl")
include("langermann_tests.jl")
include("easom_tests.jl")
include("shekel_tests.jl")
