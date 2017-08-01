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
module mutex_buffer_ctl #
(
	parameter integer C_ADDR_WIDTH = 32
) (
	input wire clk,
	input wire resetn,

	output wire intr,

	input wire [C_ADDR_WIDTH-1:0] buf0_addr,
	input wire [C_ADDR_WIDTH-1:0] buf1_addr,
	input wire [C_ADDR_WIDTH-1:0] buf2_addr,
	input wire [C_ADDR_WIDTH-1:0] buf3_addr,

	input wire w_sof,
	output reg [C_ADDR_WIDTH-1:0] w_addr,

	input wire r0_sof,
	output reg [C_ADDR_WIDTH-1:0] r0_addr,

	input wire r1_sof,
	output reg [C_ADDR_WIDTH-1:0] r1_addr
);

	localparam integer C_READER_NUM = 2;
	localparam integer C_BUFF_NUM = C_READER_NUM + 2;

	assign intr = w_sof;

	reg [C_BUFF_NUM-1:0]	r0_bmp;
	reg [C_BUFF_NUM-1:0]	r1_bmp;

	reg [C_ADDR_WIDTH-1:0]	last_addr;
	reg [C_BUFF_NUM-1:0]	last_bmp;

	reg [C_BUFF_NUM-1:0]	w_bmp;

	/// reader 0
	always @(posedge clk) begin
		if (resetn == 0) begin
			r0_addr <= 0;
			r0_bmp <= 0;
		end
		else if (r0_sof) begin
			if (w_sof) begin
				r0_addr <= w_addr;
				r0_bmp <= w_bmp;
			end
			else begin
				r0_addr <= last_addr;
				r0_bmp <= last_bmp;
			end
		end
		else begin
			r0_addr <= r0_addr;
			r0_bmp <= r0_bmp;
		end
	end

	/// reader 1 (same as reader 0)
	always @(posedge clk) begin
		if (resetn == 0) begin
			r1_addr <= 0;
			r1_bmp <= 0;
		end
		else if (r1_sof) begin
			if (w_sof) begin
				r1_addr <= w_addr;
				r1_bmp <= w_bmp;
			end
			else begin
				r1_addr <= last_addr;
				r1_bmp <= last_bmp;
			end
		end
		else begin
			r1_addr <= r1_addr;
			r1_bmp <= r1_bmp;
		end
	end

	/// last done (ready for read)
	always @(posedge clk) begin
		if (resetn == 0) begin
			last_addr <= 0;
			last_bmp <= 0;
		end
		else if (w_sof) begin
			last_addr <= w_addr;
			last_bmp <= w_bmp;
		end
		else begin
			last_addr <= last_addr;
			last_bmp <= last_bmp;
		end
	end

	always @(posedge clk) begin
		if (resetn == 0) begin
			w_addr <= 0;
			w_bmp <= 0;
		end
		else if (w_sof) begin
			casez (w_bmp | r0_bmp | r1_bmp)
			4'b???0: begin
				w_addr	<= buf0_addr;
				w_bmp	<= 4'b0001;
			end
			4'b??01: begin
				w_addr	<= buf1_addr;
				w_bmp	<= 4'b0010;
			end
			4'b?011: begin
				w_addr	<= buf2_addr;
				w_bmp	<= 4'b0100;
			end
			4'b0111: begin
				w_addr	<= buf3_addr;
				w_bmp	<= 4'b1000;
			end
			default: begin
				w_addr	<= 0;
				w_bmp	<= 4'b0000;
			end
			endcase
		end
		else begin
			w_addr <= w_addr;
			w_bmp <= w_bmp;
		end
	end

endmodule
