using NonlinearOptimizationTestFunctions
using LinearAlgebra  # Hinzugefügt für norm

tf = SINEENVELOPE_FUNCTION

# Erwartetes Minimum
expected_min = [1.5259, 1.1540]
expected_value = -3.7379439163636463
func_value_expected = sineenvelope(expected_min)
grad_expected = sineenvelope_gradient(expected_min)
println("Erwartetes Minimum $expected_min:")
println("  Funktionswert: $func_value_expected")
println("  Gradient: $grad_expected, Norm: $(norm(grad_expected))")

# Gefundener Minimizer
found_min = [1.538637632553666, 1.1370027579926583]
func_value_found = sineenvelope(found_min)
grad_found = sineenvelope_gradient(found_min)
println("Gefundener Minimizer $found_min:")
println("  Funktionswert: $func_value_found")
println("  Gradient: $grad_found, Norm: $(norm(grad_found))")

# Vergleich mit erwartetem Minimalwert
println("Abweichung Funktionswert (erwartet vs. gefunden): $(abs(func_value_expected - func_value_found))")
println("Abweichung vom erwarteten Minimalwert: $(abs(func_value_found - expected_value))")