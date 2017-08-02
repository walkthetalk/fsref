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
	parameter integer C_RESO_WIDTH  = 10
) (
	input wire clk,
	input wire resetn,

	input wire [C_RESO_WIDTH-1 : 0] ori_width,
	input wire [C_RESO_WIDTH-1 : 0] ori_height,

	input wire [C_RESO_WIDTH-1 : 0] scale_width,
	input wire [C_RESO_WIDTH-1 : 0] scale_height,

	output wire	fifo_rst,

	input wire	f0_full,
	output reg [C_PIXEL_WIDTH+1 : 0] f0_wr_data,
	output wire	f0_wr_en,

	input wire	f0_empty,
	input wire [C_PIXEL_WIDTH+1 : 0] f0_rd_data,
	output wire	f0_rd_en,

	input wire	f1_full,
	output reg [C_PIXEL_WIDTH+1 : 0] f1_wr_data,
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
	output wire [C_PIXEL_WIDTH-1:0] m_axis_tdata,
	output wire m_axis_tuser,
	output wire m_axis_tlast,
	input wire m_axis_tready
);
	wire int_resetn;

	reg out_done;
	reg out_last_pix;

	localparam C_FIFO_RST_KEEP = 5;
	localparam C_FIFO_RST_DELAY = 7;
	localparam C_FIFO_RST_SEQ = C_FIFO_RST_KEEP + C_FIFO_RST_DELAY;
	reg[C_FIFO_RST_SEQ-1:0] fifo_rst_seq;
	always @(posedge clk) begin
		if (resetn == 1'b0)
			fifo_rst_seq <= {C_FIFO_RST_SEQ{1'b1}};
		else
			fifo_rst_seq <= {fifo_rst_seq[C_FIFO_RST_SEQ-2:0], 1'b0};
	end
	assign fifo_rst = fifo_rst_seq[C_FIFO_RST_KEEP-1];

	assign int_resetn = ((resetn && ~fifo_rst_seq[C_FIFO_RST_SEQ-1])
			&& ~(out_done && i_line == 0));	/// ensure output last pixel

	wire int_f1_rd_en;

	/// counter
	reg [C_RESO_WIDTH-1:0] i_line;	/// [h,1][0]
	reg m_last;
	reg o_last_pix;
	/*
	 * @note: m_pix->m_last is only for burr on fifo read enable.
	 *        and `m_last' must keep to next read enable.
	 * @todo: if not, f1_rd_data[C_PIXEL_WIDTH] should be used with f1_dout_valid
	 */

	/// mul for compare
	wire update_imul;
	assign update_imul = s_axis_tlast && s_axis_tready && s_axis_tvalid;

	/*
	 * use current pixel info
	 */
/*	wire m_repeat_line;
	wire [C_RESO_WIDTH-1 : 0] m_line;	/// [h,1]
	wire [C_RESO_WIDTH-1 : 0] o_line;	/// [h,1][0]
	wire m_valid;	/// for output
	wire update_mul;
	assign update_mul = int_f1_rd_en && m_last;

	bilinear_scaler # (
		.C_RESO_WIDTH(C_RESO_WIDTH)
	) scaler_inst (
		.clk(clk),
		.resetn(int_resetn),
		.ori_size(ori_height),
		.scale_size(scale_height),
		.update_mul(update_mul),
		.m_repeat_line(m_repeat_line),
		.m_inv_cnt(m_line),
		.o_inv_cnt(o_line),
		.m_ovalid(m_valid)
	);
*/

	/*
	 * use next pixel info
	 */
	wire m_repeat_line_next;
	wire [C_RESO_WIDTH-1 : 0] m_line_next;	/// [h,1]
	wire [C_RESO_WIDTH-1 : 0] o_line_next;	/// [h,1][0]
	wire m_valid_next;	/// for output
	wire update_mul_next;
	wire[2:0] ratio_next;
	assign update_mul_next = int_f1_rd_en && m_last_next;

	bilinear_scaler # (
		.C_RESO_WIDTH(C_RESO_WIDTH)
	) scaler_inst_next (
		.clk(clk),
		.resetn(int_resetn),
		.ori_size(ori_height),
		.scale_size(scale_height),
		.update_mul(update_mul_next),
		.m_repeat_line(m_repeat_line_next),
		.m_inv_cnt(m_line_next),
		.o_inv_cnt(o_line_next),
		.m_ovalid(m_valid_next),
		.ratio(ratio_next)
	);
	reg m_repeat_line;
	reg [C_RESO_WIDTH-1 : 0] m_line;	/// [h,1]
	reg m_valid;	/// for output
	reg [C_RESO_WIDTH-1 : 0] i_stop_line;
	reg [2 : 0] ratio;
	always @(posedge clk) begin
		if (int_resetn == 1'b0) begin
			/// @note: init m_repeat_line with 1'b1,
			///        for case of repeating 1st line,
			///        but fail with too quick input
			m_repeat_line <= 1'b1;	/// @todo: can be optimized
			m_line <= ori_height;
			m_valid <= 1'b0;
			i_stop_line <= ori_height - 1;
			ratio <= 0;
		end
		else if (int_f1_rd_en) begin
			m_repeat_line <= m_repeat_line_next;
			m_line <= m_line_next;
			m_valid <= m_valid_next;
			if (m_line_next == 1)
				i_stop_line <= 0;
			else if (m_repeat_line_next)
				i_stop_line <= m_line_next - 1;
			else
				i_stop_line <= m_line_next - 2;
			ratio <= ratio_next;
		end
		else begin
			m_repeat_line <= m_repeat_line;
			m_line <= m_line;
			m_valid <= m_valid;
			i_stop_line <= i_stop_line;
			ratio <= ratio_next;
		end
	end

	/// s_axis
	wire snext;
	assign snext = s_axis_tvalid & s_axis_tready;
	wire ssof;
	assign ssof = snext && s_axis_tuser;

	/// m_axis
	localparam ODELAY = 0;
	reg mvalid[ODELAY:0];
	reg msof[ODELAY:0];
	reg [C_PIXEL_WIDTH-1:0] mdata[ODELAY:0];
	reg meol[ODELAY:0];
	wire mready[ODELAY+1:0];

	///  m_axis delay
	generate
		genvar i;

		for (i=1; i <= ODELAY; i=i+1) begin
			always @(posedge clk) begin
				if (int_resetn == 1'b0)
					mvalid[i] <= 1'b0;
				else if (mvalid[i-1])
					mvalid[i] <= 1'b1;
				else if (mready[i+1])
					mvalid[i] <= 1'b0;
				else
					mvalid[i] <= mvalid[i];
			end
			always @(posedge clk) begin
				if (int_resetn == 1'b0) begin
					msof[i] <= 1'b0;
					mdata[i] <= 0;
					meol[i] <= 0;
				end
				else if (mvalid[i-1] && mready[i]) begin
					msof[i] <= msof[i-1];
					mdata[i] <= mdata[i-1];
					meol[i] <= meol[i-1];
				end
				else begin
					msof[i] <= msof[i];
					mdata[i] <= mdata[i];
					meol[i] <= meol[i];
				end
			end
		end

		for (i=0; i <= ODELAY; i=i+1) begin
			assign mready[i] = ~mvalid[i] | mready[i+1];
		end
		assign mready[ODELAY+1] = m_axis_tready;
	endgenerate

	assign m_axis_tvalid = mvalid[ODELAY];
	assign m_axis_tdata = mdata[ODELAY];
	assign m_axis_tlast = meol[ODELAY];
	assign m_axis_tuser = msof[ODELAY];

	/// p1
	reg p1_valid;
	wire p1m_valid;
	wire p1rd_ready;

	reg f0_dout_valid;
	always @(posedge clk) begin
		if (int_resetn == 1'b0)
			f0_dout_valid <= 1'b0;
		else if (int_f1_rd_en && m_line_next != m_line)
			f0_dout_valid <= 1'b1;
		else
			f0_dout_valid <= f0_dout_valid;
	end

	///////////////////////////////////////////// m ////////////////////////////////////////

	/// mvalid
	always @(posedge clk) begin
		if (int_resetn == 1'b0)
			mvalid[0] <= 1'b0;
		else if (p1m_valid)
			mvalid[0] <= 1'b1;
		else if (mready[1])
			mvalid[0] <= 1'b0;
		else
			mvalid[0] <= mvalid[0];
	end
	always @(posedge clk) begin
		if (int_resetn == 1'b0)
			out_last_pix <= 1'b0;
		else if (p1m_valid && mready[0])
			out_last_pix <= o_last_pix;
		else
			out_last_pix <= out_last_pix;
	end
	always @(posedge clk) begin
		if (int_resetn == 1'b0)
			out_done <= 1'b0;
		else if (mvalid[0] && mready[1] && out_last_pix)
			out_done <= 1'b1;
		else
			out_done <= out_done;
	end
	/// mdata
	wire[C_PIXEL_WIDTH-1:0] f0_pd;
	assign f0_pd = f0_rd_data[C_PIXEL_WIDTH-1:0];
	wire[C_PIXEL_WIDTH-1:0] f1_pd;
	assign f1_pd = f1_rd_data[C_PIXEL_WIDTH-1:0];
	always @(posedge clk) begin
		if (int_resetn == 1'b0) begin
			mdata[0] <= 0;
			meol[0] <= 0;
		end
		else if (p1m_valid && mready[0]) begin
			/*
			 * @note: if ori_width > 2,
			 *        we can use `f0_ready' directly,
			 *        don't need f0_dout_valid
			 */
			$write("(");
			if (f0_dout_valid) begin
				$write(f0_pd);
				if (f0_pd + 10 != f1_pd)
					$write("error for value!!!!");
			end
			else begin
				$write("   ");
			end
			$write(" ", f1_pd, ")");

			case (ratio)
			0: mdata[0] <= f0_pd;
			1: mdata[0] <= (f0_pd + f1_pd + f0_pd*2)/4;
			2: mdata[0] <= (f0_pd + f1_pd)/2;
			3: mdata[0] <= (f0_pd + f1_pd + f1_pd*2)/4;
			default: mdata[0] <= f1_pd;
			endcase

			meol[0] <= f1_rd_data[C_PIXEL_WIDTH];
		end
		else begin
			mdata[0] <= mdata[0];
			meol[0] <= meol[0];
		end
	end
	/// msof
	reg msof_ed;
	always @(posedge clk) begin
		if (int_resetn == 1'b0)
			msof_ed <= 1'b0;
		else if (p1m_valid)
			msof_ed <= 1'b1;
		else
			msof_ed = msof_ed;
	end
	always @(posedge clk) begin
		if (int_resetn == 1'b0)
			msof[0] <= 1'b0;
		else if (p1m_valid && ~msof_ed)
			msof[0] <= 1'b1;
		else if (p1m_valid && mready[0])
			msof[0]= 1'b0;
		else
			msof[0] = msof[0];
	end

	//////////////////////////////////////////// p1 //////////////////////////////////////////

	always @(posedge clk) begin
		if (int_resetn == 1'b0)
			p1_valid <= 1'b0;
		else if (int_f1_rd_en)
			p1_valid <= 1'b1;
		else if (mready[0])
			p1_valid <= 1'b0;
		else
			p1_valid <= p1_valid;
	end

	assign p1m_valid = p1_valid && m_valid;

	always @(posedge clk) begin
		if (int_resetn == 1'b0)
			i_line <= ori_height;
		else if (update_imul)
			i_line <= i_line - 1;
		else
			i_line <= i_line;
	end

	reg[C_RESO_WIDTH-1:0] m_pix_next; /// [w,1]
	always @(posedge clk) begin
		if (int_resetn == 1'b0)
			m_pix_next <= ori_width;
		else if (int_f1_rd_en) begin
			if (m_pix_next == 1)
				m_pix_next <= ori_width;
			else
				m_pix_next <= m_pix_next - 1;
		end
		else
			m_pix_next <= m_pix_next;
	end
	reg m_last_next;
	always @(posedge clk) begin
		if (int_resetn == 1'b0) begin
			if (ori_width == 1)
				m_last_next <= 1'b1;
			else
				m_last_next <= 1'b0;
		end
		else if (int_f1_rd_en) begin
			if (m_pix_next == 2 || ori_width == 1)
				m_last_next <= 1'b1;
			else
				m_last_next <= 1'b0;
		end
		else
			m_last_next <= m_last_next;
	end

	always @(posedge clk) begin
		if (int_resetn == 1'b0)
			m_last <= 1'b0;
		else if (int_f1_rd_en)
			m_last <= m_last_next;
		else
			m_last <= m_last;
	end

	always @(posedge clk) begin
		if (int_resetn == 1'b0)
			o_last_pix <= 1'b0;
		else if (int_f1_rd_en && m_valid_next && m_last_next && o_line_next == 1)
			o_last_pix <= 1'b1;
		else
			o_last_pix <= o_last_pix;
	end

	reg o_last_line;
	always @(posedge clk) begin
		if (int_resetn == 1'b0)
			o_last_line <= 1'b0;
		else if (int_f1_rd_en && m_valid_next && o_line_next == 1)
			o_last_line <= 1'b1;
		else
			o_last_line <= o_last_line;
	end

	/// f0_ready
	reg f0_ready;
	always @(posedge clk) begin
		if (int_resetn == 1'b0)
			f0_ready <= 1'b0;
		else if (int_f1_rd_en && m_last_next && ~m_repeat_line_next)
			f0_ready <= 1'b1;
		else
			f0_ready <= f0_ready;
	end

	///@note: can use ~f0_empty to replace `f0_has_content'
	reg f0_has_content;
	always @(posedge clk) begin
		if (int_resetn == 1'b0)
			f0_has_content <= 1'b0;
		else if (int_f1_rd_en && m_last_next && ~m_repeat_line_next && ori_width <= 2)
			f0_has_content <= 1'b0;
		else if (f0_wr_en)
			f0_has_content <= 1'b1;
		else
			f0_has_content <= f0_has_content;
	end

	/// read fifo
	assign p1rd_ready = ((~p1_valid || mready[0] || ~m_valid)
			&& (
				/// wait for recieved full line
				~m_repeat_line || (i_line < m_line)
			));
	assign int_f1_rd_en	= int_resetn && ~f1_empty && p1rd_ready
				///@note: wait fifo0 for small width
				&& (~f0_ready || f0_has_content)
				&& ~o_last_pix;
	assign f1_rd_en = int_f1_rd_en;

	reg f1_rd_en_d1;
	reg f0_rd_en_d1;
	assign f0_rd_en = f0_ready && int_f1_rd_en;

	always @(posedge clk) begin
		if (int_resetn == 1'b0)
			f1_rd_en_d1 <= 1'b0;
		else
			f1_rd_en_d1 <= int_f1_rd_en;
	end
	always @(posedge clk) begin
		if (int_resetn == 1'b0)
			f0_rd_en_d1 <= 1'b0;
		else
			f0_rd_en_d1 <= f0_rd_en;
	end

	/// @note: indeed, we don't need `o_last_line', but use `o_last_pix',
	///        it exist here just for skip all input as quickly as possible.
	assign s_axis_tready = int_resetn &&
				/// @note: both below lines contain the logic of last valid line.
				///        the fifo 1 will not be full when outputing last line.
				/// @note: if the size of fifo is equal or bigger than tow lines
				///        we can drop `~f1_full'.
				((~f1_full && i_line != i_stop_line)
				/// @note: remain input
				|| (o_last_line && i_line != 0));

	///@note: if we can delay f1_rd_en to last pixel of m_repeat_line,
	///       then we don't need dov4repeat, just use f0_rd_en_d1
	reg dov4repeat;
	wire repeat_line_ready;
	assign repeat_line_ready = m_repeat_line && i_line < m_line;
	always @(posedge clk) begin
		if (int_resetn == 1'b0) begin
			dov4repeat <= 1'b0;
		end
		else if (int_f1_rd_en)
			dov4repeat <= 1'b1;
		else if (!snext && dov4repeat && repeat_line_ready) begin
			dov4repeat <= 1'b0;
		end
		else begin
			dov4repeat <= dov4repeat;
		end
	end

	/// write fifo 1
	reg r_f1_wr_en;
	assign f1_wr_en = r_f1_wr_en && ~o_last_pix;
	/*
	 * pre-last-line need 2 clock to full stored in fifo0,
	 * so we can make i_last_valid_line delay 1 clock.
	 * 1. if extent: i_last_valid_line must be 1, no change
	 * 2. if shrink: pre-last-line must not repeat, so need 2 clock
	 */
	reg [C_RESO_WIDTH-1 : 0] i_last_valid_line;
	always @(posedge clk) begin
		if (int_resetn == 1'b0)
			i_last_valid_line <= 1;
		else if (o_line_next == 1 && m_valid_next)
			i_last_valid_line <= m_line_next;
		else
			i_last_valid_line <= i_last_valid_line;
	end

	always @(posedge clk) begin
		if (int_resetn == 1'b0) begin
			r_f1_wr_en <= 1'b0;
			f1_wr_data <= 0;
		end
		else if (snext && i_line >= i_last_valid_line) begin
			r_f1_wr_en <= 1'b1;
			f1_wr_data <= {s_axis_tuser, s_axis_tlast, s_axis_tdata};
		end
		else if (dov4repeat && repeat_line_ready) begin
			r_f1_wr_en <= 1'b1;
			f1_wr_data <= f1_rd_data;
		end
		else begin
			r_f1_wr_en <= 1'b0;
			f1_wr_data <= 0;
		end
	end

	/// write fifo 0
	reg r_f0_wr_en;
	assign f0_wr_en = r_f0_wr_en && ~o_last_pix;
	always @(posedge clk) begin
		if (int_resetn == 1'b0) begin
			r_f0_wr_en <= 1'b0;
			f0_wr_data <= 0;
		end
		else if (m_repeat_line) begin
			r_f0_wr_en <= f0_rd_en_d1;
			f0_wr_data <= f0_rd_data;
		end
		else if (~o_last_line) begin
			r_f0_wr_en <= f1_rd_en_d1;
			f0_wr_data <= f1_rd_data;
		end
		else begin
			r_f0_wr_en <= 1'b0;
			f0_wr_data <= 0;
		end
	end
endmodule
