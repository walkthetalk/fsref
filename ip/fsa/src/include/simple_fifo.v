module simple_fifo # (
	parameter DEPTH_WIDTH     = 1,
	parameter DATA_WIDTH      = 1,
	parameter ALMOST_FULL_TH  = 1,
	parameter ALMOST_EMPTY_TH = 1
) (
	input  wire                  clk,
	input  wire                  rst,

	input  wire [DATA_WIDTH-1:0] wr_data,
	input  wire                  wr_en,

	output wire [DATA_WIDTH-1:0] rd_data,
	input  wire                  rd_en,

	output wire             full,
	output wire             empty,
	output wire             almost_full,
	output wire             almost_empty
);

//synthesis translate_off
initial begin
	if (DEPTH_WIDTH < 1) $display("%m : Warning: DEPTH_WIDTH must be > 0. Setting minimum value (1)");
	if (DATA_WIDTH  < 1) $display("%m : Warning: DATA_WIDTH must be > 0. Setting minimum value (1)");
end
//synthesis translate_on

	localparam integer DW = (DATA_WIDTH  < 1) ? 1 : DATA_WIDTH;
	localparam integer AW = (DEPTH_WIDTH < 1) ? 1 : DEPTH_WIDTH;
	localparam integer FULLCNT = {1'b1, {(DEPTH_WIDTH){1'b0}}};

	reg [AW  :0] cnt;
	reg [AW-1:0] write_p;
	reg [AW-1:0] read_p;

	wire we, re;
	assign we = (wr_en & ~full);
	assign re = (rd_en & ~empty);

	always @ (posedge clk) begin
		if (rst)
			write_p <= 0;
		else if (we)
			write_p <= write_p + 1;
	end

	always @ (posedge clk) begin
		if (rst)
			read_p <= 0;
		else if (re)
			read_p <= read_p + 1;
	end

	always @ (posedge clk) begin
		if (rst)
			cnt <= 0;
		else begin
			case ({we, re})
			2'b10: cnt <= cnt + 1;
			2'b01: cnt <= cnt - 1;
			default: cnt <= cnt;
			endcase
		end
	end

/// empty
	reg r_empty;
	assign empty = r_empty;
	always @ (posedge clk) begin
		if (rst)
			r_empty <= 1;
		else begin
			case ({we, re})
			2'b10: r_empty <= 0;
			2'b01: r_empty <= (cnt == 1);
			default: r_empty <= r_empty;
			endcase
		end
	end

/// full
	assign full = (cnt[AW]);

/// almost_empty
	reg r_almost_empty;
	assign almost_empty = r_almost_empty;
	always @ (posedge clk) begin
		if (rst)
			r_almost_empty <= 1'b1;
		else begin
			case ({we, re})
			2'b10: if (cnt == ALMOST_EMPTY_TH) r_almost_empty <= 0;
			2'b01: if (cnt == (ALMOST_EMPTY_TH + 1)) r_almost_empty <= 1;
			default: r_almost_empty <= r_almost_empty;
			endcase
		end
	end
/// almost_full
	reg r_almost_full;
	assign almost_full = r_almost_full;
	always @ (posedge clk) begin
		if (rst)
			r_almost_full <= (DEPTH_WIDTH == 0);
		else begin
			case ({we, re})
			2'b10: if (cnt == (FULLCNT - ALMOST_FULL_TH - 1)) r_almost_full <= 1;
			2'b01: if (cnt == (FULLCNT - ALMOST_FULL_TH)) r_almost_full <= 0;
			default: r_almost_full <= r_almost_full;
			endcase
		end
	end

	simple_dpram_sclk # (
		.ADDR_WIDTH(AW),
		.DATA_WIDTH(DW),
		.ENABLE_BYPASS(1)
	) fifo_ram (
		.clk	(clk),
		.dout	(rd_data),
		.raddr	(read_p[AW-1:0]),
		.re	(re),
		.waddr	(write_p[AW-1:0]),
		.we	(we),
		.din	(wr_data)
	);

endmodule
