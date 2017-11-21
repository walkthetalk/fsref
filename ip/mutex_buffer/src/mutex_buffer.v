`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 11/18/2016 01:33:37 PM
// Design Name:
// Module Name: mutex_buffer_ctl
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
module mutex_buffer #
(
	parameter integer C_ADDR_WIDTH = 32,
	parameter integer C_BUFF_IDX_WIDTH = 2
) (
	input wire clk,
	input wire resetn,

	output wire wr_done,

	input wire [C_ADDR_WIDTH-1:0] buf0_addr,
	input wire [C_ADDR_WIDTH-1:0] buf1_addr,
	input wire [C_ADDR_WIDTH-1:0] buf2_addr,
	input wire [C_ADDR_WIDTH-1:0] buf3_addr,

	input wire w_sof,
	output reg [C_ADDR_WIDTH-1:0] w_addr,
	output reg [C_BUFF_IDX_WIDTH-1:0] w_idx,

	input wire r0_sof,
	output reg [C_ADDR_WIDTH-1:0] r0_addr,
	output reg [C_BUFF_IDX_WIDTH-1:0] r0_idx,

	input wire r1_sof,
	output reg [C_ADDR_WIDTH-1:0] r1_addr,
	output reg [C_BUFF_IDX_WIDTH-1:0] r1_idx
);

	localparam integer C_READER_NUM = 2;
	localparam integer C_BUFF_NUM = C_READER_NUM + 2;

	assign wr_done = w_sof;

	reg [C_BUFF_NUM-1:0]	r0_bmp;
	reg [C_BUFF_NUM-1:0]	r1_bmp;

	reg [C_ADDR_WIDTH-1:0]	last_addr;
	reg [C_BUFF_NUM-1:0]	last_bmp;
	reg [C_BUFF_IDX_WIDTH-1:0] last_idx;

	reg [C_BUFF_NUM-1:0]	w_bmp;

	/// reader 0
	always @(posedge clk) begin
		if (resetn == 0) begin
			r0_addr <= 0;
			r0_bmp  <= 0;
			r0_idx  <= 0;
		end
		else if (r0_sof) begin
			if (w_sof) begin
				r0_addr <= w_addr;
				r0_bmp  <= w_bmp;
				r0_idx  <= w_idx;
			end
			else begin
				r0_addr <= last_addr;
				r0_bmp  <= last_bmp;
				r0_idx  <= last_idx;
			end
		end
	end

	/// reader 1 (same as reader 0)
	always @(posedge clk) begin
		if (resetn == 0) begin
			r1_addr <= 0;
			r1_bmp  <= 0;
			r1_idx  <= 0;
		end
		else if (r1_sof) begin
			if (w_sof) begin
				r1_addr <= w_addr;
				r1_bmp  <= w_bmp;
				r1_idx  <= w_idx;
			end
			else begin
				r1_addr <= last_addr;
				r1_bmp  <= last_bmp;
				r1_idx  <= last_idx;
			end
		end
	end

	/// last done (ready for read)
	always @(posedge clk) begin
		if (resetn == 0) begin
			last_addr <= buf0_addr;
			last_bmp  <= 4'b0001;
			last_idx  <= 0;
		end
		else if (w_sof) begin
			last_addr <= w_addr;
			last_bmp  <= w_bmp;
			last_idx  <= w_idx;
		end
	end

	always @(posedge clk) begin
		if (resetn == 0) begin
			w_addr <= buf1_addr;
			w_bmp  <= 4'b0010;
			w_idx  <= 1;
		end
		else if (w_sof) begin
			casez (w_bmp | r0_bmp | r1_bmp)
			4'b???0: begin
				w_addr	<= buf0_addr;
				w_bmp	<= 4'b0001;
				w_idx	<= 0;
			end
			4'b??01: begin
				w_addr	<= buf1_addr;
				w_bmp	<= 4'b0010;
				w_idx	<= 1;
			end
			4'b?011: begin
				w_addr	<= buf2_addr;
				w_bmp	<= 4'b0100;
				w_idx	<= 2;
			end
			4'b0111: begin
				w_addr	<= buf3_addr;
				w_bmp	<= 4'b1000;
				w_idx	<= 3;
			end
			default: begin
				w_addr <= buf1_addr;
				w_bmp  <= 4'b0010;
				w_idx  <= 1;
			end
			endcase
		end
	end

endmodule
