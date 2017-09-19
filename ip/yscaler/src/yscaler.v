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
module yscaler #
(
	parameter integer C_PIXEL_WIDTH = 8,
	parameter integer C_RESO_WIDTH  = 10,
	parameter integer C_CH0_WIDTH = 8,
	parameter integer C_CH1_WIDTH = 0,
	parameter integer C_CH2_WIDTH = 0
) (
	input  wire clk,
	input  wire resetn,
	input  wire fsync,

	input  wire [C_RESO_WIDTH-1 : 0] s_width,
	input  wire [C_RESO_WIDTH-1 : 0] s_height,

	input  wire [C_RESO_WIDTH-1 : 0] m_width,
	input  wire [C_RESO_WIDTH-1 : 0] m_height,

	input  wire s_axis_tvalid,
	input  wire [C_PIXEL_WIDTH-1:0] s_axis_tdata,
	input  wire s_axis_tuser,
	input  wire s_axis_tlast,
	output reg  s_axis_tready,

	output reg  m_axis_tvalid,
	output reg  [C_PIXEL_WIDTH-1:0] m_axis_tdata,
	output reg  m_axis_tuser,
	output reg  m_axis_tlast,
	input  wire m_axis_tready
);
	wire int_reset;
	assign int_reset = (resetn == 1'b0 || fsync);

	localparam  C_FIFO_IDX_WIDTH = 2;
	localparam  C_FIFO_NUM = 2**C_FIFO_IDX_WIDTH;
	localparam  C_SPLITER_IDX_WIDTH = 2;
	localparam  C_SPLITER_NUM = 2**C_SPLITER_IDX_WIDTH;

	reg[C_SPLITER_IDX_WIDTH:0] out_ratio;

	reg[C_FIFO_NUM-1:0] wr_act;
	reg[C_FIFO_IDX_WIDTH-1:0] rd_which;
	reg[C_FIFO_IDX_WIDTH-1:0] rd_which_pre;
	reg                       in_last_line;
	reg                       in_last_line_pre;

	wire snext;
	assign snext = s_axis_tvalid && s_axis_tready;
	wire slast;
	assign slast = snext && s_axis_tlast;

	reg [C_RESO_WIDTH-1:0] in_line_idx;
	reg                    in_line_last;
	always @ (posedge clk) begin
		if (int_reset) begin
			in_line_idx <= s_height;
			in_line_last <= (s_height == 1);
		end
		else if (slast) begin
			in_line_idx <= in_line_idx - 1;
			in_line_last <= (in_line_idx == 1);
		end
	end

	reg out_line_valid;
	reg out_pixel_valid;
	wire out_pixel_ready;
	reg out_pixel_last;

	reg  o_d1_tvalid;
	reg  [C_SPLITER_IDX_WIDTH:0] o_d1_ratio0;
	reg  [C_SPLITER_IDX_WIDTH:0] o_d1_ratio1;
	reg  [C_PIXEL_WIDTH-1:0] o_d1_tdata0;
	reg  [C_PIXEL_WIDTH-1:0] o_d1_tdata1;
	reg  o_d1_tlast;
	wire o_d1_tready;
	assign o_d1_tready = (~m_axis_tvalid || m_axis_tready);
	wire o_d1_next;
	assign o_d1_next = o_d1_tvalid && o_d1_tready;

	/// mul
	reg[C_RESO_WIDTH*2-1:0] in_mul;
	reg[C_RESO_WIDTH-1:0]   in_line;
	reg                     in_first_line;
	reg[C_RESO_WIDTH*2-1:0] out_mul;
	reg[C_RESO_WIDTH-1:0]   out_line;
	reg                     out_pixel_last_line;

	reg  [C_FIFO_NUM-1:0]    valid;

	reg  [C_FIFO_NUM-1:0]    wr_en;
	reg  [C_RESO_WIDTH-1:0]  wr_idx;
	reg  [C_PIXEL_WIDTH+1:0] wr_data;
	reg                      wr_last;
	reg  [C_FIFO_NUM-1:0]    wr_lastline;

	reg                      advance_read;
	wire                     rd_en;
	reg  [C_RESO_WIDTH-1:0]  rd_idx;
	wire [C_PIXEL_WIDTH:0] rd_data[C_FIFO_NUM-1:0];

	always @ (posedge clk) begin
		if (int_reset)
			wr_idx <= 0;
		else if (wr_en)
			wr_idx <= (wr_last ? 0 : wr_idx + 1);
	end
	always @ (posedge clk) begin
		if (int_reset) begin
			wr_data <= 0;
			wr_last <= 0;
		end
		else if (snext) begin
			wr_data <= s_axis_tdata;
			wr_last <= s_axis_tlast;
		end
	end
	generate
		genvar i;
		for (i = 0; i < C_FIFO_NUM; i = i+1) begin: single_linebuffer
			linebuffer #(
				.C_DATA_WIDTH(C_PIXEL_WIDTH+1),
				.C_ADDRESS_WIDTH(C_RESO_WIDTH)
			) linebuffer_inst (
				.clk(clk),

				.rd_en(rd_en),
				.rd_addr(rd_idx),
				.rd_data(rd_data[i]),
				.wr_en(wr_en[i]),
				.wr_addr(wr_idx),
				.wr_data(wr_data)
			);

			always @(posedge clk) begin
				if (int_reset)
					wr_en[i] <= 1'b0;
				else if (snext && wr_act[i])
					wr_en[i] <= 1'b1;
				else
					wr_en[i] <= 1'b0;
			end
			always @ (posedge clk) begin
				if (int_reset)
					valid[i] <= 0;
				else if (slast && wr_act[i])
					valid[i] <= 1;
				else if (advance_read
					&& rd_which_pre == i
					&& ~in_first_line)
					valid[i] <= 0;
			end
			always @ (posedge clk) begin
				if (int_reset)
					wr_lastline[i] <= 0;
				else if (slast && wr_act[i])
					wr_lastline[i] <= in_line_last;
			end
		end
	endgenerate

	always @ (posedge clk) begin
		if (int_reset)
			s_axis_tready <= 0;
		else if (~s_axis_tready && (~valid & wr_act))
			s_axis_tready <= 1;
		else if (slast)
			s_axis_tready <= 0;
		else
			s_axis_tready <= s_axis_tready;
	end

	always @ (posedge clk) begin
		if (int_reset)
			wr_act <= 1;
		else if (slast)
			wr_act <= {wr_act[C_FIFO_NUM-2:0], wr_act[C_FIFO_NUM-1]};
		else
			wr_act <= wr_act;
	end

	wire line_need_for_out;
	assign line_need_for_out = (in_mul >= out_mul || in_last_line);
	reg advance_out;
	reg out_line_done;
	always @ (posedge clk) begin
		if (int_reset) begin
			advance_out <= 0;
		end
		else if (~advance_out
			&& ~out_line_valid && ~out_pixel_last_line
			&& line_need_for_out && valid[rd_which])
				advance_out <= 1;
		else
			advance_out <= 0;
	end
	always @ (posedge clk) begin
		if (int_reset) begin
			out_line_done <= 0;
		end
		else if (~out_line_done
			&& out_line_valid
			&& out_pixel_last && ~out_pixel_valid)
			out_line_done <= 1;
		else
			out_line_done <= 0;
	end

	reg advance_out_d1;
	reg [C_RESO_WIDTH:0] mul_diff;
	reg single_valid_line;
	always @ (posedge clk) begin
		if (int_reset) begin
			advance_out_d1 <= 0;
			mul_diff <= 0;
			single_valid_line <= 0;
		end
		else begin
			advance_out_d1 <= advance_out;
			mul_diff <= (in_mul - out_mul);
			single_valid_line <= (in_first_line || in_last_line_pre);
		end
	end
	reg[C_RESO_WIDTH:0] spliter[C_SPLITER_NUM-1:0];
	generate
		for (i = 0; i < C_SPLITER_NUM; i = i + 1) begin: single_spliter
			always @ (posedge clk) begin
				if (int_reset)
					spliter[i] <= (m_height * (i+1)) / 4;
			end
		end
	endgenerate

	always @ (posedge clk) begin
		if (int_reset) begin
			out_ratio <= 0;
		end
		else if (advance_out_d1) begin
			if (single_valid_line)
				out_ratio <= C_SPLITER_NUM;
			else if (mul_diff <= spliter[1]) begin
				if (mul_diff <= spliter[0])
					out_ratio <= 0;
				else
					out_ratio <= 1;
			end
			else if (mul_diff <= spliter[3]) begin
				if (mul_diff <= spliter[2])
					out_ratio <= 2;
				else
					out_ratio <= 3;
			end
			else
				out_ratio <= C_SPLITER_NUM;
		end
	end

	always @ (posedge clk) begin
		if (int_reset)
			out_line <= m_height;
		else if (out_line_done)
			out_line <= out_line - 1;
	end

	always @ (posedge clk) begin
		if (int_reset)
			out_pixel_last_line <= 0;
		else if (advance_out_d1)
			out_pixel_last_line <= (out_line == 1);
	end

	always @ (posedge clk) begin
		if (int_reset)
			out_mul <= s_height;
		else if (out_line_done)
			out_mul <= out_mul + s_height * 2;
	end

	always @ (posedge clk) begin
		if (int_reset) begin
			out_line_valid <= 0;
		end
		else if (advance_out_d1)
			out_line_valid <= 1;
		else if (out_line_done)
			out_line_valid <= 0;
	end

	always @ (posedge clk) begin
		if (int_reset)
			advance_read <= 0;
		else if (~advance_read && ~out_line_valid
			&& valid[rd_which]
			&& (in_mul < out_mul && ~in_last_line_pre))
			advance_read <= 1;
		else
			advance_read <= 0;
	end
	always @ (posedge clk) begin
		if (int_reset) begin
			rd_which_pre <= 0;
			rd_which <= 0;
			in_mul <= m_height;
			in_line <= s_height;
			in_last_line <= (s_height == 1);
			in_last_line_pre <= (s_height == 1);
			in_first_line <= 1;
		end
		else if (advance_read) begin
			rd_which_pre <= rd_which;
			in_last_line_pre <= in_last_line;
			if (in_last_line) begin
				rd_which <= rd_which;
				in_mul <= in_mul;
				in_line <= in_line;
				in_last_line <= 1'b1;
				in_first_line <= in_first_line;
			end
			else begin
				rd_which <= rd_which + 1;
				in_mul <= in_mul + m_height * 2;
				in_line <= in_line - 1;
				in_last_line <= (in_line == 2);
				in_first_line <= 0;
			end
		end
	end

	always @ (posedge clk) begin
		if (int_reset)
			out_pixel_valid <= 0;
		else if (rd_en)
			out_pixel_valid <= 1;
		else if (out_pixel_ready)
			out_pixel_valid <= 0;
	end
	always @ (posedge clk) begin
		if (int_reset)
			rd_idx <= 0;
		else if (~out_line_valid)
			rd_idx <= 0;
		else if (rd_en)
			rd_idx <= rd_idx + 1;
	end
	always @ (posedge clk) begin
		if (int_reset)
			out_pixel_last <= 0;
		else if (~out_line_valid)
			out_pixel_last <= 0;
		else if (rd_en)
			out_pixel_last <= (rd_idx == s_width - 1);
	end

	assign rd_en = out_line_valid && (~out_pixel_valid || out_pixel_ready) && ~out_pixel_last;

	assign out_pixel_ready = ~o_d1_tvalid || o_d1_tready;
	wire out_next;
	assign out_next = out_pixel_valid && out_pixel_ready;
	always @ (posedge clk) begin
		if (int_reset) begin
			o_d1_tvalid <= 0;
			o_d1_tlast <= 0;
			o_d1_ratio0 <= 0;
			o_d1_ratio1 <= 0;
			o_d1_tdata0 <= 0;
			o_d1_tdata1 <= 0;
		end
		else if (out_next) begin
			o_d1_tvalid <= 1;
			o_d1_tlast <= out_pixel_last;
			o_d1_ratio0 <= out_ratio;
			o_d1_ratio1 <= C_SPLITER_NUM - out_ratio;
			o_d1_tdata0 <= rd_data[rd_which_pre];
			o_d1_tdata1 <= rd_data[rd_which];
		end
		else if (o_d1_tready)
			o_d1_tvalid <= 0;
	end

