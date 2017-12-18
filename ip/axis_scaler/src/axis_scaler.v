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
	parameter integer C_SH_WIDTH    = 10,
	parameter integer C_SW_WIDTH    = 10,
	parameter integer C_MH_WIDTH    = 10,
	parameter integer C_MW_WIDTH    = 10,
	parameter integer C_CH0_WIDTH = 8,
	parameter integer C_CH1_WIDTH = 0,
	parameter integer C_CH2_WIDTH = 0,
	parameter integer C_TEST = 0
) (
	input  wire clk,
	input  wire resetn,
	input  wire fsync,

	input  wire [C_SW_WIDTH-1 : 0]  s_width,
	input  wire [C_SH_WIDTH-1 : 0]  s_height,

	input  wire [C_MW_WIDTH-1 : 0]  m_width,
	input  wire [C_MH_WIDTH-1 : 0]  m_height,

	input  wire                     s_axis_tvalid,
	input  wire [C_PIXEL_WIDTH-1:0] s_axis_tdata,
	input  wire                     s_axis_tuser,
	input  wire                     s_axis_tlast,
	output reg                      s_axis_tready,

	output reg                      m_axis_tvalid,
	output reg  [C_PIXEL_WIDTH-1:0] m_axis_tdata,
	output reg                      m_axis_tuser,
	output reg                      m_axis_tlast,
	input  wire                     m_axis_tready
);

	wire frm_resetn;
	assign frm_resetn = (resetn && ~fsync);

	localparam  C_FIFO_IDX_WIDTH = 2;
	localparam  C_FIFO_NUM = 2**C_FIFO_IDX_WIDTH;
	localparam  C_SPLITER_IDX_WIDTH = 2;
	localparam  C_SPLITER_NUM = 2**C_SPLITER_IDX_WIDTH;

	reg  [C_FIFO_NUM-1:0]    fifo_full;

/// output
	wire [C_FIFO_NUM-1:0] r_sbmp0;
	wire [C_FIFO_NUM-1:0] r_sbmp1;
	wire [C_FIFO_NUM-1:0] r_sbmp2;
	wire [C_FIFO_IDX_WIDTH-1:0] r_sbid0;
	wire [C_FIFO_IDX_WIDTH-1:0] r_sbid1;
	wire                  r_mfirst;
	wire [C_SH_WIDTH+C_MH_WIDTH:0] r_sc;
	wire [C_SH_WIDTH+C_MH_WIDTH:0] r_mc;
	wire                  r_valid;
	wire                  r_validn;

	wire [C_MW_WIDTH-1:0] c_sidx0;
	wire [C_MW_WIDTH-1:0] c_sidx1;
	wire                  c_snew;
	wire                  c_mfirst;
	wire                  c_mlast;
	wire                  c_alast;
	wire [C_SW_WIDTH+C_MW_WIDTH:0] c_sc;
	wire [C_SW_WIDTH+C_MW_WIDTH:0] c_mc;
	wire                  c_valid;

	wire pipe_en;
	assign pipe_en = (~m_axis_tvalid || m_axis_tready);

