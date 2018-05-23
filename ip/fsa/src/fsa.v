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
	parameter integer BR_DW    = 32
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
	output wire [C_IMG_WW-1:0]      lft_header_x    ,
	output wire [C_IMG_WW-1:0]      lft_corner_top_x,
	output wire [C_IMG_HW-1:0]      lft_corner_top_y,
	output wire [C_IMG_WW-1:0]      lft_corner_bot_x,
	output wire [C_IMG_HW-1:0]      lft_corner_bot_y,
	output wire                     rt_valid ,
	output wire [C_IMG_WW-1:0]      rt_edge  ,
	output wire [C_IMG_WW-1:0]      rt_header_x    ,
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
			.BR_AW(BR_AW),
			.BR_DW(BR_DW)
		) fsa_stream_inst (
			.clk(clk),
			.resetn(m_axis_resetn),

			.height(height),
			.width(width),
			.rd_sof(r_sof_stream),
			.rd_en(rd_en_p1[RD_NUM-2]),
			.rd_addr(rd_addr_p1[RD_NUM-2]),
			.rd_data(rd_data_f[RD_NUM-2]),
			.lft_valid       (lft_valid),
			.lft_edge        (lft_edge ),
			.rt_valid        (rt_valid ),
			.rt_edge         (rt_edge  ),
			.lft_header_x    (lft_header_x    ),
			.lft_corner_top_x(lft_corner_top_x),
			.lft_corner_top_y(lft_corner_top_y),
			.lft_corner_bot_x(lft_corner_bot_x),
			.lft_corner_bot_y(lft_corner_bot_y),
			.rt_header_x     (rt_header_x     ),
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

	fsa_core # (
		.C_PIXEL_WIDTH (C_PIXEL_WIDTH),
		.C_IMG_HW (C_IMG_HW),
		.C_IMG_WW (C_IMG_WW),
		.BR_DW    (BR_DW   ),
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
		.wr_data(wr_wdata),

		.rd_en  (wr_ren  ),
		.rd_addr(wr_raddr),
		.rd_data(wr_rdata),

		.ref_data(ref_data),
		.ana_done(ana_done),
		.res_lft_valid(lft_valid),
		.res_lft_edge (lft_edge ),
		.res_rt_valid (rt_valid ),
		.res_rt_edge  (rt_edge  ),
		.res_lft_header_x    (lft_header_x    ),
		.res_lft_corner_top_x(lft_corner_top_x),
		.res_lft_corner_top_y(lft_corner_top_y),
		.res_lft_corner_bot_x(lft_corner_bot_x),
		.res_lft_corner_bot_y(lft_corner_bot_y),
		.res_rt_header_x     (rt_header_x     ),
		.res_rt_corner_top_x (rt_corner_top_x ),
		.res_rt_corner_top_y (rt_corner_top_y ),
		.res_rt_corner_bot_x (rt_corner_bot_x ),
		.res_rt_corner_bot_y (rt_corner_bot_y ),

		.s_axis_tvalid(s_axis_tvalid),
		.s_axis_tdata (s_axis_tdata ),
		.s_axis_tuser (s_axis_tuser ),
		.s_axis_tlast (s_axis_tlast ),
		.s_axis_tready(s_axis_tready)
	);
endmodule
