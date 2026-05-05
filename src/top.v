`timescale 1ns / 1ps

module top (
    input wire clk_in,
    input wire reset_n,
    output wire dac_clk_p,
    output wire dac_clk_n,
    output wire [11:0] dac_data_p,
    output wire [11:0] dac_data_n
);

    wire clkfb_buf;
    wire clkout0_buf;

    wire CLKOUT0;
    wire CLKFBOUT;
    wire LOCKED;
    wire CLKFBIN;
    
    wire reset_int = (~reset_n) | (~LOCKED);
    
    PLLE2_BASE #(
       .BANDWIDTH("OPTIMIZED"),
       .CLKFBOUT_MULT(10),       // VCO = 100 MHz * 10 = 1000 MHz
       .CLKFBOUT_PHASE(0.0),
       .CLKIN1_PERIOD(10.0),     // 100 MHz input clock
       .CLKOUT0_DIVIDE(2),       // CLKOUT0 = 1000 / 2 = 500 MHz
       .CLKOUT0_DUTY_CYCLE(0.5),
       .CLKOUT0_PHASE(0.0),
       .DIVCLK_DIVIDE(1),
       .REF_JITTER1(0.0),
       .STARTUP_WAIT("FALSE")
    ) pll_inst (
       .CLKOUT0(CLKOUT0),
       .CLKFBOUT(CLKFBOUT),
       .LOCKED(LOCKED),
       .CLKIN1(clk_in),
       .PWRDWN(1'b0),
       .RST(~reset_n),
       .CLKFBIN(CLKFBIN)
    );

    BUFG clkfb_bufg (
        .I(CLKFBOUT),
        .O(clkfb_buf)
    );

    assign CLKFBIN = clkfb_buf;

    BUFG clkout0_bufg (
        .I(CLKOUT0),
        .O(clkout0_buf)
    );

    wire dac_clk = clkout0_buf;

    wire signed [11:0] dds_out_I;
    wire signed [11:0] dds_out_Q;
    wire [31:0] m_axis_data_tdata;

    dds_compiler_0 dds_inst (
        .aclk(dac_clk),
        .m_axis_data_tvalid(),
        .m_axis_data_tdata(m_axis_data_tdata)
    );

    assign dds_out_I = m_axis_data_tdata[27:16];
    assign dds_out_Q = m_axis_data_tdata[11:0];

    wire [11:0] dds_out_I_offset = dds_out_I + 12'd2048;
    wire [11:0] dds_out_Q_offset = dds_out_Q + 12'd2048;

    reg [11:0] data_A;
    reg [11:0] data_B;

    always @(posedge dac_clk) begin
        if (reset_int) begin
            data_A <= 0;
            data_B <= 0;
        end else begin
            data_A <= dds_out_I_offset;
            data_B <= dds_out_Q_offset;
        end
    end

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
                .C(dac_clk),
                .CE(1'b1),
                .D1(data_A[i]),
                .D2(data_B[i]),
                .R(reset_int),
                .S(1'b0)
            );
        end
    endgenerate

    wire dac_clk_lvds;
    ODDR #(
        .DDR_CLK_EDGE("SAME_EDGE"),
        .INIT(1'b0),
        .SRTYPE("SYNC")
    ) oddr_clk_out (
        .Q(dac_clk_lvds),
        .C(dac_clk),
        .CE(1'b1),
        .D1(1'b1),
        .D2(1'b0),
        .R(reset_int),
        .S(1'b0)
    );

    OBUFDS #(
        .IOSTANDARD("LVPECL"),
        .SLEW("SLOW")
    ) OBUFDS_clk_inst (
        .O(dac_clk_p),
        .OB(dac_clk_n),
        .I(dac_clk_lvds)
    );

    generate
        for (i = 0; i < 12; i = i + 1) begin : OBUFDS_DATA
            OBUFDS #(
                .IOSTANDARD("LVDS"),
                .SLEW("SLOW")
            ) OBUFDS_data_inst (
                .O(dac_data_p[i]),
                .OB(dac_data_n[i]),
                .I(dac_data_s[i])
            );
        end
    endgenerate
   
endmodule
