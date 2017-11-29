`timescale 1ns / 1ps
`include "../src/axis_interconnector.v"

module test_axis_interconnector(
);
	localparam integer C_PIXEL_WIDTH	= 32;
	localparam integer C_PRIORITY_WIDTH     = 3;
	localparam integer C_S_STREAM_NUM       = 8;
	localparam integer C_M_STREAM_NUM       = 8;
	localparam integer C_IMG_BITS		= 12;
	localparam integer C_ONE2MANY           = 0;
	localparam integer C_MAX_STREAM_NUM     = 8;

	reg clk;
	reg resetn;

	reg [C_MAX_STREAM_NUM-1:0]                     s_random ;

	reg [C_IMG_BITS-1:0]     s_width  [C_MAX_STREAM_NUM-1:0];
	reg [C_IMG_BITS-1:0]     s_height [C_MAX_STREAM_NUM-1:0];
	reg                      s_valid  [C_MAX_STREAM_NUM-1:0];
	wire [C_PIXEL_WIDTH-1:0] s_data   [C_MAX_STREAM_NUM-1:0];
	wire                     s_user   [C_MAX_STREAM_NUM-1:0];
	wire                     s_last   [C_MAX_STREAM_NUM-1:0];
	wire                     s_ready  [C_MAX_STREAM_NUM-1:0];

	reg  [C_S_STREAM_NUM-1:0]         s_dst_bmp[C_MAX_STREAM_NUM-1:0];

	reg  [C_MAX_STREAM_NUM-1:0]       m_random ;
	reg  [C_MAX_STREAM_NUM-1:0]       m_enprint;

	reg [C_IMG_BITS-1:0]     m_width  [C_MAX_STREAM_NUM-1:0];
	reg [C_IMG_BITS-1:0]     m_height [C_MAX_STREAM_NUM-1:0];
	wire                     m_valid  [C_MAX_STREAM_NUM-1:0];
	wire [C_PIXEL_WIDTH-1:0] m_data   [C_MAX_STREAM_NUM-1:0];
	wire                     m_user   [C_MAX_STREAM_NUM-1:0];
	wire                     m_last   [C_MAX_STREAM_NUM-1:0];
	reg                      m_ready  [C_MAX_STREAM_NUM-1:0];

