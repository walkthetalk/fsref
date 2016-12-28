`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 11/18/2016 01:33:37 PM
// Design Name:
// Module Name: stream2fifo
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
module stream2fifo #
(
	C_PIXEL_WIDTH = 8,
	C_DATA_WIDTH = 32
) (
	input wire clk,
	input wire resetn,

	input wire	full,
	output wire [C_DATA_WIDTH/C_PIXEL_WIDTH*(C_PIXEL_WIDTH+2)-1 : 0] wr_data,
	output wire	wr_en,

	input wire s_axis_tvalid,
	input wire [C_PIXEL_WIDTH-1:0] s_axis_tdata,
	input wire s_axis_tuser,
	input wire s_axis_tlast,
	output wire s_axis_tready
);

	function integer logb2 (input integer bit_depth);
	begin
		for(logb2=0; bit_depth>0; logb2=logb2+1)
			bit_depth = bit_depth>>1;
	end
	endfunction

	localparam integer C_DDP = C_DATA_WIDTH/C_PIXEL_WIDTH;
	localparam integer C_IDX_WIDTH = logb2(C_DDP-1);

	wire snext;
	assign snext = s_axis_tvalid & s_axis_tready;
	assign s_axis_tready = ~full;

	wire [C_PIXEL_WIDTH+1:0]	latest_data;
	assign latest_data = {s_axis_tlast, s_axis_tuser, s_axis_tdata};

	generate
	if (C_DDP == 1) begin
		assign wr_data = latest_data;
		assign wr_en = snext;
	end
	else begin
		reg [C_PIXEL_WIDTH+1:0]		data[C_DDP-2:0];
		assign wr_data[(C_PIXEL_WIDTH+2)*(C_DDP-1)+C_PIXEL_WIDTH+1:(C_PIXEL_WIDTH+2)*(C_DDP-1)] = latest_data;
		//generate /// for
		genvar i;
		for (i=0; i < C_DDP-1; i=i+1) begin: single_pixel_assign
			assign wr_data[(C_PIXEL_WIDTH+2)*i+C_PIXEL_WIDTH+1 : (C_PIXEL_WIDTH+2)*i] = data[i];
		end

		for (i=0; i < C_DDP-2; i=i+1) begin: single_pixel_shift
			always @(posedge clk) begin
				if (resetn == 1'b0)
					data[i] <= 0;
				else if (snext)
					data[i] <= data[i+1];
				else
					data[i] <= data[i];
			end
		end
		//endgenerate

		always @(posedge clk) begin
			if (resetn == 1'b0)
				data[C_DDP-2] <= 0;
			else if (snext)
				data[C_DDP-2] <= latest_data;
			else
				data[C_DDP-2] <= data[C_DDP-2];
		end

		reg [C_IDX_WIDTH-1:0] pidx;
		always @(posedge clk) begin
			if (resetn == 1'b0)
				pidx <= C_DDP-1;
			else if (snext) begin
				if (pidx == 0)
					pidx <= C_DDP-1;
				else
					pidx <= pidx - 1'b1;
			end
			else
				pidx <= pidx;
		end

		assign wr_en = snext && (pidx == 0);
	end
	endgenerate

endmodule

