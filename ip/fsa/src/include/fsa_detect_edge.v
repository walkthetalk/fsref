
module fsa_detect_edge #(
	parameter integer C_PIXEL_WIDTH = 8,
	parameter integer C_IMG_HW = 12,
	parameter integer C_IMG_WW = 12,
	parameter integer BR_NUM   = 4,
	parameter integer BR_AW    = 12	/// same as C_IMG_WW
)(
	input	clk,
	input	resetn,

	input  wire                wr_sof_d3   ,
	input  wire                rd_en_d3    ,
	input  wire                hM2_p3      ,
	input  wire                hM3_p3      ,
	input  wire                hfirst_p3   ,
	input  wire                hlast_p3    ,
	input  wire                wfirst_p3   ,
	input  wire                wlast_p3    ,
	input  wire [BR_AW-1:0]    x_d3        ,
	input  wire                rd_val_outer_p3,
	input  wire [C_IMG_HW-1:0] rd_top_outer_p3,
	input  wire [C_IMG_HW-1:0] rd_bot_outer_p3,
	input  wire                rd_val_inner_p3,
	input  wire [C_IMG_HW-1:0] rd_top_inner_p3,
	input  wire [C_IMG_HW-1:0] rd_bot_inner_p3,

	output wire                     ana_done,
	output reg                      res_lft_valid       ,
	output reg  [C_IMG_WW-1:0]      res_lft_edge        ,
	output reg                      res_lft_header_outer_valid,
	output reg  [C_IMG_WW-1:0]      res_lft_header_outer_x    ,
	output reg  [C_IMG_WW-1:0]      res_lft_header_outer_y    ,
	output reg                      res_lft_corner_valid,
	output reg  [C_IMG_WW-1:0]      res_lft_corner_top_x,
	output reg  [C_IMG_HW-1:0]      res_lft_corner_top_y,
	output reg  [C_IMG_WW-1:0]      res_lft_corner_bot_x,
	output reg  [C_IMG_HW-1:0]      res_lft_corner_bot_y,
	output reg                      res_rt_valid        ,
	output reg  [C_IMG_WW-1:0]      res_rt_edge         ,
	output reg                      res_rt_header_outer_valid ,
	output reg  [C_IMG_WW-1:0]      res_rt_header_outer_x     ,
	output reg  [C_IMG_WW-1:0]      res_rt_header_outer_y     ,
	output reg                      res_rt_corner_valid ,
	output reg  [C_IMG_WW-1:0]      res_rt_corner_top_x ,
	output reg  [C_IMG_HW-1:0]      res_rt_corner_top_y ,
	output reg  [C_IMG_WW-1:0]      res_rt_corner_bot_x ,
	output reg  [C_IMG_HW-1:0]      res_rt_corner_bot_y ,

	output reg                      res_lft_header_inner_valid,
	output reg  [C_IMG_WW-1:0]      res_lft_header_inner_x    ,
	output reg  [C_IMG_WW-1:0]      res_lft_header_inner_y    ,
	output reg                      res_rt_header_inner_valid ,
	output reg  [C_IMG_WW-1:0]      res_rt_header_inner_x     ,
	output reg  [C_IMG_WW-1:0]      res_rt_header_inner_y
);
	reg wr_sof_d4;
	always @ (posedge clk) begin
		if (resetn == 1'b0)
			wr_sof_d4 <= 0;
		else
			wr_sof_d4 <= wr_sof_d3;
	end
	/////////////////////////////////////////////////////////// preprocess

	reg rd_en_d4;
	reg hM2_p4;
	reg hM3_p4;
	reg hlast_p4;
	reg wfirst_p4;
	reg wlast_p4;
	reg [C_IMG_WW-1:0] x_d4;
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			rd_en_d4  <= 1'b0;
			hM2_p4    <= 1'b0;
			hM3_p4    <= 1'b0;
			hlast_p4  <= 1'b0;
			wfirst_p4 <= 1'b0;
			wlast_p4  <= 1'b0;
			x_d4      <= 0;
		end
		else begin
			rd_en_d4  <= rd_en_d3;
			hM2_p4    <= hM2_p3;
			hM3_p4    <= hM3_p3;
			hlast_p4  <= hlast_p3;
			wfirst_p4 <= wfirst_p3;
			wlast_p4  <= wlast_p3;
			x_d4      <= x_d3;
		end
	end


	/////////////////////////////////////////////////////////// detect edge
	reg               lft_found;
	reg               lft_valid_p4;
	reg[C_IMG_WW-1:0] lft_edge_p4;
	reg               rt_found;
	reg               rt_valid_p4;
	reg[C_IMG_WW-1:0] rt_edge_p4;
	always @ (posedge clk) begin
		if (resetn == 1'b0 || hfirst_p3 == 1'b1) begin
			lft_found    <= 0;
			lft_valid_p4 <= 0;
			lft_edge_p4  <= 0;
		end
		else if (rd_en_d3 && hM3_p3) begin
			if (~lft_found && rd_val_outer_p3)
				lft_edge_p4 <= x_d3;
			if (~rd_val_outer_p3)
				lft_found <= 1;
			if (wfirst_p3 && rd_val_outer_p3)
				lft_valid_p4 <= 1;
		end
	end
	always @ (posedge clk) begin
		if (resetn == 1'b0 || hfirst_p3 == 1'b1) begin
			rt_found    <= 0;
			rt_valid_p4 <= 0;
			rt_edge_p4  <= 0;
		end
		else if (rd_en_d3 && hM3_p3) begin
			rt_found <= rd_val_outer_p3;
			if (~rt_found)
				rt_edge_p4 <= x_d3;
			if (wlast_p3 && rd_val_outer_p3)
				rt_valid_p4 <= 1'b1;
		end
	end

	/////////////////////////////////////////////////////////////////
	wire                rd_val_outer_p4;
	wire [C_IMG_HW-1:0] rd_top_outer_p4;
	wire [C_IMG_HW-1:0] rd_bot_outer_p4;

	wire                lft_header_outer_valid;
	wire [C_IMG_WW-1:0] lft_header_outer_x;
	wire [C_IMG_WW-1:0] lft_header_outer_y;
	wire                rt_header_outer_valid;
	wire [C_IMG_WW-1:0] rt_header_outer_x;
	wire [C_IMG_WW-1:0] rt_header_outer_y;

	fsa_detect_header # (
		.C_IMG_HW(C_IMG_HW),
		.C_IMG_WW(C_IMG_WW)
	) outer_header_detector (
		.clk(clk),
		.resetn(resetn),

		.rd_en_d3    (rd_en_d3    ),
		.hM3_p3      (hM3_p3      ),
		.wfirst_p3   (wfirst_p3   ),
		.wlast_p3    (wlast_p3    ),
		.rd_en_d4    (rd_en_d4    ),
		.hM1_p4      (hlast_p4    ),
		.hM2_p4      (hM2_p4      ),
		.hM3_p4      (hM3_p4      ),
		.x_d4        (x_d4        ),
		.lft_edge_p4 (lft_edge_p4 ),
		.rt_edge_p4  (rt_edge_p4  ),

		.rd_val_p3 (rd_val_outer_p3 ),
		.rd_top_p3 (rd_top_outer_p3 ),
		.rd_bot_p3 (rd_bot_outer_p3 ),

		.rd_val_p4 (rd_val_outer_p4 ),
		.rd_top_p4 (rd_top_outer_p4 ),
		.rd_bot_p4 (rd_bot_outer_p4 ),
		.lft_header_valid(lft_header_outer_valid),
		.lft_header_x    (lft_header_outer_x    ),
		.lft_header_y    (lft_header_outer_y    ),
		.rt_header_valid (rt_header_outer_valid ),
		.rt_header_x     (rt_header_outer_x     ),
		.rt_header_y     (rt_header_outer_y     )
	);

	wire                lft_header_inner_valid;
	wire [C_IMG_WW-1:0] lft_header_inner_x;
	wire [C_IMG_WW-1:0] lft_header_inner_y;
	wire                rt_header_inner_valid;
	wire [C_IMG_WW-1:0] rt_header_inner_x;
	wire [C_IMG_WW-1:0] rt_header_inner_y;

	fsa_detect_header # (
		.C_IMG_HW(C_IMG_HW),
		.C_IMG_WW(C_IMG_WW)
	) inner_header_detector (
		.clk(clk),
		.resetn(resetn),

		.rd_en_d3    (rd_en_d3    ),
		.hM3_p3      (hM3_p3      ),
		.wfirst_p3   (wfirst_p3   ),
		.wlast_p3    (wlast_p3    ),
		.rd_en_d4    (rd_en_d4    ),
		.hM1_p4      (hlast_p4    ),
		.hM2_p4      (hM2_p4      ),
		.hM3_p4      (hM3_p4      ),
		.x_d4        (x_d4        ),
		.lft_edge_p4 (lft_edge_p4 ),
		.rt_edge_p4  (rt_edge_p4  ),

		.rd_val_p3 (rd_val_inner_p3 ),
		.rd_top_p3 (rd_top_inner_p3 ),
		.rd_bot_p3 (rd_bot_inner_p3 ),

		.rd_val_p4 (/*rd_val_inner_p4*/),
		.rd_top_p4 (/*rd_top_inner_p4*/),
		.rd_bot_p4 (/*rd_bot_inner_p4*/),
		.lft_header_valid(lft_header_inner_valid),
		.lft_header_x    (lft_header_inner_x    ),
		.lft_header_y    (lft_header_inner_y    ),
		.rt_header_valid (rt_header_inner_valid ),
		.rt_header_x     (rt_header_inner_x     ),
		.rt_header_y     (rt_header_inner_y     )
	);

	///////////////////////////////////////////////////////////////// Hlast

	///////////////////////// left
	reg                lft_is_header_x ;
	reg                lft_bt_header_x ;

	reg                lft_corner_found;
	reg [C_IMG_HW-1:0] lft_corner_top_y;
	reg [C_IMG_WW-1:0] lft_corner_top_x;
	reg [C_IMG_HW-1:0] lft_corner_bot_y;
	reg [C_IMG_WW-1:0] lft_corner_bot_x;
	always @ (posedge clk) begin
		if (resetn == 1'b0 || hM2_p4 == 1'b1) begin
			lft_is_header_x    <= 0;
			lft_bt_header_x    <= 0;

			lft_corner_found   <= 1'b0;
			lft_corner_top_y   <= 0;
			lft_corner_bot_y   <= 0;
			lft_corner_top_x   <= 0;
			lft_corner_bot_x   <= 0;
		end
		else if (rd_en_d4 && hlast_p4) begin
			lft_is_header_x    <= (x_d4 + 1 == lft_header_outer_x);
			if (lft_is_header_x)
				lft_bt_header_x <= 1'b1;

			if (~rd_val_outer_p4) begin
				lft_corner_found <= lft_header_outer_valid;
			end
			if (~lft_corner_found && rd_val_outer_p4) begin
				if (/*x_d4 == lft_header_outer_x*/lft_is_header_x) begin
					lft_corner_top_x <= x_d4;
					lft_corner_top_y <= rd_top_outer_p4;
					lft_corner_bot_x <= x_d4;
					lft_corner_bot_y <= rd_bot_outer_p4;
				end
				else if (/*x_d4 > lft_header_outer_x*/lft_bt_header_x) begin
					if (rd_top_outer_p4 <= lft_corner_top_y) begin
						lft_corner_top_x <= x_d4;
						lft_corner_top_y <= rd_top_outer_p4;
					end
					if (rd_bot_outer_p4 >= lft_corner_bot_y) begin
						lft_corner_bot_x <= x_d4;
						lft_corner_bot_y <= rd_bot_outer_p4;
					end
				end
			end
		end
	end

	/////////////////// right
	reg                rt_bt_header   ;
	reg                rt_corner_found;
	reg [C_IMG_HW-1:0] rt_corner_top_y;
	reg [C_IMG_WW-1:0] rt_corner_top_x;
	reg [C_IMG_HW-1:0] rt_corner_bot_y;
	reg [C_IMG_WW-1:0] rt_corner_bot_x;
	always @ (posedge clk) begin
		if (resetn == 1'b0 || hlast_p4 == 1'b0) begin
			rt_bt_header      <= 1'b0;
			rt_corner_found   <= 1'b0;
			rt_corner_top_y   <= 0;
			rt_corner_bot_y   <= 0;
			rt_corner_top_x   <= 0;
			rt_corner_bot_x   <= 0;
		end
		else if (rd_en_d4) begin
			if (x_d4 == rt_header_outer_x)
				rt_bt_header <= 1'b1;

			rt_corner_found <= rd_val_outer_p4 && rt_header_outer_valid;
			if (~rt_corner_found) begin
				rt_corner_top_x <= x_d4;
				rt_corner_top_y <= rd_top_outer_p4;
				rt_corner_bot_x <= x_d4;
				rt_corner_bot_y <= rd_bot_outer_p4;
			end
			else if (/*x_d4 <= rt_header_outer_x*/~rt_bt_header) begin
				if (rd_top_outer_p4 < rt_corner_top_y) begin
					rt_corner_top_x <= x_d4;
					rt_corner_top_y <= rd_top_outer_p4;
				end
				if (rd_bot_outer_p4 > rt_corner_bot_y) begin
					rt_corner_bot_x <= x_d4;
					rt_corner_bot_y <= rd_bot_outer_p4;
				end
			end
		end
	end

	/////////////////////////////////////////////////////////////////// final
	/// delay 5
	reg wr_sof_d5;
	always @ (posedge clk) begin
		if (resetn == 1'b0)
			wr_sof_d5 <= 0;
		else
			wr_sof_d5 <= wr_sof_d4;
	end

	reg lft_valid_p5;
	reg[C_IMG_WW-1:0] lft_edge_p5;
	reg rt_valid_p5;
	reg[C_IMG_WW-1:0] rt_edge_p5;
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			lft_valid_p5 <= 0;
			lft_edge_p5  <= 0;
			rt_valid_p5  <= 0;
			rt_edge_p5   <= 0;
		end
		else begin
			lft_valid_p5 <= lft_valid_p4 ;
			lft_edge_p5  <= lft_edge_p4  ;
			rt_valid_p5  <= rt_valid_p4  ;
			rt_edge_p5   <= rt_edge_p4   ;
		end
	end

	/// delay 6
	reg wr_sof_d6;
	always @ (posedge clk) begin
		if (resetn == 1'b0)
			wr_sof_d6 <= 0;
		else
			wr_sof_d6 <= wr_sof_d5;
	end
	assign ana_done = wr_sof_d6;
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			res_lft_edge  <= 0;
			res_lft_valid <= 0;
			res_rt_edge   <= 0;
			res_rt_valid  <= 0;
			res_lft_corner_top_x <= 0;
			res_lft_corner_top_y <= 0;
			res_lft_corner_bot_x <= 0;
			res_lft_corner_bot_y <= 0;
			res_rt_corner_top_x  <= 0;
			res_rt_corner_top_y  <= 0;
			res_rt_corner_bot_x  <= 0;
			res_rt_corner_bot_y  <= 0;
			res_lft_header_outer_valid <= 0;
			res_lft_header_outer_x     <= 0;
			res_lft_header_outer_y     <= 0;
			res_rt_header_outer_valid  <= 0;
			res_rt_header_outer_x      <= 0;
			res_rt_header_outer_y      <= 0;
			res_lft_header_inner_valid <= 0;
			res_lft_header_inner_x     <= 0;
			res_lft_header_inner_y     <= 0;
			res_rt_header_inner_valid  <= 0;
			res_rt_header_inner_x      <= 0;
			res_rt_header_inner_y      <= 0;
		end
		else if (wr_sof_d5) begin
			res_lft_edge  <= lft_edge_p5 ;
			res_lft_valid <= lft_valid_p5;
			res_rt_edge   <= rt_edge_p5  ;
			res_rt_valid  <= rt_valid_p5 ;

			res_lft_header_outer_valid <= lft_header_outer_valid ;
			res_lft_header_outer_x     <= lft_header_outer_x     ;
			res_lft_header_outer_y     <= lft_header_outer_y     ;
			res_lft_corner_valid       <= lft_corner_found       ;
			res_lft_corner_top_x       <= lft_corner_top_x       ;
			res_lft_corner_top_y       <= lft_corner_top_y       ;
			res_lft_corner_bot_x       <= lft_corner_bot_x       ;
			res_lft_corner_bot_y       <= lft_corner_bot_y       ;
			res_rt_header_outer_valid  <= rt_header_outer_valid  ;
			res_rt_header_outer_x      <= rt_header_outer_x      ;
			res_rt_header_outer_y      <= rt_header_outer_y      ;
			res_rt_corner_valid        <= rt_corner_found        ;
			res_rt_corner_top_x        <= rt_corner_top_x        ;
			res_rt_corner_top_y        <= rt_corner_top_y        ;
			res_rt_corner_bot_x        <= rt_corner_bot_x        ;
			res_rt_corner_bot_y        <= rt_corner_bot_y        ;

			res_lft_header_inner_valid <= lft_header_inner_valid ;
			res_lft_header_inner_x     <= lft_header_inner_x     ;
			res_lft_header_inner_y     <= lft_header_inner_y     ;
			res_rt_header_inner_valid  <= rt_header_inner_valid  ;
			res_rt_header_inner_x      <= rt_header_inner_x      ;
			res_rt_header_inner_y      <= rt_header_inner_y      ;
		end
	end
endmodule
