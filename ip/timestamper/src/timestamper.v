`timescale 1ns / 1ps

module timestamper #
(
	parameter integer C_TS_WIDTH = 64
) (
	input  wire clk,
	input  wire resetn,

	output wire [C_TS_WIDTH-1:0] ts
);

	reg [C_TS_WIDTH-1:0] lvl0_ts;
	assign ts = lvl0_ts;

	always @ (posedge clk) begin
		if (resetn == 0)
			lvl0_ts <= 0;
		else
			lvl0_ts <= lvl0_ts + 1;
	end

endmodule
