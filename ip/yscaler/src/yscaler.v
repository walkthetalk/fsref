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
	localparam C_CMP_WIDTH = C_RESO_WIDTH * 2 + 1 + 1;

	localparam C_FIFO_RST_KEEP = 5;
	reg[C_FIFO_RST_KEEP-1:0] fifo_rst_keep;
	always @(posedge clk) begin
		if (resetn == 1'b0)
			fifo_rst_keep <= {C_FIFO_RST_KEEP{1'b1}};
		else
			fifo_rst_keep <= {fifo_rst_keep[C_FIFO_RST_KEEP-2:0], (o_line == 0 && i_line == 0)};
	end
	assign fifo_rst = ((fifo_rst_keep != 0) || (o_line == 0 && i_line == 0));

	localparam C_RESET_DELAY_NUM = 7;
	reg[C_RESET_DELAY_NUM-1:0] resetn_delay;
	always @(posedge clk) begin
		if (resetn == 1'b0)
			resetn_delay <= 0;
		else
			resetn_delay <= {resetn_delay[C_RESET_DELAY_NUM-2:0], ~fifo_rst};
	end
	wire int_resetn;
	assign int_resetn = (resetn_delay == {C_RESET_DELAY_NUM{1'b1}}
				&& ~fifo_rst
				|| m_axis_tvalid);	/// ensure output last pixel

	wire update_mmul;
	assign update_mmul = f1_rd_en && f1_rd_data[C_PIXEL_WIDTH] && (m_mul < o_mul_nl);
	wire update_imul;
	assign update_imul = s_axis_tlast && s_axis_tready && s_axis_tvalid;
	wire update_omul;

	/// misc
	reg f0_dout_valid;

	/// counter
	reg [C_RESO_WIDTH-1:0] i_line;	/// [h,1][0]
	reg [C_RESO_WIDTH-1:0] m_line;	/// [h,1]
	reg [C_RESO_WIDTH-1:0] o_line;	/// [h, 1][0]
	reg [C_RESO_WIDTH-1:0] o_pix;	/// [w, 1]
	reg o_last;

	/// mul for compare
	reg [C_CMP_WIDTH-1:0] m_mul_p;
	reg [C_CMP_WIDTH-1:0] m_mul;
	reg [C_CMP_WIDTH-1:0] o_mul;

	reg [C_CMP_WIDTH-1:0] m_mul_nl;
	reg [C_CMP_WIDTH-1:0] o_mul_nl;

	/// s_axis
	wire snext;
	assign snext = s_axis_tvalid & s_axis_tready;
	wire ssof;
	assign ssof = snext && s_axis_tuser;

	/// m_axis
	localparam ODELAY = 0;
	reg mvalid[ODELAY:0];
	reg msof[ODELAY:0];
	reg [C_PIXEL_WIDTH:0] mdata[ODELAY:0];
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
				end
				else if (mvalid[i-1] && mready[i]) begin
					msof[i] <= msof[i-1];
					mdata[i] <= mdata[i-1];
				end
				else begin
					msof[i] <= msof[i];
					mdata[i] <= mdata[i];
				end
			end
		end

		for (i=0; i <= ODELAY; i=i+1) begin
			assign mready[i] = ~mvalid[i] | mready[i+1];
		end
		assign mready[ODELAY+1] = m_axis_tready;
	endgenerate

	assign m_axis_tvalid = mvalid[ODELAY];
	assign m_axis_tdata = mdata[ODELAY][C_PIXEL_WIDTH-1:0];
	assign m_axis_tlast = mdata[ODELAY][C_PIXEL_WIDTH];
	assign m_axis_tuser = msof[ODELAY];

	/// p1
	reg p1_valid;
	wire p1m_valid;
	wire p1rd_ready;
	/// p1_data	@ f1_rd_data

	///////////////////////////////////////////// m ////////////////////////////////////////

	/// mvalid
	always @(posedge clk) begin
		if (int_resetn == 1'b0)
			mvalid[0] = 1'b0;
		else if (p1m_valid)
			mvalid[0] = 1'b1;
		else if (mready[1])
			mvalid[0] = 1'b0;
		else
			mvalid[0] = mvalid[0];
	end
	/// mdata
	always @(posedge clk) begin
		if (int_resetn == 1'b0) begin
			mdata[0] <= 0;
		end
		else if (p1m_valid && mready[0]) begin
			//if (f0_ready)
			//	mdata[0] <= f0_rd_data + (f1_rd_data - f0_rd_data) * (m_mul - o_mul) / (scale_height*2);
			//else
				$write("(");
				if (f0_dout_valid)
					$write(f0_rd_data[C_PIXEL_WIDTH-1:0]);
				else
					$write("   ");
				$write(" ", f1_rd_data[C_PIXEL_WIDTH-1:0], ")");

				//if (f0_dout_valid && m_mul_p < o_mul)
				//	mdata[0] <= f0_rd_data + (f1_rd_data - f0_rd_data) * (m_mul - o_mul) / (scale_height*2);
				//else
					mdata[0] <= f1_rd_data[C_PIXEL_WIDTH:0];
		end
		else begin
			mdata[0] <= mdata[0];
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
		else if (f1_rd_en)
			p1_valid <= 1'b1;
		else if (mready[0])
			p1_valid <= 1'b0;
		else
			p1_valid <= p1_valid;
	end

	assign p1m_valid = p1_valid && (m_mul >= o_mul);
	assign p1rd_ready = ((~p1_valid || mready[0] || m_mul < o_mul)
			&& (m_mul < o_mul_nl	/// if need repeat
			? (~f1_rd_data[C_PIXEL_WIDTH] || (~f1_rd_en_d1 && ~f1_rd_en_d2))	/// wait the line full stored in fifo0
			: (i_line < m_line)));
			/// @note should delay one cycle

	/// compare counter for checking if ready
	/// @note: max value is ori_height * scale_height * 2 + (ori_height or scale_height)/2

	always @(posedge clk) begin
		if (int_resetn == 1'b0)
			m_mul_nl <= (ori_height == 1 ? scale_height * 2 : scale_height * 3);
		else if (update_mmul) begin
			case (m_line)
			1:	m_mul_nl <= m_mul_nl;
			2:	m_mul_nl <= m_mul_nl + scale_height;
			default:m_mul_nl <= m_mul_nl + scale_height * 2;
			endcase
		end
		else
			m_mul_nl <= m_mul_nl;
	end
	always @(posedge clk) begin
		if (int_resetn == 1'b0)	m_mul <= scale_height;
		else if (update_mmul)	m_mul <= m_mul_nl;
		else			m_mul <= m_mul;
	end
	always @(posedge clk) begin
		if (int_resetn == 1'b0)	m_mul_p <= 0;
		else if (update_mmul)	m_mul_p <= m_mul;
		else			m_mul_p <= m_mul_p;
	end

	assign update_omul = p1m_valid && mready[0] && f1_rd_data[C_PIXEL_WIDTH];

	always @(posedge clk) begin
		if (int_resetn == 1'b0)	o_mul <= ori_height;
		else if (update_omul)	o_mul <= o_mul_nl;
		else			o_mul <= o_mul;
	end

	always @(posedge clk) begin
		if (int_resetn == 1'b0)
			o_mul_nl <= ori_height*3;
		else if (update_omul) begin
			o_mul_nl <= o_mul_nl + ori_height * 2;
		end
		else
			o_mul_nl <= o_mul_nl;
	end

	always @(posedge clk) begin
		if (int_resetn == 1'b0)
			o_line <= scale_height;
		else if (update_omul)
			o_line <= o_line - 1;
		else
			o_line <= o_line;
	end
	always @(posedge clk) begin
		if (int_resetn == 1'b0)	m_line <= ori_height;
		else if (update_mmul && m_line != 1)	m_line <= m_line - 1;
		else			m_line <= m_line;
	end
	always @(posedge clk) begin
		if (int_resetn == 1'b0)
			i_line <= ori_height;
		else if (update_imul)
			i_line <= i_line - 1;
		else
			i_line <= i_line;
	end

	always @(posedge clk) begin
		if (int_resetn == 1'b0)
			o_pix <= scale_width;
		else if (f1_rd_en)
			if (f1_rd_data[C_PIXEL_WIDTH])
				o_pix <= ori_width;
			else
				o_pix <= o_pix - 1;
		else
			o_pix <= o_pix;
	end

	always @(posedge clk) begin
		if (int_resetn == 1'b0)
			o_last <= 1'b0;
		else if (f1_rd_en && p1m_valid && o_pix == 2 && o_line == 1)
			o_last <= 1'b1;
		else
			o_last <= o_last;
	end

	/// f0_ready
	reg f0_ready;
	always @(posedge clk) begin
		if (int_resetn == 1'b0)
			f0_ready <= 1'b0;
		else if (f0_wr_en && f0_wr_data[C_PIXEL_WIDTH])
			f0_ready <= 1'b1;
		else
			f0_ready <= f0_ready;
	end

	/// read fifo
	assign f1_rd_en	= int_resetn && ~f1_empty && p1rd_ready
		&& ~o_last;
	reg f1_rd_en_d1;
	reg f1_rd_en_d2;
	reg f0_rd_en_d1;
	assign f0_rd_en = f0_ready && f1_rd_en;

	always @(posedge clk) begin
		if (int_resetn == 1'b0)
			f1_rd_en_d1 <= 1'b0;
		else
			f1_rd_en_d1 <= f1_rd_en;
	end
	always @(posedge clk) begin
		if (int_resetn == 1'b0)
			f1_rd_en_d2 <= 1'b0;
		else
			f1_rd_en_d2 <= f1_rd_en_d1;
	end
	always @(posedge clk) begin
		if (int_resetn == 1'b0)
			f0_rd_en_d1 <= 1'b0;
		else
			f0_rd_en_d1 <= f0_rd_en;
	end

	/// @note f1_rd_en_d1 is for avoiding second branch of f1_wr_*
	wire ready_for_next_pixel;
	assign ready_for_next_pixel = (m_mul >= o_mul_nl ? (i_line >= m_line) : (i_line >= m_line-1));
	assign s_axis_tready = (int_resetn && i_line != 0 &&
				((~f1_full && ready_for_next_pixel)
				|| o_line == 0));

	///@note: if we can delay f1_rd_en to last pixel of repeat_line, then we don't need dov4repeat,
	///       just use f0_rd_en_d1
	reg dov4repeat;
	wire repeat_line;
	assign repeat_line = (m_mul >= o_mul_nl || (m_line == 1 && o_line != 0));
	always @(posedge clk) begin
		if (int_resetn == 1'b0) begin
			dov4repeat <= 1'b0;
		end
		else if (f1_rd_en)
			dov4repeat <= 1'b1;
		else if (!snext && dov4repeat && repeat_line) begin
			dov4repeat <= 1'b0;
		end
		else begin
			dov4repeat <= dov4repeat;
		end
	end

	/// write fifo 1
	reg r_f1_wr_en;
	assign f1_wr_en = r_f1_wr_en && ~o_last;
	always @(posedge clk) begin
		if (int_resetn == 1'b0) begin
			r_f1_wr_en <= 1'b0;
			f1_wr_data <= 0;
		end
		else if (snext) begin
			r_f1_wr_en <= 1'b1;
			f1_wr_data <= {s_axis_tuser, s_axis_tlast, s_axis_tdata};
		end
		else if (dov4repeat && repeat_line) begin
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
	assign f0_wr_en = r_f0_wr_en && ~o_last;
	always @(posedge clk) begin
		if (int_resetn == 1'b0) begin
			r_f0_wr_en <= 1'b0;
			f0_wr_data <= 0;
		end
		else if (m_mul >= o_mul_nl) begin
			r_f0_wr_en <= f0_rd_en_d1;
			f0_wr_data <= f0_rd_data;
		end
		else begin
			r_f0_wr_en <= f1_rd_en_d1;
			f0_wr_data <= f1_rd_data;
		end
	end

	always @(posedge clk) begin
		if (int_resetn == 1'b0)
			f0_dout_valid <= 1'b0;
		else if (f0_rd_en)
			f0_dout_valid <= 1'b1;
		else
			f0_dout_valid <= f0_dout_valid;
	end
endmodule

