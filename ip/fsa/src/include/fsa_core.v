
module fsa_core #(
	parameter integer C_PIXEL_WIDTH = 8,
	parameter integer C_IMG_HW = 12,
	parameter integer C_IMG_WW = 12,
	parameter integer BR_NUM   = 4,
	parameter integer BR_AW    = 12	/// same as C_IMG_WW
)(
	input	clk,
	input	resetn,

	input  wire [C_IMG_HW-1:0]      height  ,
	input  wire [C_IMG_WW-1:0]      width   ,

	input  wire [C_IMG_WW-1:0]      win_left,
	input  wire [C_IMG_HW-1:0]      win_top,
	input  wire [C_IMG_WW-1:0]      win_width,
	input  wire [C_IMG_HW-1:0]      win_height,

	output wire                     sof     ,
	input  wire [BR_NUM-1:0]        wr_bmp  ,

	output reg  [BR_NUM-1:0]        wr_en   ,
	output reg  [BR_AW-1:0]         wr_addr ,
	output reg                      wr_black,
	output reg                      wr_val_outer,
	output reg  [C_IMG_HW-1:0]      wr_top_outer,
	output reg  [C_IMG_HW-1:0]      wr_bot_outer,
	output reg                      wr_val_inner,
	output reg  [C_IMG_HW-1:0]      wr_top_inner,
	output reg  [C_IMG_HW-1:0]      wr_bot_inner,

	output reg                      rd_en   ,
	output reg  [BR_AW-1:0]         rd_addr ,
	input  wire                     rd_black,
	input  wire                     rd_val_outer,
	input  wire [C_IMG_HW-1:0]      rd_top_outer,
	input  wire [C_IMG_HW-1:0]      rd_bot_outer,
	input  wire                     rd_val_inner,
	input  wire [C_IMG_HW-1:0]      rd_top_inner,
	input  wire [C_IMG_HW-1:0]      rd_bot_inner,

	input  wire [C_PIXEL_WIDTH-1:0] ref_data,

	input  wire                     s_axis_tvalid,
	input  wire [C_PIXEL_WIDTH-1:0] s_axis_tdata,
	input  wire                     s_axis_tuser,
	input  wire                     s_axis_tlast,
	output wire                     s_axis_tready,

	output wire                o_wr_sof_d3   ,
	output wire                o_rd_en_d3    ,
	output wire                o_hM2_p3      ,
	output wire                o_hM3_p3      ,
	output wire                o_hfirst_p3   ,
	output wire                o_hlast_p3    ,
	output wire                o_wfirst_p3   ,
	output wire                o_wlast_p3    ,
	output wire [BR_AW-1:0]    o_x_d3        ,
	output wire                o_rd_val_outer,
	output wire [C_IMG_HW-1:0] o_rd_top_outer,
	output wire [C_IMG_HW-1:0] o_rd_bot_outer,
	output wire                o_rd_val_inner,
	output wire [C_IMG_HW-1:0] o_rd_top_inner,
	output wire [C_IMG_HW-1:0] o_rd_bot_inner
);
	assign s_axis_tready = 1'b1;
	wire snext;
	assign snext = s_axis_tvalid & s_axis_tready;

	reg [C_IMG_WW-1:0] wleft;
	reg [C_IMG_WW-1:0] wright;
	reg [C_IMG_HW-1:0] htop;
	reg [C_IMG_HW-1:0] hbottom;
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			wleft <= 0;
			wright <= 0;
			htop <= 0;
			hbottom <= 0;
		end
		else if (snext && s_axis_tuser) begin
			wleft <= win_left;
			wright <= win_left + win_width;
			htop <= win_top;
			hbottom <= win_top + win_height;
		end
	end

	reg [C_PIXEL_WIDTH-1:0] tdata_p0;
	reg wfirst_p0;
	reg wlast_p0;
	reg hfirst_p0;
	reg [C_IMG_HW-1:0] y_p0;
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			rd_en       <= 0;
			rd_addr     <= 0;
			tdata_p0    <= 0;
			wfirst_p0   <= 0;
			wlast_p0    <= 0;
			hfirst_p0   <= 0;
			y_p0        <= 0;
		end
		else if (snext) begin
			rd_en       <= 1;
			if (s_axis_tuser || wlast_p0) begin
				wfirst_p0 <= 1;
				rd_addr <= 0;
			end
			else begin
				wfirst_p0 <= 0;
				rd_addr <= rd_addr + 1;
			end
			tdata_p0    <= s_axis_tdata;
			wlast_p0    <= s_axis_tlast;
			if (s_axis_tuser) begin
				y_p0 <= 0;
				hfirst_p0 <= 1;
			end
			else if (wlast_p0) begin
				y_p0 <= y_p0 + 1;
				hfirst_p0 <= 0;
			end
		end
		else begin
			rd_en <= 0;
		end
	end

	reg rd_en_d1;
	reg [BR_AW-1:0] x_d1;
	reg [C_PIXEL_WIDTH-1:0] tdata_p1;
	reg wfirst_p1;
	reg wlast_p1;
	reg hfirst_p1;
	reg hlast_p1;
	reg hM3_p1;	/// height minus 3
	reg hM2_p1;	/// height minus 2
	reg [C_IMG_HW-1:0] y_p1;
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			rd_en_d1    <= 0;
			x_d1        <= 0;
			tdata_p1    <= 0;
			wfirst_p1   <= 0;
			wlast_p1    <= 0;
			hfirst_p1   <= 0;
			hlast_p1    <= 0;
			hM2_p1      <= 0;
			hM3_p1      <= 0;
			y_p1        <= 0;
		end
		else begin
			rd_en_d1    <= rd_en;
			x_d1        <= rd_addr;
			tdata_p1    <= tdata_p0;
			wfirst_p1   <= (rd_addr == wleft);//wfirst_p0;
			wlast_p1    <= (rd_addr == wright-1);//wlast_p0;
			hfirst_p1   <= (y_p0 == htop);//hfirst_p0;
			hlast_p1    <= (y_p0 == hbottom-1);//(y_p0 == height-1);
			hM2_p1      <= (y_p0 == hbottom-2);//(y_p0 == height-2);
			hM3_p1      <= (y_p0 == hbottom-3);//(y_p0 == height-3);
			y_p1        <= y_p0;
		end
	end

	reg wlast_p1_d1;
	reg hlast_p1_d1;
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			wlast_p1_d1 <= 0;
			hlast_p1_d1 <= 0;
		end
		else begin
			wlast_p1_d1 <= wlast_p1;
			hlast_p1_d1 <= hlast_p1;
		end
	end

	// @note width window valid
	reg w_valid_p2;
	reg h_valid_p2;
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			w_valid_p2 <= 0;
			h_valid_p2 <= 0;
		end
		else begin
			if (wfirst_p1)
				w_valid_p2 <= 1;
			else if (wlast_p1_d1)
				w_valid_p2 <= 0;

			if (hfirst_p1 && wfirst_p1)
				h_valid_p2 <= 1;
			else if (hlast_p1_d1 && wlast_p1_d1)
				h_valid_p2 <= 0;
		end
	end

	reg rd_en_d2;
	reg [BR_AW-1:0] x_d2;
	reg [C_PIXEL_WIDTH-1:0] tdata_p2;
	reg wfirst_p2;
	reg wlast_p2;
	reg pfirst_p2;
	reg plast_p2;
	reg hfirst_p2;
	reg hlast_p2;
	reg hM2_p2;
	reg hM3_p2;
	reg [C_IMG_HW-1:0] y_p2;
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			rd_en_d2    <= 0;
			x_d2        <= 0;
			tdata_p2    <= 0;
			wfirst_p2   <= 0;
			wlast_p2    <= 0;
			pfirst_p2   <= 0;
			plast_p2    <= 0;
			hfirst_p2   <= 0;
			hlast_p2    <= 0;
			hM2_p2      <= 0;
			hM3_p2      <= 0;
			y_p2        <= 0;
		end
		else begin
			rd_en_d2    <= rd_en_d1;
			x_d2        <= x_d1;
			tdata_p2    <= tdata_p1;
			wfirst_p2   <= wfirst_p1;
			wlast_p2    <= wlast_p1;
			pfirst_p2   <= (wfirst_p1 && hfirst_p1);
			plast_p2    <= (wlast_p1 && hlast_p1);
			hfirst_p2   <= hfirst_p1;
			hlast_p2    <= hlast_p1;
			hM2_p2      <= hM2_p1;
			hM3_p2      <= hM3_p1;
			y_p2        <= y_p1;
		end
	end

	reg wr_sof_d3;
	reg rd_en_d3;
	reg [BR_AW-1:0] x_d3;
	reg is_black_p3;
	reg [C_PIXEL_WIDTH-1:0] tdata_p3;
	reg wfirst_p3;
	reg wlast_p3;
	//reg plast_p3;
	reg hfirst_p3;
	reg hlast_p3;
	reg hM2_p3;
	reg hM3_p3;
	reg [C_IMG_HW-1:0] y_p3;
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			wr_sof_d3   <= 0;
			rd_en_d3    <= 0;
			x_d3        <= 0;
			tdata_p3    <= 0;
			is_black_p3 <= 0;
			wfirst_p3   <= 0;
			wlast_p3    <= 0;
			//plast_p3    <= 0;
			hfirst_p3   <= 0;
			hlast_p3    <= 0;
			hM2_p3      <= 0;
			hM3_p3      <= 0;
			y_p3        <= 0;
		end
		else begin
			wr_sof_d3   <= rd_en_d2 && plast_p2;
			rd_en_d3    <= rd_en_d2 && h_valid_p2;//rd_en_d2;
			x_d3        <= x_d2;
			tdata_p3    <= tdata_p2;
			if (hfirst_p2 || hlast_p2)
				is_black_p3 <= 0;
			else
				is_black_p3 <= (tdata_p2 < ref_data);
			//plast_p3    <= plast_p2 ;
			wfirst_p3   <= wfirst_p2;
			wlast_p3    <= wlast_p2;
			hfirst_p3   <= hfirst_p2;
			hlast_p3    <= hlast_p2;
			hM2_p3      <= hM2_p2;
			hM3_p3      <= hM3_p2;
			y_p3        <= y_p2;
		end
	end
	assign sof = wr_sof_d3;

	/// delay 4
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			wr_en   <= 0;
			wr_addr <= 0;
			wr_val_outer <= 0;
			wr_black<= 0;
			wr_top_outer <= 0;
			wr_bot_outer <= 0;
			wr_val_inner <= 0;
			wr_top_inner <= 0;
			wr_bot_inner <= 0;
		end
		else if (rd_en_d3) begin
			wr_en   <= wr_bmp;
			wr_addr <= x_d3;
			wr_black <= is_black_p3;

			if (is_black_p3)
				wr_val_outer <= 1;
			else if (hfirst_p3)
				wr_val_outer <= 0;
			else
				wr_val_outer <= rd_val_outer;

			if (hfirst_p3)
				wr_top_outer <= 0;
			else if (is_black_p3 && ~rd_val_outer)
				wr_top_outer <= y_p3;
			else
				wr_top_outer <= rd_top_outer;

			if (is_black_p3)
				wr_bot_outer <= y_p3;
			else if (hfirst_p3)
				wr_bot_outer <= 0;
			else
				wr_bot_outer <= rd_bot_outer;

			/// inner
			if (hfirst_p3)
				wr_val_inner <= 0;
			else if (rd_val_outer && ~rd_black && is_black_p3)
				wr_val_inner <= 1;
			else
				wr_val_inner <= rd_val_inner;

			/// NOTE: please ensure the width of edge is two line at least.
			if (hfirst_p3)
				wr_top_inner <= 0;
			else if (is_black_p3 && rd_black && ~rd_val_inner)
				wr_top_inner <= y_p3;
			else
				wr_top_inner <= rd_top_inner;

			if (hfirst_p3)
				wr_bot_inner <= 0;
			else if (rd_val_outer && ~rd_black && is_black_p3)
				wr_bot_inner <= y_p3;
			else
				wr_bot_inner <= rd_bot_inner;
		end
		else begin
			wr_en   <= 0;
		end
	end

	//// output for advance processing
	assign o_wr_sof_d3 = wr_sof_d3;
	assign o_rd_en_d3  = rd_en_d3 ;
	assign o_hM2_p3    = hM2_p3   ;
	assign o_hM3_p3    = hM3_p3   ;
	assign o_hfirst_p3 = hfirst_p3;
	assign o_hlast_p3  = hlast_p3 ;
	assign o_wfirst_p3 = wfirst_p3;
	assign o_wlast_p3  = wlast_p3 ;
	assign o_x_d3      = x_d3     ;
	assign o_rd_val_outer = rd_val_outer;
	assign o_rd_top_outer = rd_top_outer;
	assign o_rd_bot_outer = rd_bot_outer;
	assign o_rd_val_inner = rd_val_inner;
	assign o_rd_top_inner = rd_top_inner;
	assign o_rd_bot_inner = rd_bot_inner;
endmodule
