#!/bin/bashpp

# Script for analysing data-set with increasing number of names.
# NOTE: Assuming the data-set used is random

# Specify path of file to read dataset from
#FILE_PATH=/home/suyash/Documents/GitHub/ndn-pit/datasets/Average_workload.lineLenRndOpp.fib
FILE_PATH=./Average_workload.lineLenRndOpp.fib     

# Execute loop with increasing dataset size
for num in {500000..3000000..500000}
do
    # Get first $num values from the dataset
    cat $FILE_PATH | head -n$num > temp0

    # Sort file according to length of each line
    awk '{print length, $0}' temp0 | sort -n | cut -d " " -f2- > temp1

    # Clear temp0 file
    echo "" > temp0
    # Starting from first line take k lines and sort them alphabetically
    k=500
    kn=$(($num / $k))
    echo "$kn"
    for i in $( eval echo {1..$kn..1} )
    do
	start=$(($i * $k))
	sed -n "$start,+499p" temp1 | sort >> temp0
	# echo -en "\rAt position: $i with start=$start and Added $(eval sed -n "$start,+499p" temp1 | wc -l) words to temp0 size of temp0 is: $(eval cat temp0|wc -l)"
	echo -en "\rAt position: $i with start=$start"
    done
    
    # Reverse sorted file and store it in another file
    # Uncomment the following line to perform analysis using reverse first strategy
    tac temp0 > temp2

    # execute analysis program and store the results 
    # ./a.out temp0 >> results
    ./a.out temp2 >> results
    
    echo -en "\nloop iteration: $num\n\n"
    #exit
done
    
