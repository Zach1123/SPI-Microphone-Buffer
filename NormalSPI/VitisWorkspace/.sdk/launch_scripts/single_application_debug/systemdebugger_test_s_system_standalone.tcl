connect -url tcp:127.0.0.1:3121
targets -set -nocase -filter {name =~"APU*"}
rst -system
after 3000
targets -set -filter {jtag_cable_name =~ "Digilent Zybo Z7 210351AD6838A" && level==0} -index 1
fpga -file C:/Users/Zach/Documents/VitisWorkspace/test_s/_ide/bitstream/system_top.bit
targets -set -nocase -filter {name =~"APU*"}
loadhw -hw C:/Users/Zach/Documents/VitisWorkspace/test/export/test/hw/system_top.xsa -mem-ranges [list {0x40000000 0xbfffffff}]
configparams force-mem-access 1
targets -set -nocase -filter {name =~"APU*"}
source C:/Users/Zach/Documents/VitisWorkspace/test_s/_ide/psinit/ps7_init.tcl
ps7_init
ps7_post_config
targets -set -nocase -filter {name =~ "*A9*#0"}
dow C:/Users/Zach/Documents/VitisWorkspace/test_s/Debug/test_s.elf
configparams force-mem-access 0
targets -set -nocase -filter {name =~ "*A9*#0"}
con
