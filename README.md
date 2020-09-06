test.sv : A sim test of all the functionality

Fake_proc.sv : A wrapper that outputs the apb signals to an arduino board (Must change the interrupt timer to the commented value)

###################################
Functions
###################################
Disable RTL:
  PWRITE = 1
  PWDATA = 0

Enable RTL:
  PWRITE = 1
  PWDATA = 1
  
Read Last Value:
  PWRITE = 0
  PADDR[3:0] == 0
  
Read Test Value:
  PWRITE = 0
  PADDR[3:0] != 0
