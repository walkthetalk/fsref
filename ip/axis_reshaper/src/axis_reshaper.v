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
	parameter integer C_PIXEL_WIDTH = 8,
	parameter integer C_LOCK_FRAMES = 2,
	parameter integer C_WIDTH_BITS = 12,
	parameter integer C_HEIGHT_BITS = 12
) (
	input  wire clk,
	input  wire resetn,

	input  wire s_axis_tvalid,
	input  wire [C_PIXEL_WIDTH-1:0] s_axis_tdata,
	input  wire s_axis_tuser,
	input  wire s_axis_tlast,
	output reg  s_axis_tready,

	output wire m_axis_tvalid,
	output wire [C_PIXEL_WIDTH-1:0] m_axis_tdata,
	output wire m_axis_tuser,
	output wire m_axis_tlast,
	input  wire m_axis_tready,

	output wire [C_WIDTH_BITS-1:0] m_width,
	output wire [C_HEIGHT_BITS-1:0]m_height
);
	reg                     relay_tvalid[1:0];
	reg [C_PIXEL_WIDTH-1:0] relay_tdata[1:0];
	reg                     relay_tuser[1:0];
	reg                     relay_tlast[1:0];

	wire snext;
	assign snext = s_axis_tvalid && s_axis_tready;

	assign m_axis_tvalid = relay_tvalid[0];
	assign m_axis_tdata = relay_tdata[0];
	assign m_axis_tlast = relay_tlast[0];
	assign m_axis_tuser = relay_tuser[0];

	/// check locked
	reg [C_WIDTH_BITS-1:0]  width_last;
	reg [C_WIDTH_BITS-1:0]  width_cur;
	wire width_mismatch;
	wire width_valid;
	reg[C_LOCK_FRAMES-1:0] lock_sta;
	reg [C_HEIGHT_BITS-1:0] height_last;
	reg [C_HEIGHT_BITS-1:0] height_cur;
	wire height_mismatch;
	wire height_valid;
	assign width_mismatch = (width_last != width_cur);
	assign width_valid = (width_last != 0);
	assign height_mismatch = (height_last != height_cur);
	assign height_valid = (height_last != 0);
	assign m_width = width_last;
	assign m_height = height_last;

	reg locked;
	wire store_en;
	assign store_en = snext && locked;
	reg last_last;
	always @ (posedge clk) begin
		if (resetn == 1'b0)
			last_last <= 0;
		else if (snext)
			last_last <= s_axis_tlast;
	end
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			width_cur <= 0;
			width_last  <= 0;
		end
		else if (snext) begin
			if (s_axis_tuser || last_last) begin
				width_cur  <= 0;
				width_last <= width_cur;
			end
			else begin
				width_cur  <= width_cur + 1;
				width_last <= width_last;
			end
		end
	end
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			height_cur  <= 0;
			height_last <= 0;
		end
		else if (snext) begin
			if (s_axis_tuser) begin
				height_cur <= 0;
				height_last <= height_cur;
			end
			else if (last_last)
				height_cur <= height_cur + 1;
		end
	end
	always @ (posedge clk) begin
		if (resetn == 1'b0)
			lock_sta <= 0;
		else if (snext) begin
			if (s_axis_tuser)
				lock_sta[C_LOCK_FRAMES-1:1] <= lock_sta[C_LOCK_FRAMES-2:0];

			if (width_mismatch) begin
				if (s_axis_tuser || last_last)
					lock_sta[0] <= 0;
			end
			else if (height_mismatch) begin
				if (s_axis_tuser)
					lock_sta[0] <= 0;
			end
			else if (s_axis_tuser)
				lock_sta[0] <= 1;
		end
	end
	always @ (posedge clk) begin
		if (resetn == 1'b0)
			locked <= 0;
		else if (snext && s_axis_tlast && !height_mismatch && (lock_sta == {C_LOCK_FRAMES{1'b1}}))
			locked <= 1;
	end
//////////////////// detect end ///////////////////////////////////////
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			relay_tvalid[1] <= 0;
			relay_tdata[1] <= 0;
			relay_tuser[1] <= 0;
			relay_tlast[1] <= 0;
		end
		else if (store_en) begin
			if (relay_tvalid[1]) begin
				relay_tvalid[1] <= 1;
				relay_tdata[1] <= s_axis_tdata;
				relay_tuser[1] <= s_axis_tuser;
				relay_tlast[1] <= s_axis_tlast;
			end
			else if (relay_tvalid[0] && ~m_axis_tready) begin
				relay_tvalid[1] <= 1;
				relay_tdata[1] <= s_axis_tdata;
				relay_tuser[1] <= s_axis_tuser;
				relay_tlast[1] <= s_axis_tlast;
			end
			else
				relay_tvalid[1] <= 0;
		end
		else if (~relay_tvalid[0] || m_axis_tready) begin
			relay_tvalid[1] <= 0;
		end
	end

	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			relay_tvalid[0] <= 0;
			relay_tdata[0] <= 0;
			relay_tuser[0] <= 0;
			relay_tlast[0] <= 0;
		end
		else if (~relay_tvalid[0] || m_axis_tready) begin
			if (relay_tvalid[1]) begin
				relay_tvalid[0] <= 1;
				relay_tdata[0] <= relay_tdata[1];
				relay_tuser[0] <= relay_tuser[1];
				relay_tlast[0] <= relay_tlast[1];
			end
			else if (store_en) begin
				relay_tvalid[0] <= 1;
				relay_tdata[0] <= s_axis_tdata;
				relay_tuser[0] <= s_axis_tuser;
				relay_tlast[0] <= s_axis_tlast;
			end
			else begin
				relay_tvalid[0] <= 0;
			end
		end
	end

	always @ (posedge clk) begin
		if (resetn == 1'b0)
			s_axis_tready <= 0;
		else begin
			case ({relay_tvalid[1], relay_tvalid[0]})
			2'b00, 2'b10:
				s_axis_tready <= 1;
			2'b01:
				s_axis_tready <= (~s_axis_tready || m_axis_tready);
			2'b11:
				s_axis_tready <= (~s_axis_tready && m_axis_tready);
			endcase
		end
	end

endmodule
