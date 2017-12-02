`timescale 1ns / 1ps
`include "../src/axis_blender.v"

module test_axis_blender_common(
);

	parameter integer C_CHN_WIDTH           =  8;
	parameter integer C_S0_CHN_NUM          =  1;
	parameter integer C_S1_CHN_NUM          =  1;
	parameter integer C_ALPHA_WIDTH         =  0;
	parameter integer C_S1_ENABLE           =  0;
	parameter integer C_IN_NEED_WIDTH       =  2;
	parameter integer C_OUT_NEED_WIDTH      =  1;	/// must be (C_IN_NEED_WIDTH - 1), min val is 0
	parameter integer C_M_WIDTH             =  8;	/// must be max(C_S0_CHN_NUM, C_S1_CHN_NUM) * C_CHN_WIDTH
	parameter integer C_TEST                =  0;

	reg clk;
	reg resetn;

	localparam integer C_MAX_STREAM_NUM =  2;
	localparam integer C_IMG_BITS       = 12;

	reg [C_MAX_STREAM_NUM-1:0]                     s_random ;

	reg [C_IMG_BITS-1:0]                 s_width  [C_MAX_STREAM_NUM-1:0];
	reg [C_IMG_BITS-1:0]                 s_height [C_MAX_STREAM_NUM-1:0];

	reg [C_IMG_BITS-1:0] s1_left;
	reg [C_IMG_BITS-1:0] s1_top;

	reg                                  s_valid  [C_MAX_STREAM_NUM-1:0];
	wire [C_M_WIDTH + C_ALPHA_WIDTH-1:0] s_data   [C_MAX_STREAM_NUM-1:0];
	wire [C_IN_NEED_WIDTH:0]             s_user   [C_MAX_STREAM_NUM-1:0];
	wire                                 s_last   [C_MAX_STREAM_NUM-1:0];
	wire                                 s_ready  [C_MAX_STREAM_NUM-1:0];
	reg                                  s_enable [C_MAX_STREAM_NUM-1:0];

	reg                               m_random ;
	reg                               m_enprint;

	wire                     m_valid  ;
	wire [C_M_WIDTH-1:0]     m_data   ;
	wire [C_OUT_NEED_WIDTH:0]m_user   ;
	wire                     m_last   ;
	reg                      m_ready  ;

axis_blender # (
	.C_CHN_WIDTH          (C_CHN_WIDTH     ),
	.C_S0_CHN_NUM         (C_S0_CHN_NUM    ),
	.C_S1_CHN_NUM         (C_S1_CHN_NUM    ),
	.C_ALPHA_WIDTH        (C_ALPHA_WIDTH   ),
	.C_S1_ENABLE          (C_S1_ENABLE     ),
	.C_IN_NEED_WIDTH      (C_IN_NEED_WIDTH ),
	.C_OUT_NEED_WIDTH     (C_OUT_NEED_WIDTH),
	.C_M_WIDTH            (C_M_WIDTH       ),
	.C_TEST               (C_TEST          )
) uut (
	.clk(clk),
	.resetn(resetn),

	.s0_axis_tvalid(s_valid   [0]),
	.s0_axis_tdata (s_data    [0][C_S0_CHN_NUM*C_CHN_WIDTH-1:0]),
	.s0_axis_tuser (s_user    [0]),
	.s0_axis_tlast (s_last    [0]),
	.s0_axis_tready(s_ready   [0]),

	.s1_enable     (s_enable  [0]),
	.s1_axis_tvalid(s_valid   [1]),
	.s1_axis_tdata (s_data    [1][C_S1_CHN_NUM*C_CHN_WIDTH-1:0]),
	.s1_axis_tuser (s_user    [1][0]),
	.s1_axis_tlast (s_last    [1]),
	.s1_axis_tready(s_ready   [1]),

	.m_axis_tvalid(m_valid   ),
	.m_axis_tdata (m_data    ),
	.m_axis_tuser (m_user    ),
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

reg[1:0]   enable_s;

initial begin
	s_enable[0]  <= 1;
	s_enable[1]  <= 1;
	s_random  <= 2'b00;
	m_random  <= 1'b0;
	m_enprint <= 1'b1;

	s_width [0] <= 10;
	s_height[0] <=  8;

	s_width [1] <= 3;
	s_height[1] <= 4;

	s1_left  <= 3;
	s1_top   <= 2;

	enable_s[0] <= 1;
	enable_s[1] <= 1;
end

reg [31:0] s1delay;
always @ (posedge clk) begin
	if (resetn == 1'b0)
		s1delay <= 1000;
	else if (s1delay)
		s1delay <= s1delay - 1;
end

generate
	genvar i;
	genvar j;
	for (i = 0; i < 2; i = i + 1) begin: single_input
		reg [C_IMG_BITS-1:0]     s_ridx;
		reg [C_IMG_BITS-1:0]     s_cidx;
		reg en_input;
		always @ (posedge clk) begin
			if (resetn == 1'b0)
				en_input <= 1'b0;
			else
				en_input <= (enable_s[i] ? (s_random[i] ? {$random}%2 : 1) : 0) & (s1delay == 0);
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
		if (i == 0)
			assign s_data[i]    = (s_ridx * 16 + s_cidx);
		else
			assign s_data[i]    = 0;
		assign s_user[i][0] = (s_ridx == 0 && s_cidx == 0);
		assign s_last[i]    = (s_cidx == s_width[i] - 1);

		assign s_user[i][1] = (enable_s[1] ? (s_ridx >= s1_top && s_ridx < s1_top + s_height[1]
					&& s_cidx >= s1_left && s_cidx < s1_left + s_width[1]) : 0);

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
		reg [C_IMG_BITS-1:0]     m_ridx;
		reg [C_IMG_BITS-1:0]     m_cidx;
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
				if (m_user[0]) begin
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
				if (m_user[0])
					$write("out new frame: \n");
				$write("%h ", m_data);
				if (m_last)
					$write("\n");
			end
		end
endgenerate

endmodule
