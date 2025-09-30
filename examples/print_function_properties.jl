# examples/print_function_properties.jl
# Purpose: Lists properties of all implemented test functions in NonlinearOptimizationTestFunctions.jl in a Markdown-like format.
# Context: Inspired by List_all_available_test_functions_and_their_properties.jl, robust against missing metadata and new functions, with trimmed trailing zeros.
# Last modified: September 30, 2025

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
        return "($(format_number(v[1])), ..., $(format_number(v[1])))"
    else
        return "(" * join([format_number(x) for x in v], ", ") * ")"
    end
end

# Function to print properties
function print_function_properties()
    println("# Test Function Properties")
    println("Below is a summary of the properties for all implemented test functions in NonlinearOptimizationTestFunctions.jl:\n")
    
    for tf in sort(collect(values(NonlinearOptimizationTestFunctions.TEST_FUNCTIONS)), by=tf -> tf.meta[:name])
        meta = tf.meta
        name = meta[:name]
        properties = join(sort(collect(meta[:properties])), ", ")
        is_scalable = occursin("scalable", properties)
        
        # Dynamically determine dimension
        n = try
            length(tf.meta[:min_position](2))  # Default: n=2 for scalable functions
        catch
            length(tf.meta[:min_position]())  # Fallback for fixed dimensions (e.g., shekel, hartmann)
        end
        
        # Format dimensions string
        dimensions_str = is_scalable ? "scalable (n ≥ 1)" : "n = $n"
        
        # Extract metadata
        # Handle min_value as a function or scalar (fixed call for non-scalable)
        min_value_raw = try
            if isa(meta[:min_value], Function)
                if is_scalable
                    meta[:min_value](n)
                else
                    meta[:min_value]()
                end
            else
                meta[:min_value]
            end
        catch
            NaN
        end
        min_value = isfinite(min_value_raw) ? format_number(min_value_raw) : "Unknown"
        
        min_position = try
            format_vector(meta[:min_position](n), is_scalable)
        catch
            format_vector(meta[:min_position](), is_scalable)
        end
        lb = try
            format_vector(meta[:lb](n), is_scalable)
        catch
            format_vector(meta[:lb](), is_scalable)
        end
        ub = try
            format_vector(meta[:ub](n), is_scalable)
        catch
            format_vector(meta[:ub](), is_scalable)
        end
        
        # Use :properties_source if available, else :source, else fallback
        source = get(meta, :properties_source, get(meta, :source, "Unknown Source"))
        
        # Output in Markdown format
        println("- **$name** [$source:] $properties. Minimum: $min_value at $min_position. Bounds: [$lb, $ub]. Dimensions: $dimensions_str.")
    end
end

# Main program
print_function_properties()