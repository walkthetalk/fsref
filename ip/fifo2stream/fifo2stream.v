`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 11/18/2016 01:33:37 PM
// Design Name:
// Module Name: fifo2stream
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

/// @note the frame must be multi of data_width
/// @note the data_width must be multi of pixel_width
module fifo2stream #
(
	C_PIXEL_WIDTH = 8,
	C_DATA_WIDTH = 32
) (
	input wire clk,
	input wire resetn,

	input wire	empty,
	input wire [C_DATA_WIDTH/C_PIXEL_WIDTH*(C_PIXEL_WIDTH+2)-1 : 0] rd_data,
	output wire	rd_en,

	output wire m_axis_tvalid,
	output wire [C_PIXEL_WIDTH-1:0] m_axis_tdata,
	output wire m_axis_tuser,
	output wire m_axis_tlast,
	input wire m_axis_tready
);

	function integer logb2 (input integer bit_depth);
	begin
		for(logb2=0; bit_depth>0; logb2=logb2+1)
			bit_depth = bit_depth>>1;
	end
	endfunction

	localparam integer C_DDP = C_DATA_WIDTH/C_PIXEL_WIDTH;
	localparam integer C_IDX_WIDTH = logb2(C_DDP-1);

	wire mnext;
	assign mnext = m_axis_tvalid & m_axis_tready;

	generate
	if (C_DDP == 1) begin
		reg dvalid;
		assign m_axis_tdata = rd_data[C_PIXEL_WIDTH-1:0];
		assign m_axis_tuser = rd_data[C_PIXEL_WIDTH];
		assign m_axis_tlast = rd_data[C_PIXEL_WIDTH+1];
		assign m_axis_tvalid = dvalid;
		assign rd_en = mnext & ~empty;
		always @(posedge clk) begin
			if (resetn == 1'b0) begin
				dvalid <= 0;
			end
			else if (rd_en) begin
				dvalid <= 1;
			end
			else if (mnext) begin
				dvalid <= 0;
			end
			else begin
				dvalid <= dvalid;
			end
		end
	end
	else begin
		reg [C_IDX_WIDTH-1:0] pidx;
		reg [C_DATA_WIDTH/C_PIXEL_WIDTH*(C_PIXEL_WIDTH+2)-1 : 0]	latest_data;
		reg dvalid;

		assign m_axis_tdata = latest_data[C_PIXEL_WIDTH-1:0];
		assign m_axis_tuser = latest_data[C_PIXEL_WIDTH];
		assign m_axis_tlast = latest_data[C_PIXEL_WIDTH+1];
		assign m_axis_tvalid = dvalid;
		assign rd_en = mnext & ~empty & (pidx == 0);
		always @(posedge clk) begin
			if (resetn == 1'b0) begin
				dvalid <= 0;
			end
			else if (rd_en) begin
				dvalid <= 1;
			end
			else if (mnext && (pidx == 0)) begin
				dvalid <= 0;
			end
			else begin
				dvalid <= dvalid;
			end
		end

		always @(posedge clk) begin
			if (resetn == 1'b0) begin
				latest_data <= 0;
			end
			else if (rd_en) begin
				latest_data <= rd_data;
			end
			else if (mnext && (pidx != 0)) begin
				latest_data <= latest_data >> (C_PIXEL_WIDTH+2);
			end
			else begin
				latest_data <= latest_data;
			end
		end

		always @(posedge clk) begin
			if (resetn == 1'b0)
				pidx <= C_DDP-1;
			else if (mnext) begin
				if (pidx == 0)
					pidx <= C_DDP-1;
				else
					pidx <= pidx - 1'b1;
			end
			else
				pidx <= pidx;
		end
	end
	endgenerate

endmodule

