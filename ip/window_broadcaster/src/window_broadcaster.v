
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
	generate
		if (C_MASTER_NUM > 0) begin
			assign m0_left   = s_left;
			assign m0_top    = s_top;
			assign m0_width  = s_width;
			assign m0_height = s_height;
		end
		if (C_MASTER_NUM > 1) begin
			assign m1_left   = s_left;
			assign m1_top    = s_top;
			assign m1_width  = s_width;
			assign m1_height = s_height;
		end
		if (C_MASTER_NUM > 2) begin
			assign m2_left   = s_left;
			assign m2_top    = s_top;
			assign m2_width  = s_width;
			assign m2_height = s_height;
		end
		if (C_MASTER_NUM > 3) begin
			assign m3_left   = s_left;
			assign m3_top    = s_top;
			assign m3_width  = s_width;
			assign m3_height = s_height;
		end
		if (C_MASTER_NUM > 4) begin
			assign m4_left   = s_left;
			assign m4_top    = s_top;
			assign m4_width  = s_width;
			assign m4_height = s_height;
		end
		if (C_MASTER_NUM > 5) begin
			assign m5_left   = s_left;
			assign m5_top    = s_top;
			assign m5_width  = s_width;
			assign m5_height = s_height;
		end
		if (C_MASTER_NUM > 6) begin
			assign m6_left   = s_left;
			assign m6_top    = s_top;
			assign m6_width  = s_width;
			assign m6_height = s_height;
		end
		if (C_MASTER_NUM > 7) begin
			assign m7_left   = s_left;
			assign m7_top    = s_top;
			assign m7_width  = s_width;
			assign m7_height = s_height;
		end
	endgenerate

endmodule
