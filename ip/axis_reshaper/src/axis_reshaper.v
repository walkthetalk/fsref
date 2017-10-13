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
module axis_reshaper #
(
	parameter integer C_PIXEL_WIDTH = 8

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

	reg working;
	always @ (posedge clk) begin
		if (resetn == 0)
			working <= 0;
		else if (s_axis_tvalid && s_axis_tuser)
			working <= 1;
	end

	assign s_axis_tready = ~(working && m_axis_tvalid) || m_axis_tready;
	always @ (posedge clk) begin
		if (resetn == 0) begin
			m_axis_tvalid <= 0;
			m_axis_tdata <= 0;
			m_axis_tuser <= 0;
			m_axis_tlast <= 0;
		end
		else if (snext && (s_axis_tuser || working)) begin
			m_axis_tdata <= s_axis_tdata;
			m_axis_tlast <= s_axis_tlast;
			m_axis_tuser <= s_axis_tuser;
			m_axis_tvalid <= 1;
		end
		else if (m_axis_tready) begin
			m_axis_tvalid <= 0;
		end
	end

endmodule
