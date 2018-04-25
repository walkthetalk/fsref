`timescale 1ns / 1ps

`include "./block_ram.v"
`include "./mutex_buffer.v"
`include "./fsa_core.v"

module fsa #(
	parameter integer C_PIXEL_WIDTH = 8,
	parameter integer C_IMG_HW = 12,
	parameter integer C_IMG_WW = 12,
	parameter integer C_READER_NUM = 2,
	parameter integer BR_NUM   = 4,		/// C_READER_NUM + 2
	parameter integer BR_AW    = 12,	/// same as C_IMG_WW
	parameter integer BR_DW    = 32
)(
	input	clk,
	input	resetn,

	input  wire [C_IMG_HW-1:0]      height  ,
	input  wire [C_IMG_WW-1:0]      width   ,

	input  wire [1     *C_READER_NUM-1:0] r_sof  ,
	input  wire [1     *C_READER_NUM-1:0] r_en   ,
	input  wire [BR_AW *C_READER_NUM-1:0] r_addr ,
	output wire [BR_DW *C_READER_NUM-1:0] r_data ,

	input  wire [C_PIXEL_WIDTH-1:0] ref_data,
	output wire [C_IMG_WW-1:0]      lft_v   ,
	output wire [C_IMG_WW-1:0]      rt_v    ,

	input  wire                     s_axis_tvalid,
	input  wire [C_PIXEL_WIDTH-1:0] s_axis_tdata,
	input  wire                     s_axis_tuser,
	input  wire                     s_axis_tlast,
	output wire                     s_axis_tready
);
	localparam integer RD_NUM = BR_NUM - 2 + 1;

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
		) speed_data (
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

	for (i = 0; i < C_READER_NUM; i=i+1) begin
		assign rd_en_p1[i] = r_en[i];
		assign rd_addr_p1[i] = r_addr[BR_AW*(i+1)-1: BR_AW*i];
		assign r_data[BR_DW*(i+1)-1:BR_DW*i] = rd_data_f[i];
	end
endgenerate
	assign rd_en_p1  [2] = wr_ren    ;
	assign rd_addr_p1[2] = wr_raddr  ;

	assign wr_rdata = rd_data_f[2];


	mutex_buffer # (
		.C_BUFF_NUM(BR_NUM)
	) mutex_buffer_controller (
		.clk   (clk   ),
		.resetn(resetn),

		.wr_done(),

		.w_sof(wr_sof),
		.w_bmp(wr_bmp),

		.r0_sof(r0_sof),
		.r0_bmp(rd_bmp[0]),

		.r1_sof(r1_sof),
		.r1_bmp(rd_bmp[1])
	);
	assign rd_bmp[2] = wr_bmp;

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
		.lft_v   (lft_v   ),
		.rt_v    (rt_v    ),

		.s_axis_tvalid(s_axis_tvalid),
		.s_axis_tdata (s_axis_tdata ),
		.s_axis_tuser (s_axis_tuser ),
		.s_axis_tlast (s_axis_tlast ),
		.s_axis_tready(s_axis_tready)
	);
endmodule
