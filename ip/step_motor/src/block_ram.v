module block_ram #(
	parameter C_DATA_WIDTH = 8,
	parameter C_ADDRESS_WIDTH = 8
)(
	input clk,

	input wire weA,
	input wire [(C_DATA_WIDTH-1):0] dataA,
	input wire [(C_ADDRESS_WIDTH-1):0] addrA,
	output reg [(C_DATA_WIDTH-1):0] qA,

	input wire weB,
	input wire [(C_ADDRESS_WIDTH-1):0] addrB,
	input wire [(C_DATA_WIDTH-1):0] dataB,
	output reg [(C_DATA_WIDTH-1):0] qB
);
	reg [C_DATA_WIDTH-1:0] ram[2**C_ADDRESS_WIDTH-1:0];

	always @ (posedge clk) begin
		if (weA) begin
			ram[addrA] <= dataA;
			qA <= dataA;
		end
		else
			qA <= ram[addrA];
	end

	always @ (posedge clk) begin
		if (weB) begin
			ram[addrB] <= dataB;
			qB <= dataB;
		end
		else
			qB <= ram[addrB];
	end

endmodule
