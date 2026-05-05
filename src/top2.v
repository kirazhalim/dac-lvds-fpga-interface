`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.09.2025 15:40:43
// Design Name: 
// Module Name: top2
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: `timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.09.2025 07:54:09
// Design Name: 
// Module Name: top
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


module top2(
    input wire clk_in,
    input wire reset_n,
    output wire led

    );
//    output reg [11:0] data_A,
//    output reg [11:0] data_B
    wire clk;
    wire locked;
    wire [11:0] data_p;
//    wire [11:0] data_n;
    
    clk_wiz_0 clk_ins
       (
        .clk_out1(clk),
        .reset(~reset_n),
        .locked(locked),
        .clk_in1(clk_in)
    );

    wire [31:0] m_axis_data_tdata;

    wire pulse_out;
    
    pulse_gen pulse_gen_inst (
        .clk(clk),
        .rst_n(reset_n),
        .pulse_out(pulse_out) 
    );
    
    
    dds_compiler_1 dds_inst (
        .aclk(clk),
        .m_axis_data_tvalid(),
        .aclken(pulse_out),
        .m_axis_data_tdata(m_axis_data_tdata)
    );

    reg [11:0] data_A;
    reg [11:0] data_B;

    always @(posedge clk) begin
        if (~reset_n) begin
            data_A <= 0;
            data_B <= 0;
        end else begin
            data_A <= m_axis_data_tdata[27:16] + 12'd2048;
            data_B <= m_axis_data_tdata[11:0] + 12'd2048;
        end
    end
    
   
    
    // interleaving the I and Q data
    wire [11:0] dac_data_s;
    genvar i;
    generate
        for (i = 0; i < 12; i = i + 1) begin : ODDR_DATA
            ODDR #(
                .DDR_CLK_EDGE("OPPOSITE_EDGE"),
                .INIT(1'b0),
                .SRTYPE("SYNC")
            ) oddr_data (
                .Q(dac_data_s[i]),
                .C(clk),
                .CE(pulse_out),
                .D1(data_A[i]),
                .D2(data_B[i]),
                .R(~reset_n),
                .S(1'b0)
            );
        end
    endgenerate
    
    generate
        for (i = 0; i < 12; i = i + 1) begin : OBUF_DATA
            OBUF #(
               .DRIVE(12),   // Specify the output drive strength
               .IOSTANDARD("DEFAULT"), // Specify the output I/O standard
               .SLEW("SLOW") // Specify the output slew rate
            ) OBUF_inst (
               .O(data_p[i]),     // Buffer output (connect directly to top-level port)
               .I(dac_data_s[i])      // Buffer input
            );
        end
    endgenerate
    
//  generating data_p and data_n
//    generate
//        for (i = 0; i < 12; i = i + 1) begin : OBUFDS_DATA
//            OBUFDS #(
//                .IOSTANDARD("LVDS_25"),
//                .SLEW("SLOW")
//            ) OBUFDS_data_inst (
//                .O(data_p[i]),
//                .OB(data_n[i]),
//                .I(dac_data_s[i])
//            );
//        end
//    endgenerate
    
    
    ila_0 ila_inst (
        .clk(clk), // input wire clk
        .probe0(data_A),
        .probe1(data_B),
        .probe2(data_p)
    );
        
    led_toggle led_inst(
        .clk(clk),
        .reset_n(reset_n),
        .led(led)
    );
endmodule
