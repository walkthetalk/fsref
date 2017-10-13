`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 11/18/2016 01:33:37 PM
// Design Name:
// Module Name: fscmos
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
module fscmos #
(
	// Users to add parameters here
	parameter integer C_DATA_WIDTH	= 8
)
(
	input wire		cmos_pclk,

	input wire		cmos_vsync,
	input wire		cmos_href,
	input wire [C_DATA_WIDTH-1:0]	cmos_data,

	output wire		vid_active_video,
	output wire[C_DATA_WIDTH-1:0]	vid_data,
	output wire		vid_hblank,
	output wire		vid_hsync,
	output wire		vid_vblank,
	output wire		vid_vsync,

	output wire		vid_io_out_clk
);

	assign vid_io_out_clk = cmos_pclk;
	assign vid_active_video= (cmos_href && ~cmos_vsync);
	assign vid_data = cmos_data;
	assign vid_hblank = ~cmos_href;
	assign vid_hsync = vid_hblank;

	assign vid_vsync = vid_vblank;
	assign vid_vblank = ~cmos_vsync;
endmodule
