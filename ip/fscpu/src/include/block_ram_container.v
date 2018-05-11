module block_ram_container #(
	parameter C_DATA_WIDTH = 8,
	parameter C_ADDRESS_WIDTH = 8
)(
	input clk,

	input  wire                     wr_resetn,
	input  wire                     wr_en,
	input  wire [C_DATA_WIDTH-1:0]  wr_data,
	output wire [C_ADDRESS_WIDTH:0] size,

	//input wire reA,
	input wire [(C_ADDRESS_WIDTH-1):0] addrA,
	output wire [(C_DATA_WIDTH-1):0] qA,

	//input wire reB,
	input wire [(C_ADDRESS_WIDTH-1):0] addrB,
	output wire [(C_DATA_WIDTH-1):0] qB
);
	assign size = (2**C_ADDRESS_WIDTH);

	reg  [C_ADDRESS_WIDTH-1 : 0] wr_addr;
	always @ (posedge clk) begin
		if (wr_resetn == 1'b0)
			wr_addr <= 0;
		else if (wr_en)
			wr_addr <= wr_addr + 1;
	end

	block_ram # (
		.C_DATA_WIDTH(C_DATA_WIDTH),
		.C_ADDRESS_WIDTH(C_ADDRESS_WIDTH)
	) br_inst (
		.clk(clk),
		.weA(wr_en),
		.dataA(wr_data),
		//.reA(reA),
		.addrA(wr_resetn ? wr_addr : addrA),
		.qA(qA),
		.weB(1'b0),
		.addrB(addrB),
		.dataB(0),
		//.reB(reB),
		.qB(qB)
	);

endmodule
