# NDN-FIB
This repository contains collection of all the work related to the FPGA based FIB implementation for Name Data Network. Details of the work are available in this paper.

# Directory Structure

## Analysis
Analysis directory contains a Jupyter notebook containing many of the analysis performed on the datasets. This is accompained by a C++ program, which implements stride analysis part of the Jupyter notebook. This is done to get better performance while processing large datasets.

## BST implementation
The data structure used for performing lookup is implemented as a C++ script and associated functions. This allows construction of tree which can be used for analysis or for constructing memory contents for the FPGA.

## Scripts
Scripts directory is collection of all the scripts ever used in the process of converting an FIB dataset to memory contents for FPGA.

## Hardware Description
This directory contains the complete description of the FIB in Verilog HDL, it also includes pre-configured projects for single-issue and dual-issue implementation.

# Performing simulation for using a dataset
Follow the following steps to convert a FIB dataset to memory contents for an FPGA:
1. Copy `bst-impl/BST.cpp`, all the scripts from `scripts/` and the desired dataset into a new directory of your choice.
2. Use `g++ BST.cpp -g --std=c++11` to compile the program used to generate the tree.
3. Use `a.out <dataset name> <stride size> <1 for generating files that represent generated tree>`  
   e.g. `./a.out my_dataset.fib 4 1` to generate files for tree constructed using the dataset `my_dataset.fib` having stride size of 4, also it asks the program to write the representation files.
4. Use `./generateImplementationFiles.sh` to generate memory files from the representative files generated from the previous step.
5. Rename the location for memory files in example Vivado project to use these files, also set the height of the tree appropiately.

# Contributions
Feel free to file issues and submit pull requests - contributions are welcome. 

Maintainer:
**Suyash Mahar**  
UG E&CE, IIT Roorkee  
suyash12mahar@outlook.com
