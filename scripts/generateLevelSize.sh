#!/usr/bin/env bash
# Generates a hex file containing size of each level on a new line

for f in ./generatedFiles/level*_.dat; do
    linesCount=$(cat "$f" | wc -l)
    printf "%x\n" "$linesCount" >> "./generatedFiles/sizeFileHex"
done
