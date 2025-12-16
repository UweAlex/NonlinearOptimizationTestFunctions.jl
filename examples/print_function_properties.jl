# examples/print_function_properties.jl
# Purpose: Lists properties of all implemented test functions in NonlinearOptimizationTestFunctions.jl in a Markdown-like format.
# Context: Inspired by List_all_available_test_functions_and_their_properties.jl, robust against missing metadata and new functions, with trimmed trailing zeros.
# Last modified: October 02, 2025

using NonlinearOptimizationTestFunctions
using Printf

# Helper function to format numbers, trimming trailing zeros
function format_number(x::Number)
    str = @sprintf("%.8f", x)
    return rstrip(rstrip(str, '0'), '.')
end

# Helper function to format vectors
function format_vector(v, is_scalable::Bool)
    if is_scalable && length(v) > 4
        return "($(format_number(v[1])), ..., $(format_number(v[end])))"
    else
        return "(" * join([format_number(x) for x in v], ", ") * ")"
    end
end

# Function to print properties
function print_function_properties()
    println("# Test Function Properties")
    println("Below is a summary of the properties for all implemented test functions in NonlinearOptimizationTestFunctions.jl:\n")

    for tf in sort(collect(values(TEST_FUNCTIONS)), by=tf -> tf.name)
        name = tf.name
        properties_str = join(sort(properties(tf)), ", ")
        is_scalable = scalable(tf)

        # Dynamically determine dimension using dim(tf)
        n = is_scalable ? 2 : dim(tf)  # fallback to n=2 for scalable (since no default_n without meta)

        # Format dimensions string
        dimensions_str = is_scalable ? "scalable (n ≥ 1)" : "n = $n"

        # Extract metadata using accessors
        min_value_raw = try
            min_value(tf, n)
        catch
            NaN
        end
        min_value = isfinite(min_value_raw) ? format_number(min_value_raw) : "Unknown"

        min_position = try
            format_vector(min_position(tf, n), is_scalable)
        catch
            "Unknown"
        end
        lb_str = try
            format_vector(lb(tf, n), is_scalable)
        catch
            "Unknown"
        end
        ub_str = try
            format_vector(ub(tf, n), is_scalable)
        catch
            "Unknown"
        end

        # Use :source if available, else fallback (still uses meta, but only here as no accessor)
        func_source = source(tf)  # Renamed variable to avoid conflict with function name

        # Output in Markdown format
        println("- **$name** [$func_source:] $properties_str. Minimum: $min_value at $min_position. Bounds: [$lb_str, $ub_str]. Dimensions: $dimensions_str.")
    end
end

# Main program
print_function_properties()