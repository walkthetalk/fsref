`timescale 1ns / 1ps
`include "../src/mutex_buffer.v"
module test_mutex_buffer(
    );

    localparam RANDOMOUTPUT = 1;
    localparam RANDOMINPUT = 1;

	reg[11:0] ori_height = 320;
	reg[11:0] ori_width = 240;

	reg[11:0] w_left = 3;
	reg[11:0] w_top = 3;
	reg[11:0] w_width = 5;
	reg[11:0] w_height = 6;

	reg resetn;
	reg clk;

	reg w_sof;
	reg r0_sof;
	reg r1_sof;

	wire [31:0] w_addr;
	wire [31:0] r0_addr;
	wire [31:0] r1_addr;

mutex_buffer #(
	.C_ADDR_WIDTH(32)
)uut(
	.buf0_addr(32'h3FF00000),
	.buf1_addr(32'h3FF10000),
	.buf2_addr(32'h3FF20000),
	.buf3_addr(32'h3FF30000),
	.w_sof(w_sof),
	.r0_sof(r0_sof),
	.r1_sof(r1_sof),
	.w_addr(w_addr),
	.r0_addr(r0_addr),
	.r1_addr(r1_addr),

	.clk(clk),
	.resetn(resetn));

initial begin
	clk <= 1'b1;
	forever #1 clk <= ~clk;
end
initial begin
	resetn <= 1'b0;
	repeat (5) #2 resetn <= 1'b0;
	forever #2 resetn <= 1'b1;
end

parameter integer C_RAN_FACTOR = 50;

always @(posedge clk) begin

	if (resetn == 1'b0) begin
		w_sof <= 0;
		r0_sof <= 0;
		r1_sof <= 0;
	end
	else begin
		w_sof <= w_sof ? 0 : ({$random}%C_RAN_FACTOR == 0);
		r0_sof <= r0_sof ? 0 : ({$random}%C_RAN_FACTOR == 0);
		r1_sof <= r1_sof ? 0 : ({$random}%C_RAN_FACTOR == 0);
	end
end


endmodule
