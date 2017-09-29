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
module axis_scaler #
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
	wire line_reset;

	localparam  C_FIFO_IDX_WIDTH = 2;
	localparam  C_FIFO_NUM = 2**C_FIFO_IDX_WIDTH;
	localparam  C_SPLITER_IDX_WIDTH = 2;
	localparam  C_SPLITER_NUM = 2**C_SPLITER_IDX_WIDTH;

	reg[C_SPLITER_IDX_WIDTH:0] ratio_y;

	reg[C_FIFO_NUM-1:0] wr_act;
	reg[C_FIFO_IDX_WIDTH-1:0] rd_which;
	reg[C_FIFO_IDX_WIDTH-1:0] rd_which_pre;

	wire snext;
	assign snext = s_axis_tvalid && s_axis_tready;
	wire slast;
	assign slast = snext && s_axis_tlast;

	reg [C_RESO_WIDTH-1:0] iy_line_idx;
	reg                    iy_line_last;
	always @ (posedge clk) begin
		if (int_reset) begin
			iy_line_idx <= s_height;
			iy_line_last <= (s_height == 1);
		end
		else if (slast) begin
			iy_line_idx <= iy_line_idx - 1;
			iy_line_last <= (iy_line_idx == 1);
		end
	end

	reg oy_valid;
	wire ox_valid;
	reg [1:0] ox_state;
	wire ox_ready;

	localparam  OUT_NULL = 2'b00;
	localparam  OUT_SKIP = 2'b01;
	localparam  OUT_SING = 2'b10;
	localparam  OUT_MULP = 2'b11;
	wire out_state_null; assign out_state_null = (ox_state == OUT_NULL);
	wire out_state_skip; assign out_state_skip = (ox_state == OUT_SKIP);
	wire out_state_sing; assign out_state_sing = (ox_state == OUT_SING);
	wire out_state_mulp; assign out_state_mulp = (ox_state == OUT_MULP);
	/// @NOTE: null and skip are all not valid
	assign ox_valid = ox_state[1];

	reg  o_d1_tvalid;
	reg  [C_SPLITER_IDX_WIDTH:0] y_d1_ratio0;
	reg  [C_SPLITER_IDX_WIDTH:0] y_d1_ratio1;
	reg  [C_PIXEL_WIDTH-1:0] o_d1_tdata00;
	reg  [C_PIXEL_WIDTH-1:0] o_d1_tdata10;
	reg  [C_PIXEL_WIDTH-1:0] o_d1_tdata01;
	reg  [C_PIXEL_WIDTH-1:0] o_d1_tdata11;

	reg  o_d1_tlast;
	wire o_d1_tready;
	wire o_d1_next;

	reg  o_d2_tvalid;
	reg  [C_SPLITER_IDX_WIDTH:0] x_d2_ratio0;
	reg  [C_SPLITER_IDX_WIDTH:0] x_d2_ratio1;
	reg  [C_PIXEL_WIDTH-1:0] o_d2_tdata0;
	reg  [C_PIXEL_WIDTH-1:0] o_d2_tdata1;

	reg o_d2_tlast;
	wire o_d2_tready;
	wire o_d2_next;

	assign o_d1_tready = (~o_d2_tvalid || o_d2_tready);
	assign o_d1_next = o_d1_tvalid && o_d1_tready;
	assign o_d2_tready = (~m_axis_tvalid || m_axis_tready);
	assign o_d2_next = o_d2_tvalid && o_d2_tready;

	/// mul
	reg[C_RESO_WIDTH*2-1:0] iy_mul;
	reg[C_RESO_WIDTH-1:0]   iy_line;
	reg                     iy_first;
	reg                     iy_last;
	reg[C_RESO_WIDTH*2-1:0] oy_mul;
	reg[C_RESO_WIDTH-1:0]   oy_line;
	reg                     oy_last;

	reg  [C_FIFO_NUM-1:0]    valid;

	reg  [C_FIFO_NUM-1:0]    wr_en;
	reg  [C_RESO_WIDTH-1:0]  wr_idx;
	reg  [C_PIXEL_WIDTH-1:0] wr_data;
	reg                      wr_last;

	reg                      advance_read;
	wire                     rd_en;
	reg  [C_RESO_WIDTH-1:0]  rd_idx;
	wire [C_PIXEL_WIDTH-1:0] rd_data[C_FIFO_NUM-1:0];
	reg  [C_PIXEL_WIDTH-1:0] rd_data_00;
	reg  [C_PIXEL_WIDTH-1:0] rd_data_10;
	wire [C_PIXEL_WIDTH-1:0] rd_data_01;
	wire [C_PIXEL_WIDTH-1:0] rd_data_11;
	assign rd_data_01 = rd_data[rd_which_pre];
	assign rd_data_11 = rd_data[rd_which];

	reg advance_out;
	reg oy_done;
	reg advance_out_d1;
	reg oy_posedge;
	reg [C_RESO_WIDTH:0] ymul_diff;

	/// xscale
	reg[C_RESO_WIDTH*2-1:0] op_mul;
	reg[C_RESO_WIDTH*2-1:0] op_mul_n;
	reg[C_RESO_WIDTH-1:0] op_idx;
	reg                 op_last;
	reg                 op_last_cur;
	/// same clock as rd_en
	wire[C_RESO_WIDTH*2-1:0] ip_mul;
	reg[C_RESO_WIDTH*2-1:0] ip_mul_cur;
	reg[C_RESO_WIDTH*2-1:0] ip_mul_next;
	reg[C_RESO_WIDTH-1:0] ip_idx;
	reg                 ip_last;
	assign ip_mul = (rd_en ? ip_mul_next : ip_mul_cur);

	reg rd_line_done;
	reg[C_RESO_WIDTH:0] xmul_diff;
	reg[C_SPLITER_IDX_WIDTH:0] x_d1_ratio;
	wire out_next;

	always @ (posedge clk) begin
		if (line_reset) begin
			rd_data_00 <= 0;
			rd_data_10 <= 0;
		end
		else if (rd_en) begin
			rd_data_00 <= (oy_posedge ? 0 : rd_data_01);
			rd_data_10 <= (oy_posedge ? 0 : rd_data_11);
		end
	end

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
				.C_DATA_WIDTH(C_PIXEL_WIDTH),
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
					&& ~iy_first)
					valid[i] <= 0;
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

	always @ (posedge clk) begin
		if (int_reset) begin
			advance_out <= 0;
		end
		else if (~advance_out
			&& ~oy_valid && ~advance_out_d1
			&& ~oy_last
			/// need this line for output
			&& (iy_mul >= oy_mul || iy_last)
			&& valid[rd_which])
				advance_out <= 1;
		else
			advance_out <= 0;
	end
	always @ (posedge clk) begin
		if (int_reset) begin
			oy_done <= 0;
		end
		else if (~oy_done
			&& oy_valid
			&& op_last_cur && out_next)
			oy_done <= 1;
		else
			oy_done <= 0;
	end

	always @ (posedge clk) begin
		if (int_reset) begin
			advance_out_d1 <= 0;
			ymul_diff <= 0;
		end
		else begin
			advance_out_d1 <= advance_out;
			if (iy_mul >= oy_mul) begin
				if (iy_first)
					ymul_diff <= 0;
				else
					ymul_diff <= iy_mul - oy_mul;
			end
			else if (iy_last)
				ymul_diff <= 0;
		end
	end
	reg[C_RESO_WIDTH:0] y_spliter[C_SPLITER_NUM-1:0];
	generate
		for (i = 0; i < C_SPLITER_NUM; i = i + 1) begin: single_spliter
			always @ (posedge clk) begin
				if (int_reset)
					y_spliter[i] <= (m_height * (i+1)) / C_SPLITER_NUM;
			end
		end
	endgenerate

	always @ (posedge clk) begin
		if (int_reset) begin
			ratio_y <= 0;
		end
		else if (advance_out_d1) begin
			if (ymul_diff <= y_spliter[1]) begin
				if (ymul_diff <= y_spliter[0])
					ratio_y <= 0;
				else
					ratio_y <= 1;
			end
			else if (ymul_diff <= y_spliter[3]) begin
				if (ymul_diff <= y_spliter[2])
					ratio_y <= 2;
				else
					ratio_y <= 3;
			end
			else
				ratio_y <= C_SPLITER_NUM;
		end
	end

	always @ (posedge clk) begin
		if (int_reset)
			oy_line <= m_height;
		else if (oy_done)
			oy_line <= oy_line - 1;
	end

	always @ (posedge clk) begin
		if (int_reset)
			oy_last <= 0;
		else if (advance_out_d1)
			oy_last <= (oy_line == 1);
	end

	always @ (posedge clk) begin
		if (int_reset)
			oy_mul <= s_height;
		else if (oy_done)
			oy_mul <= oy_mul + s_height * 2;
	end

	always @ (posedge clk) begin
		if (int_reset) begin
			oy_valid <= 0;
		end
		else if (advance_out_d1)
			oy_valid <= 1;
		else if (oy_done)
			oy_valid <= 0;
	end

	always @ (posedge clk) begin
		if (int_reset)
			oy_posedge <= 0;
		else
			oy_posedge <= advance_out_d1;
	end

	always @ (posedge clk) begin
		if (int_reset)
			advance_read <= 0;
		else if (~advance_read && ~oy_valid
			&& valid[rd_which]
			&& (iy_mul < oy_mul && ~iy_last))
			advance_read <= 1;
		else
			advance_read <= 0;
	end
	always @ (posedge clk) begin
		if (int_reset) begin
			rd_which_pre <= 0;
			rd_which <= 0;
			iy_mul <= m_height;
			iy_line <= s_height;
			iy_last <= (s_height == 1);
			iy_first <= 1;
		end
		else if (advance_read) begin
			rd_which_pre <= rd_which;
			if (iy_last) begin
				rd_which <= rd_which;
				iy_mul <= iy_mul;
				iy_line <= iy_line;
				iy_last <= 1'b1;
				iy_first <= iy_first;
			end
			else begin
				rd_which <= rd_which + 1;
				iy_mul <= iy_mul + m_height * 2;
				iy_line <= iy_line - 1;
				iy_last <= (iy_line == 2);
				iy_first <= 0;
			end
		end
	end

	always @ (posedge clk) begin
		if (line_reset) begin
			ip_mul_cur <= 0;
			ip_mul_next <= m_width;
			ip_idx <= s_width;
			ip_last <= (s_width == 1);
		end
		else if (rd_en) begin
			ip_mul_cur <= ip_mul_next;
			ip_mul_next <= ip_mul_next + m_width * 2;
			if (ip_last) begin
				ip_idx <= ip_idx;
				ip_last <= 1;
			end
			else begin
				ip_idx <= ip_idx - 1;
				ip_last <= (ip_idx == 2);
			end
		end
	end

	wire cmp_ip_gt_op;
	assign cmp_ip_gt_op = (ip_mul >= op_mul);

	always @ (posedge clk) begin
		if (line_reset) begin
			op_mul <= s_width;
			op_mul_n <= (m_width == 1 ? s_width : s_width * 3);
			op_idx <= m_width;
			op_last <= (m_width == 1);
		end
		else if (~op_last &&
			(rd_en ? (cmp_ip_gt_op || ip_last) : out_next)
			) begin
			op_mul <= op_mul_n;
			if (op_idx == 1) begin
				op_mul_n <= op_mul_n;
				op_idx <= op_idx;
			end
			else begin
				op_mul_n <= op_mul_n + s_width * 2;
				op_idx <= op_idx - 1;
			end
			op_last <= (op_idx == 2);
		end
	end
	always @ (posedge clk) begin
		if (line_reset) begin
			op_last_cur <= 0;
		end
		else if (out_next) begin
			op_last_cur <= op_last;
		end
	end

	always @ (posedge clk) begin
		if (line_reset)
			rd_line_done <= 0;
		else if (rd_en) begin
			if (ip_last)
				rd_line_done <= 1;
			else if (cmp_ip_gt_op && op_last)
				rd_line_done <= 1;
		end
	end
	always @ (posedge clk) begin
		if (line_reset) begin
			ox_state <= OUT_NULL;
		end
		else if (out_next || rd_en) begin
			if (out_next && op_last_cur) begin
				ox_state <= OUT_NULL;
			end
			else if (cmp_ip_gt_op) begin
				if (ip_mul >= op_mul_n)
					ox_state <= OUT_MULP;
				else
					ox_state <= OUT_SING;

				if (oy_posedge)
					xmul_diff <= 0;
				else begin
					xmul_diff <= ip_mul - op_mul;
				end
			end
			else if (ip_last) begin
				ox_state <= OUT_SING;
				xmul_diff <= 0;
			end
			else begin
				ox_state <= OUT_SKIP;
			end
		end
	end
	reg[C_RESO_WIDTH:0] x_spliter[C_SPLITER_NUM-1:0];
	generate
		for (i = 0; i < C_SPLITER_NUM; i = i + 1) begin: single_x_spliter
			always @ (posedge clk) begin
				if (int_reset)
					x_spliter[i] <= m_width * (i*2+1) / C_SPLITER_NUM;
			end
		end
	endgenerate

	assign line_reset = int_reset || ~oy_valid;
	always @ (posedge clk) begin
		if (line_reset)
			rd_idx <= 0;
		else if (rd_en)
			rd_idx <= rd_idx + 1;
	end

	assign rd_en = (oy_valid && ~rd_line_done)
			&& (~ox_valid || (out_state_sing && ox_ready));

	assign ox_ready = ~o_d1_tvalid || o_d1_tready;

	assign out_next = ox_valid && ox_ready;
	always @ (posedge clk) begin
		if (int_reset) begin
			o_d1_tvalid <= 0;
			o_d1_tlast <= 0;

			y_d1_ratio0 <= 0;
			y_d1_ratio1 <= 0;

			o_d1_tdata01 <= 0;
			o_d1_tdata11 <= 0;
			o_d1_tdata00 <= 0;
			o_d1_tdata10 <= 0;
		end
		else if (out_next) begin
			o_d1_tvalid <= 1;
			o_d1_tlast <= op_last_cur;
			y_d1_ratio0 <= ratio_y;
			y_d1_ratio1 <= C_SPLITER_NUM - ratio_y;
			o_d1_tdata01 <= rd_data_01;
			o_d1_tdata11 <= rd_data_11;
			o_d1_tdata00 <= rd_data_00;
			o_d1_tdata10 <= rd_data_10;
		end
		else if (o_d1_tready)
			o_d1_tvalid <= 0;
	end

	always @ (posedge clk) begin
		if (int_reset) begin
			x_d1_ratio <= 0;
		end
		else if (out_next) begin
			if (xmul_diff <= x_spliter[2]) begin
				if (xmul_diff <= x_spliter[0]) begin
					x_d1_ratio <= 0;
				end
				else if (xmul_diff <= x_spliter[1]) begin
					x_d1_ratio <= 1;
				end
				else begin
					x_d1_ratio <= 2;
				end
			end
			else begin
				if (xmul_diff <= x_spliter[3]) begin
					x_d1_ratio <= 3;
				end
				else begin
					x_d1_ratio <= C_SPLITER_NUM;
				end
			end
		end
	end


