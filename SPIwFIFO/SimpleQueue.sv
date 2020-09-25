`timescale 1ns / 1ps


////////////////
localparam bufferSize = 128; //must be a power of 2
localparam InterruptPoint = 2; //cannot be 0
///////////////

localparam logbufferSize = $clog2(bufferSize);


module SimpleQueue(
    input sys_clk,
    input PRESETn,
    
    
    input async_write,
    input [15:0] data_in,
    input sync_read,
    input sync_enable, //have to enable after every read burst
    
    
    output logic interrupt,
    output logic [15:0] data_out
    );
    
    logic disable_interrupt;
    
    logic [bufferSize - 1: 0][15:0] buffer;
    logic [logbufferSize - 1: 0] Head, Tail;
    
    logic [logbufferSize: 0] space_free; //1 bigger to handle no data in buffer
    
    always_comb begin
        data_out = buffer[Head];

        if(Head > Tail) begin
            space_free = (Head - Tail); 
        end else begin
            space_free = (bufferSize - Tail + Head);
        end
        
         interrupt = (space_free <= InterruptPoint) && !disable_interrupt; //There should not be a race case because far more than 10 pieces of data will be read in the 1/16000 of a second
    end 
    
    always_ff @(posedge sys_clk or negedge PRESETn) begin
            if(~PRESETn) begin
                Head <= 0;
                disable_interrupt <= 1'b0;
            end else if (sync_read) begin
                Head <= Head + 1;
                disable_interrupt <= 1'b1;
            end else if(sync_enable) begin
                disable_interrupt <= 1'b0;
            end
    end
    
    
    always_ff @(posedge async_write or negedge PRESETn) begin
            if(~PRESETn) begin
                Tail <= 0;
            end else begin
                Tail <= Tail + 1;
                buffer[Tail] <= data_in;
            end
    end
endmodule
