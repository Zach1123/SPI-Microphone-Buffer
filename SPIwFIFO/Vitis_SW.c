#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "sleep.h"

#include "xbasic_types.h"
#include "xscugic.h"
#include "xil_exception.h"


#define INTC_INTERRUPT_ID_0 61 // IRQ_F2P[0:0]
#define INTC_INTERRUPT_ID_1 62 // IRQ_F2P[1:1]
// instance of interrupt controller
static XScuGic intc;

volatile int counter;
volatile int x;
volatile int MicData;
uint *addr = 0x40010000;


void setup_interrupt_system();

void isr0 (void *intc_inst_ptr) { //NOT USED
    xil_printf("isr0 called??\n\r");
}

void isr1 (void *intc_inst_ptr) {
	for(int i = 0; i < 64; i++)
	{
	    x += 1;
	    MicData = *addr;
	}
	counter += 1;
	*addr = 1;
}

int main()
{
	x = 0;
	setup_interrupt_system();


    init_platform();


    int iter = 0;
    while(iter < 100){
    	if(x > 1600)
    	{
        	printf("%d\n\r", MicData);
        	x = x % 1600;
        	iter += 1;
    	}
    	//printf("%d\n\r", (x - prev_x));
    }


    *addr = 0;
    sleep(10);
    *addr = 1;


    iter = 0;
    while(iter < 100){
    	if(x > 1600)
    	{
        	printf("%d\n\r", MicData);
        	x = x % 1600;
        	iter += 1;
    	}
    	//printf("%d\n\r", (x - prev_x));
    }


    x = 0;
	counter = 0;
    sleep(10);
	printf("%d\n\r", counter);
	printf("%d\n\r", x);


    x = 0;
	counter = 0;
    sleep(10);
	printf("%d\n\r", x);
	printf("%d\n\r", counter);

    cleanup_platform();
    return 0;
}

void setup_interrupt_system() {
    int result;
    XScuGic *intc_instance_ptr = &intc;
    XScuGic_Config *intc_config;

    // get config for interrupt controller
    intc_config = XScuGic_LookupConfig(XPAR_PS7_SCUGIC_0_DEVICE_ID);

    // initialize the interrupt controller driver
    result = XScuGic_CfgInitialize(intc_instance_ptr, intc_config, intc_config->CpuBaseAddress);

    // initialize the interrupt controller driver
    //result = XScuGic_CfgInitialize(intc_instance_ptr, intc_config, intc_config->CpuBaseAddress);

    // set the priority of IRQ_F2P[0:0] to 0xA0 (highest 0xF8, lowest 0x00) and a trigger for a rising edge 0x3.
    XScuGic_SetPriorityTriggerType(intc_instance_ptr, INTC_INTERRUPT_ID_0, 0xA0, 0x3);

    // connect the interrupt service routine isr0 to the interrupt controller
    result = XScuGic_Connect(intc_instance_ptr, INTC_INTERRUPT_ID_0, (Xil_ExceptionHandler)isr0, (void *)&intc);

    // enable interrupts for IRQ_F2P[0:0]
    XScuGic_Enable(intc_instance_ptr, INTC_INTERRUPT_ID_0);

    // set the priority of IRQ_F2P[1:1] to 0xA8 (highest 0xF8, lowest 0x00) and a trigger for a rising edge 0x3.
    XScuGic_SetPriorityTriggerType(intc_instance_ptr, INTC_INTERRUPT_ID_1, 0xA8, 0x3);

    // connect the interrupt service routine isr1 to the interrupt controller
    result = XScuGic_Connect(intc_instance_ptr, INTC_INTERRUPT_ID_1, (Xil_ExceptionHandler)isr1, (void *)&intc);

    // enable interrupts for IRQ_F2P[1:1]
    XScuGic_Enable(intc_instance_ptr, INTC_INTERRUPT_ID_1);

    // initialize the exception table and register the interrupt controller handler with the exception table
    Xil_ExceptionInit();

    Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT, (Xil_ExceptionHandler)XScuGic_InterruptHandler, intc_instance_ptr);

    // enable non-critical exceptions
    Xil_ExceptionEnable();
}
