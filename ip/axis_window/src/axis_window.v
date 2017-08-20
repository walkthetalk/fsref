`timescale 1 ns / 1 ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 11/18/2016 01:33:37 PM
// Design Name:
// Module Name: axis_window
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
module axis_window #
(
	parameter integer C_PIXEL_WIDTH	= 8,
	parameter integer C_IMG_WBITS = 12,
	parameter integer C_IMG_HBITS = 12
)
(
	input wire clk,
	input wire resetn,

	input wire [C_IMG_WBITS-1 : 0] win_left,
	input wire [C_IMG_HBITS-1 : 0] win_top,

	input wire [C_IMG_WBITS-1 : 0] win_width,
	input wire [C_IMG_HBITS-1 : 0] win_height,

	/// S_AXIS
	input  wire s_axis_tvalid,
	input  wire [C_PIXEL_WIDTH-1:0] s_axis_tdata,
	input  wire s_axis_tuser,
	input  wire s_axis_tlast,
	output reg  s_axis_tready,

	/// M_AXIS
	output reg  m_axis_tvalid,
	output reg  [C_PIXEL_WIDTH-1:0] m_axis_tdata,
	output reg  m_axis_tuser,
	output reg  m_axis_tlast,
	input  wire m_axis_tready
);

	reg [C_IMG_WBITS-1 : 0] col_idx;
	reg [C_IMG_HBITS-1 : 0] row_idx;
	reg [C_PIXEL_WIDTH-1:0] data,

	wire nextin;
	assign nextin = s_axis_tvalid & s_axis_tready;

	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			col_idx <= 0;
			row_idx <= 0;
		end
		else if (nextin) begin
			if (s_axis_tuser) begin
				col_idx <= 0;
				row_idx <= 0;
			end
			else if (s_axis_tlast) begin
				col_idx <= 0;
				row_idx <= row_idx + 1;
			end
			else begin
				col_idx <= col_idx + 1;
				row_idx <= row_idx;
			end
		end
		else begin
			col_idx <= col_idx;
			row_idx <= row_idx;
		end
	end


endmodule
