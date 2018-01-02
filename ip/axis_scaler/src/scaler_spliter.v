module scaler_spliter # (
	parameter integer C_S_WIDTH = 12,
	parameter integer C_M_WIDTH = 12,
	parameter integer C_S_BMP   = 0 ,
	parameter integer C_S_BID   = 0 ,
	parameter integer C_S_IDX   = 0 ,	/// C_S_WIDTH or 0
	parameter integer C_SPLIT_ID_WIDTH = 2,
	parameter integer C_TEST    = 0
) (
	input wire clk,
	input wire resetn,

	input [C_S_WIDTH-1:0] s_nbr,
	input [C_M_WIDTH-1:0] m_nbr,

	input wire enable,

	input  wire                                       i_valid         ,
	input  wire                                       i_s_advance     ,
	input  wire                                       i_s_last        ,
	input  wire [C_S_WIDTH + C_M_WIDTH        :0]     i_s_c           ,
	input  wire [C_S_BMP + C_S_BID + C_S_IDX - 1 : 0] i_s_bmp_bid_idx0,
	input  wire [C_S_BMP + C_S_BID + C_S_IDX - 1 : 0] i_s_bmp_bid_idx1,
	input  wire [C_S_BMP + C_S_BID + C_S_IDX - 1 : 0] i_s_bmp_bid_idx2,
	input  wire                                       i_m_advance     ,
	input  wire                                       i_m_first       ,
	input  wire                                       i_m_last        ,
	input  wire [C_S_WIDTH + C_M_WIDTH        :0]     i_m_c           ,
	input  wire                                       i_a_last        ,
	input  wire                                       i_d_valid       ,

	output wire                                       o_valid         ,
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

	localparam integer C_SPLITERN = (1 << C_SPLIT_ID_WIDTH);
///////////////////////////////////// spliter //////////////////////////////////
	reg[C_M_WIDTH:0]   spliter[C_SPLITERN-1:0];
	always @ (posedge clk) begin
		spliter[0] <= (m_nbr * 1 + m_nbr * 0) / 4;
		spliter[1] <= (m_nbr * 2 + m_nbr * 1) / 4;
		spliter[2] <= (m_nbr * 4 + m_nbr * 1) / 4;
		spliter[3] <= (m_nbr * 8 - m_nbr * 1) / 4;
	end

///////////////////////////////////// input ////////////////////////////////////
	wire input_same01;
generate
if (C_S_BID) begin
	wire [C_S_BID-1:0] bid0;
	wire [C_S_BID-1:0] bid1;
	assign bid0 = i_s_bmp_bid_idx0[C_S_BID+C_S_IDX-1:C_S_IDX];
	assign bid1 = i_s_bmp_bid_idx1[C_S_BID+C_S_IDX-1:C_S_IDX];
	assign input_same01 = (bid0 == bid1);
end
else if (C_S_BMP) begin
	wire [C_S_BMP-1:0] bmp0;
	wire [C_S_BMP-1:0] bmp1;
	assign bmp0 = i_s_bmp_bid_idx0[C_S_BMP+C_S_BID+C_S_IDX-1:C_S_BID+C_S_IDX];
	assign bmp1 = i_s_bmp_bid_idx1[C_S_BMP+C_S_BID+C_S_IDX-1:C_S_BID+C_S_IDX];
	assign input_same01 = (bmp0 == bmp1);
end
else if (C_S_IDX) begin
	wire [C_S_WIDTH-1:0] idx0;
	wire [C_S_WIDTH-1:0] idx1;
	assign idx0 = i_s_bmp_bid_idx0[C_S_IDX-1:0];
	assign idx1 = i_s_bmp_bid_idx1[C_S_IDX-1:0];
	assign input_same01 = (idx0 == idx1);
end
else begin
	assign input_same01 = 1;
end
endgenerate

////////////////////////////////////// delay 0 /////////////////////////////////
	reg                                         dly0_valid         ;
	reg                                         dly0_s_advance     ;
	reg                                         dly0_s_last        ;
	reg [C_S_BMP + C_S_BID + C_S_WIDTH - 1 : 0] dly0_s_bmp_bid_idx0;
	reg [C_S_BMP + C_S_BID + C_S_WIDTH - 1 : 0] dly0_s_bmp_bid_idx1;
	reg [C_S_BMP + C_S_BID + C_S_WIDTH - 1 : 0] dly0_s_bmp_bid_idx2;
	reg                                         dly0_m_advance     ;
	reg                                         dly0_m_first       ;
	reg                                         dly0_m_last        ;
	reg                                         dly0_a_last        ;
	reg                                         dly0_d_valid       ;
	reg [C_M_WIDTH     :0]                      dly0_diff          ;

	always @ (posedge clk) begin
		if (resetn == 1'b0)
			dly0_valid          <= 0               ;
		else if (enable) begin
			dly0_valid          <= i_valid         ;
			dly0_s_advance      <= i_s_advance     ;
			dly0_s_last         <= i_s_last        ;
			dly0_s_bmp_bid_idx0 <= i_s_bmp_bid_idx0;
			dly0_s_bmp_bid_idx1 <= i_s_bmp_bid_idx1;
			dly0_s_bmp_bid_idx2 <= i_s_bmp_bid_idx2;
			dly0_m_advance      <= i_m_advance     ;
			dly0_m_first        <= i_m_first       ;
			dly0_m_last         <= i_m_last        ;
			dly0_a_last         <= i_a_last        ;
			dly0_d_valid        <= i_d_valid       ;
			dly0_diff           <= (input_same01 ? 0 : (i_s_c - i_m_c));
		end
	end

	wire[C_SPLITERN-1:0]                        dly0_cmp           ;
generate
genvar i;
for (i = 0; i < C_SPLITERN; i=i+1) begin: single_cmp
	assign dly0_cmp[i] = (dly0_diff <= spliter[i]);
end
endgenerate

////////////////////////////////////// delay 1 /////////////////////////////////
	reg                                         dly1_valid         ;
	reg                                         dly1_s_advance     ;
	reg                                         dly1_s_last        ;
	reg [C_S_BMP + C_S_BID + C_S_WIDTH - 1 : 0] dly1_s_bmp_bid_idx0;
	reg [C_S_BMP + C_S_BID + C_S_WIDTH - 1 : 0] dly1_s_bmp_bid_idx1;
	reg [C_S_BMP + C_S_BID + C_S_WIDTH - 1 : 0] dly1_s_bmp_bid_idx2;
	reg                                         dly1_m_advance     ;
	reg                                         dly1_m_first       ;
	reg                                         dly1_m_last        ;
	reg                                         dly1_a_last        ;
	reg                                         dly1_d_valid       ;
	reg [C_SPLIT_ID_WIDTH : 0]                  dly1_split_id      ;


	always @ (posedge clk) begin
		if (resetn == 1'b0)
			dly1_valid          <= 0                  ;
		else if (enable) begin
			dly1_valid          <= dly0_valid         ;
			dly1_s_advance      <= dly0_s_advance     ;
			dly1_s_last         <= dly0_s_last        ;
			dly1_s_bmp_bid_idx0 <= dly0_s_bmp_bid_idx0;
			dly1_s_bmp_bid_idx1 <= dly0_s_bmp_bid_idx1;
			dly1_s_bmp_bid_idx2 <= dly0_s_bmp_bid_idx2;
			dly1_m_advance      <= dly0_m_advance     ;
			dly1_m_first        <= dly0_m_first       ;
			dly1_m_last         <= dly0_m_last        ;
			dly1_a_last         <= dly0_a_last        ;
			dly1_d_valid        <= dly0_d_valid       ;

			case (dly0_cmp)
			4'b1111: dly1_split_id <= 0;
			4'b1110: dly1_split_id <= 1;
			4'b1100: dly1_split_id <= 2;
			4'b1000: dly1_split_id <= 3;
			default: dly1_split_id <= 4;
			endcase
		end
	end

	assign o_valid          = dly1_valid         ;
	assign o_s_advance      = dly1_s_advance     ;
	assign o_s_last         = dly1_s_last        ;
	assign o_s_bmp_bid_idx0 = dly1_s_bmp_bid_idx0;
	assign o_s_bmp_bid_idx1 = dly1_s_bmp_bid_idx1;
	assign o_s_bmp_bid_idx2 = dly1_s_bmp_bid_idx2;
	assign o_m_advance      = dly1_m_advance     ;
	assign o_m_first        = dly1_m_first       ;
	assign o_m_last         = dly1_m_last        ;
	assign o_a_last         = dly1_a_last        ;
	assign o_d_valid        = dly1_d_valid       ;
	assign o_split_id       = dly1_split_id      ;

endmodule
