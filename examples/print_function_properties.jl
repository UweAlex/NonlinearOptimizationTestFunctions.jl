# examples/print_function_properties.jl
# Purpose: Lists properties of all implemented test functions in NonlinearOptimizationTestFunctions.jl in a Markdown-like format.
# Context: Inspired by List_all_available_test_functions_and_their_properties.jl, robust against missing metadata and new functions, with trimmed trailing zeros.
# Last modified: August 22, 2025

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
        dimensions = tf.dim() 

#is_scalable ? (name == "rosenbrock" ? "Any n >= 2" : "Any n >= 1") : "n=$n"
        
        # Extract metadata
        # Handle min_value as a function or scalar
        min_value = try
            value = isa(meta[:min_value], Function) ? meta[:min_value](is_scalable ? n : ()) : meta[:min_value]
            format_number(value)
        catch
            "Unknown"  # Fallback if min_value cannot be evaluated
        end
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
        # Robust handling of missing :in_molga_smutnicki_2005
        source = get(meta, :in_molga_smutnicki_2005, false) ? "[Molga & Smutnicki (2005)]" : 
                 haskey(meta, :in_molga_smutnicki_2005) ? "[Jamil & Yang (2013)]" : "[Unknown Source]"
        
        # Output in Markdown format
        println("- **$name** $source: $properties. Minimum: $min_value at $min_position. Bounds: [$lb, $ub]. Dimensions: $dimensions.")
    end
end

# Main program
print_function_properties()