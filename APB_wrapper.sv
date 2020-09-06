module SPI_APB_wrapper(
    input PCLK, // PCLK for timer operation
    input PRESETn, // Reset
    input PSEL, // Device select
    input [11:0] PADDR, // Address
    input PENABLE, // Transfer control
    input PWRITE, // Write control
    input [31:0] PWDATA, // Write data
    output logic [31:0] PRDATA , // Read data
    output logic PREADY, // Device ready
    output logic PSLVERR, // Device error response
    
    //SPI
	input MISO,
	output logic CS_b,
	output logic sclk,
    //SPI
   
    input clk8,
    output logic interrupt
    );
    
    logic timer_enabled;
    logic write_enable, read_enable;
    
    logic [15:0] PRDATA_temp;
    logic [14:0] clock_divider, n_clock_divider;
    
    SPI spi0(PCLK, ~PRESETn, read_enable, MISO, CS_b, sclk, PRDATA_temp);
    
    assign PREADY = 1'b1; //Always ready
    assign PSLVERR = 1'b0; //Always okay
    
    assign read_enable  = PSEL & PENABLE & ~PWRITE;
    assign write_enable = PSEL & PENABLE & PWRITE;
    
    
    always_comb begin
        n_clock_divider = clock_divider + 1;   
        
        if(PADDR[3:0] == 4'b0) begin
            PRDATA = {16'b0, PRDATA_temp};
        end else begin
            PRDATA = 32'hDEADDEAD;
        end
    end
    
    always @(posedge clk8 or negedge PRESETn) begin
        if(~PRESETn) begin
            clock_divider <= 1'b0;   
            interrupt <= 1'b0;
        end else begin
            if(n_clock_divider >= 15'd250) begin //Cycles per half //489
                clock_divider <= 1'b0;   
                interrupt <= !interrupt;
            end else if(timer_enabled) begin
                clock_divider <= n_clock_divider;
            end      
        end        
    end
    
    always @(posedge PCLK or negedge PRESETn) begin
        if(~PRESETn) begin
            timer_enabled <= 1'b1; //default on for now
        end else if(write_enable) begin
            timer_enabled <= PWDATA[0];
        end
    end
    
endmodule
