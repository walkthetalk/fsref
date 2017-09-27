`timescale 1ns / 1ps
`include "../src/axis_shifter.v"
`include "../src/axis_blender.v"

module testblender(
);
	parameter integer C_S0_PIXEL_WIDTH	= 32;
	parameter integer C_S1_PIXEL_WIDTH	= 8;
	parameter integer C_S2_PIXEL_WIDTH	= 8;
	parameter integer C_M_PIXEL_WIDTH	= 24;
	parameter integer C_IMG_WBITS = 12;
	parameter integer C_IMG_HBITS = 12;

	localparam integer C_TEST_COL = 1;
	localparam integer C_TEST_ROW = 1;
	localparam integer RANDOMOUTPUT = 1;
	localparam integer RANDOMINPUT = 1;


	wire[C_M_PIXEL_WIDTH-1:0] mdata;
	wire                      mlast;
	reg                       mready;
	wire                      muser;
	wire                      mvalid;

	wire[C_S0_PIXEL_WIDTH-1:0] s0data;
	wire                       s0last;
	wire                       s0ready;
	wire                       s0user;
	reg                        s0valid;
	wire[C_S1_PIXEL_WIDTH-1:0] s1data;
	wire                       s1last;
	wire                       s1ready;
	wire                       s1user;
	reg                        s1valid;
	wire[C_S2_PIXEL_WIDTH-1:0] s2data;
	wire                       s2last;
	wire                       s2ready;
	wire                       s2user;
	reg                        s2valid;

	reg resetn;
	reg clk;

	reg order_1over2;

	reg[C_IMG_WBITS-1 : 0] out_width;
	reg[C_IMG_HBITS-1 : 0] out_height;

	reg[C_IMG_WBITS-1 : 0] s0left;
	reg[C_IMG_HBITS-1 : 0] s0top;
	reg[C_IMG_WBITS-1 : 0] s0width;
	reg[C_IMG_HBITS-1 : 0] s0height;
	reg[C_IMG_WBITS-1 : 0] s1left;
	reg[C_IMG_HBITS-1 : 0] s1top;
	reg[C_IMG_WBITS-1 : 0] s1width;
	reg[C_IMG_HBITS-1 : 0] s1height;
	reg[C_IMG_WBITS-1 : 0] s2left;
	reg[C_IMG_HBITS-1 : 0] s2top;
	reg[C_IMG_WBITS-1 : 0] s2width;
	reg[C_IMG_HBITS-1 : 0] s2height;

axis_blender # (
	.C_S0_PIXEL_WIDTH(C_S0_PIXEL_WIDTH),
	.C_S1_PIXEL_WIDTH(C_S1_PIXEL_WIDTH),
	.C_S2_PIXEL_WIDTH(C_S2_PIXEL_WIDTH),
	.C_M_PIXEL_WIDTH(C_M_PIXEL_WIDTH),
	.C_IMG_WBITS(C_IMG_WBITS),
	.C_IMG_HBITS(C_IMG_HBITS)
) uut (
	.clk(clk),
	.resetn(resetn),

	.order_1over2(order_1over2),

	.out_width(out_width),
	.out_height(out_height),

	/// S0_AXIS
	.s0_axis_tvalid(s0valid),
	.s0_axis_tdata (s0data),
	.s0_axis_tuser (s0user),
	.s0_axis_tlast (s0last),
	.s0_axis_tready(s0ready),
	.s0_win_left   (s0left),
	.s0_win_top    (s0top),
	.s0_win_width  (s0width),
	.s0_win_height (s0height),

	/// S1_AXIS
	.s1_axis_tvalid(s1valid),
	.s1_axis_tdata (s1data),
	.s1_axis_tuser (s1user),
	.s1_axis_tlast (s1last),
	.s1_axis_tready(s1ready),
	.s1_win_left   (s1left),
	.s1_win_top    (s1top),
	.s1_win_width  (s1width),
	.s1_win_height (s1height),

	/// S2_AXIS
	.s2_axis_tvalid(s2valid),
	.s2_axis_tdata (s2data),
	.s2_axis_tuser (s2user),
	.s2_axis_tlast (s2last),
	.s2_axis_tready(s2ready),
	.s2_win_left   (s2left),
	.s2_win_top    (s2top),
	.s2_win_width  (s2width),
	.s2_win_height (s2height),

	/// M_AXIS
	.m_axis_tvalid(mvalid),
	.m_axis_tdata(mdata),
	.m_axis_tuser(muser),
	.m_axis_tlast(mlast),
	.m_axis_tready(mready)
);

initial begin
	clk <= 1'b1;
	forever #1 clk <= ~clk;
end
initial begin
	resetn <= 1'b0;
	repeat (5) #2 resetn <= 1'b0;
	forever #2 resetn <= 1'b1;
end
initial begin
	out_width <= 10;
	out_height <= 10;
	s0width <= 10;
	s0height <= 10;
	s0top <= 0;
	s0left <= 0;
	s1width <= 4;
	s1height <= 7;
	s1top <= 0;
	s1left <= 0;
	s2width <= 5;
	s2height <= 4;
	s2top <= 4;
	s2left <= 5;
	order_1over2 <= 1;
end

/// stream 0
reg[11:0] s0_row;
reg[11:0] s0_col;
reg randominput0;
assign s0data = ((C_TEST_ROW ? 'hF : s0_row) * 16 + (C_TEST_COL ? 'hF : s0_col)) * 32'h10000;
assign s0user = (s0_row == 0 && s0_col == 0);
assign s0last = (s0_col == s0height - 1);
always @ (posedge clk) begin
	if (resetn == 1'b0)
		randominput0 <= 1'b0;
	else
		randominput0 <= (RANDOMINPUT ? {$random}%2 : 1);

	if (resetn == 1'b0)
		s0valid <= 1'b0;
	else if (~s0valid) begin
		if (randominput0)
			s0valid <= 1'b1;
	end
	else if (s0valid && s0ready)
		s0valid <= randominput0;

	if (resetn == 1'b0) begin
		s0_row <= 0;
		s0_col <= 0;
	end
	else if (s0valid && s0ready) begin
		if (s0_col != s0width - 1) begin
			s0_col <= s0_col + 1;
			s0_row <= s0_row;
		end
		else if (s0_row != s0height - 1) begin
			s0_col <= 0;
			s0_row <= s0_row + 1;
		end
		else begin
			s0_row <= 0;
			s0_col <= 0;
		end
	end
end

/// stream 1
reg[11:0] s1_row;
reg[11:0] s1_col;
reg randominput1;
assign s1data = ((C_TEST_ROW ? 'hF : s1_row) * 16 + (C_TEST_COL ? 'hF : s1_col));
assign s1user = (s1_row == 0 && s1_col == 0);
assign s1last = (s1_col == s1height - 1);
always @ (posedge clk) begin
	if (resetn == 1'b0)
		randominput1 <= 1'b0;
	else
		randominput1 <= (RANDOMINPUT ? {$random}%2 : 1);

	if (resetn == 1'b0)
		s1valid <= 1'b0;
	else if (~s1valid) begin
		if (randominput1)
			s1valid <= 1'b1;
	end
	else if (s1valid && s1ready)
		s1valid <= randominput1;

	if (resetn == 1'b0) begin
		s1_row <= 0;
		s1_col <= 0;
	end
	else if (s1valid && s1ready) begin
		if (s1_col != s1width - 1) begin
			s1_col <= s1_col + 1;
			s1_row <= s1_row;
		end
		else if (s1_row != s1height - 1) begin
			s1_col <= 0;
			s1_row <= s1_row + 1;
		end
		else begin
			s1_row <= 0;
			s1_col <= 0;
		end
	end
end

/// stream 2
reg[11:0] s2_row;
reg[11:0] s2_col;
reg randominput2;
assign s2data = ((C_TEST_ROW ? 'hF : s2_row) * 16 + (C_TEST_COL ? 'hF : s2_col));
assign s2user = (s2_row == 0 && s2_col == 0);
assign s2last = (s2_col == s2height - 1);
always @ (posedge clk) begin
	if (resetn == 1'b0)
		randominput2 <= 1'b0;
	else
		randominput2 <= (RANDOMINPUT ? {$random}%2 : 1);

	if (resetn == 1'b0)
		s2valid <= 1'b0;
	else if (~s2valid) begin
		if (randominput2)
			s2valid <= 1'b1;
	end
	else if (s2valid && s2ready)
		s2valid <= randominput2;

	if (resetn == 1'b0) begin
		s2_row <= 0;
		s2_col <= 0;
	end
	else if (s2valid && s2ready) begin
		if (s2_col != s2width - 1) begin
			s2_col <= s2_col + 1;
			s2_row <= s2_row;
		end
		else if (s2_row != s2height - 1) begin
			s2_col <= 0;
			s2_row <= s2_row + 1;
		end
		else begin
			s2_row <= 0;
			s2_col <= 0;
		end
	end
end

reg[11:0] out_row;
reg[11:0] out_col;
reg[7:0]  out_data;
reg out_last;

reg randomoutput;
always @(posedge clk) begin
	if (resetn == 1'b0)
		randomoutput <= 1'b0;
	else
		randomoutput <= (RANDOMOUTPUT ? {$random}%2 : 1);


	if (resetn == 1'b0)
		mready <= 1'b0;
	else if (randomoutput)
		mready <= 1'b1;
	else
		mready <= 1'b0;


	if (resetn == 1'b0) begin
		out_data <= 0;
		out_last <= 0;
	end
	else if (mready && mvalid) begin
		out_data <= mdata;
		out_last <= mlast;
	end


	if (resetn == 1'b0) begin
		out_col = 0;
		out_row = 0;
	end
	else if (mready && mvalid) begin
		if (muser) begin
			out_col = 0;
			out_row = 0;
		end
		else if (out_last) begin
			out_col = 0;
			out_row = out_row + 1;
		end
		else begin
			out_col = out_col + 1;
			out_row = out_row;
		end
		if (muser)
			$write("start new frame: \n");
		$write("%h ", mdata);
		if (mlast)
			$write("\n");
	end
end


endmodule
