# examples/generate_functions_md.jl
#
# Purpose:
# This script automatically generates a Markdown file (FUNCTIONS.md) containing
# an alphabetical list of all benchmark functions registered in the package.
# It distinguishes between scalable and non-scalable (fixed-dimension) functions,
# displaying appropriate dimension information and concrete values for bounds and minima.
#
# The script demonstrates key package features:
# - Retrieval of all registered functions via the TEST_FUNCTIONS dictionary
# - Use of accessor functions for metadata retrieval
# - Handling of scalable functions via the fixed() utility
# - Generation of human-readable documentation from live metadata
#
# Last modified: December 18, 2025

using NonlinearOptimizationTestFunctions  # Core package containing all test functions
using Dates                              # Used to insert the current generation date

# ------------------------------------------------------------------
# Helper function: format vectors for readable display
# ------------------------------------------------------------------
# Formats arrays (e.g., bounds or minimum positions) for output.
# Short vectors are displayed fully; longer ones show only the first and last elements.
function format_vector(v)
    rounded = round.(v; digits=8)                     # Round values to 8 decimal places
    if length(rounded) > 4
        return "[$(rounded[1]), ..., $(rounded[end])]"  # Abbreviated representation
    else
        return "[$(join(rounded, ", "))]"              # Complete representation
    end
end

# ------------------------------------------------------------------
# Core function: generate a Markdown block for a single test function
# ------------------------------------------------------------------
# Produces a formatted Markdown section for one TestFunction.
# Scalable functions are temporarily converted using fixed() to obtain concrete values
# for display (bounds, minimum position, etc.), while preserving the original scalable status.
function generate_block(tf::TestFunction)
    # Retrieve basic metadata using package accessors
    name_str = name(tf)                           # Function name
    desc = description(tf)                    # Textual description
    formula = math(tf)                           # LaTeX mathematical expression
    props_str = join(properties(tf), ", ")         # Sorted list of properties (properties() returns sorted)
    ref = source(tf)                         # Reference/source information

    # Determine scalability and prepare dimension string
    is_scalable = scalable(tf)                     # Boolean accessor: true if "scalable" property present
    if is_scalable
        default_n_val = tf.meta[:default_n]        # Default dimension for scalable functions (per package rule)
        dim_str = "scalable (default n = $default_n_val)"
        # Temporarily create a fixed instance to obtain concrete values for display
        fixed_example = fixed(tf)                  # fixed() converts scalable to fixed using default_n
        lb_val = lb(fixed_example)               # Lower bounds (vector)
        ub_val = ub(fixed_example)               # Upper bounds (vector)
        min_pos = min_position(fixed_example)     # Position of global minimum
        min_val = min_value(fixed_example)        # Value of global minimum
    else
        dim_str = "fixed (n = $(dim(tf)))"         # dim() returns the fixed dimension for non-scalable functions
        lb_val = lb(tf)                          # Direct access (no argument needed for fixed functions)
        ub_val = ub(tf)
        min_pos = min_position(tf)
        min_val = min_value(tf)
    end

    # Format bounds and minimum information
    bounds_str = "Bounds: $(format_vector(lb_val)) to $(format_vector(ub_val))"
    min_str = "Global minimum: $min_val at $(format_vector(min_pos))"

    # Optional note for scalable functions
    scalability_note = is_scalable ?
                       "\n- **Note**: Scalable function – shown with default_n = $default_n_val. Use `fixed(tf; n=...)` for custom dimensions." :
                       ""

    # Assemble and return the complete Markdown block
    """
### $name_str
- **Description**: $desc
- **Formula**: $formula
- **Dimension**: $dim_str
- **Bounds / Minimum**: $bounds_str; $min_str
- **Properties**: $props_str
- **Reference**: $ref$scalability_note
"""
end

# ------------------------------------------------------------------
# Main function: generate the complete FUNCTIONS.md file
# ------------------------------------------------------------------
# Collects all registered test functions, sorts them alphabetically by name,
# and writes the formatted Markdown documentation.
function generate_functions_md()
    # Retrieve all test functions and sort by name
    funcs = sort(collect(values(TEST_FUNCTIONS)); by=tf -> tf.name)

    # Write the output file
    open("all_functions.md", "w") do io
        write(io, "# Alphabetical List of Benchmark Functions\n\n")
        write(io, "Generated automatically on $(Dates.format(now(), "yyyy-mm-dd")) from package metadata.\n\n")
        write(io, "Scalable functions are shown with their default dimension (`default_n`). Use `fixed(tf; n=...)` to create fixed-dimension instances.\n\n")

        # Write a block for each function
        for tf in funcs
            write(io, generate_block(tf) * "\n\n")
        end

        # Add instructions for regeneration
        write(io, "## How to update\n")
        write(io, "Run `julia --project=. examples/generate_functions_md.jl` to regenerate this file.\n")
    end

    println("Generated FUNCTIONS.md successfully!")
end

# ------------------------------------------------------------------
# Execute when the script is run directly
# ------------------------------------------------------------------
generate_functions_md()