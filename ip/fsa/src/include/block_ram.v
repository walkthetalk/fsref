module block_ram #(
	parameter C_DATA_WIDTH = 8,
	parameter C_ADDRESS_WIDTH = 8
)(
	input clk,

	input wire wr_en,
	input wire [(C_ADDRESS_WIDTH-1):0] wr_addr,
	input wire [(C_DATA_WIDTH-1):0]    wr_data,

	input wire rd_en,
	input wire [(C_ADDRESS_WIDTH-1):0] rd_addr,
	output reg [(C_DATA_WIDTH-1):0]    rd_data
);
	reg [C_DATA_WIDTH-1:0] ram[2**C_ADDRESS_WIDTH-1:0];

	always @ (posedge clk) begin
		if (wr_en)
			ram[wr_addr] <= wr_data;
	end

	always @ (posedge clk) begin
		if (rd_en)
			rd_data <= ram[rd_addr];
	end

endmodule
