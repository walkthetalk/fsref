module fsa_detect_header # (
	parameter integer C_IMG_HW = 12,
	parameter integer C_IMG_WW = 12
) (
	input	clk,
	input	resetn,

	input  wire                rd_en_d3    ,
	input  wire                hM3_p3      ,
	input  wire                wfirst_p3   ,
	input  wire                wlast_p3    ,
	input  wire                rd_en_d4    ,
	input  wire                hM2_p4      ,
	input  wire                hM3_p4      ,

	input  wire [C_IMG_WW-1:0] x_d4        ,
	input  wire [C_IMG_WW-1:0] lft_edge_p4 ,
	input  wire [C_IMG_WW-1:0] rt_edge_p4  ,

	input  wire                rd_val_p3,
	input  wire [C_IMG_HW-1:0] rd_top_p3,
	input  wire [C_IMG_HW-1:0] rd_bot_p3,

	output reg                rd_val_p4,
	output reg [C_IMG_HW-1:0] rd_top_p4,
	output reg [C_IMG_HW-1:0] rd_bot_p4,

	output reg                lft_header_valid,
	output reg [C_IMG_WW-1:0] lft_header_x,
	output reg                rt_header_valid,
	output reg [C_IMG_WW-1:0] rt_header_x
);
	localparam integer fiber_height_tol = 2;

	wire[C_IMG_HW-1:0] col_height_p3;
	assign col_height_p3 = (rd_bot_p3 - rd_top_p3);

	//reg                rd_val_p4;
	//reg [C_IMG_HW-1:0] rd_top_p4;
	//reg [C_IMG_HW-1:0] rd_bot_p4;
	reg [C_IMG_HW-1:0] rd_height_p4;
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			rd_val_p4 <= 1'b0;
			rd_top_p4 <= 0;
			rd_bot_p4 <= 0;
			rd_height_p4 <= 0;
		end
		else begin
			rd_val_p4 <= rd_val_p3;
			rd_top_p4 <= rd_top_p3;
			rd_bot_p4 <= rd_bot_p3;
			rd_height_p4 <= col_height_p3;
		end
	end

	//////////////////////////// height ////////////////////////////////////

	reg [C_IMG_HW-1:0] lft_height_lower_p4;
	reg [C_IMG_HW-1:0] lft_height_upper_p4;

	reg [C_IMG_HW-1:0] rt_height_lower_p4;
	reg [C_IMG_HW-1:0] rt_height_upper_p4;
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			lft_height_lower_p4 <= 0;
			lft_height_upper_p4 <= 0;
			rt_height_lower_p4  <= 0;
			rt_height_upper_p4  <= 0;
		end
		else if (rd_en_d3 && hM3_p3) begin
			if (wfirst_p3) begin
				lft_height_upper_p4 <= col_height_p3 + fiber_height_tol;
				lft_height_lower_p4 <= col_height_p3 - fiber_height_tol;
			end

			if (wlast_p3) begin
				rt_height_upper_p4  <= col_height_p3 + fiber_height_tol;
				rt_height_lower_p4  <= col_height_p3 - fiber_height_tol;
			end
		end
	end

	//////////////////////////// header ///////////////////////////////////
	localparam integer C_FIBER_THICKNESS_LEN_HALF = 3;
	localparam integer C_FIBER_THICKNESS_LEN = C_FIBER_THICKNESS_LEN_HALF * 2 + 1;
	/// HM2
	///////////////////////// left
	reg                             lft_header_done;
	//reg                             lft_header_valid;
	//reg [C_IMG_WW-1:0]              lft_header_x;
	reg [C_FIBER_THICKNESS_LEN-1:0] lft_col_valid;
	wire                            lft_col_thickness_valid;
	assign lft_col_thickness_valid = (rd_height_p4 <= lft_height_upper_p4 && rd_height_p4 >= lft_height_lower_p4);
	wire                            update_lft_header_x;
	assign update_lft_header_x = (~lft_header_done && lft_col_valid == {C_FIBER_THICKNESS_LEN{1'b1}});

	always @ (posedge clk) begin
		if (resetn == 1'b0 || hM3_p4 == 1'b1) begin
			lft_header_done  <= 0;
			lft_header_valid <= 1'b0;
			lft_col_valid    <= 0;
			lft_header_x     <= 0;
		end
		else if (rd_en_d4 && hM2_p4) begin
			lft_col_valid <= { lft_col_valid[C_FIBER_THICKNESS_LEN-2:0], lft_col_thickness_valid};
			if (x_d4 == lft_edge_p4)
				lft_header_done <= 1;
			if (update_lft_header_x) begin
				lft_header_valid <= 1;
				lft_header_x     <= x_d4 - C_FIBER_THICKNESS_LEN_HALF - 1;
			end
		end
	end

	//////////////// right
	reg                             rt_header_start;
	//reg                             rt_header_valid;
	//reg [C_IMG_WW-1:0]              rt_header_x;
	reg [C_FIBER_THICKNESS_LEN-1:0] rt_col_valid;
	wire                            rt_col_thickness_valid;
	assign rt_col_thickness_valid = (rd_height_p4 <= rt_height_upper_p4 && rd_height_p4 >= rt_height_lower_p4);
	wire                            update_rt_header_x;
	assign update_rt_header_x = ((~rt_header_valid && rt_header_start) && rt_col_valid == {C_FIBER_THICKNESS_LEN{1'b1}});
	always @ (posedge clk) begin
		if (resetn == 1'b0 || hM3_p4 == 1'b1) begin
			rt_header_start <= 0;
			rt_header_valid <= 1'b0;
			rt_col_valid    <= 0;
			rt_header_x     <= 0;
		end
		else if (rd_en_d4 && hM2_p4) begin
			rt_col_valid  <= { rt_col_valid[C_FIBER_THICKNESS_LEN-2:0],  rt_col_thickness_valid};
			if (x_d4 == rt_edge_p4)
				rt_header_start <= 1;
			if (update_rt_header_x) begin
				rt_header_valid <= 1;
				rt_header_x     <= x_d4 - C_FIBER_THICKNESS_LEN_HALF - 1;
			end
		end
	end
endmodule
