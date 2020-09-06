module test();

localparam CLOCK_PERIOD = 8.0;
localparam FIXED_CLOCK_PERIOD = 125.0;

logic PCLK, PRESETn, PSEL;
logic [11:0] PADDR;
logic PENABLE, PWRITE;
logic [31:0] PWDATA;

logic [31:0] PRDATA;
logic PREADY, PSLVERR;
    
logic MISO, CS_b, sclk;

logic clk8, interrupt;


SPI_APB_wrapper wrap(   PCLK, PRESETn, PSEL, PADDR, PENABLE, PWRITE, PWDATA,
                        PRDATA, PREADY, PSLVERR,
                        
                        MISO, CS_b, sclk,
                        clk8, interrupt
                    );


always begin
    #(CLOCK_PERIOD/2.0);
    PCLK = ~PCLK;
end


always begin
    #(FIXED_CLOCK_PERIOD/2.0);
    clk8 = ~clk8;
end

logic interrupt_h;

always @(posedge PCLK) begin //Set APB Request after interrupt
    if(!interrupt && interrupt_h) begin
         PSEL = 1;   
         PENABLE = 1;  
    end else begin
         PSEL = 0;   
         PENABLE = 0;  
    end
    interrupt_h = interrupt;
end

initial begin
	PCLK = 1'b0; //Reset
	clk8 = 1'b0;
	
    PRESETn = 1'b0;
    PWRITE = 0;
    PADDR = 12'b0;
    PWDATA = 32'b0;
    
    MISO = 1'b1;
    
    @(negedge PCLK);   
	PRESETn = 1'b1;


	for(int h = 0; h < 50000; h++) begin //Test normal use
        @(negedge PCLK);
	end
	
    PSEL = 1; //Disable 
    PENABLE = 1;  
	PWRITE = 1;
    @(negedge PCLK); 
	PWRITE = 0;	
    PSEL = 1;   
    PENABLE = 1;  

    for(int h = 0; h < 50000; h++) begin
        @(negedge PCLK);
	end
	
    PSEL = 1; //Enable 
    PENABLE = 1; 
	PWRITE = 1;
    PWDATA = 1;	
    @(negedge PCLK);
	PWRITE = 0;	
    PWDATA = 0;	
    PSEL = 1;   
    PENABLE = 1; 
	
    for(int h = 0; h < 50000; h++) begin
        @(negedge PCLK);
	end
	
	PADDR = 4; //Read Test Reg
	
    for(int h = 0; h < 50000; h++) begin
        @(negedge PCLK);
	end
	
	
	@(negedge PCLK);
	$finish;
end


endmodule