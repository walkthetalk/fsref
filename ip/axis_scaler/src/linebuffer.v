module linebuffer #(
	parameter C_DATA_WIDTH = 8,
	parameter C_ADDRESS_WIDTH = 8
)(
	input clk,

	input  wire                       w0,
	input  wire [C_ADDRESS_WIDTH-1:0] a0,
	input  wire [C_DATA_WIDTH-1   :0] d0,

	input  wire [C_ADDRESS_WIDTH-1:0] a1,
	output reg  [C_DATA_WIDTH-1   :0] q1
);
	reg [C_DATA_WIDTH-1:0] ram[2**C_ADDRESS_WIDTH-1:0];

	always @ (posedge clk) begin
		if (w0)
			ram[a0] <= d0;
	end
	always @ (posedge clk) begin
		q1 <= ram[a1];
	end

endmodule
