`timescale 1 ns / 1 ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 11/18/2016 01:33:37 PM
// Design Name:
// Module Name: axis_shifter
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
module axis_shifter_v2 #
(
	parameter integer C_PIXEL_WIDTH	= 8,
	parameter integer C_IMG_WBITS = 12,
	parameter integer C_IMG_HBITS = 12
)
(
	input wire clk,
	input wire resetn,
	input wire fsync,
	input wire lsync,

	input wire [C_IMG_WBITS-1 : 0] col_idx,
	input wire [C_IMG_WBITS-1 : 0] col_idx_next,
	input wire col_update,
	input wire [C_IMG_HBITS-1 : 0] row_idx,
	input wire [C_IMG_HBITS-1 : 0] row_idx_next,
	input wire row_update,

	input wire [C_IMG_WBITS-1 : 0] s_win_left,
	input wire [C_IMG_HBITS-1 : 0] s_win_top,
	input wire [C_IMG_WBITS-1 : 0] s_win_width,
	input wire [C_IMG_HBITS-1 : 0] s_win_height,

	output wire s_need,
	output reg s_eol,
	output wire s_sof
);
	reg col_need;
	reg row_need;
	always @ (posedge clk) begin
		if (resetn == 1'b0 || lsync)
			col_need <= 0;
		else if (col_update) begin
			if (col_idx == s_win_left + s_win_width)
				col_need <= 0;
			else if (col_idx == s_win_left)
				col_need <= 1;
			else
				col_need <= col_need;
		end
		else
			col_need <= col_need;
	end
	always @ (posedge clk) begin
		if (resetn == 1'b0 || fsync)
			row_need <= 0;
		else if (row_update) begin
			if (row_idx == s_win_top + s_win_height)
				row_need <= 0;
			else if (row_idx == s_win_top)
				row_need <= 1;
			else
				row_need <= row_need;
		end
		else
			row_need <= row_need;
	end

	assign s_need = (col_need && row_need);

	reg first_line;
	always @ (posedge clk) begin
		if (resetn == 1'b0)
			first_line <= 0;
		else if (row_update)
			first_line <= (row_idx == s_win_top);
		else
			first_line <= first_line;
	end
	reg first_pixel;
	always @ (posedge clk) begin
		if (resetn == 1'b0)
			first_pixel <= 0;
		else if (col_update)
			first_pixel <= (col_idx == s_win_left);
		else
			first_pixel <= first_pixel;
	end

	assign s_sof = first_line && first_pixel;

	always @ (posedge clk) begin
		if (resetn == 1'b0)
			s_eol <= 0;
		else if (col_update)
			s_eol <= (col_idx_next == s_win_left + s_win_width);
		else
			s_eol <= s_eol;
	end

endmodule
