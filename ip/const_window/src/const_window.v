
`timescale 1 ns / 1 ps

module const_window #
(
	parameter integer C_HBITS = 12,
	parameter integer C_WBITS = 12,

	parameter integer C_TOP = 0,
	parameter integer C_LEFT = 0,
	parameter integer C_WIDTH = 320,
	parameter integer C_HEIGHT = 240
)
(

	output wire [C_WBITS-1 : 0] left,
	output wire [C_WBITS-1 : 0] width,
	output wire [C_HBITS-1 : 0] top,
	output wire [C_HBITS-1 : 0] height
);
	assign left   = C_LEFT;
	assign width  = C_WIDTH;
	assign top    = C_TOP;
	assign height = C_HEIGHT;

endmodule
