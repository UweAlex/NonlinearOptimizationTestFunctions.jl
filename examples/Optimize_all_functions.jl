using NonlinearOptimizationTestFunctions, Optim


# Default dimension for scalable functions
default_n = 2

# Detailed comment on how to properly call the optimizer:
# The optimizer is invoked using the `optimize` function from the Optim.jl package.
# - **Objective Function (tf.f)**: The function to minimize, provided by the TestFunction object (tf).
#   It takes a vector of parameters as input and returns a scalar value representing the objective.
# - **Initial Point (input_start_point)**: The starting point for the optimization, which must be a vector
#   within the function's domain. It is clamped to the lower and upper bounds (lb, ub) to ensure validity.
#   For functions with specific domain requirements (e.g., alpinen2 requires [0, 10]^n), bounds are
#   overridden accordingly.
# - **Method (Fminbox(NelderMead()))**: For bounded functions, Fminbox wraps NelderMead to enforce box
#   constraints, ensuring all evaluated points stay within [lb, ub]. NelderMead is a derivative-free method
#   suitable for multimodal and non-differentiable functions. For unbounded functions, NelderMead is used
#   directly.
# - **Options (Optim.Options(f_reltol=1e-6))**: Configuration options include a relative tolerance
#   (f_reltol) of 1e-6 for convergence. Other options like iterations or time limits can be adjusted.
# - **Boundary Handling**: Fminbox ensures that all points evaluated during optimization stay within the
#   specified bounds [lb, ub], eliminating the need for manual clamping during iterations. For alpinen2,
#   bounds are explicitly set to [0, 10]^n to match its domain.
# - **Output**: The result object contains the minimizer (Optim.minimizer(result)) and the minimum
#   value (Optim.minimum(result)), which are printed for verification.
# - **Error Handling**: Fminbox prevents domain errors by enforcing bounds, addressing issues like those
#   encountered with alpinen2 where inputs outside [0, 10]^n caused errors.

for tf in values(NonlinearOptimizationTestFunctions.TEST_FUNCTIONS)
      
    # Get dimension using get_n
    dim = get_n(tf)
    
    # Use default_n for scalable functions (where get_n returns -1)
    local n = dim == -1 ? default_n : nothing
    
    # Get the predefined start point from metadata
    start_point = n === nothing ? tf.start() : tf.start(n)

    
    # Perform optimization
    if bounded(tf)  # Use Fminbox with NelderMead for bounded functions
        lb = n === nothing ? tf.lb() : tf.lb(n)
        ub = n === nothing ? tf.ub() : tf.ub(n)

        
        # Adjust start_point to function-specific domain if necessary
        if tf.name == :alpinen2
            lb = zeros(length(start_point))  # Override to [0, 0] for alpinen2
            ub = ones(length(start_point)) * 10.0  # Override to [10, 10] for alpinen2
        end
        
        # Clamp and validate start_point
        clamped_start_point = clamp.(start_point, lb, ub)
       
        
        # Reformat bounds to [unten_x, oben_x, unten_y, oben_y] for testing
        bounds = Float64[vcat(lb[1], ub[1], lb[2], ub[2])...]
        
        # Store input for verification
        input_start_point = copy(clamped_start_point)
        
        
        # Use Fminbox with NelderMead for bounded optimization

        result = optimize(
            tf.f,              # Objective function
            lb,                # Lower bounds
            ub,                # Upper bounds
            input_start_point, # Explicitly passed start point
            Fminbox(NelderMead()), # Fminbox with NelderMead as inner optimizer
            Optim.Options(f_reltol=1e-6) # Convergence tolerance
        )
    else

        result = optimize(
            tf.f,              # Objective function
            start_point,       # Predefined start point
            NelderMead(),      # Optimization algorithm
            Optim.Options(f_reltol=1e-6) # Convergence tolerance
        )
    end
    
   
    
    # Print results
    println("$(tf.name): minimizer = $(Optim.minimizer(result)), minimum = $(Optim.minimum(result))")
    println("--------------------------------------------------")
end