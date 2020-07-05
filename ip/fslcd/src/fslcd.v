`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 11/18/2016 01:33:37 PM
// Design Name:
// Module Name: fslcd
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
module fslcd #
(
	/// single component data width
	parameter integer C_IN_COMP_WIDTH = 8,
	parameter integer C_OUT_COMP_WIDTH = 6
) (
	input vid_io_in_clk,

	input vid_active_video,
	input [C_IN_COMP_WIDTH*3-1:0] vid_data,
	input vid_hsync,
	input vid_vsync,

	output [C_OUT_COMP_WIDTH-1:0] r,
	output [C_OUT_COMP_WIDTH-1:0] g,
	output [C_OUT_COMP_WIDTH-1:0] b,
	output hsync_out,
	output vsync_out,
	output active_data,
	output out_clk
);

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

	localparam integer C_EXTENT = C_OUT_COMP_WIDTH - C_IN_COMP_WIDTH;

	assign active_data = vid_active_video;

	if (C_IN_COMP_WIDTH >= C_OUT_COMP_WIDTH) begin
		assign r = vid_data[com_msb(2):com_lsb_shrink(2)];
		assign g = vid_data[com_msb(1):com_lsb_shrink(1)];
		assign b = vid_data[com_msb(0):com_lsb_shrink(0)];
	end
	else begin
		assign r = { vid_data[com_msb(2):com_lsb_extent(2)], {C_EXTENT{1'b1}} };
		assign g = { vid_data[com_msb(1):com_lsb_extent(1)], {C_EXTENT{1'b1}} };
		assign b = { vid_data[com_msb(0):com_lsb_extent(0)], {C_EXTENT{1'b1}} };
	end

	assign hsync_out = vid_hsync;
	assign vsync_out = vid_vsync;
	assign out_clk = vid_io_in_clk;

endmodule