axis_interconnector # (
	.C_PIXEL_WIDTH(C_PIXEL_WIDTH),
	.C_S_STREAM_NUM(C_S_STREAM_NUM),
	.C_M_STREAM_NUM(C_M_STREAM_NUM),
	.C_ONE2MANY(1)
) uut (
	.clk(clk),
	.resetn(resetn),

	.s0_axis_tvalid(s_valid   [0]),
	.s0_axis_tdata (s_data    [0]),
	.s0_axis_tuser (s_user    [0]),
	.s0_axis_tlast (s_last    [0]),
	.s0_axis_tready(s_ready   [0]),
	.s0_dst_bmp    (s_dst_bmp [0]),
	.m0_axis_tvalid(m_valid   [0]),
	.m0_axis_tdata (m_data    [0]),
	.m0_axis_tuser (m_user    [0]),
	.m0_axis_tlast (m_last    [0]),
	.m0_axis_tready(m_ready   [0]),

	.s1_axis_tvalid(s_valid   [1]),
	.s1_axis_tdata (s_data    [1]),
	.s1_axis_tuser (s_user    [1]),
	.s1_axis_tlast (s_last    [1]),
	.s1_axis_tready(s_ready   [1]),
	.s1_dst_bmp    (s_dst_bmp [1]),
	.m1_axis_tvalid(m_valid   [1]),
	.m1_axis_tdata (m_data    [1]),
	.m1_axis_tuser (m_user    [1]),
	.m1_axis_tlast (m_last    [1]),
	.m1_axis_tready(m_ready   [1]),

	.s2_axis_tvalid(s_valid   [2]),
	.s2_axis_tdata (s_data    [2]),
	.s2_axis_tuser (s_user    [2]),
	.s2_axis_tlast (s_last    [2]),
	.s2_axis_tready(s_ready   [2]),
	.s2_dst_bmp    (s_dst_bmp [2]),
	.m2_axis_tvalid(m_valid   [2]),
	.m2_axis_tdata (m_data    [2]),
	.m2_axis_tuser (m_user    [2]),
	.m2_axis_tlast (m_last    [2]),
	.m2_axis_tready(m_ready   [2]),

	.s3_axis_tvalid(s_valid   [3]),
	.s3_axis_tdata (s_data    [3]),
	.s3_axis_tuser (s_user    [3]),
	.s3_axis_tlast (s_last    [3]),
	.s3_axis_tready(s_ready   [3]),
	.s3_dst_bmp    (s_dst_bmp [3]),
	.m3_axis_tvalid(m_valid   [3]),
	.m3_axis_tdata (m_data    [3]),
	.m3_axis_tuser (m_user    [3]),
	.m3_axis_tlast (m_last    [3]),
	.m3_axis_tready(m_ready   [3]),

	.s4_axis_tvalid(s_valid   [4]),
	.s4_axis_tdata (s_data    [4]),
	.s4_axis_tuser (s_user    [4]),
	.s4_axis_tlast (s_last    [4]),
	.s4_axis_tready(s_ready   [4]),
	.s4_dst_bmp    (s_dst_bmp [4]),
	.m4_axis_tvalid(m_valid   [4]),
	.m4_axis_tdata (m_data    [4]),
	.m4_axis_tuser (m_user    [4]),
	.m4_axis_tlast (m_last    [4]),
	.m4_axis_tready(m_ready   [4]),

	.s5_axis_tvalid(s_valid   [5]),
	.s5_axis_tdata (s_data    [5]),
	.s5_axis_tuser (s_user    [5]),
	.s5_axis_tlast (s_last    [5]),
	.s5_axis_tready(s_ready   [5]),
	.s5_dst_bmp    (s_dst_bmp [5]),
	.m5_axis_tvalid(m_valid   [5]),
	.m5_axis_tdata (m_data    [5]),
	.m5_axis_tuser (m_user    [5]),
	.m5_axis_tlast (m_last    [5]),
	.m5_axis_tready(m_ready   [5]),

	.s6_axis_tvalid(s_valid   [6]),
	.s6_axis_tdata (s_data    [6]),
	.s6_axis_tuser (s_user    [6]),
	.s6_axis_tlast (s_last    [6]),
	.s6_axis_tready(s_ready   [6]),
	.s6_dst_bmp    (s_dst_bmp [6]),
	.m6_axis_tvalid(m_valid   [6]),
	.m6_axis_tdata (m_data    [6]),
	.m6_axis_tuser (m_user    [6]),
	.m6_axis_tlast (m_last    [6]),
	.m6_axis_tready(m_ready   [6]),

	.s7_axis_tvalid(s_valid   [7]),
	.s7_axis_tdata (s_data    [7]),
	.s7_axis_tuser (s_user    [7]),
	.s7_axis_tlast (s_last    [7]),
	.s7_axis_tready(s_ready   [7]),
	.s7_dst_bmp    (s_dst_bmp [7]),
	.m7_axis_tvalid(m_valid   [7]),
	.m7_axis_tdata (m_data    [7]),
	.m7_axis_tuser (m_user    [7]),
	.m7_axis_tlast (m_last    [7]),
	.m7_axis_tready(m_ready   [7])
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
	s_random  <= 8'b11111111;
	m_random  <= 8'b11111111;
	m_enprint <= (1 << 5);
	/// NOTE: SELECT ONE TO PRINT
	s_dst_bmp[0] <= (1 << 0);
	s_dst_bmp[1] <= (1 << 1);
	s_dst_bmp[2] <= (1 << 2);
	s_dst_bmp[3] <= (1 << 3);
	s_dst_bmp[4] <= (1 << 4);
	s_dst_bmp[5] <= (1 << 7);
	s_dst_bmp[6] <= (1 << 6);
	s_dst_bmp[7] <= (1 << 5);

	s_width[0] <=  3; s_height[0] <=  5;
	s_width[1] <= 10; s_height[1] <=  9;
	s_width[2] <=  8; s_height[2] <=  7;
	s_width[3] <=  6; s_height[3] <=  3;
	s_width[4] <=  7; s_height[4] <=  8;
	s_width[5] <=  6; s_height[5] <=  5;
	s_width[6] <=  3; s_height[6] <=  2;
	s_width[7] <=  4; s_height[7] <=  8;
end

generate
	genvar i;
	genvar j;
	for (i = 0; i < C_S_STREAM_NUM; i = i + 1) begin: single_input
		reg [C_IMG_BITS-1:0]     s_ridx;
		reg [C_IMG_BITS-1:0]     s_cidx;
		reg en_input;
		always @ (posedge clk) begin
			if (resetn == 1'b0) en_input <= 1'b0;
			else		en_input <= (s_random[i] ? {$random}%2 : 1);
		end
		always @ (posedge clk) begin
			if (resetn == 1'b0)
				s_valid[i] <= 1'b0;
			else if (~s_valid[i]) begin
				if (en_input)
					s_valid[i] <= 1'b1;
			end
			else begin
				if (s_ready[i])
					s_valid[i] <= en_input;
			end
		end
		assign s_data[i] = (s_ridx * 16 + s_cidx) + i * 256;
		assign s_user[i] = (s_ridx == 0 && s_cidx == 0);
		assign s_last[i] = (s_cidx == s_width[i] - 1);

		always @ (posedge clk) begin
			if (resetn == 1'b0) begin
				s_ridx <= 0;
				s_cidx <= 0;
			end
			else if (s_valid[i] && s_ready[i]) begin
				if (s_cidx != s_width[i] - 1) begin
					s_cidx <= s_cidx + 1;
					s_ridx <= s_ridx;
				end
				else if (s_ridx != s_height[i] - 1) begin
					s_cidx <= 0;
					s_ridx <= s_ridx + 1;
				end
				else begin
					s_cidx <= 0;
					s_ridx <= 0;
				end
			end
		end
	end
endgenerate


generate
	for (i = 0; i < C_M_STREAM_NUM; i = i + 1) begin: single_output
		reg [C_IMG_BITS-1:0]     m_ridx;
		reg [C_IMG_BITS-1:0]     m_cidx;
		reg en_output;
		always @ (posedge clk) begin
			if (resetn == 1'b0) en_output <= 1'b0;
			else		en_output <= (m_random[i] ? {$random}%2 : 1);
		end
		always @(posedge clk) begin
			if (resetn == 1'b0)
				m_ready[i] <= 1'b0;
			else if (~m_ready[i])
				m_ready[i] <= en_output;
			else begin
				if (m_valid[i])
					m_ready[i] <= en_output;
			end
		end
		always @(posedge clk) begin
			if (resetn == 1'b0) begin
				m_ridx = 0;
				m_cidx = 0;
			end
			else if (m_ready[i] && m_valid[i]) begin
				if (m_user[i]) begin
					m_ridx = 0;
					m_cidx = 0;
				end
				else if (m_last[i]) begin
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
			else if (m_ready[i] && m_valid[i] && m_enprint[i]) begin
				if (m_user[i])
					$write("out %h start new frame: \n", i);
				$write("%h ", m_data[i]);
				if (m_last[i])
					$write("\n");
			end
		end
	end
endgenerate


endmodule
