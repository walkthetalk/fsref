`timescale 1 ns / 1 ps
/**
 * @note:
 * 1. width of image must be integral multiple of C_M_AXI_DATA_WIDTH.
 */
module line_reader #
(
	parameter integer C_IMG_WBITS	= 12,
	parameter integer C_WRITE_INDEX_BITS = 10,

	// Burst Length. Supports 1, 2, 4, 8, 16, 32, 64, 128, 256 burst lengths
	parameter integer C_M_AXI_BURST_LEN	= 16,
	// Width of Address Bus
	parameter integer C_M_AXI_ADDR_WIDTH	= 32,
	// Width of Data Bus
	parameter integer C_M_AXI_DATA_WIDTH	= 32
)
(
	input wire [C_IMG_WBITS-1:0] img_width,

	input wire sol,
	input wire [C_M_AXI_ADDR_WIDTH-1 : 0] line_addr,

	output wire end_of_line_pulse,
	output wire [C_M_AXI_DATA_WIDTH-1 : 0] wr_data,
	output wire [C_WRITE_INDEX_BITS-1 : 0] wr_addr,
	output wire wr_en,

	input wire  M_AXI_ACLK,
	input wire  M_AXI_ARESETN,

	output wire [C_M_AXI_ADDR_WIDTH-1 : 0] M_AXI_ARADDR,
	output wire [7 : 0] M_AXI_ARLEN,
	output wire [2 : 0] M_AXI_ARSIZE,
	output wire [1 : 0] M_AXI_ARBURST,
	output wire  M_AXI_ARLOCK,
	output wire [3 : 0] M_AXI_ARCACHE,
	output wire [2 : 0] M_AXI_ARPROT,
	output wire [3 : 0] M_AXI_ARQOS,
	output wire  M_AXI_ARVALID,
	input wire  M_AXI_ARREADY,

	input wire [C_M_AXI_DATA_WIDTH-1 : 0] M_AXI_RDATA,
	input wire [1 : 0] M_AXI_RRESP,
	input wire  M_AXI_RLAST,
	input wire  M_AXI_RVALID,
	output wire  M_AXI_RREADY
);

	function integer clogb2 (input integer bit_depth);
	begin
		for(clogb2=0; bit_depth>0; clogb2=clogb2+1)
			bit_depth = bit_depth >> 1;
	end
	endfunction

	localparam integer C_ADATA_PIXELS = 2**(C_IMG_WBITS - C_WRITE_INDEX_BITS);
	// C_TRANSACTIONS_NUM is the width of the index counter for
	// number of write or read transaction.
	localparam integer C_TRANSACTIONS_NUM = clogb2(C_M_AXI_BURST_LEN-1);
	//Burst size in bytes
	localparam integer C_BURST_SIZE_BYTES	= C_M_AXI_BURST_LEN * C_M_AXI_DATA_WIDTH/8;

	/// registers
	reg [C_M_AXI_ADDR_WIDTH-1 : 0] 	axi_araddr;
	reg  	axi_arvalid;
	/// @note: don't across 4K edge
	reg  	start_burst_pulse;
	reg  	burst_read_active;
	// @note next_burst_len is real length - 1
	reg [C_TRANSACTIONS_NUM-1:0] next_burst_len;
	wire	burst_done;
	//Interface response error flags
	wire  	read_resp_error;
	wire  	rnext;

	reg	sol_d1;
	reg	lining;
	reg	r_eol;
	reg [C_IMG_WBITS-1 : 0] r_img_col_idx;
	reg [C_WRITE_INDEX_BITS-1 : 0] r_wr_addr;

	// I/O Connections assignments
	assign wr_data		= M_AXI_RDATA;
	assign rnext 		= M_AXI_RVALID && M_AXI_RREADY;
	assign wr_en		= rnext;
	assign wr_addr		= r_wr_addr;

	//Read Address (AR)
	assign M_AXI_ARADDR	= axi_araddr;
	assign M_AXI_ARLEN	= next_burst_len;
	assign M_AXI_ARSIZE	= clogb2((C_M_AXI_DATA_WIDTH/8)-1);
	assign M_AXI_ARBURST	= 2'b01;
	assign M_AXI_ARLOCK	= 1'b0;
	assign M_AXI_ARCACHE	= 4'b0000;
	assign M_AXI_ARPROT	= 3'h0;
	assign M_AXI_ARQOS	= 4'h0;
	assign M_AXI_ARVALID	= axi_arvalid;
	//Read and Read Response (R)
	assign M_AXI_RREADY	= burst_read_active;


	//----------------------------
	//Read Address Channel
	//----------------------------

	always @(posedge M_AXI_ACLK) begin
		if (M_AXI_ARESETN == 0) begin
			axi_arvalid <= 1'b0;
		end
		else if (start_burst_pulse) begin
			axi_arvalid <= 1'b1;
		end
		else if (M_AXI_ARREADY) begin
			axi_arvalid <= 1'b0;
		end
	end


	// Next address after ARREADY indicates previous address acceptance
	always @(posedge M_AXI_ACLK) begin
		if (M_AXI_ARESETN == 0) begin
			axi_araddr <= 'b0;
		end
		else if (sol) begin
			axi_araddr <= line_addr;
		end
		else if (burst_done) begin
			axi_araddr <= axi_araddr + C_BURST_SIZE_BYTES;
		end
	end


	//--------------------------------
	//Read Data (and Response) Channel
	//--------------------------------

	//Flag any read response errors
	assign read_resp_error = M_AXI_RREADY & M_AXI_RVALID & M_AXI_RRESP[1];

	always @(posedge M_AXI_ACLK) begin
		if (M_AXI_ARESETN == 1'b0)
			start_burst_pulse <= 1'b0;
		else if (start_burst_pulse)
			start_burst_pulse <= 0;
		else if (lining && ~burst_read_active)
			start_burst_pulse <= 1'b1;
	end

	assign burst_done = (rnext && M_AXI_RLAST);
	always @(posedge M_AXI_ACLK) begin
		if (M_AXI_ARESETN == 0)
			burst_read_active <= 1'b0;
		else if (start_burst_pulse)
			burst_read_active <= 1'b1;
		else if (burst_done)
			burst_read_active <= 0;
	end

	// Add user logic here

	// User logic ends
	always @(posedge M_AXI_ACLK) begin
		if (M_AXI_ARESETN == 1'b0) begin
			next_burst_len <= 0;
		end
		else if (sol_d1 || burst_done) begin
			if (r_img_col_idx >= C_M_AXI_BURST_LEN * C_ADATA_PIXELS)
				next_burst_len <= C_M_AXI_BURST_LEN - 1;
			else
				next_burst_len <= r_img_col_idx / C_ADATA_PIXELS - 1;
		end
	end

	always @(posedge M_AXI_ACLK) begin
		if (M_AXI_ARESETN == 0) begin
			r_img_col_idx <= 0;
		end
		else if (sol) begin
			r_img_col_idx <= img_width - C_ADATA_PIXELS;
		end
		else if (rnext) begin
			if (!r_eol) begin
				r_img_col_idx <= r_img_col_idx - C_ADATA_PIXELS;
			end
		end
	end

	always @(posedge M_AXI_ACLK) begin
		if (M_AXI_ARESETN == 0) begin
			r_wr_addr <= 0;
		end
		else if (sol) begin
			r_wr_addr <= 0;
		end
		else if (rnext) begin
			r_wr_addr <= r_wr_addr + 1;
		end
	end

	always @(posedge M_AXI_ACLK) begin
		if (M_AXI_ARESETN == 0) begin
			sol_d1 <= 1'b0;
		end
		else begin
			sol_d1 <= sol;
		end
	end
	always @(posedge M_AXI_ACLK) begin
		if (M_AXI_ARESETN == 0) begin
			lining <= 0;
		end
		else if (sol_d1) begin
			lining <= 1;
		end
		else if (burst_done && r_eol) begin
			lining <= 0;
		end
	end
	reg lining_d1;
	always @(posedge M_AXI_ACLK) begin
		if (M_AXI_ARESETN == 0)
			lining_d1 <= 0;
		else
			lining_d1 <= lining;
	end
	assign end_of_line_pulse = (lining_d1 && ~lining);

	// @note image_width must >  C_ADATA_PIXELS * 2
	always @(posedge M_AXI_ACLK) begin
		if (M_AXI_ARESETN == 0) begin
			r_eol <= 1'b1;
		end
		else if (sol) begin
			r_eol <= 1'b0;
		end
		else if (rnext) begin
			if (r_img_col_idx == C_ADATA_PIXELS) begin
				r_eol <= 1;
			end
		end
	end

endmodule
