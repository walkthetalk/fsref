
module fsa_core #(
	parameter integer C_PIXEL_WIDTH = 8,
	parameter integer C_IMG_HW = 12,
	parameter integer C_IMG_WW = 12,
	parameter integer BR_DW    = 32,
	parameter integer BR_NUM   = 4,
	parameter integer BR_AW    = 12	/// same as C_IMG_WW
)(
	input	clk,
	input	resetn,

	input  wire [C_IMG_HW-1:0]      height  ,
	input  wire [C_IMG_WW-1:0]      width   ,

	output wire                     sof     ,
	input  wire [BR_NUM-1:0]        wr_bmp  ,

	output reg  [BR_NUM-1:0]        wr_en   ,
	output reg  [BR_AW-1:0]         wr_addr ,
	output wire [BR_DW-1:0]         wr_data ,

	output reg                      rd_en   ,
	output reg  [BR_AW-1:0]         rd_addr ,
	input  wire [BR_DW-1:0]         rd_data ,

	input  wire [C_PIXEL_WIDTH-1:0] ref_data,
	output wire                     ana_done,
	output reg                      res_lft_valid       ,
	output reg  [C_IMG_WW-1:0]      res_lft_edge        ,
	output reg  [C_IMG_WW-1:0]      res_lft_header_x    ,
	output reg  [C_IMG_WW-1:0]      res_lft_corner_top_x,
	output reg  [C_IMG_HW-1:0]      res_lft_corner_top_y,
	output reg  [C_IMG_WW-1:0]      res_lft_corner_bot_x,
	output reg  [C_IMG_HW-1:0]      res_lft_corner_bot_y,
	output reg                      res_rt_valid        ,
	output reg  [C_IMG_WW-1:0]      res_rt_edge         ,
	output reg  [C_IMG_WW-1:0]      res_rt_header_x     ,
	output reg  [C_IMG_WW-1:0]      res_rt_corner_top_x ,
	output reg  [C_IMG_HW-1:0]      res_rt_corner_top_y ,
	output reg  [C_IMG_WW-1:0]      res_rt_corner_bot_x ,
	output reg  [C_IMG_HW-1:0]      res_rt_corner_bot_y ,

	input  wire                     s_axis_tvalid,
	input  wire [C_PIXEL_WIDTH-1:0] s_axis_tdata,
	input  wire                     s_axis_tuser,
	input  wire                     s_axis_tlast,
	output wire                     s_axis_tready
);
	localparam integer BBIT_B = 0;
	localparam integer BBIT_E = BBIT_B + C_IMG_HW;
	localparam integer TBIT_B = BBIT_E;
	localparam integer TBIT_E = TBIT_B + C_IMG_HW;
	localparam integer VBIT   = TBIT_E;

	assign wr_data[BR_DW-1:VBIT+1] = 0;

	reg                wr_val;
	wire               rd_val;
	assign wr_data[VBIT] = wr_val;
	assign rd_val = rd_data[VBIT];

	reg [C_IMG_HW-1:0] wr_top;
	wire[C_IMG_HW-1:0] rd_top;
	assign wr_data[TBIT_E-1:TBIT_B] = wr_top;
	assign rd_top = rd_data[TBIT_E-1:TBIT_B];

	reg [C_IMG_HW-1:0] wr_bot;
	wire[C_IMG_HW-1:0] rd_bot;
	assign wr_data[BBIT_E-1:BBIT_B] = wr_bot;
	assign rd_bot = rd_data[BBIT_E-1:BBIT_B];

	assign s_axis_tready = 1'b1;
	wire snext;
	assign snext = s_axis_tvalid & s_axis_tready;

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
			wfirst_p1   <= wfirst_p0;
			wlast_p1    <= wlast_p0;
			hfirst_p1   <= hfirst_p0;
			hlast_p1    <= (y_p0 == height-1);
			hM2_p1      <= (y_p0 == height-2);
			hM3_p1      <= (y_p0 == height-3);
			y_p1        <= y_p0;
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
			rd_en_d3    <= rd_en_d2;
			x_d3        <= x_d2;
			tdata_p3    <= tdata_p2;
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
	reg wr_sof_d4;
	always @ (posedge clk) begin
		if (resetn == 1'b0)
			wr_sof_d4 <= 0;
		else
			wr_sof_d4 <= wr_sof_d3;
	end

	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			wr_en   <= 0;
			wr_addr <= 0;
			wr_val  <= 0;
			wr_top  <= 0;
			wr_bot  <= 0;
		end
		else if (rd_en_d3) begin
			wr_en   <= wr_bmp;
			wr_addr <= x_d3;

			if (tdata_p3 < ref_data)
				wr_val <= 1;
			else if (hfirst_p3)
				wr_val <= 0;
			else
				wr_val <= rd_val;

			if (hfirst_p3)
				wr_top <= 0;
			else if (tdata_p3 < ref_data && ~rd_val)
				wr_top <= y_p3;
			else
				wr_top <= rd_top;

			if (tdata_p3 < ref_data)
				wr_bot <= y_p3;
			else if (hfirst_p3)
				wr_bot <= 0;
			else
				wr_bot <= rd_bot;
		end
		else begin
			wr_en   <= 0;
		end
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
			rd_val_p4 <= rd_val;
			rd_top_p4 <= rd_top;
			rd_bot_p4 <= rd_bot;
			rd_height_p4 <= rd_bot - rd_top;
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
			if (~lft_found && rd_val)
				lft_edge_p4 <= x_d3;
			if (~rd_val)
				lft_found <= 1;
			if (wfirst_p3 && rd_val)
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
			rt_found <= rd_val;
			if (~rt_found || ~rd_val)
				rt_edge_p4 <= x_d3;
			if (wlast_p3 && rd_val)
				rt_valid_p4 <= 1'b1;
		end
	end

	//////////////////////////// height ////////////////////////////////////
	localparam integer fiber_height_tol = 3;
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
					lft_height_valid <= rd_val;
					lft_height       <= rd_height_p4;
					lft_height_upper <= rd_height_p4 + fiber_height_tol;
					lft_height_lower <= rd_height_p4 - fiber_height_tol;
				end

				if (wlast_p4) begin
					rt_height_valid  <= rd_val;
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
				lft_header_found <= 1'b1;
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
				rt_header_found <= 1'b1;
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
				lft_corner_found <= 1'b1;
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
			rt_corner_found <= rd_val_p4;
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
			res_lft_header_x     <= lft_header_x    ;
			res_lft_corner_top_x <= lft_corner_top_x;
			res_lft_corner_top_y <= lft_corner_top_y;
			res_lft_corner_bot_x <= lft_corner_bot_x;
			res_lft_corner_bot_y <= lft_corner_bot_y;
			res_rt_header_x      <= rt_header_x     ;
			res_rt_corner_top_x  <= rt_corner_top_x ;
			res_rt_corner_top_y  <= rt_corner_top_y ;
			res_rt_corner_bot_x  <= rt_corner_bot_x ;
			res_rt_corner_bot_y  <= rt_corner_bot_y ;
		end
	end
endmodule
