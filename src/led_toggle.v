`timescale 1ns / 1ps
module led_toggle #(
    parameter count_max = 250_000_000 - 1  // toggle every 0.5 seconds
)(
    clk,
    reset_n,
    led
);
    input wire clk;
    input wire reset_n;
    output reg led;
    
    reg [28:0] counter = 0;
    
    always @(posedge clk or negedge reset_n) begin
        if (~reset_n) begin
            counter <= 0;
            led <= 0;
        end else begin
            if (counter == count_max) begin
                counter <= 0;
                led <= ~led;
            end else begin
                counter <= counter + 1;
            end
        end
    
    end

endmodule