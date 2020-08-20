`timescale 1 ns / 1 ps

module asym_ram(clkW, clkR, we, re, wa, ra, wd, rd);
	parameter WR_DATA_WIDTH = 64;
	parameter WR_ADDR_WIDTH = 9;
	parameter RD_DATA_WIDTH = 8;
	parameter RD_ADDR_WIDTH = 12;

	input clkW;
	input we;
	input [WR_ADDR_WIDTH-1:0] wa;
	input [WR_DATA_WIDTH-1:0] wd;

	input clkR;
	input re;
	input [RD_ADDR_WIDTH-1:0] ra;
	output [RD_DATA_WIDTH-1:0] rd;

	`define max(a,b) {(a) > (b) ? (a) : (b)}
	`define min(a,b) {(a) < (b) ? (a) : (b)}

	function integer log2;
		input integer value;

		integer shifted;
		integer res;
		begin
			shifted = value-1;
			for (res=0; shifted>0; res=res+1)
				shifted = shifted>>1;
			log2 = res;
		end
	endfunction
	localparam SIZEA = 2**WR_ADDR_WIDTH;
	localparam SIZEB = 2**RD_ADDR_WIDTH;
	localparam maxSIZE = `max(SIZEA, SIZEB);

	localparam maxWIDTH = `max(WR_DATA_WIDTH, RD_DATA_WIDTH);
	localparam minWIDTH = `min(WR_DATA_WIDTH, RD_DATA_WIDTH);
	localparam RATIO = maxWIDTH / minWIDTH;
	localparam log2RATIO = log2(RATIO);

	reg [minWIDTH-1:0] RAM [0:maxSIZE-1];
	reg [RD_DATA_WIDTH-1:0] readB;
	assign rd = readB;

	generate
		if (WR_DATA_WIDTH <= RD_DATA_WIDTH) begin
			always @(posedge clkW) begin
				if (we)
					RAM[wa] <= wd;
			end
		end
		else begin
			always @(posedge clkW) begin: ramwrite
				integer i;
				reg [log2RATIO-1:0] lsbaddr;
				if (we) begin
					for (i = 0; i < RATIO; i = i+1) begin
						lsbaddr = i;
						RAM[{wa,lsbaddr}] <= wd[(i+1)*minWIDTH-1 -: minWIDTH];
					end
				end
			end
		end

		if (WR_DATA_WIDTH >= RD_DATA_WIDTH) begin
			always @(posedge clkR) begin
				if (re)
					readB <= RAM[ra];
			end
		end
		else begin
			always @(posedge clkR) begin : ramread
				integer i;
				reg [log2RATIO-1:0] lsbaddr;
				if (re) begin
					for (i = 0; i < RATIO; i = i+1) begin
						lsbaddr = i;
						readB[(i+1)*minWIDTH-1 -: minWIDTH] <= RAM[{ra,lsbaddr}];
					end
				end
			end
		end
	endgenerate
endmodule
