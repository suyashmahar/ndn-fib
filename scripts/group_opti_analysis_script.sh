#!/bin/bashpp

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

    # Starting from first line take k lines and sort them alphabetically
    k=500
    kn=$(($num / $k))
    echo "$kn"
    for i in $( eval echo {0..$kn..1} )
    do
	echo -en "\rAt position: $i"
	start=$(($i * $k))
	sed -n "$start,+500p" temp1 | sort >> temp2
    done
    
    # Reverse sorted file and store it in another file
    tac temp2 > temp3

    # execute analysis program and store the results 
    ./a.out temp2 >> results
    ./a.out temp3 >> results
    
    echo -en "\nloop iteration: $num\n\n"
done
    
