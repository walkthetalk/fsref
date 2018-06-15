`timescale 1ns / 1ps

module fsa #(
	parameter integer C_TEST = 0,
	parameter integer C_OUT_DW = 1,
	parameter integer C_OUT_DV = 1,
	parameter integer C_PIXEL_WIDTH = 8,
	parameter integer C_IMG_HW = 12,
	parameter integer C_IMG_WW = 12,
	parameter integer BR_NUM   = 4,
	parameter integer BR_AW    = 12,	/// same as C_IMG_WW
	parameter integer BR_DW    = 51		/// C_IMG_HW * 4 + 1
)(
	input	clk,
	input	resetn,

	input  wire [C_IMG_HW-1:0]      height  ,
	input  wire [C_IMG_WW-1:0]      width   ,

	input  wire r_sof  ,
	input  wire r_en   ,
	input  wire [BR_AW-1:0] r_addr ,
	output wire [BR_DW-1:0] r_data ,

	input  wire [C_PIXEL_WIDTH-1:0] ref_data,
	output wire                     ana_done,
	output wire                     lft_valid,
	output wire [C_IMG_WW-1:0]      lft_edge ,
	output wire                     lft_header_outer_valid,
	output wire [C_IMG_WW-1:0]      lft_header_outer_x    ,
	output wire                     lft_corner_valid,
	output wire [C_IMG_WW-1:0]      lft_corner_top_x,
	output wire [C_IMG_HW-1:0]      lft_corner_top_y,
	output wire [C_IMG_WW-1:0]      lft_corner_bot_x,
	output wire [C_IMG_HW-1:0]      lft_corner_bot_y,
	output wire                     rt_valid ,
	output wire [C_IMG_WW-1:0]      rt_edge  ,
	output wire                     rt_header_outer_valid,
	output wire [C_IMG_WW-1:0]      rt_header_outer_x    ,
	output wire                     rt_corner_valid,
	output wire [C_IMG_WW-1:0]      rt_corner_top_x,
	output wire [C_IMG_HW-1:0]      rt_corner_top_y,
	output wire [C_IMG_WW-1:0]      rt_corner_bot_x,
	output wire [C_IMG_HW-1:0]      rt_corner_bot_y,

	input  wire                     s_axis_tvalid,
	input  wire [C_PIXEL_WIDTH-1:0] s_axis_tdata,
	input  wire                     s_axis_tuser,
	input  wire                     s_axis_tlast,
	output wire                     s_axis_tready,

	input  wire                       m_axis_fsync,
	input  wire                       m_axis_resetn,

	output wire                       m_axis_tvalid,
	output wire [C_TEST+C_OUT_DW-1:0] m_axis_tdata,
	output wire                       m_axis_tuser,
	output wire                       m_axis_tlast,
	input  wire                       m_axis_tready
);
	localparam integer RD_OUT_STREAM = (C_OUT_DW > 0 ? 1 : 0);
	localparam integer RD_NUM = 1 + 1 + RD_OUT_STREAM;

	localparam integer BOT_OL = 0;
	localparam integer BOT_OH = BOT_OL + C_IMG_HW - 1;
	localparam integer TOP_OL = BOT_OH + 1;
	localparam integer TOP_OH = TOP_OL + C_IMG_HW - 1;
	localparam integer VAL_OL = TOP_OH + 1;
	localparam integer VAL_OH = VAL_OL;

	localparam integer BOT_IL = VAL_OH + 1;
	localparam integer BOT_IH = BOT_IL + C_IMG_HW - 1;
	localparam integer TOP_IL = BOT_IH + 1;
	localparam integer TOP_IH = TOP_IL + C_IMG_HW - 1;
	localparam integer VAL_IL = TOP_IH + 1;
	localparam integer VAL_IH = VAL_IL;

	localparam integer BLACK_L = VAL_IH + 1;
	localparam integer BLACK_H = BLACK_L;

	/// block ram for speed data
	wire              wr_sof;
	wire [BR_NUM-1:0] wr_bmp;
	wire [BR_NUM-1:0] wr_wen;
	wire [BR_AW-1:0]  wr_waddr;
	wire [BR_DW-1:0]  wr_wdata;
	wire              wr_ren;
	wire [BR_AW-1:0]  wr_raddr;
	wire [BR_DW-1:0]  wr_rdata;

	wire [BR_NUM-1:0]   rd_bmp    [RD_NUM-1:0];

	wire                rd_en_p1  [RD_NUM-1:0];
	wire [BR_AW-1:0]    rd_addr_p1[RD_NUM-1:0];

	reg                 rd_en    [BR_NUM-1:0];
	reg  [BR_AW-1:0]    rd_addr  [BR_NUM-1:0];

	reg                 rd_en_d1 [BR_NUM-1:0];
	wire [BR_DW-1:0]    rd_data  [BR_NUM-1:0];

	reg  [BR_DW-1:0]    rd_data_f[RD_NUM-1:0];

	genvar i;
	integer j;
generate
	for (i = 0; i < BR_NUM; i=i+1) begin
		block_ram # (
			.C_DATA_WIDTH(BR_DW),
			.C_ADDRESS_WIDTH(BR_AW)
		) fsa_ppinfo (
			.clk(clk),
			.wr_en  (wr_wen[i]),
			.wr_addr(wr_waddr ),
			.wr_data(wr_wdata ),
			.rd_en  (rd_en[i] ),
			.rd_addr(rd_addr[i]),
			.rd_data(rd_data[i])
		);
		always @ (posedge clk) begin
			for (j=0; j < RD_NUM; j=j+1) begin
				if (rd_en_p1[j] && rd_bmp[j][i]) begin
					rd_en  [i] <= 1'b1;
					rd_addr[i] <= rd_addr_p1[j];
				end
			end
			rd_en_d1[i] <= rd_en[i];
		end
	end

	for (i = 0; i < RD_NUM; i=i+1) begin
		always @ (posedge clk) begin
			if (resetn == 1'b0)
				rd_data_f [i] <= 1'b0;
			else begin
				case (rd_bmp[i])
				1: rd_data_f [i] <= rd_data[0];
				2: rd_data_f [i] <= rd_data[1];
				4: rd_data_f [i] <= rd_data[2];
				8: rd_data_f [i] <= rd_data[3];
				default: rd_data_f [i] <= 0;
				endcase
			end
		end
	end

	assign rd_en_p1[0] = r_en;
	assign rd_addr_p1[0] = r_addr;
	assign r_data = rd_data_f[0];
endgenerate
	assign rd_en_p1  [RD_NUM-1] = wr_ren    ;
	assign rd_addr_p1[RD_NUM-1] = wr_raddr  ;

	assign wr_rdata = rd_data_f[RD_NUM-1];


	wire r_sof_stream;
	wire [BR_NUM-1:0] r_bmp_stream;
	mutex_buffer # (
		.C_BUFF_NUM(BR_NUM)
	) mutex_buffer_controller (
		.clk   (clk   ),
		.resetn(resetn),

		.wr_done(),

		.w_sof(wr_sof),
		.w_bmp(wr_bmp),

		.r0_sof(r_sof),
		.r0_bmp(rd_bmp[0]),

		.r1_sof(r_sof_stream),
		.r1_bmp(r_bmp_stream)
	);
	assign rd_bmp[RD_NUM-1] = wr_bmp;

generate
	if (C_OUT_DW <= 0) begin
		assign r_sof_stream = 0;
	end
	else begin
		assign rd_bmp[RD_NUM-2] = r_bmp_stream;
		fsa_stream # (
			.C_TEST(C_TEST),
			.C_OUT_DW(C_OUT_DW),
			.C_OUT_DV(C_OUT_DV),
			.C_IMG_HW(C_IMG_HW),
			.C_IMG_WW(C_IMG_WW),
			.BR_AW(BR_AW)
		) fsa_stream_inst (
			.clk(clk),
			.resetn(m_axis_resetn),

			.height(height),
			.width(width),
			.rd_sof(r_sof_stream),
			.rd_en(rd_en_p1[RD_NUM-2]),
			.rd_addr(rd_addr_p1[RD_NUM-2]),
			.rd_black    (rd_data_f[RD_NUM-2][BLACK_H:BLACK_L]),
			.rd_val_outer(rd_data_f[RD_NUM-2][VAL_OH : VAL_OL]),
			.rd_top_outer(rd_data_f[RD_NUM-2][TOP_OH : TOP_OL]),
			.rd_bot_outer(rd_data_f[RD_NUM-2][BOT_OH : BOT_OL]),
			.rd_val_inner(rd_data_f[RD_NUM-2][VAL_IH : VAL_IL]),
			.rd_top_inner(rd_data_f[RD_NUM-2][TOP_IH : TOP_IL]),
			.rd_bot_inner(rd_data_f[RD_NUM-2][BOT_IH : BOT_IL]),
			.lft_valid       (lft_valid),
			.lft_edge        (lft_edge ),
			.rt_valid        (rt_valid ),
			.rt_edge         (rt_edge  ),
			.lft_header_outer_valid(lft_header_outer_valid),
			.lft_header_outer_x    (lft_header_outer_x    ),
			.lft_corner_valid(lft_corner_valid),
			.lft_corner_top_x(lft_corner_top_x),
			.lft_corner_top_y(lft_corner_top_y),
			.lft_corner_bot_x(lft_corner_bot_x),
			.lft_corner_bot_y(lft_corner_bot_y),
			.rt_header_outer_valid (rt_header_outer_valid ),
			.rt_header_outer_x     (rt_header_outer_x     ),
			.rt_corner_valid (rt_corner_valid ),
			.rt_corner_top_x (rt_corner_top_x ),
			.rt_corner_top_y (rt_corner_top_y ),
			.rt_corner_bot_x (rt_corner_bot_x ),
			.rt_corner_bot_y (rt_corner_bot_y ),

			.fsync(m_axis_fsync),
			.m_axis_tvalid(m_axis_tvalid),
			.m_axis_tdata (m_axis_tdata ),
			.m_axis_tuser (m_axis_tuser ),
			.m_axis_tlast (m_axis_tlast ),
			.m_axis_tready(m_axis_tready)
		);
	end
endgenerate

	wire                fsaic_wr_sof_d3   ;
	wire                fsaic_rd_en_d3    ;
	wire                fsaic_hM2_p3      ;
	wire                fsaic_hM3_p3      ;
	wire                fsaic_hfirst_p3   ;
	wire                fsaic_hlast_p3    ;
	wire                fsaic_wfirst_p3   ;
	wire                fsaic_wlast_p3    ;
	wire [BR_AW-1:0]    fsaic_x_d3        ;
	wire                fsaic_rd_val_outer;
	wire [C_IMG_HW-1:0] fsaic_rd_top_outer;
	wire [C_IMG_HW-1:0] fsaic_rd_bot_outer;

	fsa_core # (
		.C_PIXEL_WIDTH (C_PIXEL_WIDTH),
		.C_IMG_HW (C_IMG_HW),
		.C_IMG_WW (C_IMG_WW),
		.BR_NUM   (BR_NUM  ),
		.BR_AW    (BR_AW   )	/// same as C_IMG_WW
	) algo (
		.clk(clk),
		.resetn(resetn),

		.height(height),
		.width (width),

		.sof   (wr_sof),
		.wr_bmp(wr_bmp),

		.wr_en  (wr_wen),
		.wr_addr(wr_waddr),
		.wr_black    (wr_wdata[BLACK_H:BLACK_L]),
		.wr_val_outer(wr_wdata[VAL_OH : VAL_OL]),
		.wr_top_outer(wr_wdata[TOP_OH : TOP_OL]),
		.wr_bot_outer(wr_wdata[BOT_OH : BOT_OL]),
		.wr_val_inner(wr_wdata[VAL_IH : VAL_IL]),
		.wr_top_inner(wr_wdata[TOP_IH : TOP_IL]),
		.wr_bot_inner(wr_wdata[BOT_IH : BOT_IL]),

		.rd_en  (wr_ren  ),
		.rd_addr(wr_raddr),
		.rd_black    (wr_rdata[BLACK_H:BLACK_L]),
		.rd_val_outer(wr_rdata[VAL_OH : VAL_OL]),
		.rd_top_outer(wr_rdata[TOP_OH : TOP_OL]),
		.rd_bot_outer(wr_rdata[BOT_OH : BOT_OL]),
		.rd_val_inner(wr_rdata[VAL_IH : VAL_IL]),
		.rd_top_inner(wr_rdata[TOP_IH : TOP_IL]),
		.rd_bot_inner(wr_rdata[BOT_IH : BOT_IL]),

		.ref_data(ref_data),

		.s_axis_tvalid(s_axis_tvalid),
		.s_axis_tdata (s_axis_tdata ),
		.s_axis_tuser (s_axis_tuser ),
		.s_axis_tlast (s_axis_tlast ),
		.s_axis_tready(s_axis_tready),

		.o_wr_sof_d3   (fsaic_wr_sof_d3   ),
		.o_rd_en_d3    (fsaic_rd_en_d3    ),
		.o_hM2_p3      (fsaic_hM2_p3      ),
		.o_hM3_p3      (fsaic_hM3_p3      ),
		.o_hfirst_p3   (fsaic_hfirst_p3   ),
		.o_hlast_p3    (fsaic_hlast_p3    ),
		.o_wfirst_p3   (fsaic_wfirst_p3   ),
		.o_wlast_p3    (fsaic_wlast_p3    ),
		.o_x_d3        (fsaic_x_d3        ),
		.o_rd_val_outer(fsaic_rd_val_outer),
		.o_rd_top_outer(fsaic_rd_top_outer),
		.o_rd_bot_outer(fsaic_rd_bot_outer)
	);

	fsa_detect_edge # (
		.C_PIXEL_WIDTH (C_PIXEL_WIDTH),
		.C_IMG_HW (C_IMG_HW),
		.C_IMG_WW (C_IMG_WW),
		.BR_NUM   (BR_NUM  ),
		.BR_AW    (BR_AW   )	/// same as C_IMG_WW
	) edge_detector (
		.clk(clk),
		.resetn(resetn),

		.wr_sof_d3   (fsaic_wr_sof_d3   ),
		.rd_en_d3    (fsaic_rd_en_d3    ),
		.hM2_p3      (fsaic_hM2_p3      ),
		.hM3_p3      (fsaic_hM3_p3      ),
		.hfirst_p3   (fsaic_hfirst_p3   ),
		.hlast_p3    (fsaic_hlast_p3    ),
		.wfirst_p3   (fsaic_wfirst_p3   ),
		.wlast_p3    (fsaic_wlast_p3    ),
		.x_d3        (fsaic_x_d3        ),
		.rd_val_outer_p3(fsaic_rd_val_outer),
		.rd_top_outer_p3(fsaic_rd_top_outer),
		.rd_bot_outer_p3(fsaic_rd_bot_outer),

		.ana_done(ana_done),
		.res_lft_valid(lft_valid),
		.res_lft_edge (lft_edge ),
		.res_rt_valid (rt_valid ),
		.res_rt_edge  (rt_edge  ),
		.res_lft_header_outer_valid(lft_header_outer_valid),
		.res_lft_header_outer_x    (lft_header_outer_x    ),
		.res_lft_corner_valid(lft_corner_valid),
		.res_lft_corner_top_x(lft_corner_top_x),
		.res_lft_corner_top_y(lft_corner_top_y),
		.res_lft_corner_bot_x(lft_corner_bot_x),
		.res_lft_corner_bot_y(lft_corner_bot_y),
		.res_rt_header_outer_valid (rt_header_outer_valid ),
		.res_rt_header_outer_x     (rt_header_outer_x     ),
		.res_rt_corner_valid (rt_corner_valid),
		.res_rt_corner_top_x (rt_corner_top_x ),
		.res_rt_corner_top_y (rt_corner_top_y ),
		.res_rt_corner_bot_x (rt_corner_bot_x ),
		.res_rt_corner_bot_y (rt_corner_bot_y )
	);
endmodule
