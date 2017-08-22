
`timescale 1 ns / 1 ps

module axilite2regctl #
(
	// Users to add parameters here

	// User parameters ends
	// Do not modify the parameters beyond this line

	// Width of S_AXI data bus
	parameter integer C_DATA_WIDTH	= 32,
	// Width of S_AXI address bus
	parameter integer C_ADDR_WIDTH	= 8
)
(
	input wire  clk,
	input wire  resetn,

	/// reg ctl interface
	output [C_ADDR_WIDTH-1:0] rd_addr,
	input [C_DATA_WIDTH-1:0] rd_data,

	output wr_en,
	output [C_ADDR_WIDTH-1:0] wr_addr,
	output [C_DATA_WIDTH-1:0] wr_data,

	/// slave axi lite
	input wire [C_ADDR_WIDTH-1 : 0] s_axi_awaddr,
	input wire [2 : 0] s_axi_awprot,
	input wire  s_axi_awvalid,
	output wire  s_axi_awready,
	input wire [C_DATA_WIDTH-1 : 0] s_axi_wdata,
	input wire  s_axi_wvalid,
	output wire  s_axi_wready,
	output wire [1 : 0] s_axi_bresp,
	output wire  s_axi_bvalid,
	input wire  s_axi_bready,
	input wire [C_ADDR_WIDTH-1 : 0] s_axi_araddr,
	input wire [2 : 0] s_axi_arprot,
	input wire  s_axi_arvalid,
	output wire  s_axi_arready,
	output wire [C_DATA_WIDTH-1 : 0] s_axi_rdata,
	output wire [1 : 0] s_axi_rresp,
	output wire  s_axi_rvalid,
	input wire  s_axi_rready
);

	// AXI4LITE signals
	reg [C_ADDR_WIDTH-1 : 0] 	axi_awaddr;
	reg  	axi_awready;
	reg  	axi_wready;
	reg [1 : 0] 	axi_bresp;
	reg  	axi_bvalid;
	reg [C_ADDR_WIDTH-1 : 0] 	axi_araddr;
	reg  	axi_arready;
	reg [C_DATA_WIDTH-1 : 0] 	axi_rdata;
	reg [1 : 0] 	axi_rresp;
	reg  	axi_rvalid;

	wire	 slv_reg_rden;
	wire	 slv_reg_wren;
	integer	 byte_index;
	reg	 aw_en;

	/**
	 * read/write interface
	 */
	assign rd_addr = axi_araddr;
	assign wr_addr = axi_awaddr;
	assign wr_en = slv_reg_wren;
	assign wr_data = s_axi_wdata;

	// I/O Connections assignments

	assign s_axi_awready	= axi_awready;
	assign s_axi_wready	= axi_wready;
	assign s_axi_bresp	= axi_bresp;
	assign s_axi_bvalid	= axi_bvalid;
	assign s_axi_arready	= axi_arready;
	assign s_axi_rdata	= axi_rdata;
	assign s_axi_rresp	= axi_rresp;
	assign s_axi_rvalid	= axi_rvalid;
	// Implement axi_awready generation
	// axi_awready is asserted for one clk clock cycle when both
	// s_axi_awvalid and s_axi_wvalid are asserted. axi_awready is
	// de-asserted when reset is low.

	always @( posedge clk )
	begin
		if ( resetn == 1'b0 )
		begin
		axi_awready <= 1'b0;
		aw_en <= 1'b1;
		end
		else
		begin
		if (~axi_awready && s_axi_awvalid && s_axi_wvalid && aw_en)
		begin
			// slave is ready to accept write address when
			// there is a valid write address and write data
			// on the write address and data bus. This design
			// expects no outstanding transactions.
			axi_awready <= 1'b1;
			aw_en <= 1'b0;
		end
		else if (s_axi_bready && axi_bvalid)
			begin
			aw_en <= 1'b1;
			axi_awready <= 1'b0;
			end
		else
		begin
			axi_awready <= 1'b0;
		end
		end
	end

	// Implement axi_awaddr latching
	// This process is used to latch the address when both
	// s_axi_awvalid and s_axi_wvalid are valid.

	always @( posedge clk )
	begin
		if ( resetn == 1'b0 )
		begin
		axi_awaddr <= 0;
		end
		else
		begin
		if (~axi_awready && s_axi_awvalid && s_axi_wvalid && aw_en)
		begin
			// Write Address latching
			axi_awaddr <= s_axi_awaddr;
		end
		end
	end

	// Implement axi_wready generation
	// axi_wready is asserted for one clk clock cycle when both
	// s_axi_awvalid and s_axi_wvalid are asserted. axi_wready is
	// de-asserted when reset is low.

	always @( posedge clk )
	begin
		if ( resetn == 1'b0 )
		begin
		axi_wready <= 1'b0;
		end
		else
		begin
		if (~axi_wready && s_axi_wvalid && s_axi_awvalid && aw_en )
		begin
			// slave is ready to accept write data when
			// there is a valid write address and write data
			// on the write address and data bus. This design
			// expects no outstanding transactions.
			axi_wready <= 1'b1;
		end
		else
		begin
			axi_wready <= 1'b0;
		end
		end
	end

	// Implement memory mapped register select and write logic generation
	// The write data is accepted and written to memory mapped registers when
	// axi_awready, s_axi_wvalid, axi_wready and s_axi_wvalid are asserted. Write strobes are used to
	// select byte enables of slave registers while writing.
	// These registers are cleared when reset (active low) is applied.
	// Slave register write enable is asserted when valid address and data are available
	// and the slave is ready to accept the write address and write data.
	assign slv_reg_wren = axi_wready && s_axi_wvalid && axi_awready && s_axi_awvalid;

	// Implement write response logic generation
	// The write response and response valid signals are asserted by the slave
	// when axi_wready, s_axi_wvalid, axi_wready and s_axi_wvalid are asserted.
	// This marks the acceptance of address and indicates the status of
	// write transaction.

	always @( posedge clk )
	begin
		if ( resetn == 1'b0 )
		begin
		axi_bvalid  <= 0;
		axi_bresp   <= 2'b0;
		end
		else
		begin
		if (axi_awready && s_axi_awvalid && ~axi_bvalid && axi_wready && s_axi_wvalid)
		begin
			// indicates a valid write response is available
			axi_bvalid <= 1'b1;
			axi_bresp  <= 2'b0; // 'OKAY' response
		end                   // work error responses in future
		else
		begin
			if (s_axi_bready && axi_bvalid)
			//check if bready is asserted while bvalid is high)
			//(there is a possibility that bready is always asserted high)
			begin
			axi_bvalid <= 1'b0;
			end
		end
		end
	end

	// Implement axi_arready generation
	// axi_arready is asserted for one clk clock cycle when
	// s_axi_arvalid is asserted. axi_awready is
	// de-asserted when reset (active low) is asserted.
	// The read address is also latched when s_axi_arvalid is
	// asserted. axi_araddr is reset to zero on reset assertion.

	always @( posedge clk )
	begin
		if ( resetn == 1'b0 )
		begin
		axi_arready <= 1'b0;
		axi_araddr  <= 32'b0;
		end
		else
		begin
		if (~axi_arready && s_axi_arvalid)
		begin
			// indicates that the slave has acceped the valid read address
			axi_arready <= 1'b1;
			// Read address latching
			axi_araddr  <= s_axi_araddr;
		end
		else
		begin
			axi_arready <= 1'b0;
		end
		end
	end

	// Implement axi_arvalid generation
	// axi_rvalid is asserted for one clk clock cycle when both
	// s_axi_arvalid and axi_arready are asserted. The slave registers
	// data are available on the axi_rdata bus at this instance. The
	// assertion of axi_rvalid marks the validity of read data on the
	// bus and axi_rresp indicates the status of read transaction.axi_rvalid
	// is deasserted on reset (active low). axi_rresp and axi_rdata are
	// cleared to zero on reset (active low).
	always @( posedge clk )
	begin
		if ( resetn == 1'b0 )
		begin
		axi_rvalid <= 0;
		axi_rresp  <= 0;
		end
		else
		begin
		if (axi_arready && s_axi_arvalid && ~axi_rvalid)
		begin
			// Valid read data is available at the read data bus
			axi_rvalid <= 1'b1;
			axi_rresp  <= 2'b0; // 'OKAY' response
		end
		else if (axi_rvalid && s_axi_rready)
		begin
			// Read data is accepted by the master
			axi_rvalid <= 1'b0;
		end
		end
	end

	// Implement memory mapped register select and read logic generation
	// Slave register read enable is asserted when valid address is available
	// and the slave is ready to accept the read address.
	assign slv_reg_rden = axi_arready & s_axi_arvalid & ~axi_rvalid;

	// Output register or memory read data
	always @( posedge clk )
	begin
		if ( resetn == 1'b0 )
		begin
		axi_rdata  <= 0;
		end
		else
		begin
		// When there is a valid read address (s_axi_arvalid) with
		// acceptance of read address by the slave (axi_arready),
		// output the read dada
		if (slv_reg_rden)
		begin
			axi_rdata <= rd_data;     // register read data
		end
		end
	end

	// Add user logic here

	// User logic ends

endmodule
