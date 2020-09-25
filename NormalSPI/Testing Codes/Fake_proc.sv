module FakeProc(
	input sysclk,
	input reset,	
	input quick_sample,
	
    //SPI
	input MISO,
	output logic CS_b,
	output logic sclk,
    //SPI
    
    output logic debug,
    output logic interrupt,
    output logic [11:0] data
    );
    
    logic PSEL, PENABLE;
    logic [31:0] PRDATA;
    
    logic PREADY;
    
    logic quick_sample_h;
    
    logic [2:0] counter;
    logic clk8; //15.625 mhz
    
    logic PSLVERR;
    
    
    SPI_APB_wrapper wrap(   sysclk, ~reset, PSEL, 12'b0, PENABLE, 1'b0, 32'b0,
                            PRDATA, PREADY, PSLVERR,
                            
                            MISO, CS_b, sclk,
                            clk8, interrupt
                        );
    
    
    always_comb begin
        PSEL = (quick_sample & ~quick_sample_h);
        PENABLE = (quick_sample & ~quick_sample_h);
        
        clk8 = counter[2];
        
        data = PRDATA[11:0]; 
    end
    

    
    always_ff @(posedge sysclk) begin
            if(reset) begin
                counter <= 1'b0;
            end else begin
                counter <= counter + 1;
            end
            quick_sample_h <= quick_sample;
    end
endmodule