`define BLEND_D1(_start, _stop) \
	o_d2_tdata0[_stop:_start] <= ( \
		o_d1_tdata00[_stop:_start] * y_d1_ratio0 + \
		o_d1_tdata10[_stop:_start] * y_d1_ratio1 \
	) / C_SPLITER_NUM; \
	o_d2_tdata1[_stop:_start] <= ( \
		o_d1_tdata01[_stop:_start] * y_d1_ratio0 + \
		o_d1_tdata11[_stop:_start] * y_d1_ratio1 \
	) / C_SPLITER_NUM;

	generate
		if (C_CH0_WIDTH > 0) begin
			always @ (posedge clk) begin
				if (o_d1_next) begin
					`BLEND_D1(0, C_CH0_WIDTH-1)
				end
			end
		end
		if (C_CH1_WIDTH > 0) begin
			always @ (posedge clk) begin
				if (o_d1_next) begin
					`BLEND_D1(C_CH0_WIDTH, C_CH0_WIDTH+C_CH1_WIDTH-1)
				end
			end
		end
		if (C_CH2_WIDTH > 0) begin
			always @ (posedge clk) begin
				if (o_d1_next) begin
					`BLEND_D1(C_CH0_WIDTH+C_CH1_WIDTH, C_CH0_WIDTH+C_CH1_WIDTH+C_CH2_WIDTH-1)
				end
			end
		end
	endgenerate
	always @ (posedge clk) begin
		if (int_reset) begin
			o_d2_tlast <= 0;
			o_d2_tvalid <= 0;
			x_d2_ratio0 <= 0;
			x_d2_ratio1 <= 0;
		end
		else if (o_d1_next) begin
			o_d2_tlast <= o_d1_tlast;
			o_d2_tvalid <= 1;
			x_d2_ratio0 <= x_d1_ratio;
			x_d2_ratio1 <= C_SPLITER_NUM - x_d1_ratio;
		end
		else if (o_d2_tready)
			o_d2_tvalid <= 0;
	end

