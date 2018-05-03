module simple_dpram_sclk # (
	parameter ADDR_WIDTH = 32,
	parameter DATA_WIDTH = 32,
	parameter ENABLE_BYPASS = 1
) (
	input			clk,
	input  [ADDR_WIDTH-1:0]	raddr,
	input		 	re,
	input  [ADDR_WIDTH-1:0]	waddr,
	input 			we,
	input  [DATA_WIDTH-1:0]	din,
	output [DATA_WIDTH-1:0]	dout
);

   reg [DATA_WIDTH-1:0]     mem[(1<<ADDR_WIDTH)-1:0];
   reg [DATA_WIDTH-1:0]     rdata;

generate
if (ENABLE_BYPASS) begin : bypass_gen
	reg [DATA_WIDTH-1:0]     din_r;
	reg 			 bypass;

	assign dout = bypass ? din_r : rdata;

	always @(posedge clk) begin
		if (re)
			din_r <= din;
	end

	always @(posedge clk) begin
		if (re) begin
			if (waddr == raddr && we)
				bypass <= 1;
			else
				bypass <= 0;
		end
	end
end else begin
	assign dout = rdata;
end
endgenerate

	always @(posedge clk) begin
		if (we)
			mem[waddr] <= din;
		if (re)
			rdata <= mem[raddr];
	end

endmodule
