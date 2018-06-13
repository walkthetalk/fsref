
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
	input  wire                hlast_p3    ,
	input  wire                wfirst_p3   ,
	input  wire                wlast_p3    ,
	input  wire [BR_AW-1:0]    x_d3        ,
	input  wire                rd_val_outer,
	input  wire [C_IMG_HW-1:0] rd_top_outer,
	input  wire [C_IMG_HW-1:0] rd_bot_outer,

	output wire                     ana_done,
	output reg                      res_lft_valid       ,
	output reg  [C_IMG_WW-1:0]      res_lft_edge        ,
	output reg                      res_lft_header_valid,
	output reg  [C_IMG_WW-1:0]      res_lft_header_x    ,
	output reg                      res_lft_corner_valid,
	output reg  [C_IMG_WW-1:0]      res_lft_corner_top_x,
	output reg  [C_IMG_HW-1:0]      res_lft_corner_top_y,
	output reg  [C_IMG_WW-1:0]      res_lft_corner_bot_x,
	output reg  [C_IMG_HW-1:0]      res_lft_corner_bot_y,
	output reg                      res_rt_valid        ,
	output reg  [C_IMG_WW-1:0]      res_rt_edge         ,
	output reg                      res_rt_header_valid ,
	output reg  [C_IMG_WW-1:0]      res_rt_header_x     ,
	output reg                      res_rt_corner_valid ,
	output reg  [C_IMG_WW-1:0]      res_rt_corner_top_x ,
	output reg  [C_IMG_HW-1:0]      res_rt_corner_top_y ,
	output reg  [C_IMG_WW-1:0]      res_rt_corner_bot_x ,
	output reg  [C_IMG_HW-1:0]      res_rt_corner_bot_y
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
	reg rd_val_p4;
	reg [C_IMG_WW-1:0] x_d4;
	reg [C_IMG_HW-1:0] rd_top_p4;
	reg [C_IMG_HW-1:0] rd_bot_p4;
	reg [C_IMG_HW-1:0] rd_height_p4;
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			rd_en_d4 <= 1'b0;
			hM2_p4   <= 1'b0;
			hM3_p4   <= 1'b0;
			hlast_p4 <= 1'b0;
			wfirst_p4 <= 1'b0;
			wlast_p4  <= 1'b0;
			rd_val_p4 <= 1'b0;
			rd_top_p4 <= 0;
			rd_bot_p4 <= 0;
			rd_height_p4 <= 0;
			x_d4         <= 0;
		end
		else begin
			rd_en_d4  <= rd_en_d3;
			hM2_p4    <= hM2_p3;
			hM3_p4    <= hM3_p3;
			hlast_p4  <= hlast_p3;
			wfirst_p4 <= wfirst_p3;
			wlast_p4  <= wlast_p3;
			rd_val_p4 <= rd_val_outer;
			rd_top_p4 <= rd_top_outer;
			rd_bot_p4 <= rd_bot_outer;
			rd_height_p4 <= rd_bot_outer - rd_top_outer;
			x_d4         <= x_d3;
		end
	end

	/////////////////////////////////////////////////////////// detect edge
	reg lft_found;
	reg lft_valid_p4;
	reg[C_IMG_WW-1:0] lft_edge_p4;
	reg rt_found;
	reg rt_valid_p4;
	reg[C_IMG_WW-1:0] rt_edge_p4;
	always @ (posedge clk) begin
		if (resetn == 1'b0 || ~hlast_p3) begin
			lft_found  <= 0;
			lft_valid_p4  <= 0;
			lft_edge_p4   <= 0;
		end
		else if (rd_en_d3) begin
			if (~lft_found && rd_val_outer)
				lft_edge_p4 <= x_d3;
			if (~rd_val_outer)
				lft_found <= 1;
			if (wfirst_p3 && rd_val_outer)
				lft_valid_p4 <= 1;
		end
	end
	always @ (posedge clk) begin
		if (resetn == 1'b0 || ~hlast_p3) begin
			rt_found  <= 0;
			rt_valid_p4  <= 0;
			rt_edge_p4   <= 0;
		end
		else if (rd_en_d3) begin
			rt_found <= rd_val_outer;
			if (~rt_found || ~rd_val_outer)
				rt_edge_p4 <= x_d3;
			if (wlast_p3 && rd_val_outer)
				rt_valid_p4 <= 1'b1;
		end
	end

	//////////////////////////// height ////////////////////////////////////
	localparam integer fiber_height_tol = 2;
	reg                lft_height_valid;
	reg [C_IMG_HW-1:0] lft_height;
	reg [C_IMG_HW-1:0] lft_height_lower;
	reg [C_IMG_HW-1:0] lft_height_upper;

	reg                rt_height_valid;
	reg [C_IMG_HW-1:0] rt_height;
	reg [C_IMG_HW-1:0] rt_height_lower;
	reg [C_IMG_HW-1:0] rt_height_upper;
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			lft_height_valid <= 0;
			lft_height       <= 0;
			lft_height_lower <= 0;
			lft_height_upper <= 0;
			rt_height_valid  <= 0;
			rt_height        <= 0;
			rt_height_lower  <= 0;
			rt_height_upper  <= 0;
		end
		else if (rd_en_d4) begin
			if (hM3_p4) begin
				if (wfirst_p4) begin
					lft_height_valid <= rd_val_outer;
					lft_height       <= rd_height_p4;
					lft_height_upper <= rd_height_p4 + fiber_height_tol;
					lft_height_lower <= rd_height_p4 - fiber_height_tol;
				end

				if (wlast_p4) begin
					rt_height_valid  <= rd_val_outer;
					rt_height        <= rd_height_p4;
					rt_height_upper <= rd_height_p4 + fiber_height_tol;
					rt_height_lower <= rd_height_p4 - fiber_height_tol;
				end
			end
		end
	end

	///////////////////////////////////////////////////////////////// corner
	localparam integer C_FIBER_THICKNESS_LEN_HALF = 3;
	localparam integer C_FIBER_THICKNESS_LEN = C_FIBER_THICKNESS_LEN_HALF * 2 + 1;
	/// HM2
	///////////////////////// left
	reg                             lft_header_found;
	reg [C_FIBER_THICKNESS_LEN-1:0] lft_col_valid;
	reg [C_IMG_WW-1:0]              lft_header_x;
	wire                            lft_col_thickness_valid;
	assign lft_col_thickness_valid = (rd_height_p4 <= lft_height_upper && rd_height_p4 >= lft_height_lower);
	wire                            update_lft_header_x;
	assign update_lft_header_x = (~lft_header_found && lft_col_valid == {C_FIBER_THICKNESS_LEN{1'b1}});

	always @ (posedge clk) begin
		if (resetn == 1'b0 || hM3_p4 == 1'b1) begin
			lft_header_found <= 1'b0;
			lft_col_valid    <= 0;
			lft_header_x        <= 0;
		end
		else if (rd_en_d4 && hM2_p4) begin
			lft_col_valid <= { lft_col_valid[C_FIBER_THICKNESS_LEN-2:0], lft_col_thickness_valid};
			if (~rd_val_p4) begin
				lft_header_found <= lft_height_valid;
			end
			if (update_lft_header_x) begin
				lft_header_x        <= x_d4 - C_FIBER_THICKNESS_LEN_HALF - 1;
			end
		end
	end

	//////////////// right
	reg                             rt_header_found;
	reg [C_FIBER_THICKNESS_LEN-1:0] rt_col_valid;
	reg [C_IMG_WW-1:0]              rt_header_x;
	wire                            rt_col_thickness_valid;
	assign rt_col_thickness_valid = (rd_height_p4 <= rt_height_upper && rd_height_p4 >= rt_height_lower);
	wire                            update_rt_header_x;
	assign update_rt_header_x = (~rt_header_found && rt_col_valid == {C_FIBER_THICKNESS_LEN{1'b1}});
	always @ (posedge clk) begin
		if (resetn == 1'b0 || hM3_p4 == 1'b1) begin
			rt_header_found <= 1'b0;
			rt_col_valid    <= 0;
			rt_header_x        <= 0;
		end
		else if (rd_en_d4 && hM2_p4) begin
			rt_col_valid  <= { rt_col_valid[C_FIBER_THICKNESS_LEN-2:0],  rt_col_thickness_valid};
			if (~rd_val_p4) begin
				rt_header_found <= 1'b0;
			end
			else if (update_rt_header_x) begin
				rt_header_found    <= rt_height_valid;
				rt_header_x        <= x_d4 - C_FIBER_THICKNESS_LEN_HALF - 1;
			end
		end
	end
	///////////////////////////////////////////////////////////////// Hlast

	///////////////////////// left
	reg                lft_corner_found;
	reg [C_IMG_HW-1:0] lft_corner_top_y;
	reg [C_IMG_WW-1:0] lft_corner_top_x;
	reg [C_IMG_HW-1:0] lft_corner_bot_y;
	reg [C_IMG_WW-1:0] lft_corner_bot_x;
	always @ (posedge clk) begin
		if (resetn == 1'b0 || hM2_p4 == 1'b1) begin
			lft_corner_found   <= 1'b0;
			lft_corner_top_y   <= 0;
			lft_corner_bot_y   <= 0;
			lft_corner_top_x   <= 0;
			lft_corner_bot_x   <= 0;
		end
		else if (rd_en_d4 && hlast_p4) begin
			if (~rd_val_p4) begin
				lft_corner_found <= lft_header_found;
			end
			if (~lft_corner_found && rd_val_p4) begin
				if (x_d4 == lft_header_x) begin
					lft_corner_top_x <= x_d4;
					lft_corner_top_y <= rd_top_p4;
					lft_corner_bot_x <= x_d4;
					lft_corner_bot_y <= rd_bot_p4;
				end
				else if (x_d4 > lft_header_x) begin
					if (rd_top_p4 <= lft_corner_top_y) begin
						lft_corner_top_x <= x_d4;
						lft_corner_top_y <= rd_top_p4;
					end
					if (rd_bot_p4 >= lft_corner_bot_y) begin
						lft_corner_bot_x <= x_d4;
						lft_corner_bot_y <= rd_bot_p4;
					end
				end
			end
		end
	end

	/////////////////// right
	reg                rt_corner_found;
	reg [C_IMG_HW-1:0] rt_corner_top_y;
	reg [C_IMG_WW-1:0] rt_corner_top_x;
	reg [C_IMG_HW-1:0] rt_corner_bot_y;
	reg [C_IMG_WW-1:0] rt_corner_bot_x;
	always @ (posedge clk) begin
		if (resetn == 1'b0 || hlast_p4 == 1'b0) begin
			rt_corner_found   <= 1'b0;
			rt_corner_top_y   <= 0;
			rt_corner_bot_y   <= 0;
			rt_corner_top_x   <= 0;
			rt_corner_bot_x   <= 0;
		end
		else if (rd_en_d4) begin
			rt_corner_found <= rd_val_p4 && rt_header_found;
			if (~rt_corner_found) begin
				rt_corner_top_x <= x_d4;
				rt_corner_top_y <= rd_top_p4;
				rt_corner_bot_x <= x_d4;
				rt_corner_bot_y <= rd_bot_p4;
			end
			else if (x_d4 <= rt_header_x) begin
				if (rd_top_p4 < rt_corner_top_y) begin
					rt_corner_top_x <= x_d4;
					rt_corner_top_y <= rd_top_p4;
				end
				if (rd_bot_p4 > rt_corner_bot_y) begin
					rt_corner_bot_x <= x_d4;
					rt_corner_bot_y <= rd_bot_p4;
				end
			end
		end
	end

	/////////////////////////////////////////////////////////////////// final
	/// delay 5
	reg lft_valid_p5;
	reg[C_IMG_WW-1:0] lft_edge_p5;
	reg rt_valid_p5;
	reg[C_IMG_WW-1:0] rt_edge_p5;
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			lft_edge_p5  <= 0;
			lft_valid_p5 <= 0;
			rt_edge_p5   <= 0;
			rt_valid_p5  <= 0;
		end
		else if (rd_en_d4) begin
			lft_edge_p5  <= lft_edge_p4 ;
			lft_valid_p5 <= lft_valid_p4;
			rt_edge_p5   <= rt_edge_p4  ;
			rt_valid_p5  <= rt_valid_p4 ;
		end
	end
	reg wr_sof_d5;
	always @ (posedge clk) begin
		if (resetn == 1'b0)
			wr_sof_d5 <= 0;
		else
			wr_sof_d5 <= wr_sof_d4;
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
		end
		else if (wr_sof_d5) begin
			res_lft_edge  <= lft_edge_p5;
			res_lft_valid <= lft_valid_p5;
			res_rt_edge   <= rt_edge_p5;
			res_rt_valid  <= rt_valid_p5;
			res_lft_header_valid <= lft_header_found;
			res_lft_header_x     <= lft_header_x    ;
			res_lft_corner_valid <= lft_corner_found;
			res_lft_corner_top_x <= lft_corner_top_x;
			res_lft_corner_top_y <= lft_corner_top_y;
			res_lft_corner_bot_x <= lft_corner_bot_x;
			res_lft_corner_bot_y <= lft_corner_bot_y;
			res_rt_header_valid  <= rt_header_found ;
			res_rt_header_x      <= rt_header_x     ;
			res_rt_corner_valid  <= rt_corner_found ;
			res_rt_corner_top_x  <= rt_corner_top_x ;
			res_rt_corner_top_y  <= rt_corner_top_y ;
			res_rt_corner_bot_x  <= rt_corner_bot_x ;
			res_rt_corner_bot_y  <= rt_corner_bot_y ;
		end
	end
endmodule
