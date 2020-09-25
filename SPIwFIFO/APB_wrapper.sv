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
    logic sample;
    logic write_enable, read_enable;
    
    logic sync_enable;
    
    logic [15:0] sampleData_temp, PRDATA_temp;
    logic [10:0] clock_divider, n_clock_divider;
    
    SPI spi0(clk8, PRESETn, sample, MISO, CS_b, sclk, sampleData_temp);
    
    SimpleQueue que(PCLK, PRESETn, sample, sampleData_temp, read_enable, sync_enable, interrupt, PRDATA_temp); 
    
    assign PREADY = 1'b1; //Always ready
    assign PSLVERR = 1'b0; //Always okay
    
    assign read_enable = PSEL & PENABLE & ~PWRITE;
    assign write_enable = PSEL & PENABLE & PWRITE;
      
    assign sync_enable = write_enable && PWDATA[0]; //must renable after every burst
    
   
    always_comb begin
        n_clock_divider = clock_divider + 1; 
        sample = (n_clock_divider == 15'd500);
        
        if(PADDR[3:0] == 4'b0) begin
            PRDATA = {16'b0, PRDATA_temp};
        end else begin
            PRDATA = 32'hDEADDEAD;
        end
    end
    
    always @(posedge clk8 or negedge PRESETn) begin
        if(~PRESETn | ~timer_enabled) begin
            clock_divider <= 1'b0; 
        end else begin
            if(n_clock_divider >= 15'd500) begin
                clock_divider <= 1'b0; 
            end else begin
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