# NonlinearOptimizationTestFunctionsInJulia

## Introduction

NonlinearOptimizationTestFunctionsInJulia is a Julia package designed for testing and benchmarking nonlinear optimization algorithms. It provides a comprehensive collection of standard test functions, each equipped with analytical gradients, metadata, and validation mechanisms. The package supports scalable and non-scalable functions, ensuring compatibility with high-dimensional optimization problems and automatic differentiation tools like ForwardDiff. Key features include:

- Standardized Test Functions: A curated set of well-known optimization test functions (e.g., Rosenbrock, Ackley, Branin) with consistent interfaces.
- Analytical Gradients: Each function includes an analytical gradient for efficient optimization and testing.
- TestFunction Structure: Encapsulates function, gradient, and metadata (e.g., name, start point, global minimum, properties, bounds).
- Validation and Flexibility: Metadata validation ensures correctness, and properties like unimodal, multimodal, or differentiable enable filtering for specific use cases.
- Integration with Optimization Libraries: Seamless compatibility with Optim.jl, NLopt.jl, and other Julia optimization packages.

The package is ideal for researchers, developers, and students evaluating optimization algorithms, offering a robust framework for nonlinear optimization benchmarking.

## Installation

To install the package, clone the repository and instantiate the environment:

git clone https://github.com/your-repo/NonlinearOptimizationTestFunctionsInJulia.git
cd NonlinearOptimizationTestFunctionsInJulia
julia --project=. -e 'using Pkg; Pkg.instantiate()'

Ensure dependencies like LinearAlgebra, ForwardDiff, and Optim are installed. For specific examples, additional packages (e.g., NLopt, Zygote) may be required.

## Usage

The package provides a TestFunction structure containing the function (f), gradient (grad), in-place gradient (gradient!), and metadata (meta). Functions are stored in TEST_FUNCTIONS, a dictionary mapping function names to TestFunction instances. Below are examples demonstrating the package's capabilities, corresponding to files in the examples directory.

### Examples

1. Comparing Optimization Methods (examples/Compare_optimization_methods.jl):
   Compares Gradient Descent and L-BFGS on the Rosenbrock function, demonstrating how to use TestFunction with Optim.jl to evaluate different algorithms.

   using NonlinearOptimizationTestFunctions, Optim
   tf = NonlinearOptimizationTestFunctions.ROSENBROCK_FUNCTION
   n = 2
   result_gd = optimize(tf.f, tf.gradient!, tf.meta[:start](n), GradientDescent(), Optim.Options(f_reltol=1e-6))
   result_lbfgs = optimize(tf.f, tf.gradient!, tf.meta[:start](n), LBFGS(), Optim.Options(f_reltol=1e-6))
   println("Gradient Descent on $(tf.meta[:name]): $(Optim.minimizer(result_gd)), $(Optim.minimum(result_gd))")
   println("L-BFGS on $(tf.meta[:name]): $(Optim.minimizer(result_lbfgs)), $(Optim.minimum(result_lbfgs))")

2. Computing Hessian with Zygote (examples/Compute_hessian_with_zygote.jl):
   Performs three Newton steps on the Rosenbrock function using analytical gradients and Zygote's Hessian computation, showcasing integration with automatic differentiation.

   using NonlinearOptimizationTestFunctions, Zygote, LinearAlgebra
   tf = NonlinearOptimizationTestFunctions.ROSENBROCK_FUNCTION
   n = 2
   x = tf.meta[:start](n)
   x = x - inv(Zygote.hessian(tf.f, x)) * tf.grad(x)
   x = x - inv(Zygote.hessian(tf.f, x)) * tf.grad(x)
   x = x - inv(Zygote.hessian(tf.f, x)) * tf.grad(x)
   println("Nach 3 Newton-Schritten für $(tf.meta[:name]): $x")

3. Listing Test Functions and Properties (examples/List_all_available_test_functions_and_their_properties.jl):
   Displays all available test functions with their start points, minima, and properties, useful for inspecting function characteristics.

   using NonlinearOptimizationTestFunctions
   n = 2
   for tf in values(NonlinearOptimizationTestFunctions.TEST_FUNCTIONS)
       println("$(tf.meta[:name]): Start at $(tf.meta[:start](n)), Minimum at $(tf.meta[:min_position](n)), Value $(tf.meta[:min_value]), Properties: $(join(tf.meta[:properties], ", "))")
   end

4. Optimizing All Functions (examples/Optimize_all_functions.jl):
   Optimizes all test functions using Optim.jl's L-BFGS algorithm, demonstrating batch processing of test functions.

   using NonlinearOptimizationTestFunctions, Optim
   n = 2
   for tf in values(NonlinearOptimizationTestFunctions.TEST_FUNCTIONS)
       result = optimize(tf.f, tf.gradient!, tf.meta[:start](n), LBFGS(), Optim.Options(f_reltol=1e-6))
       println("$(tf.meta[:name]): $(Optim.minimizer(result)), $(Optim.minimum(result))")
   end

