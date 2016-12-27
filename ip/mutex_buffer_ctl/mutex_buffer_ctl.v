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
	C_ADDR_WIDTH = 32
) (
	input wire clk,
	input wire resetn,

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

	function integer com_msb (input integer com_idx);
	begin
		com_msb = C_IN_COMP_WIDTH * (com_idx + 1) - 1;
	end
	endfunction

	function integer com_lsb_shrink (input integer com_idx);
	begin
		com_lsb_shrink = C_IN_COMP_WIDTH * (com_idx + 1) - C_OUT_COMP_WIDTH;
	end
	endfunction

	function integer com_lsb_extent (input integer com_idx);
	begin
		com_lsb_extent = C_IN_COMP_WIDTH * com_idx;
	end
	endfunction

	localparam integer C_BUFF_NUM = C_READER_NUM + 2;

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
		else if (r_sof) begin
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
		else if (r_sof) begin
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
			last_addr <= waddr;
			last_bmp <= wbmp;
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
			case (w_bmp | r0_bmp | r1_bmp)
			4'bxxx0: begin
				w_addr	<= buf0_addr;
				w_bmp	<= 4'b0001;
			end
			4'bxx01: begin
				w_addr	<= buf1_addr;
				w_bmp	<= 4'b0010;
			end
			4'bx011: begin
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
	end

endmodule

