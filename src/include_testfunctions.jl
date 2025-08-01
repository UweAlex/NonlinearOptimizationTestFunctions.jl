# src/include_testfunctions.jl
# Purpose: Includes all test function definitions.
# Context: Part of NonlinearOptimizationTestFunctionsInJulia, enables modular function loading.
# Last modified: 19. Juli 2025

include("functions/rosenbrock.jl")
include("functions/sphere.jl")
include("functions/ackley.jl")
include("functions/axisparallelhyperellipsoid.jl")
include("functions/rastrigin.jl")
include("functions/griewank.jl")
include("functions/schwefel.jl")
include("functions/michalewicz.jl")
include("functions/branin.jl")
include("functions/goldsteinprice.jl")
include("functions/shubert.jl")
include("functions/sixhumpcamelback.jl")
include("functions/langermann.jl")
include("functions/easom.jl")
include("functions/shekel.jl")
include("functions/hartmann.jl")

