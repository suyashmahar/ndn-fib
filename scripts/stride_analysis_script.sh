#!/bin/bash

# Clear results file
echo "" > results

FILE_PATH=/home/suyash/Documents/GitHub/ndn-pit/datasets/1Mdataset.unique.random.fib
awk '{print length, $0}' $FILE_PATH | sort -n | cut -d " " -f2- | tac > temp1
for num in {1..16..1}
do
    ./a.out temp1 $num >> results
    echo "loop iteration: $i"
done
    
