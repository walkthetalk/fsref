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
module fscmos(
	input		cmos_pclk,

	input		cmos_vsync,
	input		cmos_href,
	input[7:0]	cmos_data,

	output		vid_active_video,
	output[7:0]	vid_data,
	output		vid_hblank,
	output		vid_hsync,
	output		vid_vblank,
	output		vid_vsync,

	output		vid_io_out_clk
);

	assign vid_io_out_clk = cmos_pclk;
	assign vid_active_video= (cmos_href && ~cmos_vsync);
	assign vid_data = cmos_data;
	assign vid_hblank = ~cmos_href;
	assign vid_hsync = cmos_href;

	assign vid_vsync = cmos_vsync;
	assign vid_vblank = ~cmos_vsync;
endmodule
