@echo off
title Julia Environment Activation and Test
cd /d "C:\Users\uweal\NonlinearOptimizationTestFunctions.jl"
julia -i -e "using Pkg; Pkg.activate(\".\"); using NonlinearOptimizationTestFunctions; tf = ROSENBROCK_FUNCTION; prob = optimization_problem(tf); println(\"Test successful: optimization_problem is defined.\")"
pause