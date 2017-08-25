/**
 * @note:
 * 1. size of image must be integral multiple of C_M_AXI_DATA_WIDTH * C_M_AXI_BURST_LEN.
 * 2. the sof [start of frame] must be 1'b1 for first image data.
 * 3. width of image must be integral multiple of C_M_AXI_DATA_WIDTH.
 * 4. @TODO: if burst length bigger than 16, it may be modified by slave.
 */
module MM2FIFO #
(
	parameter integer C_IMG_WBITS	= 12,
	parameter integer C_IMG_HBITS	= 12,
	parameter integer C_ADATA_PIXELS = 4,
	parameter integer C_DATACOUNT_BITS = 12,

	// Burst Length. Supports 1, 2, 4, 8, 16, 32, 64, 128, 256 burst lengths
	parameter integer C_M_AXI_BURST_LEN	= 16,
	// Thread ID Width
	parameter integer C_M_AXI_ID_WIDTH	= 1,
	// Width of Address Bus
	parameter integer C_M_AXI_ADDR_WIDTH	= 32,
	// Width of Data Bus
	parameter integer C_M_AXI_DATA_WIDTH	= 32
)
(
	input wire soft_resetn,
	output wire resetting,

	input wire [C_IMG_WBITS-1:0] img_width,
	input wire [C_IMG_HBITS-1:0] img_height,

	input wire fsync,

	output wire sof,
	output wire eol,
	output wire [C_M_AXI_DATA_WIDTH-1 : 0] dout,
	output wire wr_en,
	input wire full,
	input wire [C_DATACOUNT_BITS-1:0] wr_data_count,

	output wire frame_pulse,
	input wire [C_M_AXI_ADDR_WIDTH-1 : 0] base_addr,

	input wire  M_AXI_ACLK,
	input wire  M_AXI_ARESETN,

	output wire [C_M_AXI_ID_WIDTH-1 : 0] M_AXI_ARID,
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

	input wire [C_M_AXI_ID_WIDTH-1 : 0] M_AXI_RID,
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

	function integer cupperbytes(input integer bit_depth);
	begin
		if (bit_depth <= 8)
			cupperbytes = 1;
		else if (bit_depth <= 16)
			cupperbytes = 2;
		else
			cupperbytes = 4;
	end
	endfunction

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
	//Interface response error flags
	wire  	read_resp_error;
	wire  	rnext;

	reg	r_sof;
	reg	r_eol;
	reg [C_IMG_WBITS-1 : 0] r_img_col_idx;
	reg [C_IMG_HBITS-1 : 0] r_img_row_idx;

	///  resetting
	reg soft_resetn_d1;
	always @ (posedge M_AXI_ACLK) begin
		if (M_AXI_ARESETN == 1'b0) soft_resetn_d1 <= 1'b0;
		else soft_resetn_d1 <= soft_resetn;
	end

	reg r_soft_resetting;
	assign resetting = r_soft_resetting;
	always @ (posedge M_AXI_ACLK) begin
		if (M_AXI_ARESETN == 1'b0)
			r_soft_resetting <= 1'b1;
		else if (~(start_burst_pulse | burst_read_active))
			r_soft_resetting <= 1'b0;
		else if (rnext && M_AXI_RLAST)
			r_soft_resetting <= 1'b0;
		else if (~soft_resetn && soft_resetn_d1)	/// soft_resetn negedge
			r_soft_resetting <= 1'b1;
		else
			r_soft_resetting <= r_soft_resetting;
	end

	// I/O Connections assignments
	assign sof		= r_sof;
	assign eol		= r_eol;
	assign dout		= M_AXI_RDATA;
	assign rnext 		= M_AXI_RVALID && M_AXI_RREADY;
	assign wr_en		= rnext && ~resetting;

	//Read Address (AR)
	assign M_AXI_ARID	= 0;
	assign M_AXI_ARADDR	= axi_araddr;
	assign M_AXI_ARLEN	= C_M_AXI_BURST_LEN - 1;
	assign M_AXI_ARSIZE	= clogb2((C_M_AXI_DATA_WIDTH/8)-1);
	assign M_AXI_ARBURST	= 2'b01;
	assign M_AXI_ARLOCK	= 1'b0;
	assign M_AXI_ARCACHE	= 4'b0000;
	assign M_AXI_ARPROT	= 3'h0;
	assign M_AXI_ARQOS	= 4'h0;
	assign M_AXI_ARVALID	= axi_arvalid;
	//Read and Read Response (R)
	/// @NOTE: ensure fifo is not full (by checking count when start burst)
	assign M_AXI_RREADY	= burst_read_active;


	//----------------------------
	//Read Address Channel
	//----------------------------

	always @(posedge M_AXI_ACLK) begin
		if (M_AXI_ARESETN == 0) begin
			axi_arvalid <= 1'b0;
		end
		else if (~axi_arvalid && start_burst_pulse) begin
			axi_arvalid <= 1'b1;
		end
		else if (M_AXI_ARREADY && axi_arvalid) begin
			axi_arvalid <= 1'b0;
		end
		else
			axi_arvalid <= axi_arvalid;
	end


	// Next address after ARREADY indicates previous address acceptance
	always @(posedge M_AXI_ACLK) begin
		if (M_AXI_ARESETN == 0) begin
			axi_araddr <= 'b0;
		end
		else if (start_burst_pulse) begin
			if (final_data)
				axi_araddr <= base_addr;
			else
				axi_araddr <= axi_araddr + C_BURST_SIZE_BYTES;
		end
		else
			axi_araddr <= axi_araddr;
	end


	//--------------------------------
	//Read Data (and Response) Channel
	//--------------------------------
	wire final_data;
	assign final_data = (r_img_col_idx == 0 && r_img_row_idx == 0);

	//Flag any read response errors
	assign read_resp_error = M_AXI_RREADY & M_AXI_RVALID & M_AXI_RRESP[1];

	assign frame_pulse = ~(start_burst_pulse || burst_read_active)
			&& final_data
			&& fsync
			&& soft_resetn;

	always @(posedge M_AXI_ACLK) begin
		if (M_AXI_ARESETN == 1'b0)
			start_burst_pulse <= 1'b0;
		else if (~(start_burst_pulse || burst_read_active)
			&& (~final_data || fsync)
			&& soft_resetn
			&& (wr_data_count < C_M_AXI_BURST_LEN)
			&& (img_width != 0 && img_height != 0))
			start_burst_pulse <= 1'b1;
		else
			start_burst_pulse <= 1'b0;
	end

	always @(posedge M_AXI_ACLK) begin
		if (M_AXI_ARESETN == 0)
			burst_read_active <= 1'b0;
		else if (start_burst_pulse)
			burst_read_active <= 1'b1;
		else if (rnext && M_AXI_RLAST)
			burst_read_active <= 0;
	end

	// Add user logic here

	// User logic ends
	always @(posedge M_AXI_ACLK) begin
		if (M_AXI_ARESETN == 0 || r_soft_resetting) begin
			r_img_col_idx <= 0;
			r_img_row_idx <= 0;
		end
		else if (start_burst_pulse && final_data) begin
			r_img_col_idx <= img_width - C_ADATA_PIXELS;
			r_img_row_idx <= img_height - 1;
		end
		else if (rnext) begin
			if (r_img_col_idx != 0) begin
				r_img_col_idx <= r_img_col_idx - C_ADATA_PIXELS;
				r_img_row_idx <= r_img_row_idx;
			end
			else if (r_img_row_idx != 0) begin
				r_img_col_idx <= img_width - C_ADATA_PIXELS;
				r_img_row_idx <= r_img_row_idx - 1;
			end
			else begin
				r_img_col_idx <= r_img_col_idx;
				r_img_row_idx <= r_img_row_idx;
			end
		end
		else begin
			r_img_col_idx <= r_img_col_idx;
			r_img_row_idx <= r_img_row_idx;
		end
	end

	always @(posedge M_AXI_ACLK) begin
		if (M_AXI_ARESETN == 0) begin
			r_sof <= 1'b0;
		end
		else if (start_burst_pulse && final_data) begin
			r_sof <= 1'b1;
		end
		else if (rnext) begin
			r_sof <= 1'b0;
		end
		else begin
			r_sof <= r_sof;
		end
	end

	always @(posedge M_AXI_ACLK) begin
		if (M_AXI_ARESETN == 0) begin
			r_eol <= 1'b0;
		end
		else if (img_width == C_ADATA_PIXELS) begin
			r_eol <= 1'b1;
		end
		else if (rnext) begin
			r_eol <= (r_img_col_idx == C_ADATA_PIXELS);
		end
		else
			r_eol <= r_eol;
	end

endmodule
