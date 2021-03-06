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

	output wire                           s4_zpd,
	input  wire                           s4_xen,
	input  wire                           s4_xrst,
	input  wire [C_MICROSTEP_WIDTH-1:0]   s4_ms,
	input  wire                           s4_drive,
	input  wire                           s4_dir,

	output wire                           s5_zpd,
	input  wire                           s5_xen,
	input  wire                           s5_xrst,
	input  wire [C_MICROSTEP_WIDTH-1:0]   s5_ms,
	input  wire                           s5_drive,
	input  wire                           s5_dir,

	output wire [C_MICROSTEP_WIDTH-1:0]   pm_ms,
	input  wire                           pm0_zpd,
	output wire                           pm0_xen,
	output wire                           pm0_xrst,
	output wire                           pm0_drive,
	output wire                           pm0_dir,
	input  wire                           pm1_zpd,
	output wire                           pm1_xen,
	output wire                           pm1_xrst,
	output wire                           pm1_drive,
	output wire                           pm1_dir,

	output wire [C_MICROSTEP_WIDTH-1:0]   am_ms,
	output wire                           am0_xen,
	output wire                           am0_xrst,
	output wire                           am0_drive,
	output wire                           am0_dir,
	output wire                           am1_xen,
	output wire                           am1_xrst,
	output wire                           am1_drive,
	output wire                           am1_dir,

	output wire [C_MICROSTEP_WIDTH-1:0]   rm_ms,
	output wire                           rm0_xen,
	output wire                           rm0_xrst,
	output wire                           rm0_drive,
	output wire                           rm0_dir,
	output wire                           rm1_xen,
	output wire                           rm1_xrst,
	output wire                           rm1_drive,
	output wire                           rm1_dir
);

	assign s0_zpd = pm0_zpd;
	assign s1_zpd = pm1_zpd;
	assign pm_ms   = s0_ms;
	assign pm0_xen   = s0_xen;
	assign pm0_xrst  = s0_xrst;
	assign pm0_drive = s0_drive;
	assign pm0_dir   = s0_dir;
	assign pm1_xen   = s1_xen;
	assign pm1_xrst  = s1_xrst;
	assign pm1_drive = s1_drive;
	assign pm1_dir   = s1_dir;

	assign am_ms   = s2_ms;
	assign am0_xen   = s2_xen;
	assign am0_xrst  = s2_xrst;
	assign am0_drive = s2_drive;
	assign am0_dir   = s2_dir;
	assign am1_xen   = s3_xen;
	assign am1_xrst  = s3_xrst;
	assign am1_drive = s3_drive;
	assign am1_dir   = s3_dir;

	assign rm_ms   = s4_ms;
	assign rm0_xen   = s4_xen;
	assign rm0_xrst  = s4_xrst;
	assign rm0_drive = s4_drive;
	assign rm0_dir   = s4_dir;
	assign rm1_xen   = s5_xen;
	assign rm1_xrst  = s5_xrst;
	assign rm1_drive = s5_drive;
	assign rm1_dir   = s5_dir;

endmodule