common_scaler # (
	.C_S_WIDTH(C_SH_WIDTH),
	.C_M_WIDTH(C_MH_WIDTH),
	.C_S_BMP  (C_FIFO_NUM),
	.C_S_BID  (C_FIFO_IDX_WIDTH),
	.C_M_CLR  (1         ),
	.C_TEST   (0         )
) rscaler (
	.clk(clk),
	.resetn(frm_resetn),
	.enable(1'b1),

	.s_nbr(s_height),
	.m_nbr(m_height),

	.s_bmp0   (r_sbmp0   ),
	.s_bmp1   (r_sbmp1   ),
	.s_bmp2   (r_sbmp2   ),
	.s_bid0   (r_sbid0   ),
	.s_bid1   (r_sbid1   ),
	.s_ready  ((r_sbmp2 & fifo_full) != 0),
	.m_first  (r_mfirst  ),
	.m_ready  (~r_valid || (pipe_en && c_alast)),
	.d_valid  (r_valid   ),
	.d_validn (r_validn  ),
	.s_c      (r_sc      ),
	.m_c      (r_mc      )
);
common_scaler # (
	.C_S_WIDTH(C_SW_WIDTH),
	.C_M_WIDTH(C_MW_WIDTH),
	.C_S_IDX  (1         ),
	.C_M_CLR  (1         ),
	.C_TEST   (0         )
) cscaler (
	.clk(clk),
	.resetn(frm_resetn),
	.enable(1'b1),

	.s_nbr(s_width),
	.m_nbr(m_width),

	.s_idx0   (c_sidx0  ),
	.s_idx1   (c_sidx1  ),
	.s_ready  (~c_alast || r_validn || (r_sbmp2 & fifo_full)),
	.m_first  (c_mfirst ),
	.m_last   (c_mlast  ),
	.m_ready  (pipe_en  ),
	.a_last   (c_alast  ),
	.d_valid  (c_valid  ),
	.d_new    (c_snew    ),
	.s_c      (c_sc     ),
	.m_c      (c_mc     )
);

/// input
	wire snext;
	assign snext = s_axis_tvalid && s_axis_tready;
	wire slast;
	assign slast = snext && s_axis_tlast;

	reg  [C_FIFO_NUM-1:0]    wr_act;
	reg  [C_FIFO_NUM-1:0]    wr_act_next;
	reg  [C_FIFO_NUM-1:0]    wr_en;
	reg  [C_SW_WIDTH-1:0]    wr_idx;
	reg  [C_PIXEL_WIDTH-1:0] wr_data;
	reg                      wr_last;

	wire [C_PIXEL_WIDTH-1:0] rd_data[C_FIFO_NUM-1:0];

	always @ (posedge clk) begin
		if (frm_resetn == 1'b0)
			wr_idx <= 0;
		else if (wr_en)
			wr_idx <= (wr_last ? 0 : wr_idx + 1);
	end
	always @ (posedge clk) begin
		if (frm_resetn == 1'b0) begin
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
				.C_ADDRESS_WIDTH(C_SW_WIDTH)
			) linebuffer_inst (
				.clk(clk),

				.w0(wr_en[i]  ),
				.a0(wr_idx    ),
				.d0(wr_data   ),
				.a1(c_sidx1   ),
				.q1(rd_data[i])
			);

			always @(posedge clk) begin
				if (frm_resetn == 1'b0)
					wr_en[i] <= 1'b0;
				else if (snext && wr_act[i])
					wr_en[i] <= 1'b1;
				else
					wr_en[i] <= 1'b0;
			end
			always @ (posedge clk) begin
				if (frm_resetn == 1'b0)
					fifo_full[i] <= 0;
				else if (slast && wr_act[i])
					fifo_full[i] <= 1;
				else if (pipe_en
					&& ~r_validn && c_alast && (r_sbmp2 & fifo_full)	/// next line
					&& (r_sbmp0[i] && ~r_sbmp1[i]))		/// is this line
					fifo_full[i] <= 0;
			end
		end
	endgenerate

	always @ (posedge clk) begin
		if (frm_resetn == 1'b0)
			s_axis_tready <= 0;
		else if (s_axis_tready) begin
			if ((s_axis_tvalid && s_axis_tlast)
				&& ((~fifo_full & wr_act_next) == 0))
				s_axis_tready <= 0;
		end
		else begin
			if ((~fifo_full & wr_act))
				s_axis_tready <= 1;
		end
	end

	always @ (posedge clk) begin
		if (frm_resetn == 1'b0) begin
			wr_act      <= 1;
			wr_act_next <= 2;
		end
		else if (slast) begin
			wr_act      <= wr_act_next;
			wr_act_next <= {wr_act_next[C_FIFO_NUM-2:0], wr_act_next[C_FIFO_NUM-1]};
		end
	end

/// process
	reg[C_MH_WIDTH:0]   y_spliter[3:0];
	reg[C_MW_WIDTH:0]   x_spliter[3:0];
	always @ (posedge clk) begin
		y_spliter[0] <= (m_height * 1 + m_height * 0) / 4;
		y_spliter[1] <= (m_height * 2 + m_height * 1) / 4;
		y_spliter[2] <= (m_height * 4 + m_height * 1) / 4;
		y_spliter[3] <= (m_height * 8 - m_height * 1) / 4;

		x_spliter[0] <= (m_width  * 1 + m_width  * 0) / 4;
		x_spliter[1] <= (m_width  * 2 + m_width  * 1) / 4;
		x_spliter[2] <= (m_width  * 4 + m_width  * 1) / 4;
		x_spliter[3] <= (m_width  * 8 - m_width  * 1) / 4;
	end

	///////////////////////////// 0 ////////////////////////////////////////
	reg                    o0_valid;
	reg[C_FIFO_IDX_WIDTH-1:0] o0_sbid0;
	reg[C_FIFO_IDX_WIDTH-1:0] o0_sbid1;
	reg                    o0_new;
	reg[C_MH_WIDTH     :0] o0_ydiff;
	reg[C_MW_WIDTH     :0] o0_xdiff;
	reg                    o0_user;
	reg                    o0_last;

	//wire rd_en;
	//assign rd_en = (r_valid && c_valid);
	always @ (posedge clk) begin
		if (frm_resetn == 1'b0)
			o0_valid <= 0;
		else if (pipe_en) begin
			o0_valid <= r_valid && c_valid;
			o0_new   <= c_snew;
			o0_sbid0 <= r_sbid0;
			o0_sbid1 <= r_sbid1;
			if (r_sbid0 == r_sbid1)
				o0_ydiff <= 0;
			else
				o0_ydiff <= r_sc - r_mc;
			/// fix xdiff for first pixel, indeed also for last pixel
			if (c_sidx0 == c_sidx1)
				o0_xdiff <= 0;
			else
				o0_xdiff <= c_sc - c_mc;
			o0_user <= (r_mfirst && c_mfirst);
			o0_last <= c_mlast;
		end
	end

	///////////////////////////// 1 ////////////////////////////////////////
	reg                    o1_valid;
	reg[C_PIXEL_WIDTH-1:0] o1_00;
	reg[C_PIXEL_WIDTH-1:0] o1_01;
	reg[C_PIXEL_WIDTH-1:0] o1_10;
	reg[C_PIXEL_WIDTH-1:0] o1_11;
	reg [2:0]              o1_yid;
	reg [2:0]              o1_xid;
	wire[3:0]              o1_ycmp;
	wire[3:0]              o1_xcmp;
	reg                    o1_user;
	reg                    o1_last;
generate
	for (i = 0; i < 4; i=i+1) begin: single_cmp
		assign o1_ycmp[i] = (o0_ydiff <= y_spliter[i]);
		assign o1_xcmp[i] = (o0_xdiff <= x_spliter[i]);
	end
endgenerate
	always @ (posedge clk) begin
		if (frm_resetn == 1'b0) begin
			o1_valid <= 0;
		end
		else if (pipe_en) begin
			o1_valid <= o0_valid;
			if (o0_new) begin
				o1_00 <= o1_01;
				o1_01 <= rd_data[o0_sbid0];
				o1_10 <= o1_11;
				o1_11 <= rd_data[o0_sbid1];
			end
			case (o1_ycmp)
			4'b1111: o1_yid <= 0;
			4'b1110: o1_yid <= 1;
			4'b1100: o1_yid <= 2;
			4'b1000: o1_yid <= 3;
			default: o1_yid <= 4;	/// 0000
			endcase
			case (o1_xcmp)
			4'b1111: o1_xid <= 0;
			4'b1110: o1_xid <= 1;
			4'b1100: o1_xid <= 2;
			4'b1000: o1_xid <= 3;
			default: o1_xid <= 4;	/// 0000
			endcase
			o1_user <= o0_user;
			o1_last <= o0_last;
		end
	end

	///////////////////////////// 2 ////////////////////////////////////////
	reg                    o2_valid;
	reg[C_PIXEL_WIDTH-1:0] o2_xinterp0;
	reg[C_PIXEL_WIDTH-1:0] o2_xinterp1;
	reg[2:0]               o2_yid;
	reg                    o2_user;
	reg                    o2_last;
	always @ (posedge clk) begin
		if (frm_resetn == 1'b0) begin
			o2_valid <= 0;
		end
		else if (pipe_en) begin
			o2_valid <= o1_valid;
			case (o1_xid)
			0: begin
				o2_xinterp0 <= o1_01;
				o2_xinterp1 <= o1_11;
			end
			1: begin
				o2_xinterp0 <= (o1_01 * 3 + o1_00) / 4;
				o2_xinterp1 <= (o1_11 * 3 + o1_10) / 4;
			end
			2: begin
				o2_xinterp0 <= (o1_01 + o1_00) / 2;
				o2_xinterp1 <= (o1_11 + o1_10) / 2;
			end
			3: begin
				o2_xinterp0 <= (o1_01 + o1_00 * 3) / 4;
				o2_xinterp1 <= (o1_11 + o1_10 * 3) / 4;
			end
			default: begin
				o2_xinterp0 <= o1_00;
				o2_xinterp1 <= o1_10;
			end
			endcase
			o2_yid <= o1_yid;
			o2_user  <= o1_user;
			o2_last  <= o1_last;
		end
	end

	///////////////////////////// 3 ////////////////////////////////////////
	always @ (posedge clk) begin
		if (frm_resetn == 1'b0)
			m_axis_tvalid <= 0;
		else if (pipe_en) begin
			m_axis_tvalid <= o2_valid;
			case (o2_yid)
			0:	m_axis_tdata <= o2_xinterp1;
			1:	m_axis_tdata <= (o2_xinterp1 * 3 + o2_xinterp0) / 4;
			2:	m_axis_tdata <= (o2_xinterp1     + o2_xinterp0) / 2;
			3:	m_axis_tdata <= (o2_xinterp1 + o2_xinterp0 * 3) / 4;
			default:m_axis_tdata <= o2_xinterp0;
			endcase
			m_axis_tuser <= o2_user;
			m_axis_tlast <= o2_last;
		end
	end
endmodule