`define BLEND(_start, _stop) \
	m_axis_tdata[_stop:_start] <= (o_d1_tdata0[_stop:_start] * o_d1_ratio0 + o_d1_tdata1[_stop:_start] * o_d1_ratio1) / C_SPLITER_NUM

	generate
		if (C_CH0_WIDTH > 0) begin
			always @ (posedge clk) begin
				if (o_d1_next)
					`BLEND(0, C_CH0_WIDTH-1);
			end
		end
		if (C_CH1_WIDTH > 0) begin
			always @ (posedge clk) begin
				if (o_d1_next)
					`BLEND(C_CH0_WIDTH, C_CH0_WIDTH+C_CH1_WIDTH-1);
			end
		end
		if (C_CH2_WIDTH > 0) begin
			always @ (posedge clk) begin
				if (o_d1_next)
					`BLEND(C_CH0_WIDTH+C_CH1_WIDTH, C_CH0_WIDTH+C_CH1_WIDTH+C_CH2_WIDTH-1);
			end
		end
	endgenerate

	always @ (posedge clk) begin
		if (int_reset) begin
			m_axis_tvalid <= 0;
			m_axis_tlast <= 0;
		end
		else if (o_d1_next) begin
			m_axis_tvalid <= 1;
			m_axis_tlast <= o_d1_tlast;
		end
		else if (m_axis_tready)
			m_axis_tvalid <= 0;
	end
	always @ (posedge clk) begin
		if (int_reset)
			m_axis_tuser <= 1;
		else if (m_axis_tvalid && m_axis_tready)
			m_axis_tuser <= 0;
	end
endmodule