5. Optimizing with NLopt (examples/Optimize_with_nlopt.jl):
   Optimizes the Rosenbrock function using NLopt.jl's LD_LBFGS algorithm, highlighting compatibility with external optimization libraries.

   using NonlinearOptimizationTestFunctions
   if isdefined(Main, :NLopt)
       using NLopt
       tf = NonlinearOptimizationTestFunctions.ROSENBROCK_FUNCTION
       n = 2
       opt = Opt(:LD_LBFGS, n)
       NLopt.ftol_rel!(opt, 1e-6)
       NLopt.lower_bounds!(opt, tf.meta[:lb](n))
       NLopt.upper_bounds!(opt, tf.meta[:ub](n))
       NLopt.min_objective!(opt, (x, grad) -> begin
           f = tf.f(x)
           if length(grad) > 0
               tf.gradient!(grad, x)
           end
           f
       end)
       minf, minx, ret = optimize(opt, tf.meta[:start](n))
       println("$(tf.meta[:name]): $minx, $minf")
   else
       println("NLopt.jl is not installed. Please install it to run this example.")
   end

## Test Functions

The package includes a variety of test functions for nonlinear optimization, each defined in src/functions/<functionname>.jl. Below is a complete list of available functions, their properties, minima, bounds, and supported dimensions, based on precise values from sources like al-roomi.org, sfu.ca, and Molga & Smutnicki (2005).

- Ackley: Multimodal, non-convex, differentiable, scalable. Minimum: 0.0 at (0, ..., 0). Bounds: [-32.768, 32.768]^n. Dimensions: Any n.
- AxisParallelHyperEllipsoid: Unimodal, convex, differentiable, separable, scalable. Minimum: 0.0 at (0, ..., 0). Bounds: [-5.12, 5.12]^n. Dimensions: Any n.
- Branin: Multimodal, differentiable, non-scalable. Minimum: 0.397887 at (-π, 12.275), (π, 2.275), (9.42478, 2.475). Bounds: [-5, 10] × [0, 15]. Dimensions: n=2.
- Easom: Unimodal, differentiable, non-scalable. Minimum: -1.0 at (π, π). Bounds: [-100, 100]^2. Dimensions: n=2.
- GoldsteinPrice: Multimodal, differentiable, non-scalable. Minimum: 3.0 at (0, -1). Bounds: [-2, 2]^2. Dimensions: n=2.
- Griewank: Multimodal, non-convex, differentiable, scalable. Minimum: 0.0 at (0, ..., 0). Bounds: [-600, 600]^n. Dimensions: Any n.
- Hartmann: Multimodal, differentiable, non-scalable. Minimum: -3.862782 for n=3 at (0.114614, 0.555649, 0.852547); -3.322368 for n=6 at (0.20169, 0.150011, 0.476874, 0.275332, 0.311652, 0.6573). Bounds: [0, 1]^n. Dimensions: n=3 or n=6.
- Langermann: Multimodal, differentiable, non-scalable. Minimum: approximately -5.1621259 at (2.002992, 1.006096). Bounds: [0, 10]^2. Dimensions: n=2.
- Michalewicz: Multimodal, differentiable, separable, scalable. Minimum: approximately -4.687658 for n=5, -9.66015 for n=10. Bounds: [0, π]^n. Dimensions: Any n.
- Rastrigin: Multimodal, non-convex, differentiable, separable, scalable. Minimum: 0.0 at (0, ..., 0). Bounds: [-5.12, 5.12]^n. Dimensions: Any n.
- Rosenbrock: Unimodal, non-convex, differentiable, scalable. Minimum: 0.0 at (1, ..., 1). Bounds: [-5, 10]^n. Dimensions: Any n.
- Schwefel: Multimodal, non-convex, differentiable, separable, scalable. Minimum: 0.0 at (420.968746, ..., 420.968746). Bounds: [-500, 500]^n. Dimensions: Any n.
- Shekel: Multimodal, differentiable, non-scalable. Minimum: approximately -10.1532 for m=5, -10.4029 for m=7, -10.5364 for m=10 at (4, 4, 4, 4). Bounds: [0, 10]^4. Dimensions: n=4.
- Shubert: Multimodal, differentiable, non-scalable. Minimum: -186.7309 at multiple points (e.g., (-7.0835, 4.8580)). Bounds: [-10, 10]^2. Dimensions: n=2.
- SixHumpCamelback: Multimodal, differentiable, non-scalable. Minimum: -1.031628453489877 at (±0.08984201368301331, ±0.7126564032704135). Bounds: [-5, 5]^2. Dimensions: n=2.
- Sphere: Unimodal, convex, differentiable, separable, scalable. Minimum: 0.0 at (0, ..., 0). Bounds: [-5.12, 5.12]^n. Dimensions: Any n.

## Running Tests

To run the test suite, execute:

cd /path/to/NonlinearOptimizationTestFunctionsInJulia
julia --project=. -e 'using Pkg; Pkg.instantiate(); include("test/runtests.jl")'

Tests cover function evaluations, metadata validation, edge cases (NaN, Inf, 1e-308), and optimization with Optim.jl. Gradient tests are centralized in test/runtests.jl for consistency.

## Contributing

Contributions are welcome! Please submit pull requests with new test functions, tests, or improvements. Ensure all tests pass and documentation is updated.

## License

This package is licensed under the MIT License. See LICENSE for details.