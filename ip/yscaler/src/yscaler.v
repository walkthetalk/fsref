`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 11/18/2016 01:33:37 PM
// Design Name:
// Module Name: pcfa
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
	C_PIXEL_WIDTH = 8,
	C_RESO_WIDTH  = 10
) (
	input wire clk,
	input wire resetn,
	input wire fsync,

	input wire [C_RESO_WIDTH-1 : 0] ori_width,
	input wire [C_RESO_WIDTH-1 : 0] ori_height,

	input wire [C_RESO_WIDTH-1 : 0] scale_width,
	input wire [C_RESO_WIDTH-1 : 0] scale_height,

	output wire	fifo_rst,

	input wire	f0_full,
	output wire [C_PIXEL_WIDTH+1 : 0] f0_wr_data,
	output wire	f0_wr_en,

	input wire	f0_empty,
	input wire [C_PIXEL_WIDTH+1 : 0] f0_rd_data,
	output wire	f0_rd_en,

	input wire	f1_full,
	output wire [C_PIXEL_WIDTH+1 : 0] f1_wr_data,
	output wire	f1_wr_en,

	input wire	f1_empty,
	input wire [C_PIXEL_WIDTH+1 : 0] f1_rd_data,
	output wire	f1_rd_en,

	input wire s_axis_tvalid,
	input wire [C_PIXEL_WIDTH-1:0] s_axis_tdata,
	input wire s_axis_tuser,
	input wire s_axis_tlast,
	output wire s_axis_tready,

	output wire m_axis_tvalid,
	output wire [C_PIXEL_WIDTH*3-1:0] m_axis_tdata,
	output wire m_axis_tuser,
	output wire m_axis_tlast,
	input wire m_axis_tready
);
	localparam C_CMP_WIDTH = C_RESO_WIDTH * 2 + 1 + 1;

	wire int_resetn;
	assign int_resetn = resetn | ~fsync;

	/// mul for compare
	reg [C_CMP_WIDTH-1:0] i_mul;
	reg [C_CMP_WIDTH-1:0] m_mul;
	reg [C_CMP_WIDTH-1:0] o_mul;

	wire [C_CMP_WIDTH-1:0] m_mul_next;
	wire [C_CMP_WIDTH-1:0] o_mul_next;
	assign o_mul_next = o_mul + ori_height * 2;
	assign m_mul_next = m_mul + scale_height * 2;

	/// s_axis
	wire snext;
	assign snext = s_axis_tvalid & s_axis_tready;
	wire ssof;
	assign ssof = snext && s_axis_tuser;
	wire seol;
	assign seol = snext && s_axis_tlast;

	/// m_axis
	wire mnext;
	reg mvalid;
	reg msof;
	reg meol;
	reg [C_PIXEL_WIDTH-1:0] mdata;
	wire mready;
	assign mready = ~mvalid | m_axis_tready;
	assign mnext = m_axis_tvalid & m_axis_tready;
	assign m_axis_tvalid = mvalid;
	assign m_axis_tdata = mdata;
	assign m_axis_tuser = msof;
	assign m_axis_tlast = meol;

	/// m_axis_pre
	reg mvalid_p1;
	always @(posedge clk) begin
		if (int_resetn == 1'b0)
			mvalid_p1 <= 1'b0;
		else if (f1_rd_en)
			mvalid_p1 <= 1'b1;
		else if (mready)
			mvalid_p1 <= 1'b0;
		else
			mvalid_p1 <= mvalid_p1;
	end

	/// pre -> m

	wire mupdate;
	assign mupdate = mvalid_p1 && (m_mul >= o_mul);

	always @(posedge clk) begin
		if (int_resetn == 1'b0)
			mvalid = 1'b0;
		else if (mupdate)
			mvalid = 1'b1;
		else if (m_axis_tready)
			mvalid = 1'b0;
		else
			mvalid = mvalid;
	end
	/// meol
	always @(posedge clk) begin
		if (int_resetn == 1'b0)
			meol <= 1'b0;
		else if (mupdate)
			meol <= f1_rd_data[C_PIXEL_WIDTH+1];
		else
			meol <= meol;
	end
	/// mdata
	always @(posedge clk) begin
		if (int_resetn == 1'b0)
			mdata <= 0;
		else if (mupdate) begin
			if (f0_full_line)
				mdata <= f0_rd_data + (f1_rd_data - f0_rd_data) * (m_mul - o_mul) / (scale_height*2);
			else
				mdata <= f1_rd_data;
		end
		else
			mdata <= mdata;
	end
	/// msof
	reg[1:0] msof_ed;
	always @(posedge clk) begin
		if (int_resetn == 1'b0)
			msof_ed <= 2'b00;
		else if (mupdate)
			msof_ed <= {msof_ed[0], 1'b1};
		else
			msof_ed <= msof_ed;
	end
	assign msof = (msof_ed == 2'b01);

	/// compare counter for checking if ready
	/// @note: max value is ori_height * scale_height * 2 + (ori_height or scale_height)/2
	always @(posedge clk) begin
		if (int_resetn == 1'b0)
			i_mul <= scale_height;
		else if (seol)
			i_mul <= i_mul + scale_height * 2;
		else
			i_mul <= i_mul;
	end

	always @(posedge clk) begin
		if (int_resetn == 1'b0)
			m_mul <= scale_height;
		else if (mupdate && f1_rd_data[C_PIXEL_WIDTH+1] && (m_mul < o_mul_next))
			m_mul <= m_mul + scale_height * 2;
		else
			m_mul <= m_mul;
	end

	always @(posedge clk) begin
		if (int_resetn == 1'b0)
			o_mul <= ori_height;
		else if (mupdate && f1_rd_data[C_PIXEL_WIDTH+1])
			o_mul <= o_mul + ori_height * 2;
		else
			o_mul <= o_mul;
	end

	/// line_remain
	reg[C_RESO_WIDTH-1 : 0] s_height_remain;
	reg[C_RESO_WIDTH-1 : 0] m_height_remain;

	always @(posedge clk) begin
		if (resetn == 1'b0)
			s_height_remain <= 0;
		else if (fsync)
			s_height_remain <= ori_height;
		else if (seol)
			s_height_remain <= s_height_remain - 1'b1;
		else
			s_height_remain <= s_height_remain;
	end

	always @(posedge clk) begin
		if (resetn == 1'b0)
			m_height_remain <= 0;
		else if (fsync)
			m_height_remain <= scale_height;
		else if (meol)
			m_height_remain <= m_height_remain - 1'b1;
		else
			m_height_remain <= m_height_remain;
	end

	/// read fifo
	assign f1_rd_en = ~f1_empty && (~mvalid_p1 || mready) && ((m_mul < o_mul_next) || (i_mul > m_mul));
	assign f0_rd_en = f0_full_line && f1_rd_en;

	reg f1_rd_en_d1;
	always @(posedge clk) begin
		if (int_resetn == 1'b0)
			f1_rd_en_d1 <= 1'b0;
		else
			f1_rd_en_d1 <= f1_rd_en;
	end

	reg f0_full_line;
	always @(posedge clk) begin
		if (int_resetn == 1'b0)
			f0_full_line <= 1'b0;
		else if (f0_wr_en && f0_wr_data[C_PIXEL_WIDTH])
			f0_full_line <= 1'b1;
		else
			f0_full_line <= f0_full_line;
	end

	wire ready_for_next_pixel;
	assign ready_for_next_pixel = (i_mul < (m_mul >= o_mul_next ? m_mul : m_mul_next));
	assign s_axis_tready = ~f1_full && ready_for_next_pixel && (s_height_remain != 0);

	/// write fifo 1
	reg [C_PIXEL_WIDTH+1:0] r_f1_wr_data;
	assign f1_wr_data = r_f1_wr_data;

	reg r_f1_wr_en;
	assign f1_wr_en = r_f1_wr_en;

	always @(posedge clk) begin
		if (int_resetn == 1'b0) begin
			r_f1_wr_en <= 1'b0;
			r_f1_wr_data <= 0;
		end
		else if (snext) begin
			r_f1_wr_en <= 1'b1;
			r_f1_wr_data <= {s_axis_tlast, s_axis_tuser, s_axis_tdata};
		end
		else if (f1_rd_en_d1 && (m_mul >= o_mul_next)) begin
			r_f1_wr_en <= 1'b1;
			r_f1_wr_data <= f1_rd_data;
		end
		else begin
			r_f1_wr_en <= 1'b0;
			r_f1_wr_data <= 0;
		end
	end

	/// write fifo 0
	reg [C_PIXEL_WIDTH+1:0] r_f0_wr_data;
	assign f0_wr_data = r_f0_wr_data;
	reg r_f0_wr_en;
	assign f0_wr_en = r_f0_wr_en;

	always @(posedge clk) begin
		if (int_resetn == 1'b0) begin
			r_f0_wr_en <= 1'b0;
			r_f0_wr_data <= 0;
		end
		else if (f1_rd_en_d1) begin
			if (m_mul >= o_mul_next) begin
				r_f0_wr_en <= f0_full_line;
				r_f0_wr_data <= f0_rd_data;
			end
			else begin
				r_f0_wr_en <= 1'b1;
				r_f0_wr_data <= f1_rd_data;
			end
		end
		else begin
			r_f0_wr_en <= 1'b0;
			r_f0_wr_data <= 0;
		end
	end

endmodule

