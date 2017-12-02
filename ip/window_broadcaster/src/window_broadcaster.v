
`timescale 1 ns / 1 ps

module window_broadcaster #
(
	parameter integer C_HBITS = 12,
	parameter integer C_WBITS = 12,

	parameter integer C_MASTER_NUM = 1
)
(
	input wire [C_WBITS-1 : 0] s_left,
	input wire [C_WBITS-1 : 0] s_width,
	input wire [C_HBITS-1 : 0] s_top,
	input wire [C_HBITS-1 : 0] s_height,

	output wire [C_WBITS-1 : 0] m0_left,
	output wire [C_WBITS-1 : 0] m0_width,
	output wire [C_HBITS-1 : 0] m0_top,
	output wire [C_HBITS-1 : 0] m0_height,

	output wire [C_WBITS-1 : 0] m1_left,
	output wire [C_WBITS-1 : 0] m1_width,
	output wire [C_HBITS-1 : 0] m1_top,
	output wire [C_HBITS-1 : 0] m1_height,

	output wire [C_WBITS-1 : 0] m2_left,
	output wire [C_WBITS-1 : 0] m2_width,
	output wire [C_HBITS-1 : 0] m2_top,
	output wire [C_HBITS-1 : 0] m2_height,

	output wire [C_WBITS-1 : 0] m3_left,
	output wire [C_WBITS-1 : 0] m3_width,
	output wire [C_HBITS-1 : 0] m3_top,
	output wire [C_HBITS-1 : 0] m3_height,

	output wire [C_WBITS-1 : 0] m4_left,
	output wire [C_WBITS-1 : 0] m4_width,
	output wire [C_HBITS-1 : 0] m4_top,
	output wire [C_HBITS-1 : 0] m4_height,

	output wire [C_WBITS-1 : 0] m5_left,
	output wire [C_WBITS-1 : 0] m5_width,
	output wire [C_HBITS-1 : 0] m5_top,
	output wire [C_HBITS-1 : 0] m5_height,

	output wire [C_WBITS-1 : 0] m6_left,
	output wire [C_WBITS-1 : 0] m6_width,
	output wire [C_HBITS-1 : 0] m6_top,
	output wire [C_HBITS-1 : 0] m6_height,

	output wire [C_WBITS-1 : 0] m7_left,
	output wire [C_WBITS-1 : 0] m7_width,
	output wire [C_HBITS-1 : 0] m7_top,
	output wire [C_HBITS-1 : 0] m7_height
);
	localparam integer C_MAX_OUT = 8;
	wire [C_WBITS-1 : 0] m_left  [C_MAX_OUT-1:0];
	wire [C_WBITS-1 : 0] m_width [C_MAX_OUT-1:0];
	wire [C_HBITS-1 : 0] m_top   [C_MAX_OUT-1:0];
	wire [C_HBITS-1 : 0] m_height[C_MAX_OUT-1:0];
`define ASSIGN_SINGLE_O(i) \
	assign m``i``_left   = m_left  [i]; \
	assign m``i``_width  = m_width [i]; \
	assign m``i``_top    = m_top   [i]; \
	assign m``i``_height = m_height[i];

	`ASSIGN_SINGLE_O(0)
	`ASSIGN_SINGLE_O(1)
	`ASSIGN_SINGLE_O(2)
	`ASSIGN_SINGLE_O(3)
	`ASSIGN_SINGLE_O(4)
	`ASSIGN_SINGLE_O(5)
	`ASSIGN_SINGLE_O(6)
	`ASSIGN_SINGLE_O(7)
	generate
		genvar i;
		for (i=0; i < C_MAX_OUT; i = i+1) begin: single_output
			if (i < C_MASTER_NUM) begin
				assign m_left  [i] = s_left  ;
				assign m_top   [i] = s_top   ;
				assign m_width [i] = s_width ;
				assign m_height[i] = s_height;
			end
			else begin
				assign m_left  [i] = 0;
				assign m_top   [i] = 0;
				assign m_width [i] = 0;
				assign m_height[i] = 0;
			end
		end
	endgenerate

endmodule
