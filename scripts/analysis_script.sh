#!/bin/bash

# Script for analysing data-set with increasing number of names.
# NOTE: Assuming the data-set used is random

# Specify path of file to read dataset from
FILE_PATH=/home/suyash/Documents/GitHub/ndn-pit/datasets/Average_workload.lineLenRndOpp.fib

# Execute loop with increasing dataset size
for num in {500000..3000000..500000}
do
    # Get first $num values from the dataset
    cat $FILE_PATH | head -n$num > temp0

    # Sort file according to length of each line
    awk '{print length, $0}' temp0 | sort -n | cut -d " " -f2- > temp1

    # Reverse sorted file and store it in another file
    tac temp1 > temp2

    # execute analysis program and store the results 
    ./a.out temp1 >> results
    ./a.out temp2 >> results
    
    echo "loop iteration: $i"
done
    
