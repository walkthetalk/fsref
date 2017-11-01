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
module fsmotor #
(
	parameter integer C_MICROSTEP_WIDTH = 3
) (
	output wire                           s0_zpd,
	input  wire                           s0_xen,
	input  wire                           s0_xrst,
	input  wire [C_MICROSTEP_WIDTH-1:0]   s0_ms,
	input  wire                           s0_drive,
	input  wire                           s0_dir,

	output wire                           s1_zpd,
	input  wire                           s1_xen,
	input  wire                           s1_xrst,
	input  wire [C_MICROSTEP_WIDTH-1:0]   s1_ms,
	input  wire                           s1_drive,
	input  wire                           s1_dir,

	output wire                           s2_zpd,
	input  wire                           s2_xen,
	input  wire                           s2_xrst,
	input  wire [C_MICROSTEP_WIDTH-1:0]   s2_ms,
	input  wire                           s2_drive,
	input  wire                           s2_dir,

	output wire                           s3_zpd,
	input  wire                           s3_xen,
	input  wire                           s3_xrst,
	input  wire [C_MICROSTEP_WIDTH-1:0]   s3_ms,
	input  wire                           s3_drive,
	input  wire                           s3_dir,

	output wire                           pm_xen,
	output wire                           pm_xrst,
	output wire [C_MICROSTEP_WIDTH-1:0]   pm_ms,
	input  wire                           pm0_zpd,
	output wire                           pm0_drive,
	output wire                           pm0_dir,
	input  wire                           pm1_zpd,
	output wire                           pm1_drive,
	output wire                           pm1_dir,

	output wire                           am_xen,
	output wire                           am_xrst,
	output wire [C_MICROSTEP_WIDTH-1:0]   am_ms,
	output wire                           am0_drive,
	output wire                           am0_dir,
	output wire                           am1_drive,
	output wire                           am1_dir
);

	assign s0_zpd = pm0_zpd;
	assign s1_zpd = pm1_zpd;
	assign pm_xen  = s0_xen;
	assign pm_xrst = s0_xrst;
	assign pm_ms   = s0_ms;
	assign pm0_drive = s0_drive;
	assign pm0_dir   = s0_dir;
	assign pm1_drive = s1_drive;
	assign pm1_dir   = s1_dir;

	assign am_xen  = s2_xen;
	assign am_xrst = s2_xrst;
	assign am_ms   = s2_ms;
	assign am0_drive = s2_drive;
	assign am0_dir   = s2_dir;
	assign am1_drive = s3_drive;
	assign am1_dir   = s3_dir;

endmodule
