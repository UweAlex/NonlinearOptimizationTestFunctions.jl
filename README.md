# NonlinearOptimizationTestFunctions.jl

[![JuliaHub](https://img.shields.io/badge/JuliaHub-1.10+-blue)](https://juliahub.com/ui/Packages/NonlinearOptimizationTestFunctions)  
[![CI](https://github.com/UweAlex/NonlinearOptimizationTestFunctions.jl/actions/workflows/ci.yml/badge.svg)](https://github.com/UweAlex/NonlinearOptimizationTestFunctions.jl/actions)  
[![Codecov](https://codecov.io/gh/UweAlex/NonlinearOptimizationTestFunctions.jl/graph/badge.svg)](https://codecov.io/gh/UweAlex/NonlinearOptimizationTestFunctions.jl)  
[![Tests](https://img.shields.io/badge/tests-350%2B-success)](test/)  
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Comprehensive, rigorously tested collection of nonlinear optimization test functions for Julia.  
Over 200 standard benchmark problems with analytical gradients, known global minima, bounds and detailed mathematical properties.  

Perfect for developers of global optimizers, local solvers, derivative-free methods, metaheuristics and gradient-based algorithms.

## Key Features

- Analytical gradients verified against ForwardDiff and Zygote  
- Rich metadata: global minimum, recommended starting points, bounds, modality, convexity, separability, etc.  
- Domain-safe box-constraint wrapper (`with_box_constraints`)  
- Full compatibility with Optim.jl, NLopt.jl, GalacticOptim.jl, BlackBoxOptim.jl  
- More than 350 automated tests covering edge cases, high-precision arithmetic and gradient accuracy  

## Installation

using Pkg  
Pkg.add("NonlinearOptimizationTestFunctions")

## Quick Start

using NonlinearOptimizationTestFunctions, Optim  

tf = ROSENBROCK_FUNCTION  
result = optimize(tf.f, tf.grad, start(tf), LBFGS())  
println("Rosenbrock minimum: ", minimum(result))

## Documentation

Complete manual, full function reference, detailed examples, properties, testing strategy and roadmap:  
[https://uwealex.github.io/NonlinearOptimizationTestFunctions.jl](https://uwealex.github.io/NonlinearOptimizationTestFunctions.jl)

Legacy documentation (pre-2025) is archived here:  
[Legacy docs](https://github.com/UweAlex/NonlinearOptimizationTestFunctions.jl/tree/master/legacy-docs)