`define BLEND(_start, _stop) \
	m_axis_tdata[_stop:_start] <= ( \
		o_d2_tdata0[_stop:_start] * x_d2_ratio0 + \
		o_d2_tdata1[_stop:_start] * x_d2_ratio1 \
	) / C_SPLITER_NUM;

//	m_axis_tdata[_stop:_start] <= (o_d1_tdata0[_stop:_start] * y_d1_ratio0 + o_d1_tdata1[_stop:_start] * y_d1_ratio1) / C_SPLITER_NUM


	generate
		if (C_CH0_WIDTH > 0) begin
			always @ (posedge clk) begin
				if (o_d2_next)
					`BLEND(0, C_CH0_WIDTH-1)
			end
		end
		if (C_CH1_WIDTH > 0) begin
			always @ (posedge clk) begin
				if (o_d2_next)
					`BLEND(C_CH0_WIDTH, C_CH0_WIDTH+C_CH1_WIDTH-1)
			end
		end
		if (C_CH2_WIDTH > 0) begin
			always @ (posedge clk) begin
				if (o_d2_next)
					`BLEND(C_CH0_WIDTH+C_CH1_WIDTH, C_CH0_WIDTH+C_CH1_WIDTH+C_CH2_WIDTH-1)
			end
		end
	endgenerate

	always @ (posedge clk) begin
		if (int_reset) begin
			m_axis_tvalid <= 0;
			m_axis_tlast <= 0;
		end
		else if (o_d2_next) begin
			m_axis_tvalid <= 1;
			m_axis_tlast <= o_d2_tlast;
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
