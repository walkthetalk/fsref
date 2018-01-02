`include "./scaler_1d.v"
/**
 * scaler for single dimension
 */
module scaler_2d # (
	parameter integer C_SH_WIDTH    = 10,
	parameter integer C_SW_WIDTH    = 10,
	parameter integer C_MH_WIDTH    = 10,
	parameter integer C_MW_WIDTH    = 10,
	parameter integer C_LINE_BMP    = 4 ,
	parameter integer C_LINE_BID    = 2 ,
	parameter integer C_LINE_IDX    = 0 ,	/// 0 or C_SH_WIDTH
	parameter integer C_SPLIT_ID_WIDTH = 2
) (
	input wire clk,
	input wire resetn,

	input  wire [C_SW_WIDTH-1 : 0]  s_width,
	input  wire [C_SH_WIDTH-1 : 0]  s_height,

	input  wire [C_MW_WIDTH-1 : 0]  m_width,
	input  wire [C_MH_WIDTH-1 : 0]  m_height,

	output wire                        o_valid     ,
	input  wire                        i_ready     ,
	output wire                        o_d_valid   ,
	output wire                        o_tuser     ,
	output wire                        o_tlast     ,
	output wire [C_SPLIT_ID_WIDTH : 0] o_r_split_id,
	output wire [C_SPLIT_ID_WIDTH : 0] o_c_split_id,
	output wire [C_LINE_BMP-1 : 0]     o_r_bmp0    ,
	output wire [C_LINE_BMP-1 : 0]     o_r_bmp1    ,
	output wire [C_LINE_BID-1 : 0]     o_r_bid0    ,
	output wire [C_LINE_BID-1 : 0]     o_r_bid1    ,
	output wire                        o_r_update0 ,
	output wire [C_SW_WIDTH-1 : 0]     o_c_idx0    ,
	output wire [C_SW_WIDTH-1 : 0]     o_c_idx1    ,
	output wire                        o_c_new1

);
	wire                             algo_enable       ;

	wire                             row_valid         ;
	wire                             row_ready         ;
	wire                             row_s_advance     ;
	wire                             row_s_last        ;
	wire [C_LINE_BMP + C_LINE_BID - 1 : 0] row_s_bmp_bid_idx0;
	wire [C_LINE_BMP + C_LINE_BID - 1 : 0] row_s_bmp_bid_idx1;
	wire [C_LINE_BMP + C_LINE_BID - 1 : 0] row_s_bmp_bid_idx2;
	wire                             row_m_advance     ;
	wire                             row_m_first       ;
	wire                             row_m_last        ;
	wire                             row_a_last        ;
	wire                             row_d_valid       ;
	wire [C_SPLIT_ID_WIDTH : 0]      row_split_id      ;

	assign row_ready = algo_enable && (~row_d_valid || col_a_last);

	wire                             col_valid         ;
	wire                             col_ready         ;
	wire                             col_s_advance     ;
	wire                             col_s_last        ;
	wire [C_SW_WIDTH - 1 : 0]        col_s_bmp_bid_idx0;
	wire [C_SW_WIDTH - 1 : 0]        col_s_bmp_bid_idx1;
	wire [C_SW_WIDTH - 1 : 0]        col_s_bmp_bid_idx2;
	wire                             col_m_advance     ;
	wire                             col_m_first       ;
	wire                             col_m_last        ;
	wire                             col_a_last        ;
	wire                             col_d_valid       ;
	wire [C_SPLIT_ID_WIDTH : 0]      col_split_id      ;

	assign col_ready = algo_enable && row_d_valid;

	scaler_1d # (
		.C_S_WIDTH  (C_SH_WIDTH),
		.C_M_WIDTH  (C_MH_WIDTH),
		.C_S_BMP    (C_LINE_BMP),
		.C_S_BID    (C_LINE_BID),
		.C_S_IDX    (0         ),
		.C_SPLIT_ID_WIDTH (C_SPLIT_ID_WIDTH)
	) row_scaler (
		.clk      (clk   ),
		.resetn   (resetn),

		.s_nbr    (s_height),
		.m_nbr    (m_height),

		.o_valid         (row_valid         ),
		.i_ready         (row_ready         ),
		.o_s_advance     (row_s_advance     ),
		.o_s_last        (row_s_last        ),
		.o_s_bmp_bid_idx0(row_s_bmp_bid_idx0),
		.o_s_bmp_bid_idx1(row_s_bmp_bid_idx1),
		.o_s_bmp_bid_idx2(row_s_bmp_bid_idx2),
		.o_m_advance     (row_m_advance     ),
		.o_m_first       (row_m_first       ),
		.o_m_last        (row_m_last        ),
		.o_a_last        (row_a_last        ),
		.o_d_valid       (row_d_valid       ),
		.o_split_id      (row_split_id      )
	);


	scaler_1d # (
		.C_S_WIDTH  (C_SW_WIDTH),
		.C_M_WIDTH  (C_MW_WIDTH),
		.C_S_BMP    (0         ),
		.C_S_BID    (0         ),
		.C_S_IDX    (C_SW_WIDTH),
		.C_SPLIT_ID_WIDTH (C_SPLIT_ID_WIDTH)
	) col_scaler (
		.clk      (clk   ),
		.resetn   (resetn),

		.s_nbr    (s_width),
		.m_nbr    (m_width),

		.o_valid         (col_valid         ),
		.i_ready         (col_ready         ),
		.o_s_advance     (col_s_advance     ),
		.o_s_last        (col_s_last        ),
		.o_s_bmp_bid_idx0(col_s_bmp_bid_idx0),
		.o_s_bmp_bid_idx1(col_s_bmp_bid_idx1),
		.o_s_bmp_bid_idx2(col_s_bmp_bid_idx2),
		.o_m_advance     (col_m_advance     ),
		.o_m_first       (col_m_first       ),
		.o_m_last        (col_m_last        ),
		.o_a_last        (col_a_last        ),
		.o_d_valid       (col_d_valid       ),
		.o_split_id      (col_split_id      )
	);

	wire                             rc_valid     ;
	wire                             rc_d_valid   ;
	wire                             rc_tuser     ;
	wire                             rc_tlast     ;
	wire [C_SPLIT_ID_WIDTH : 0]      rc_r_split_id;
	wire [C_SPLIT_ID_WIDTH : 0]      rc_c_split_id;
	wire [C_LINE_BMP-1 : 0]          rc_r_bmp0    ;
	wire [C_LINE_BMP-1 : 0]          rc_r_bmp1    ;
	wire [C_LINE_BID-1 : 0]          rc_r_bid0    ;
	wire [C_LINE_BID-1 : 0]          rc_r_bid1    ;
	wire                             rc_r_update0 ;
	wire [C_SW_WIDTH-1 : 0]          rc_c_idx0    ;
	wire [C_SW_WIDTH-1 : 0]          rc_c_idx1    ;
	reg                              rc_c_new1    ;

	assign rc_valid      = row_valid & col_valid       ;
	assign rc_d_valid    = row_d_valid & col_d_valid   ;
	assign rc_tuser      = row_m_first & col_m_first   ;
	assign rc_tlast      = col_m_last                  ;
	assign rc_r_split_id = row_split_id                ;
	assign rc_c_split_id = col_split_id                ;
	assign rc_r_bmp0     = row_s_bmp_bid_idx0[C_LINE_BMP+C_LINE_BID-1 : C_LINE_BID]       ;
	assign rc_r_bmp1     = row_s_bmp_bid_idx1[C_LINE_BMP+C_LINE_BID-1 : C_LINE_BID]       ;
	assign rc_r_bid0     = row_s_bmp_bid_idx0[C_LINE_BID-1            :          0]       ;
	assign rc_r_bid1     = row_s_bmp_bid_idx1[C_LINE_BID-1            :          0]       ;
	assign rc_r_update0  = row_ready && row_s_advance && (rc_r_bmp0 != rc_r_bmp1);
	assign rc_c_idx0     = col_s_bmp_bid_idx0                                    ;
	assign rc_c_idx1     = col_s_bmp_bid_idx1                                    ;
	always @ (posedge clk) begin
		if (resetn == 1'b0)
			rc_c_new1 <= 0;
		else if (~col_valid)
			rc_c_new1 <= 1'b1;
		else if (col_ready)
			rc_c_new1 <= col_s_advance;
	end

	localparam integer C_DATA_WIDTH = (5
			+ (C_SPLIT_ID_WIDTH+1) * 2
			+ (C_LINE_BMP + C_LINE_BID) * 2
			+ C_SW_WIDTH * 2);

	scaler_relay # (
		.C_DATA_WIDTH(C_DATA_WIDTH)
	) relay (
		.clk      (clk   ),
		.resetn   (resetn),

		.s_valid(rc_valid),
		.s_data ({
			rc_d_valid   ,
			rc_tuser     ,
			rc_tlast     ,
			rc_r_split_id,
			rc_c_split_id,
			rc_r_bmp0    ,
			rc_r_bmp1    ,
			rc_r_bid0    ,
			rc_r_bid1    ,
			rc_r_update0 ,
			rc_c_idx0    ,
			rc_c_idx1    ,
			rc_c_new1
		}),
		.s_ready(algo_enable),

		.m_valid(o_valid),
		.m_data ({
			o_d_valid   ,
			o_tuser     ,
			o_tlast     ,
			o_r_split_id,
			o_c_split_id,
			o_r_bmp0    ,
			o_r_bmp1    ,
			o_r_bid0    ,
			o_r_bid1    ,
			o_r_update0 ,
			o_c_idx0    ,
			o_c_idx1    ,
			o_c_new1
		}),
		.m_ready(i_ready)
	);

endmodule
