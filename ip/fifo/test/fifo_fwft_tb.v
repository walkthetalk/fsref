`include "../src/fifo/fifo_fwft.v"

module fifo_fwft_tb # (
	parameter depth_width = 4
);

	localparam dw = 16;

	reg clk = 1'b1;
	reg rst = 1'b1;

	always  #10  clk <= ~clk;
	initial #100 rst <= 0;

	reg  [dw-1:0] wr_data;
	wire          wr_en;
	wire [dw-1:0] rd_data;
	wire          rd_en;
	wire          full;
	wire          empty;

	fifo_fwft # (
		.DEPTH_WIDTH (depth_width),
		.DATA_WIDTH  (dw)
	) dut (
		.clk (clk),
		.rst (rst),

		.din	(wr_data),
		.wr_en	(wr_en & !full),
		.full	(full),

		.dout   (rd_data),
		.rd_en	(rd_en),
		.empty	(empty)
	);

	reg random_write;
	always @ (posedge clk) begin
		if (rst)
			random_write <= 0;
		else
			random_write <= ({$random} % 2 == 0);
	end

	assign wr_en = random_write && ~full;

	always @ (posedge clk) begin
		if (rst)
			wr_data <= 0;
		else if (wr_en)
			wr_data <= wr_data + 1;
	end

	reg random_read;
	always @ (posedge clk) begin
		if (rst)
			random_read <= 0;
		else
			random_read <= ({$random} % 4 == 0);
	end
	assign rd_en = ~rst && ~empty && random_read;
endmodule
