#
# This file was created by Xilinx Vitis tool.
#


#
# tools
#

RM = rm -f
RMDIR = rm -rf

#
# variables
#

SDCARD_GEN = sdcard_gen
GENERATE_BIF = ::scw::generate_bif

XPFM_PATH = C:/Users/Zach/Documents/VitisWorkspace/test/export/test/test.xpfm
SYS_CONFIG = test
DOMAINS = standalone_domain
BIF_PATH = C:/Users/Zach/Documents/VitisWorkspace/test_s_system/Debug/system.bif

BITSTREAM_PATH = C:/Users/Zach/Documents/VitisWorkspace/test_s/_ide/bitstream/system_top.bit
SD_FILES = --elf C:/Users/Zach/Documents/VitisWorkspace/test_s/Debug/test_s.elf,ps7_cortexa9_0

#
# primary build targets
#

all: sd_card

sd_card:
	-@echo Generating bif file for the system project
	generate_system_bif.bat 52262 ${XPFM_PATH} ${DOMAINS} ${BIF_PATH}
	${SDCARD_GEN} --xpfm ${XPFM_PATH} --sys_config ${SYS_CONFIG} --bif ${BIF_PATH} --bitstream ${BITSTREAM_PATH} ${SD_FILES}

clean:
	$(RMDIR) ./_sds
	${RMDIR} sd_card
	${RM} system.bif

.PHONY: all sd_card clean


