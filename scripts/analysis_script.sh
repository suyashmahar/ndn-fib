#!/bin/bash

FILE_PATH=/home/suyash/Documents/GitHub/ndn-pit/datasets/Average_workload.lineLenRndOpp.fib
for num in {500000..3000000..500000}
do
    cat $FILE_PATH | head -n$num > temp0
    awk '{print length, $0}' temp0 | sort -n | cut -d " " -f2- > temp1
    tac temp1 > temp2
    
    ./a.out temp1 >> results
    ./a.out temp2 >> results
    echo "loop iteration: $i"
done
    
