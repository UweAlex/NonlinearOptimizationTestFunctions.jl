using NonlinearOptimizationTestFunctions

sorted_tfs = sort(collect(values(TEST_FUNCTIONS)); by=tf -> tf.meta[:name])

for tf_orig in sorted_tfs
    tf = fixed(tf_orig)
    props = join(tf.meta[:properties], ", ")
    println("$(tf.meta[:name]): Start at $(start(tf)), Minimum at $(min_position(tf)), Value $(min_value(tf)), Properties: $props")
end