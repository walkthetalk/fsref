`include "./simple_fifo.v"
`include "./fifo_fwft_adapter.v"

module fifo_fwft # (
	parameter DATA_WIDTH = 0,
	parameter DEPTH_WIDTH = 0
) (
	input  wire                  clk,
	input  wire                  rst,
	input  wire [DATA_WIDTH-1:0] din,
	input  wire                  wr_en,
	output wire                  full,
	output wire [DATA_WIDTH-1:0] dout,
	input  wire                  rd_en,
	output wire                  empty,
	output wire                  valid
);

	wire [DATA_WIDTH-1:0]    fifo_dout;
	wire                     fifo_empty;
	wire                     fifo_rd_en;

	// orig_fifo is just a normal (non-FWFT) synchronous or asynchronous FIFO
	simple_fifo # (
		.DEPTH_WIDTH (DEPTH_WIDTH),
		.DATA_WIDTH  (DATA_WIDTH )
	) fifo0 (
		.clk       (clk       ),
		.rst       (rst       ),
		.rd_en     (fifo_rd_en),
		.rd_data   (fifo_dout ),
		.empty     (fifo_empty),
		.wr_en     (wr_en     ),
		.wr_data   (din       ),
		.full      (full      )
	);

	fifo_fwft_adapter # (
		.DATA_WIDTH (DATA_WIDTH)
	) fwft_adapter (
		.clk          (clk       ),
		.rst          (rst       ),
		.rd_en        (rd_en     ),
		.fifo_empty   (fifo_empty),
		.fifo_rd_en   (fifo_rd_en),
		.fifo_dout    (fifo_dout ),
		.dout         (dout      ),
		.empty        (empty     ),
		.valid        (valid     )
	);

endmodule
