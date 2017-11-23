`timescale 1ns / 1ps
`include "../src/axis_generator.v"

module test_axis_generator(
);
	localparam integer C_WIN_NUM     = 8;
	localparam integer C_PIXEL_WIDTH = 8;
	localparam integer C_IMG_WBITS   = 12;
	localparam integer C_IMG_HBITS   = 12;
	localparam integer C_MAX_WIN_NUM = 8;

	reg clk;
	reg resetn;

	reg                      s_random ;
	reg [C_IMG_WBITS-1:0]    s_width ;
	reg [C_IMG_HBITS-1:0]    s_height;

	reg                      s_valid ;
	wire [C_PIXEL_WIDTH-1:0] s_data  ;
	wire                     s_user  ;
	wire                     s_last  ;
	wire                     s_ready ;

	reg  [C_IMG_WBITS-1 : 0] win_left   [C_MAX_WIN_NUM-1 : 0];
	reg  [C_IMG_HBITS-1 : 0] win_top    [C_MAX_WIN_NUM-1 : 0];
	reg  [C_IMG_WBITS-1 : 0] win_width  [C_MAX_WIN_NUM-1 : 0];
	reg  [C_IMG_HBITS-1 : 0] win_height [C_MAX_WIN_NUM-1 : 0];
	wire [C_IMG_WBITS-1 : 0] win_righte [C_MAX_WIN_NUM-1 : 0];
	wire [C_IMG_HBITS-1 : 0] win_bottome[C_MAX_WIN_NUM-1 : 0];

	reg                      m_random ;
	reg [C_MAX_WIN_NUM-1:0]  m_enprint;

	wire                     m_valid ;
	wire [C_PIXEL_WIDTH-1:0] m_data  ;
	wire                     m_user  ;
	wire                     m_last  ;
	reg                      m_ready ;

	wire [C_WIN_NUM-1:0] win_pixel_need;

axis_generator # (
	.C_WIN_NUM     (C_WIN_NUM     ),
	.C_PIXEL_WIDTH (C_PIXEL_WIDTH ),
	.C_IMG_WBITS   (C_IMG_WBITS   ),
	.C_IMG_HBITS   (C_IMG_HBITS   )
) uut (
	.clk(clk),
	.resetn(resetn),

	.width(s_width),
	.height(s_height),

	.win0_left    (win_left   [0]),
	.win0_top     (win_top    [0]),
	.win0_width   (win_width  [0]),
	.win0_height  (win_height [0]),
	.win0_righte  (win_righte [0]),
	.win0_bottome (win_bottome[0]),

	.win1_left    (win_left   [1]),
	.win1_top     (win_top    [1]),
	.win1_width   (win_width  [1]),
	.win1_height  (win_height [1]),
	.win1_righte  (win_righte [1]),
	.win1_bottome (win_bottome[1]),

	.win2_left    (win_left   [2]),
	.win2_top     (win_top    [2]),
	.win2_width   (win_width  [2]),
	.win2_height  (win_height [2]),
	.win2_righte  (win_righte [2]),
	.win2_bottome (win_bottome[2]),

	.win3_left    (win_left   [3]),
	.win3_top     (win_top    [3]),
	.win3_width   (win_width  [3]),
	.win3_height  (win_height [3]),
	.win3_righte  (win_righte [3]),
	.win3_bottome (win_bottome[3]),

	.win4_left    (win_left   [4]),
	.win4_top     (win_top    [4]),
	.win4_width   (win_width  [4]),
	.win4_height  (win_height [4]),
	.win4_righte  (win_righte [4]),
	.win4_bottome (win_bottome[4]),

	.win5_left    (win_left   [5]),
	.win5_top     (win_top    [5]),
	.win5_width   (win_width  [5]),
	.win5_height  (win_height [5]),
	.win5_righte  (win_righte [5]),
	.win5_bottome (win_bottome[5]),

	.win6_left    (win_left   [6]),
	.win6_top     (win_top    [6]),
	.win6_width   (win_width  [6]),
	.win6_height  (win_height [6]),
	.win6_righte  (win_righte [6]),
	.win6_bottome (win_bottome[6]),

	.win7_left    (win_left   [7]),
	.win7_top     (win_top    [7]),
	.win7_width   (win_width  [7]),
	.win7_height  (win_height [7]),
	.win7_righte  (win_righte [7]),
	.win7_bottome (win_bottome[7]),

	.m_axis_tvalid(m_valid   ),
	.m_axis_tdata (m_data    ),
	.m_axis_tuser (m_user    ),
	.m_axis_tlast (m_last    ),
	.m_axis_tready(m_ready   ),

	.win_pixel_need(win_pixel_need)
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
	s_random  <= 1;
	m_random  <= 1;
	m_enprint <= (1 << 5);

	s_width  <= 20;
	s_height <= 15;

	win_left[0] <= 3; win_top[0] <= 10; win_width[0] <=  5; win_height[0] <=  3;
	win_left[1] <= 3; win_top[1] <= 10; win_width[1] <=  5; win_height[1] <=  3;
	win_left[2] <= 3; win_top[2] <= 10; win_width[2] <=  5; win_height[2] <=  3;
	win_left[3] <= 3; win_top[3] <= 10; win_width[3] <=  5; win_height[3] <=  3;
	win_left[4] <= 3; win_top[4] <= 10; win_width[4] <=  5; win_height[4] <=  3;
	win_left[5] <= 0; win_top[5] <=  0; win_width[5] <= 20; win_height[5] <= 15;
	win_left[6] <= 3; win_top[6] <= 10; win_width[6] <=  5; win_height[6] <=  3;
	win_left[7] <= 3; win_top[7] <= 10; win_width[7] <=  5; win_height[7] <=  3;
end

generate
	genvar i;
	for (i = 0; i < C_MAX_WIN_NUM; i = i+1) begin: single_win_assign
		assign win_righte[i] = win_left[i] + win_width[i] - 1;
		assign win_bottome[i] = win_top[i] + win_height[i] - 1;
	end
endgenerate

generate
	reg [C_IMG_HBITS-1:0]     m_ridx;
	reg [C_IMG_WBITS-1:0]     m_cidx;
	reg en_output;
	always @ (posedge clk) begin
		if (resetn == 1'b0) en_output <= 1'b0;
		else		en_output <= (m_random ? {$random}%2 : 1);
	end
	always @(posedge clk) begin
		if (resetn == 1'b0)
			m_ready <= 1'b0;
		else if (~m_ready)
			m_ready <= en_output;
		else begin
			if (m_valid)
				m_ready <= en_output;
		end
	end
	always @(posedge clk) begin
		if (resetn == 1'b0) begin
			m_ridx = 0;
			m_cidx = 0;
		end
		else if (m_ready && m_valid) begin
			if (m_user) begin
				m_ridx = 0;
				m_cidx = 0;
			end
			else if (m_last) begin
				m_cidx = 0;
				m_ridx = m_ridx + 1;
			end
			else begin
				m_cidx = m_cidx + 1;
				m_ridx = m_ridx;
			end
		end
	end
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
		end
		else if (m_ready && m_valid && m_enprint) begin
			if (m_user)
				$write("out start new frame: \n");
			if (win_pixel_need & m_enprint)
				$write("1 ");
			else
				$write("0 ");
			if (m_last)
				$write("\n");
		end
	end
endgenerate

endmodule
