`include "./scaler_core.v"
`include "./scaler_spliter.v"
`include "./scaler_relay.v"
/**
 * scaler for single dimension
 */
module scaler_1d # (
	parameter integer C_S_WIDTH  = 12,
	parameter integer C_M_WIDTH  = 12,
	parameter integer C_S_BMP    = 4 ,
	parameter integer C_S_BID    = 2 ,
	parameter integer C_S_IDX    = 0 , /// C_S_WIDTH or 0
	parameter integer C_SPLIT_ID_WIDTH = 2
) (
	input wire clk,
	input wire resetn,

	input [C_S_WIDTH-1:0] s_nbr,
	input [C_M_WIDTH-1:0] m_nbr,

	output wire                                       o_valid         ,
	input  wire                                       i_ready         ,

	output wire                                       o_s_advance     ,
	output wire                                       o_s_last        ,
	output wire [C_S_BMP + C_S_BID + C_S_IDX - 1 : 0] o_s_bmp_bid_idx0,
	output wire [C_S_BMP + C_S_BID + C_S_IDX - 1 : 0] o_s_bmp_bid_idx1,
	output wire [C_S_BMP + C_S_BID + C_S_IDX - 1 : 0] o_s_bmp_bid_idx2,
	output wire                                       o_m_advance     ,
	output wire                                       o_m_first       ,
	output wire                                       o_m_last        ,
	output wire                                       o_a_last        ,
	output wire                                       o_d_valid       ,
	output wire [C_SPLIT_ID_WIDTH : 0]                o_split_id
);

/////////////////////////////  row  ////////////////////////////////////////////
	wire                                       sd_algo_enable              ;

	wire                                       sd_core2split_o_valid       ;
	wire                                       sd_core2split_s_advance     ;
	wire                                       sd_core2split_s_last        ;
	wire [C_S_WIDTH + C_M_WIDTH : 0]           sd_core2split_s_c           ;
	wire [C_S_BMP + C_S_BID + C_S_IDX - 1 : 0] sd_core2split_s_bmp_bid_idx0;
	wire [C_S_BMP + C_S_BID + C_S_IDX - 1 : 0] sd_core2split_s_bmp_bid_idx1;
	wire [C_S_BMP + C_S_BID + C_S_IDX - 1 : 0] sd_core2split_s_bmp_bid_idx2;
	wire                                       sd_core2split_m_advance     ;
	wire                                       sd_core2split_m_first       ;
	wire                                       sd_core2split_m_last        ;
	wire [C_S_WIDTH + C_M_WIDTH : 0]           sd_core2split_m_c           ;
	wire                                       sd_core2split_a_last        ;
	wire                                       sd_core2split_d_valid       ;

	scaler_core # (
		.C_S_WIDTH (C_S_WIDTH),
		.C_M_WIDTH (C_M_WIDTH),
		.C_S_BMP   (C_S_BMP  ),
		.C_S_BID   (C_S_BID  ),
		.C_S_IDX   (C_S_IDX  )
	) sd_core (
		.clk      (clk   ),
		.resetn   (resetn),

		.s_nbr    (s_nbr),
		.m_nbr    (m_nbr),

		.enable        (sd_algo_enable              ),
		.o_valid       (sd_core2split_o_valid       ),
		.s_advance     (sd_core2split_s_advance     ),
		.s_last        (sd_core2split_s_last        ),
		.s_c           (sd_core2split_s_c           ),
		.s_bmp_bid_idx0(sd_core2split_s_bmp_bid_idx0),
		.s_bmp_bid_idx1(sd_core2split_s_bmp_bid_idx1),
		.s_bmp_bid_idx2(sd_core2split_s_bmp_bid_idx2),
		.m_advance     (sd_core2split_m_advance     ),
		.m_first       (sd_core2split_m_first       ),
		.m_last        (sd_core2split_m_last        ),
		.m_c           (sd_core2split_m_c           ),
		.a_last        (sd_core2split_a_last        ),
		.d_valid       (sd_core2split_d_valid       )
	);

	wire                                       sd_split2relay_valid         ;
	wire                                       sd_split2relay_s_advance     ;
	wire                                       sd_split2relay_s_last        ;
	wire [C_S_BMP + C_S_BID + C_S_IDX - 1 : 0] sd_split2relay_s_bmp_bid_idx0;
	wire [C_S_BMP + C_S_BID + C_S_IDX - 1 : 0] sd_split2relay_s_bmp_bid_idx1;
	wire [C_S_BMP + C_S_BID + C_S_IDX - 1 : 0] sd_split2relay_s_bmp_bid_idx2;
	wire                                       sd_split2relay_m_advance     ;
	wire                                       sd_split2relay_m_first       ;
	wire                                       sd_split2relay_m_last        ;
	wire                                       sd_split2relay_a_last        ;
	wire                                       sd_split2relay_d_valid       ;
	wire [C_SPLIT_ID_WIDTH : 0]                sd_split2relay_split_id      ;
	scaler_spliter # (
		.C_S_WIDTH        (C_S_WIDTH       ),
		.C_M_WIDTH        (C_M_WIDTH       ),
		.C_S_BMP          (C_S_BMP         ),
		.C_S_BID          (C_S_BID         ),
		.C_S_IDX          (C_S_IDX         ),
		.C_SPLIT_ID_WIDTH (C_SPLIT_ID_WIDTH)
	) sd_spliter (
		.clk      (clk   ),
		.resetn   (resetn),

		.s_nbr    (s_nbr),
		.m_nbr    (m_nbr),

		.enable          (sd_algo_enable               ),
		.i_valid         (sd_core2split_o_valid        ),
		.i_s_advance     (sd_core2split_s_advance      ),
		.i_s_last        (sd_core2split_s_last         ),
		.i_s_c           (sd_core2split_s_c            ),
		.i_s_bmp_bid_idx0(sd_core2split_s_bmp_bid_idx0 ),
		.i_s_bmp_bid_idx1(sd_core2split_s_bmp_bid_idx1 ),
		.i_s_bmp_bid_idx2(sd_core2split_s_bmp_bid_idx2 ),
		.i_m_advance     (sd_core2split_m_advance      ),
		.i_m_first       (sd_core2split_m_first        ),
		.i_m_last        (sd_core2split_m_last         ),
		.i_m_c           (sd_core2split_m_c            ),
		.i_a_last        (sd_core2split_a_last         ),
		.i_d_valid       (sd_core2split_d_valid        ),

		.o_valid         (sd_split2relay_valid         ),
		.o_s_advance     (sd_split2relay_s_advance     ),
		.o_s_last        (sd_split2relay_s_last        ),
		.o_s_bmp_bid_idx0(sd_split2relay_s_bmp_bid_idx0),
		.o_s_bmp_bid_idx1(sd_split2relay_s_bmp_bid_idx1),
		.o_s_bmp_bid_idx2(sd_split2relay_s_bmp_bid_idx2),
		.o_m_advance     (sd_split2relay_m_advance     ),
		.o_m_first       (sd_split2relay_m_first       ),
		.o_m_last        (sd_split2relay_m_last        ),
		.o_a_last        (sd_split2relay_a_last        ),
		.o_d_valid       (sd_split2relay_d_valid       ),
		.o_split_id      (sd_split2relay_split_id      )
	);

	localparam integer C_DATA_WIDTH = (7
			+ (C_S_BMP + C_S_BID + C_S_IDX) * 3
			+ (C_SPLIT_ID_WIDTH + 1));
	scaler_relay # (
		.C_DATA_WIDTH(C_DATA_WIDTH)
	) relay (
		.clk      (clk   ),
		.resetn   (resetn),

		.s_valid(sd_split2relay_valid),
		.s_data ({
			sd_split2relay_s_advance     ,
			sd_split2relay_s_last        ,
			sd_split2relay_s_bmp_bid_idx0,
			sd_split2relay_s_bmp_bid_idx1,
			sd_split2relay_s_bmp_bid_idx2,
			sd_split2relay_m_advance     ,
			sd_split2relay_m_first       ,
			sd_split2relay_m_last        ,
			sd_split2relay_a_last        ,
			sd_split2relay_d_valid       ,
			sd_split2relay_split_id
		}),
		.s_ready(sd_algo_enable),

		.m_valid(o_valid),
		.m_data ({
			o_s_advance     ,
			o_s_last        ,
			o_s_bmp_bid_idx0,
			o_s_bmp_bid_idx1,
			o_s_bmp_bid_idx2,
			o_m_advance     ,
			o_m_first       ,
			o_m_last        ,
			o_a_last        ,
			o_d_valid       ,
			o_split_id
		}),
		.m_ready(i_ready)
	);

endmodule
