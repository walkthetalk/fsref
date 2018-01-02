`timescale 1ns / 1ps

`include "./linebuffer.v"
`include "./scaler_2d.v"

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
	parameter integer C_OUT_RELAY = 1
) (
	input  wire clk,
	input  wire resetn,
	input  wire fsync,

	input  wire [C_SW_WIDTH-1 : 0]  s_width ,
	input  wire [C_SH_WIDTH-1 : 0]  s_height,
	input  wire [C_MW_WIDTH-1 : 0]  m_width ,
	input  wire [C_MH_WIDTH-1 : 0]  m_height,

	input  wire                     s_axis_tvalid,
	input  wire [C_PIXEL_WIDTH-1:0] s_axis_tdata,
	input  wire                     s_axis_tuser,
	input  wire                     s_axis_tlast,
	output reg                      s_axis_tready,

	output wire                     m_axis_tvalid,
	output wire [C_PIXEL_WIDTH-1:0] m_axis_tdata,
	output wire                     m_axis_tuser,
	output wire                     m_axis_tlast,
	input  wire                     m_axis_tready
);

	reg en_transmit;
	always @ (posedge clk) begin
		if (resetn == 1'b0)
			en_transmit <= 0;
		else if (fsync)
			en_transmit <= 1;
	end
	wire frm_resetn;
	assign frm_resetn = (en_transmit && ~fsync);

	localparam  C_FIFO_IDX_WIDTH = 2;
	localparam  C_FIFO_NUM = 2**C_FIFO_IDX_WIDTH;
	localparam  C_S_BMP    = C_FIFO_NUM;
	localparam  C_S_BID    = C_FIFO_IDX_WIDTH;
	localparam  C_SPLIT_ID_WIDTH = 2;

	reg  [C_FIFO_NUM-1:0]    fifo_full;
	wire snext;
	assign snext = s_axis_tvalid && s_axis_tready;
	wire slast;
	assign slast = snext && s_axis_tlast;

//////////////////////////////////////// algo //////////////////////////////////
	wire                        algo_valid     ;
	wire                        algo_ready     ;
	wire                        algo_d_valid   ;
	wire                        algo_tuser     ;
	wire                        algo_tlast     ;
	wire [C_SPLIT_ID_WIDTH : 0] algo_r_split_id;
	wire [C_SPLIT_ID_WIDTH : 0] algo_c_split_id;
	wire [C_S_BMP-1 : 0]        algo_r_bmp0    ;
	wire [C_S_BMP-1 : 0]        algo_r_bmp1    ;
	wire [C_S_BID-1 : 0]        algo_r_bid0    ;
	wire [C_S_BID-1 : 0]        algo_r_bid1    ;
	wire                        algo_r_update0 ;
	wire [C_SW_WIDTH-1 : 0]     algo_c_idx0    ;
	wire [C_SW_WIDTH-1 : 0]     algo_c_idx1    ;
	wire                        algo_c_new1    ;

	scaler_2d # (
		.C_SH_WIDTH       (C_SH_WIDTH      ),
		.C_SW_WIDTH       (C_SW_WIDTH      ),
		.C_MH_WIDTH       (C_MH_WIDTH      ),
		.C_MW_WIDTH       (C_MW_WIDTH      ),
		.C_LINE_BMP       (C_S_BMP         ),
		.C_LINE_BID       (C_S_BID         ),
		.C_SPLIT_ID_WIDTH (C_SPLIT_ID_WIDTH)
	) scaler_algo (
		.clk      (clk   ),
		.resetn   (frm_resetn),

		.s_width  (s_width ),
		.s_height (s_height),
		.m_width  (m_width ),
		.m_height (m_height),

		.o_valid     (algo_valid     ),
		.i_ready     (algo_ready     ),
		.o_d_valid   (algo_d_valid   ),
		.o_tuser     (algo_tuser     ),
		.o_tlast     (algo_tlast     ),
		.o_r_split_id(algo_r_split_id),
		.o_c_split_id(algo_c_split_id),
		.o_r_bmp0    (algo_r_bmp0    ),
		.o_r_bmp1    (algo_r_bmp1    ),
		.o_r_bid0    (algo_r_bid0    ),
		.o_r_bid1    (algo_r_bid1    ),
		.o_r_update0 (algo_r_update0 ),
		.o_c_idx0    (algo_c_idx0    ),
		.o_c_idx1    (algo_c_idx1    ),
		.o_c_new1    (algo_c_new1    )
	);

////////////////////////////////////// fifo ////////////////////////////////////
	reg  [C_FIFO_NUM-1:0]    wr_act     ;
	reg  [C_FIFO_NUM-1:0]    wr_act_next;
	reg  [C_FIFO_NUM-1:0]    wr_en      ;
	reg  [C_SW_WIDTH-1:0]    wr_idx     ;
	reg  [C_PIXEL_WIDTH-1:0] wr_data    ;
	reg                      wr_last    ;

	wire [C_PIXEL_WIDTH-1:0] rd_data[C_FIFO_NUM-1:0];

	always @ (posedge clk) begin
		if (frm_resetn == 1'b0)
			wr_idx <= 0;
		else if (wr_en)
			wr_idx <= (wr_last ? 0 : wr_idx + 1);
	end
	always @ (posedge clk) begin
		if (frm_resetn == 1'b0) begin
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

			.w0(wr_en[i]   ),
			.a0(wr_idx     ),
			.d0(wr_data    ),
			.r1(algo_valid && algo_ready),
			.a1(algo_c_idx1),
			.q1(rd_data[i] )
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
			else if (algo_r_update0 && algo_r_bmp0[i])
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
	reg                      o_valid;
	reg  [C_PIXEL_WIDTH-1:0] o_data ;
	reg                      o_user ;
	reg                      o_last ;
	wire                     o_ready;

	wire pipe_en;
	assign pipe_en = (~o_valid || o_ready);

	wire line_valid;
	assign line_valid = ((algo_r_bmp1 & fifo_full) != 0);
	assign algo_ready = (line_valid && pipe_en);

	///////////////////////////// 0 ////////////////////////////////////////
	reg                       o0_valid ;
	reg[C_FIFO_IDX_WIDTH-1:0] o0_sbid0 ;
	reg[C_FIFO_IDX_WIDTH-1:0] o0_sbid1 ;
	reg[C_SPLIT_ID_WIDTH  :0] o0_yid ;
	reg[C_SPLIT_ID_WIDTH  :0] o0_xid ;
	reg                       o0_user  ;
	reg                       o0_last  ;
	reg                       o0_new   ;

	//wire rd_en;
	//assign rd_en = (r_valid && c_valid);
	always @ (posedge clk) begin
		if (frm_resetn == 1'b0)
			o0_valid <= 0;
		else if (pipe_en) begin
			o0_valid  <= line_valid && algo_d_valid   ;
			o0_sbid0  <= algo_r_bid0    ;
			o0_sbid1  <= algo_r_bid1    ;
			o0_yid    <= algo_r_split_id;
			o0_xid    <= algo_c_split_id;
			o0_user   <= algo_tuser     ;
			o0_last   <= algo_tlast     ;
			o0_new    <= algo_c_new1    ;
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
	reg                    o1_user;
	reg                    o1_last;
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
			o1_yid <= o0_yid;
			o1_xid <= o0_xid;
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
			o_valid <= 0;
		else if (pipe_en) begin
			o_valid <= o2_valid;
			case (o2_yid)
			0:	o_data <= o2_xinterp1;
			1:	o_data <= (o2_xinterp1 * 3 + o2_xinterp0    ) / 4;
			2:	o_data <= (o2_xinterp1     + o2_xinterp0    ) / 2;
			3:	o_data <= (o2_xinterp1     + o2_xinterp0 * 3) / 4;
			default:o_data <= o2_xinterp0;
			endcase
			o_user <= o2_user;
			o_last <= o2_last;
		end
	end

	///////////////////////////// out //////////////////////////////////////
	scaler_relay # (
		.C_DATA_WIDTH(C_PIXEL_WIDTH + 2),
		.C_PASSTHROUGH(C_OUT_RELAY == 0)
	) relay (
		.clk      (clk   ),
		.resetn   (frm_resetn),

		.s_valid(o_valid),
		.s_data ({
			o_data,
			o_last,
			o_user
		}),
		.s_ready(o_ready),

		.m_valid(m_axis_tvalid),
		.m_data ({
			m_axis_tdata,
			m_axis_tlast,
			m_axis_tuser
		}),
		.m_ready(m_axis_tready)
	);
endmodule
