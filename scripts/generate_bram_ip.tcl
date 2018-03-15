#!/usr/bin/env tclsh

# Generates BRAM IP with generated COE files in Vivado

# Change the name of this variable to reflect your source set, run and impl
set sourceSetName "sources_1"
set runName "run_1"
set synthName "run_1"
set implName "impl_1"
set ipPath "/home/suyash/comptreesim_tcl_ip/comptreesim_tcl_ip.srcs/sources_1/ip/"

set fileList {
    lsort [glob -directory "./generatedFiles/" "level*_.dat"]
}
set fileCounter 0

# Generate IP corresponding to each file in the list $fileList
foreach file "$fileList" {
    update_compile_order -fileset "${sourceSetName}"

    set ipName "blk_mem_gen_${fileCounter}"
    create_ip -name blk_mem_gen -vendor xilinx.com -library ip -version 8.4 -module_name "${ipName}"
    set_property -dict [list CONFIG.Memory_Type {Dual_Port_ROM} CONFIG.Write_Width_A {8} CONFIG.Read_Width_A {8} CONFIG.Enable_A {Always_Enabled} CONFIG.Write_Width_B {8} CONFIG.Read_Width_B {8} CONFIG.Enable_B {Always_Enabled} CONFIG.Register_PortA_Output_of_Memory_Primitives {false} CONFIG.Register_PortB_Output_of_Memory_Primitives {false} CONFIG.Load_Init_File {true} CONFIG.Coe_File {"$file"} CONFIG.Port_A_Write_Rate {0} CONFIG.Port_B_Clock {100} CONFIG.Port_B_Enable_Rate {100}] [get_ips "${ipName}"]
    generate_target {instantiation_template} [get_files "${ipPath}/${ipName}/${ipName}.xci"]
    update_compile_order -fileset "${sourceSetName}"
    generate_target all [get_files  "${ipPath}/${ipName}/${ipName}.xci"]
    catch { config_ip_cache -export [get_ips -all "${ipName}"] }
    export_ip_user_files -of_objects [get_files "${ipPath}/${ipName}/${ipName}.xci"] -no_script -sync -force -quiet
    create_ip_run [get_files -of_objects [get_fileset "${sourceSetName}"] "${ipPath}/${ipName}/${ipName}.xci"]
    launch_runs -jobs 30 "${ipName}_${synthName}"

    puts "[INFO] [CUSTOM SCRIPT] Generated for $file"
    incr fileCounter
}

puts "[INFO] Generation completed"
