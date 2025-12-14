using NonlinearOptimizationTestFunctions

# Filtere alle multimodalen Testfunktionen
multimodal_funcs = filter_testfunctions(tf -> property(tf, "multimodal"))
multimodal_names = [tf.name for tf in multimodal_funcs]  # .name ist der saubere Anzeigename

# Filtere alle Funktionen, die die Property "finite_at_inf" haben
finite_at_inf_funcs = filter_testfunctions(tf -> property(tf, "finite_at_inf"))
finite_at_inf_names = [tf.name for tf in finite_at_inf_funcs]

# Ausgabe
println("Anzahl multimodaler Funktionen: $(length(multimodal_funcs))")
println("Multimodale Funktionen:")
for name in sort(multimodal_names)
    println("  • $name")
end

println("\nAnzahl Funktionen mit finite_at_inf: $(length(finite_at_inf_funcs))")
println("Funktionen mit finite_at_inf:")
for name in sort(finite_at_inf_names)
    println("  • $name")
end