#!/usr/bin/env sh

f="./sample_file"
for f in ./generatedFiles/*; do
    content=$(awk '{print $0, ","}' "$f" | tr -d ' ' | head -n-1)
    tail=$(tail -n-1 $f)
    tail=${tail%$'\n'}
    printf "memory_initialization_radix = 16;\nmemory_initialization_vector = \n${content}\n${tail};\n" > "$f"
done
