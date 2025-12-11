# examples/property_statistics.jl
# 100 % garantiert läuft – kein Printf, kein Crayons, nichts

using NonlinearOptimizationTestFunctions

# Sammle alle Properties
counter = Dict{String,Int}()

for tf in values(TEST_FUNCTIONS)
    props = get(tf.meta, :properties, Set{String}())
    for p in props
        key = lowercase(p)
        counter[key] = get(counter, key, 0) + 1
    end
end

# Sortiere nach Häufigkeit
sorted = sort(collect(counter), by = x -> x[2], rev = true)
total = length(TEST_FUNCTIONS)

println("\n=== PROPERTY-STATISTIK ($(total) Funktionen) ===\n")
println("  Anzahl  | Property")
println("----------+----------------------------------------")

for (i, (prop, count)) in enumerate(sorted)
    percent = round(100 * count / total, digits=1)
    println(lpad(count, 7), "  | $prop  ($percent%)  ")
end

println("\nGesamt verschiedene Properties: $(length(sorted))")
if !isempty(sorted)
    top = first(sorted)
    println("Häufigste Property: \"$(top[1])\" mit $(top[2]) Vorkommen")
end