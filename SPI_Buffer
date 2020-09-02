localparam log_clock_div =  6; //Min 1
localparam clock_delay = log_clock_div - 1;

module SPI(
	input sysclk,
	input reset,
	input sample,

    //SPI
	input MISO,
	output logic CS_b,
	output logic sclk,
    //SPI

	output logic [15:0] SPI_data);

	logic [clock_delay:0] clk_divider, n_clk_divider;
	logic [4:0] cycle_counter;
	
	logic neg_sclk_tran;
	

	always_comb begin

	
		n_clk_divider = clk_divider + 1;
		sclk = clk_divider[clock_delay];
        CS_b = cycle_counter[4] && sclk;
		
		neg_sclk_tran = (~n_clk_divider[clock_delay] && clk_divider[clock_delay]); 
	end

	always_ff @(posedge sysclk) begin
		if(reset) begin
			cycle_counter <= 5'b11111;
			SPI_data <= 16'b0;
			clk_divider <= {1'b1, {clock_delay{1'b0}}};
		end else begin
			if(sample) begin
                cycle_counter <= 5'd15;
			end
			
            if(~CS_b) begin
                clk_divider <= n_clk_divider;
            end
            
			if(neg_sclk_tran) begin
			    SPI_data[cycle_counter] <= MISO;
			    cycle_counter <= cycle_counter - 1;
			end
		end
	end
endmodule
