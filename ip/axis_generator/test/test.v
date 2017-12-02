`timescale 1ns / 1ps
`include "../src/axis_generator.v"

module test_axis_generator(
);
	localparam integer C_WIN_NUM     = 8;
	localparam integer C_PIXEL_WIDTH = 8;
	localparam integer C_IMG_WBITS   = 12;
	localparam integer C_IMG_HBITS   = 12;
	localparam integer C_MAX_WIN_NUM = 8;
	localparam integer C_EXT_FSYNC   = 1;

	reg clk;
	reg resetn;
	reg fsync;

	reg [C_IMG_WBITS-1:0]    s_width ;
	reg [C_IMG_HBITS-1:0]    s_height;

	reg  [C_IMG_WBITS-1 : 0] win_left   [C_MAX_WIN_NUM-1 : 0];
	reg  [C_IMG_HBITS-1 : 0] win_top    [C_MAX_WIN_NUM-1 : 0];
	reg  [C_IMG_WBITS-1 : 0] win_width  [C_MAX_WIN_NUM-1 : 0];
	reg  [C_IMG_HBITS-1 : 0] win_height [C_MAX_WIN_NUM-1 : 0];
	reg  [C_MAX_WIN_NUM-1:0] s_dst_bmp  [C_MAX_WIN_NUM-1 : 0];

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
	.C_EXT_FSYNC   (C_EXT_FSYNC   ),
	.C_PIXEL_WIDTH (C_PIXEL_WIDTH ),
	.C_IMG_WBITS   (C_IMG_WBITS   ),
	.C_IMG_HBITS   (C_IMG_HBITS   )
) uut (
	.clk(clk),
	.resetn(resetn),
	.fsync(fsync),

	.width(s_width),
	.height(s_height),

	.s0_left    (win_left   [0]),
	.s0_top     (win_top    [0]),
	.s0_width   (win_width  [0]),
	.s0_height  (win_height [0]),
	.s0_dst_bmp (s_dst_bmp  [0]),

	.s1_left    (win_left   [1]),
	.s1_top     (win_top    [1]),
	.s1_width   (win_width  [1]),
	.s1_height  (win_height [1]),
	.s1_dst_bmp (s_dst_bmp  [1]),

	.s2_left    (win_left   [2]),
	.s2_top     (win_top    [2]),
	.s2_width   (win_width  [2]),
	.s2_height  (win_height [2]),
	.s2_dst_bmp (s_dst_bmp  [2]),

	.s3_left    (win_left   [3]),
	.s3_top     (win_top    [3]),
	.s3_width   (win_width  [3]),
	.s3_height  (win_height [3]),
	.s3_dst_bmp (s_dst_bmp  [3]),

	.s4_left    (win_left   [4]),
	.s4_top     (win_top    [4]),
	.s4_width   (win_width  [4]),
	.s4_height  (win_height [4]),
	.s4_dst_bmp (s_dst_bmp  [4]),

	.s5_left    (win_left   [5]),
	.s5_top     (win_top    [5]),
	.s5_width   (win_width  [5]),
	.s5_height  (win_height [5]),
	.s5_dst_bmp (s_dst_bmp  [5]),

	.s6_left    (win_left   [6]),
	.s6_top     (win_top    [6]),
	.s6_width   (win_width  [6]),
	.s6_height  (win_height [6]),
	.s6_dst_bmp (s_dst_bmp  [6]),

	.s7_left    (win_left   [7]),
	.s7_top     (win_top    [7]),
	.s7_width   (win_width  [7]),
	.s7_height  (win_height [7]),
	.s7_dst_bmp (s_dst_bmp  [7]),

	.m_axis_tvalid(m_valid   ),
	.m_axis_tdata (m_data    ),
	.m_axis_tuser ({win_pixel_need, m_user}    ),
	.m_axis_tlast (m_last    ),
	.m_axis_tready(m_ready   )
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
	fsync <= 0;
end

reg [31:0] fsync_cnt;
reg [31:0] win_seq = 32'b11000;

always @ (posedge clk) begin
	if (resetn == 1'b0) begin
		fsync <= 0;
		fsync_cnt <= 0;
	end
	else if (fsync_cnt == 0) begin
		fsync_cnt <= 1000;
		fsync     <= 1;
		win_seq   <= (win_seq >> 1);
		if (win_seq[0]) begin
			win_left[0] <= 0; win_top[0] <= 0; win_width[0] <=  20; win_height[0] <= 15;
		end
		else begin
			win_left[0] <= 0; win_top[0] <=  0; win_width[0] <=  0; win_height[0] <=  0;
		end
		win_left[1] <= 3; win_top[1] <= 10; win_width[1] <=  5; win_height[1] <=  3;
		win_left[2] <= 3; win_top[2] <= 10; win_width[2] <=  5; win_height[2] <=  3;
		win_left[3] <= 3; win_top[3] <= 10; win_width[3] <=  5; win_height[3] <=  3;
		win_left[4] <= 3; win_top[4] <= 10; win_width[4] <=  5; win_height[4] <=  3;
		win_left[5] <= 0; win_top[5] <=  0; win_width[5] <= 20; win_height[5] <= 15;
		win_left[6] <= 3; win_top[6] <= 10; win_width[6] <=  5; win_height[6] <=  3;
		win_left[7] <= 3; win_top[7] <= 10; win_width[7] <=  5; win_height[7] <=  3;
	end
	else begin
		fsync     <= 0;
		fsync_cnt <= fsync_cnt - 1;
	end
end

initial begin
	m_random  <= 1;
	m_enprint <= (1 << 0);

	s_width  <= 20;
	s_height <= 15;

	s_dst_bmp[0] <= 8'b00000001;
	s_dst_bmp[1] <= 8'b00000010;
	s_dst_bmp[2] <= 8'b00000000;
	s_dst_bmp[3] <= 8'b00000000;
	s_dst_bmp[4] <= 8'b00000000;
	s_dst_bmp[5] <= 8'b00000000;
	s_dst_bmp[6] <= 8'b00000000;
	s_dst_bmp[7] <= 8'b00000000;
end

generate
	reg [C_IMG_HBITS-1:0]     m_ridx;
	reg [C_IMG_WBITS-1:0]     m_cidx;
	reg en_output;
	always @ (posedge clk) begin
		if (resetn == 1'b0) en_output <= 1'b0;
		else		en_output <= (m_random ? {$random}%2 : 1) & (fsync < 500);
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
		else if (m_ready && m_valid) begin
			if (m_user)
				$write("out start new frame: \n");
			if ((win_pixel_need & m_enprint) != 0)
				$write("1 ");
			else
				$write("0 ");
			if (m_last)
				$write("\n");
		end
	end
endgenerate

endmodule