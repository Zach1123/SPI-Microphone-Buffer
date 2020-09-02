
module SPI_APB_wrapper(
    input PCLK,
    input fixed_clock, //8 mhz
    input PRESETn,
    input PSEL,
    input PENABLE,
    
    //SPI
	input MISO,
	output logic CS_b,
	output logic sclk,
    //SPI
    
    output logic [15:0] PRDATA,
    output logic PREADY,
    
    output logic interrupt
    );
    
    logic [14:0] clock_divider, n_clock_divider;
    
    logic exact_sample;
    SPI spi0(PCLK, ~PRESETn, exact_sample, MISO, CS_b, sclk, PRDATA);
    
    
    always_comb begin
        exact_sample = PSEL & PENABLE;
        PREADY = PSEL & PENABLE;
        
        n_clock_divider = clock_divider + 1;   
    end
    
    always @(posedge fixed_clock or negedge PRESETn) begin
        if(!PRESETn) begin
            clock_divider <= 1'b0;   
            interrupt <= 1'b0;
        end else begin
            if(n_clock_divider >= 15'd250) begin //Cycles per half
                clock_divider <= 1'b0;   
                interrupt <= !interrupt;
            end else begin
                clock_divider <= n_clock_divider;
            end      
        end        
    end
    
endmodule
