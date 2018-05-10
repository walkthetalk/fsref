module block_ram #(
	parameter C_DATA_WIDTH = 8,
	parameter C_ADDRESS_WIDTH = 8
)(
	input clk,

	input  wire                     wr_resetn,
	input  wire                     wr_en,
	input  wire [C_DATA_WIDTH-1:0]  wr_data,
	output wire [C_ADDRESS_WIDTH:0] size,

	input wire reA,
	input wire [(C_ADDRESS_WIDTH-1):0] addrA,
	output reg [(C_DATA_WIDTH-1):0] qA,

	input wire reB,
	input wire [(C_ADDRESS_WIDTH-1):0] addrB,
	output reg [(C_DATA_WIDTH-1):0] qB
);
	reg [C_DATA_WIDTH-1:0] ram[2**C_ADDRESS_WIDTH-1:0];

	assign size = (2**C_ADDRESS_WIDTH);
	reg  [C_ADDRESS_WIDTH-1 : 0] wr_addr;
	always @ (posedge clk) begin
		if (wr_resetn == 1'b0)
			wr_addr <= 0;
		else if (wr_en)
			wr_addr <= wr_addr + 1;
	end

	always @ (posedge clk) begin
		if (wr_resetn && wr_en)
			ram[wr_addr] <= wr_data;
		if (reA)
			qA <= ram[addrA];
		if (reB)
			qB <= ram[addrB];
	end

endmodule
