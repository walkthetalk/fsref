module abs #(
	parameter integer C_WIDTH = 32
)(
	input signed [C_WIDTH-1:0] din,
	output[C_WIDTH-1:0] dout
);

	assign dout = (din[C_WIDTH-1] == 1) ? (~din + 1'b1) : din;

endmodule
