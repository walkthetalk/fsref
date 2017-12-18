`timescale 1ns / 1ps

`include "../src/common_scaler.v"

module test_common_scaler();

	localparam RANDOMOUTPUT = 0;
	localparam RANDOMINPUT = 1;

	localparam integer C_S_WIDTH = 12;
	localparam integer C_M_WIDTH = 12;
	localparam integer C_TEST    =  0;


reg clk;
reg resetn;
reg [C_S_WIDTH-1:0] s_nbr;
reg [C_M_WIDTH-1:0] m_nbr;

reg update;

common_scaler # (
	.C_S_WIDTH(C_S_WIDTH),
	.C_M_WIDTH(C_M_WIDTH),
	.C_S_BMP  (4        ),
	.C_TEST(C_TEST)
) uut (
	.clk(clk),
	.resetn(resetn),
	.enable(1),
	.s_ready(1),
	.m_ready(1),

	.s_nbr(s_nbr),
	.m_nbr(m_nbr),
	.update(update)
);

initial begin
	clk <= 1'b1;
	forever #1 clk <= ~clk;
end

initial begin
	resetn <= 1'b0;
	repeat (5) #2 resetn <= 1'b0;
	forever #2 resetn <= 1'b1;
end

initial begin
	s_nbr <= 5;
	m_nbr <= 30;
end

always @ (posedge clk) begin
	if (resetn == 1'b0)
		update <= 0;
	else
		update <= (RANDOMOUTPUT ? {$random}%2 : 1);
end

endmodule
