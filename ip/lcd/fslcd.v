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
module fslcd(
    input clk,
    input vid_active,
    input [23:0] vid_data,
    input hsync,
    input vsync,
    output clk_out,
    output [5:0] r,
    output [5:0] g,
    output [5:0] b,
    output hsync_out,
    output vsync_out,
    output [3:0] ctrl_out
);

    assign ctrl_out[0] = vid_active;
    assign ctrl_out[1] = 1;
    assign ctrl_out[2] = 1;
    assign ctrl_out[3] = 0;

    assign clk_out = clk;

    assign r = vid_data[23:18];
    assign g = vid_data[15:10];
    assign b = vid_data[7:2];

    assign hsync_out = hsync;
    assign vsync_out = vsync;

endmodule
