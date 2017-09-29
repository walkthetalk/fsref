`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 11/18/2016 01:33:37 PM
// Design Name:
// Module Name: scaler
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
module axis_bayer_extractor #
(
	parameter integer C_PIXEL_WIDTH = 8,
	parameter integer C_COL_ODD = 0,
	parameter integer C_ROW_ODD = 0

) (
	input  wire clk,
	input  wire resetn,

	input  wire s_axis_tvalid,
	input  wire [C_PIXEL_WIDTH-1:0] s_axis_tdata,
	input  wire s_axis_tuser,
	input  wire s_axis_tlast,
	output wire  s_axis_tready,

	output reg  m_axis_tvalid,
	output reg  [C_PIXEL_WIDTH-1:0] m_axis_tdata,
	output reg  m_axis_tuser,
	output reg  m_axis_tlast,
	input  wire m_axis_tready
);
	wire snext;
	assign snext = s_axis_tvalid && s_axis_tready;
	wire mnext;
	assign mnext = m_axis_tvalid && m_axis_tready;

	reg sline_lsb;
	reg spixel_lsb;
	always @ (posedge clk) begin
		if (resetn == 1'b0)
			sline_lsb <= 0;
		else if (snext && s_axis_tlast)
			sline_lsb <= ~sline_lsb;
	end
	always @ (posedge clk) begin
		if (resetn == 1'b0)
			spixel_lsb <= 0;
		else if (snext)
			spixel_lsb <= ~spixel_lsb;
	end

	always @ (posedge clk) begin
		if (resetn == 1'b0)
			m_axis_tdata <= 0;
		else if (snext
			&& (spixel_lsb == C_COL_ODD)
			&& (sline_lsb == C_ROW_ODD))
			m_axis_tdata <= s_axis_tdata;
	end
	always @ (posedge clk) begin
		if (resetn == 1'b0)
			m_axis_tvalid <= 0;
		else if (snext
			&& (spixel_lsb == 1)
			&& (sline_lsb == C_ROW_ODD))
			m_axis_tvalid <= 1;
		else if (m_axis_tready)
			m_axis_tvalid <= 0;
	end

	always @ (posedge clk) begin
		if (resetn == 1'b0)
			m_axis_tlast <= 0;
		else if (snext
			&& (spixel_lsb == 1)
			&& (sline_lsb == C_ROW_ODD))
			m_axis_tlast <= s_axis_tlast;
	end

	always @ (posedge clk) begin
		if (resetn == 1'b0)
			m_axis_tuser <= 0;
		else if (snext
			&& s_axis_tuser)
			m_axis_tuser <= 1;
		else if (mnext)
			m_axis_tuser <= 0;
	end
	assign s_axis_tready = (~m_axis_tvalid || m_axis_tready);

endmodule
