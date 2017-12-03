#!/usr/bin/env bash

####----####----####----####----####
# Declarations
STRIDE_SIZE=8
DEST_DIR=./generatedFiles/

STRIDE_FILE_NAME_PREFIX="level_"
STRIDE_FILE_NAME_SUFFIX=".dat"

LP_FILE_NAME_PREFIX="level_"
LP_FILE_NAME_SUFFIX="lp.dat"

RP_FILE_NAME_PREFIX="level_"
RP_FILE_NAME_SUFFIX="rp.dat"
  
RP_VB_FILE_NAME_PREFIX="vb_level_"
RP_VB_FILE_NAME_SUFFIX="rp.dat"

LP_VB_FILE_NAME_PREFIX="vb_level_"
LP_VB_FILE_NAME_SUFFIX="lp.dat"

# Make directory for destination files
mkdir $DEST_DIR

####----####----####----####----####
counter=-1
initialStr=$STRIDE_FILE_NAME_PREFIX
# Read the stride information from file stride_file.dat
while read line; do
    # Skip the first element
    if [ $counter != -1 ]
    then
	strideArray=( $line )
	for i in "${strideArray[@]}"; do
	    echo "level: $i"
	    ./asciiToHex.py $i $STRIDE_SIZE >> "$DEST_DIR$initialStr$STRIDE_FILE_NAME_SUFFIX"
	    #echo -e "\n" >> "$initialStr$STRIDE_FILE_NAME_SUFFIX"
	done

	# Update file name for next iteration
	initialStr="${initialStr}_"
    fi
    counter=$(($counter + 1))
done < stride_file.dat


####----####----####----####----####
counter=-1
initialStr=$LP_VB_FILE_NAME_PREFIX
# Read the stride information from file stride_file.dat
while read line; do
    # Skip the first element
    if [ $counter != -1 ]
    then
	strideArray=( $line )
	for i in "${strideArray[@]}"; do
	    echo "level: $i"
	    ./asciiToHex.py $i $STRIDE_SIZE >> "$DEST_DIR$initialStr$LP_VB_FILE_NAME_SUFFIX"
	done

	# Update file name for next iteration
	initialStr="${initialStr}_"
    fi
    counter=$(($counter + 1))
done < lpVb_file.dat


####----####----####----####----####
counter=-1
initialStr=$RP_VB_FILE_NAME_PREFIX
# Read the stride information from file stride_file.dat
while read line; do
    # Skip the first element
    if [ $counter != -1 ]
    then
	strideArray=( $line )
	for i in "${strideArray[@]}"; do
	    echo "level: $i"
	    ./asciiToHex.py $i $STRIDE_SIZE >> "$DEST_DIR$initialStr$RP_VB_FILE_NAME_SUFFIX"
	done

	# Update file name for next iteration
	initialStr="${initialStr}_"
    fi
    counter=$(($counter + 1))
done < rpVb_file.dat


####----####----####----####----####
counter=-1
initialStr=$LP_FILE_NAME_PREFIX
# Read the stride information from file stride_file.dat
while read line; do
    # Skip the first element
    if [ $counter != -1 ]
    then
	strideArray=( $line )
	for i in "${strideArray[@]}"; do
	    echo "level: $i"
	    ./asciiToHex.py $i $STRIDE_SIZE >> "$DEST_DIR$initialStr$LP_FILE_NAME_SUFFIX"
	done

	# Update file name for next iteration
	initialStr="${initialStr}_"
    fi
    counter=$(($counter + 1))
done < lp_file.dat


####----####----####----####----####
counter=-1
initialStr=$RP_FILE_NAME_PREFIX
# Read the stride information from file stride_file.dat
while read line; do
    # Skip the first element
    if [ $counter != -1 ]
    then
	strideArray=( $line )
	for i in "${strideArray[@]}"; do
	    echo "level: $i"
	    ./asciiToHex.py $i $STRIDE_SIZE >> "$DEST_DIR$initialStr$RP_FILE_NAME_SUFFIX"
	done

	# Update file name for next iteration
	initialStr="${initialStr}_"
    fi
    counter=$(($counter + 1))
done < rp_file.dat

