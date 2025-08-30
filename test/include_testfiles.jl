# test/include_testfiles.jl
# Purpose: Includes all function-specific test files for NonlinearOptimizationTestFunctions.
# Context: Part of the test suite, enables modular test loading for individual test functions.
# Last modified: 18. Juli 2025

using Test, NonlinearOptimizationTestFunctions, ForwardDiff, Optim, Zygote


include("ackley2_tests.jl")
include("ackley_tests.jl")
include("adjiman_tests.jl")
include("axisparallelhyperellipsoid_tests.jl")
include("bartelsconn_tests.jl")
include("beale_tests.jl")
include("bird_tests.jl")
include("bohachevsky_tests.jl")
include("booth_tests.jl")
include("branin_tests.jl")
include("bukin6_tests.jl")
include("crossintray_tests.jl")
include("dekkersaarts_tests.jl")
include("dejongf4_tests.jl")
include("dejongF5modified_tests.jl")
include("dejongf5original_tests.jl")
include("dixonprice_tests.jl")
include("dropwave_tests.jl")
include("easom_tests.jl")
include("eggholder_tests.jl")
include("giunta_tests.jl")
include("goldsteinprice_tests.jl") 
include("griewank_tests.jl")
include("hartmann_tests.jl")
include("himmelblau_tests.jl")
include("holdertable_tests.jl")
include("keane_tests.jl")
include("kearfott_tests.jl")
include("langermann_tests.jl")
include("levy_tests.jl")
include("levyjamil_tests.jl")
include("matyas_tests.jl")
include("mccormick_tests.jl")
include("michalewicz_tests.jl")
include("mishrabird_tests.jl")
include("quadratic_tests.jl")
include("rana_tests.jl")
include("rastrigin_tests.jl")
include("rosenbrock_tests.jl")
include("rotatedhyperellipsoid_tests.jl")
include("schaffern1_tests.jl")
include("schaffern2_tests.jl")
include("schaffern4_tests.jl")
include("schwefel_tests.jl")
include("shekel_tests.jl")
include("shubert_tests.jl")
include("sineenvelope_tests.jl")
include("sixhumpcamelback_tests.jl")
include("sphere_tests.jl")
include("step_tests.jl")
include("styblinskitang_tests.jl")
include("sumofpowers_tests.jl")
include("threehumpcamel_tests.jl")
include("trid_tests.jl")
include("wood_tests.jl")
include("zakharov_tests.jl")
include("alpinen1_tests.jl")
include("alpinen2_tests.jl")
include("powell_tests.jl")
include("colville_tests.jl")































