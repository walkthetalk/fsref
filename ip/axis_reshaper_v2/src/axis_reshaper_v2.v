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
module axis_reshaper_v2 #
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
	output reg  [C_PIXEL_WIDTH-1:0] m_axis_tdata,
	output reg  m_axis_tuser,
	output reg  m_axis_tlast,
	input  wire m_axis_tready,

	input  wire [C_WIDTH_BITS-1:0] m_width,
	input  wire [C_HEIGHT_BITS-1:0]m_height,

	output wire o_resetn
);
	wire                    relay_tvalid;
	reg [C_PIXEL_WIDTH-1:0] relay_tdata;
	reg                     relay_tuser;
	reg                     relay_tlast;
	wire                    relay_tready;

	reg drop_input;
	reg frame_resetn;
	assign o_resetn = (~drop_input && frame_resetn && resetn);

	reg m_axis_real_tvalid;
	assign m_axis_tvalid = ~drop_input && m_axis_real_tvalid && frame_resetn;
	wire m_axis_can_push;
	wire m_axis_final_tready;
	assign m_axis_can_push = (~m_axis_real_tvalid || drop_input || m_axis_final_tready);
	assign m_axis_final_tready = m_axis_tready && frame_resetn;

	reg relay_real_tvalid;
	assign relay_tvalid = relay_real_tvalid && ~drop_input;
	wire relay_can_push;
	assign relay_can_push = (~relay_tvalid || relay_tready);
	assign relay_tready = m_axis_can_push;
	

	wire snext;
	assign snext = s_axis_tvalid && s_axis_tready;
	wire relay_next;
	assign relay_next = relay_tvalid && relay_tready;

	/// count column / row
	reg [C_WIDTH_BITS-1:0]  col;
	reg [C_HEIGHT_BITS-1:0]  row;
	wire col_equal_width;
	assign col_equal_width = (col == m_width);
	wire row_equal_height;
	assign row_equal_height = (row == m_height);
	always @ (posedge clk) begin
		if (resetn == 1'b0)
			col <= 1;
		else if (snext) begin
			if (s_axis_tuser)
				col <= 2;
			else if (col_equal_width)
				col <= 1;
			else
				col  <= col + 1;
		end
	end
	always @ (posedge clk) begin
		if (resetn == 1'b0)
			row  <= 1;
		else if (snext) begin
			if (s_axis_tuser)
				row <= 1;
			else if (col_equal_width) begin
				if (row_equal_height)
					row <= 1;
				else
					row <= row + 1;
			end
		end
	end

	/// check error
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			frame_resetn <= 1;
		end
		else if (snext && s_axis_tuser && (row != 1 || col != 1)) begin
			frame_resetn <= 0;
		end
		else begin
			frame_resetn <= 1;
		end
	end
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			drop_input  <= 0;
		end
		else if (snext) begin
			if (s_axis_tuser) begin
				drop_input <= 0;
			end
			else begin
				if ((s_axis_tlast && ~col_equal_width)
					|| (~s_axis_tlast && col_equal_width)) begin
					drop_input <= 1;
				end
			end
		end
	end
//////////////////// detect end ///////////////////////////////////////
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			relay_real_tvalid <= 0;
			relay_tdata  <= 0;
			relay_tuser  <= 0;
			relay_tlast  <= 0;
		end
		else if (snext && (relay_tvalid || ~m_axis_can_push)) begin
			relay_real_tvalid <= 1;
			relay_tdata  <= s_axis_tdata;
			relay_tuser  <= s_axis_tuser;
			relay_tlast  <= s_axis_tlast;
		end
		else if (relay_tready) begin
			relay_real_tvalid <= 0;
		end
	end

	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			m_axis_real_tvalid <= 0;
			m_axis_tdata  <= 0;
			m_axis_tuser  <= 0;
			m_axis_tlast  <= 0;
		end
		else if (relay_next) begin
			m_axis_real_tvalid <= 1;
			m_axis_tdata  <= relay_tdata;
			m_axis_tuser  <= relay_tuser;
			m_axis_tlast  <= relay_tlast;
		end
		else if (snext && m_axis_can_push) begin
			m_axis_real_tvalid <= 1;
			m_axis_tdata  <= s_axis_tdata;
			m_axis_tuser  <= s_axis_tuser;
			m_axis_tlast  <= s_axis_tlast;
		end
		else if (m_axis_final_tready) begin
			m_axis_real_tvalid <= 0;
		end
	end

	always @ (posedge clk) begin
		if (resetn == 1'b0)
			s_axis_tready <= 0;
		else if (frame_resetn == 1'b0)
			/// @note wait col/row reset to 1
			s_axis_tready <= 0;
		else if (drop_input == 1'b1)
			s_axis_tready <= 1;
		else begin
			case ({relay_real_tvalid, m_axis_real_tvalid})
			2'b00:
				s_axis_tready <= 1;
			2'b10: begin
				$write("err: invalid tvaild state: \n");
				s_axis_tready <= 1;
			end
			2'b01:
				s_axis_tready <= (~s_axis_tready || m_axis_tready);
			2'b11:
				s_axis_tready <= (~s_axis_tready && m_axis_tready);
			endcase
		end
	end

endmodule
