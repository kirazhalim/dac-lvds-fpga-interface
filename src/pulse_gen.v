`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.09.2025 16:16:01
// Design Name: 
// Module Name: pulse_gen
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module pulse_gen(
    input wire clk,
    input wire rst_n,
    output reg pulse_out
    );
    
    parameter PW = 1000;
    parameter PRI = 10000;
    
    reg [13:0] counter;
    
    always @(posedge clk) begin
        if (~rst_n) begin
            counter    <= 14'd0;
            pulse_out  <= 1'b0;
        end else begin
            if (counter < PRI - 1)
                counter <= counter + 1;
            else
                counter <= 14'd0;

            if (counter < PW)
                pulse_out <= 1'b1;
            else
                pulse_out <= 1'b0;
        end
    end
    
    
    
    
endmodule
