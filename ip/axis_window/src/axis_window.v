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
	output wire s_axis_tready,

	/// M_AXIS
	output wire  m_axis_tvalid,
	output reg  [C_PIXEL_WIDTH-1:0] m_axis_tdata,
	output reg  m_axis_tuser,
	output reg  m_axis_tlast,
	input  wire m_axis_tready
);

	reg [C_IMG_WBITS-1 : 0] col_idx;
	reg [C_IMG_HBITS-1 : 0] row_idx;
	reg [C_PIXEL_WIDTH-1:0] data;
	reg dvalid;
	wire dready;

	wire nextin;
	assign nextin = s_axis_tvalid & s_axis_tready;
	assign s_axis_tready = ~dvalid | dready;

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
	always @(posedge clk) begin
		if (resetn == 1'b0)
			data <= 0;
		else if (nextin)
			data <= s_axis_tdata;
		else
			data <= data;
	end

	always @ (posedge clk) begin
		if (resetn == 1'b0)
			dvalid <= 0;
		else if (nextin)
			dvalid <= 1;
		else if (dready)
			dvalid <= 0;
		else
			dvalid <= dvalid;
	end

	reg col_valid;
	reg row_valid;
	reg dvalid_d1;
	assign m_axis_tvalid = col_valid & row_valid & dvalid_d1;
	wire nextin_d1;
	assign nextin_d1 = dvalid & dready;
	assign dready = ~m_axis_tvalid | m_axis_tready;
	always @ (posedge clk) begin
		if (resetn == 1'b0)
			col_valid <= 0;
		else if (nextin_d1) begin
			if (win_left <= col_idx && col_idx <= win_left + win_width)
				col_valid <= 1;
			else
				col_valid <= 0;
		end
		else
			col_valid <= col_valid;
	end
	always @ (posedge clk) begin
		if (resetn == 1'b0)
			row_valid <= 0;
		else if (nextin_d1) begin
			if (win_top <= row_idx && row_idx <= win_top + win_height)
				row_valid <= 1;
			else
				row_valid <= row_valid;
		end
		else
			row_valid <= row_valid;
	end
	always @ (posedge clk) begin
		if (resetn == 1'b0)
			dvalid_d1 <= 1'b0;
		else if (nextin_d1)
			dvalid_d1 <= 1'b1;
		else if (m_axis_tready)
			dvalid_d1 <= 1'b0;
		else
			dvalid_d1 <= dvalid_d1;
	end
	always @(posedge clk) begin
		if (resetn == 1'b0)
			m_axis_tlast <= 1'b0;
		else if (nextin_d1)
			m_axis_tlast <= (col_idx == win_left + win_width);
		else
			m_axis_tlast <= m_axis_tlast;
	end
	always @(posedge clk) begin
		if (resetn == 1'b0)
			m_axis_tuser <= 1'b0;
		else if (nextin_d1)
			m_axis_tuser <= (col_idx == win_left && row_idx == win_top);
		else
			m_axis_tuser <= m_axis_tuser;
	end

	always @ (posedge clk) begin
		if (resetn == 1'b0)
			m_axis_tdata <= 0;
		else if (nextin_d1)
			m_axis_tdata <= data;
		else
			m_axis_tdata <= m_axis_tdata;
	end

endmodule
