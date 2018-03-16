#!/usr/bin/env tclsh

# NOTE: Tested with Vivado 2017.4 Design Suite only

# Configure these variables for your project
set projectXprLoc "/home/suyash/ip_tcl_test/ip_tcl_test.xpr"
set sourceSetName "sources_1"
set sizeFile "/tmp/generatedFiles/sizeFile"
set runName "run_1"
set synthName "run_1"
set implName "impl_1"
set ipPath "/home/suyash/ip_tcl_test/ip_tcl_test.srcs/sources_1/ip/"

# Configure RAM attributes
set pointerSize 17
set strideSize 8

# Opens the projecta and generates BRAM IP with generated COE files in Vivado
open_project "${projectXprLoc}"

# Reads a file to a list
proc listFromFile {filename} {
    set f [open $filename r]
    set data [split [string trim [read $f]]]
    close $f
    return $data
}

set sizeList [listFromFile "${sizeFile}"]
# Read size of each level from file `./generatedFiless/sizeFile' and
# use it as depth attribute for the IP generator
set fileList {
    lsort [glob -directory "/tmp/generatedFiles/" "level*_.dat"]
}
set fileCounter 0

# Generate IP corresponding to each file in the list $fileList
foreach file "$fileList" {
    set bramDepth [lindex "${sizeList}" $fileCounter]
    set ipName "blk_mem_gen_${fileCounter}"
    
    update_compile_order -fileset "${sourceSetName}"
    create_ip -name blk_mem_gen -vendor xilinx.com -library ip -version 8.4 -module_name "${ipName}"
    set_property -dict [list
			CONFIG.Memory_Type {Dual_Port_ROM}
			CONFIG.Write_Width_A $pointerSize
			CONFIG.Write_Depth_A $bramDepth
			CONFIG.Read_Width_A $pointerSize
			CONFIG.Enable_A {Always_Enabled}
			CONFIG.Write_Width_B $pointerSize
			CONFIG.Read_Width_B $pointerSize
			CONFIG.Enable_B {Always_Enabled}
			CONFIG.Register_PortA_Output_of_Memory_Primitives {false}
			CONFIG.Register_PortB_Output_of_Memory_Primitives {false}
			CONFIG.Load_Init_File {true} CONFIG.Coe_File "$file"
			CONFIG.Port_A_Write_Rate {0}
			CONFIG.Port_B_Clock {100}
			CONFIG.Port_B_Enable_Rate {100}] [get_ips "${ipName}"]
    
    generate_target {instantiation_template} [get_files "${ipPath}/${ipName}/${ipName}.xci"]
    update_compile_order -fileset "${sourceSetName}"
    generate_target all [get_files  "${ipPath}/${ipName}/${ipName}.xci"]
    catch { config_ip_cache -export [get_ips -all "${ipName}"] }
    export_ip_user_files -of_objects [get_files "${ipPath}/${ipName}/${ipName}.xci"] -no_script -sync -force -quiet
    create_ip_run [get_files -of_objects [get_fileset "${sourceSetName}"] "${ipPath}/${ipName}/${ipName}.xci"]
    launch_runs -jobs 30 "${ipName}_${synthName}"

    wait_on_run "${ipName}_${synthName}"
    
    puts "[INFO] [CUSTOM SCRIPT] Generated for $file"
    incr fileCounter
}

puts "[INFO] Generation completed"
