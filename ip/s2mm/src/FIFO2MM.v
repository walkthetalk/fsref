/**
 * @note:
 * 1. size of image must be integral multiple of C_M_AXI_DATA_WIDTH * C_M_AXI_BURST_LEN.
 * 2. the sof [start of frame] must be 1'b1 for first image data.
 */
module FIFO2MM #
(
	parameter integer C_DATACOUNT_BITS = 12,
	// Burst Length. Supports 1, 2, 4, 8, 16, 32, 64, 128, 256 burst lengths
	parameter integer C_M_AXI_BURST_LEN	= 16,
	// Thread ID Width
	parameter integer C_M_AXI_ID_WIDTH	= 1,
	// Width of Address Bus
	parameter integer C_M_AXI_ADDR_WIDTH	= 32,
	// Width of Data Bus
	parameter integer C_M_AXI_DATA_WIDTH	= 32,
	// Image width/height pixel number bits
	parameter integer C_IMG_WBITS = 12,
	parameter integer C_IMG_HBITS = 12,
	parameter integer C_PIXEL_WIDTH = 8
)
(
	input wire soft_resetn,
	output wire resetting,

	input wire [C_IMG_WBITS-1:0] img_width,
	input wire [C_IMG_HBITS-1:0] img_height,

	input wire sof,
	input wire [C_M_AXI_DATA_WIDTH-1 : 0] din,
	input wire empty,
	output wire rd_en,
	input wire [C_DATACOUNT_BITS-1:0] rd_data_count,

	output wire frame_pulse,
	input wire [C_M_AXI_ADDR_WIDTH-1 : 0] base_addr,

	input wire  M_AXI_ACLK,
	input wire  M_AXI_ARESETN,

	output wire [C_M_AXI_ID_WIDTH-1 : 0] M_AXI_AWID,
	output wire [C_M_AXI_ADDR_WIDTH-1 : 0] M_AXI_AWADDR,
	output wire [7 : 0] M_AXI_AWLEN,
	output wire [2 : 0] M_AXI_AWSIZE,
	output wire [1 : 0] M_AXI_AWBURST,
	output wire M_AXI_AWLOCK,
	output wire [3 : 0] M_AXI_AWCACHE,
	output wire [2 : 0] M_AXI_AWPROT,
	output wire [3 : 0] M_AXI_AWQOS,
	output wire M_AXI_AWVALID,
	input wire  M_AXI_AWREADY,

	output wire [C_M_AXI_DATA_WIDTH-1 : 0] M_AXI_WDATA,
	output wire [C_M_AXI_DATA_WIDTH/8-1 : 0] M_AXI_WSTRB,
	output wire M_AXI_WLAST,
	output wire M_AXI_WVALID,
	input wire  M_AXI_WREADY,

	input wire [C_M_AXI_ID_WIDTH-1 : 0] M_AXI_BID,
	input wire [1 : 0] M_AXI_BRESP,
	input wire  M_AXI_BVALID,
	output wire  M_AXI_BREADY
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
	localparam integer C_TRANSACTIONS_NUM	= clogb2(C_M_AXI_BURST_LEN-1);
	//Burst size in bytes
	localparam integer C_BURST_SIZE_BYTES	= C_M_AXI_BURST_LEN * C_M_AXI_DATA_WIDTH/8;
	localparam integer C_PIXEL_BYTES = cupperbytes(C_PIXEL_WIDTH);
	localparam integer C_ADATA_PIXELS = C_M_AXI_DATA_WIDTH/8/C_PIXEL_BYTES;

	///  resetting
	reg soft_resetn_d1;
	always @ (posedge M_AXI_ACLK) begin
		if (M_AXI_ARESETN == 1'b0) soft_resetn_d1 <= 1'b0;
		else soft_resetn_d1 <= soft_resetn;
	end
	wire soft_reset_posedge;
	assign soft_reset_posedge = (~soft_resetn && soft_resetn_d1);

	reg r_soft_restting;
	assign resetting = ~M_AXI_ARESETN | r_soft_restting | ~soft_resetn;
	always @ (posedge M_AXI_ACLK) begin
		if (M_AXI_ARESETN == 1'b0)
			r_soft_restting <= 1'b0;
		else if (M_AXI_BVALID)
			r_soft_restting <= 1'b0;
		else if (soft_reset_posedge
			&& (start_burst_pulse || burst_active || r_dvalid))
			r_soft_restting <= 1'b1;
		else
			r_soft_restting <= r_soft_restting;
	end

	// @note: do not cause bursts across 4K address boundaries.
	reg [C_M_AXI_ADDR_WIDTH-1 : 0] 	axi_awaddr;
	reg	axi_awvalid;
	reg	axi_wlast;
	//write beat count in a burst
	reg [C_TRANSACTIONS_NUM : 0] 	write_index;
	reg	start_burst_pulse;
	reg     start_burst_pulse_d1;
	reg     start_burst_pulse_d2;
	reg	burst_active;
	wire	wnext;
	reg	need_data;
	reg	r_dvalid;
 	reg [C_IMG_WBITS-1:0] r_img_col_idx;
 	reg [C_IMG_HBITS-1:0] r_img_row_idx;

	assign wnext = M_AXI_WREADY & M_AXI_WVALID;

	// I/O Connections assignments
	reg r_frame_pulse;
	assign frame_pulse = r_frame_pulse;
	always @ (posedge M_AXI_ACLK) begin
		if (M_AXI_ARESETN == 0)
			r_frame_pulse <= 1'b0;
		else if (~r_frame_pulse && start_burst_pulse && final_data)
			r_frame_pulse <= 1'b1;
		else
			r_frame_pulse <= 1'b0;
	end

	assign rd_en		= need_data && (~r_dvalid | wnext) && ~r_soft_restting;
	always @(posedge M_AXI_ACLK) begin
		if (M_AXI_ARESETN == 0)
			r_dvalid <= 1'b0;
		else if (rd_en)
			r_dvalid <= 1'b1;
		else if (wnext)
			r_dvalid <= 1'b0;
		else
			r_dvalid <= r_dvalid;
	end

	assign M_AXI_AWID	= 0;
	assign M_AXI_AWADDR	= axi_awaddr;
	assign M_AXI_AWLEN	= C_M_AXI_BURST_LEN - 1;
	assign M_AXI_AWSIZE	= clogb2((C_M_AXI_DATA_WIDTH/8)-1);
	//INCR burst type is usually used, except for keyhole bursts
	assign M_AXI_AWBURST	= 2'b01;
	assign M_AXI_AWLOCK	= 1'b0;
	//write response must be sended by terminal device, i.e. memory or its' controller
	assign M_AXI_AWCACHE	= 4'b0010;
	assign M_AXI_AWPROT	= 3'h0;
	assign M_AXI_AWQOS	= 4'h0;
	assign M_AXI_AWVALID	= axi_awvalid;
	//Write Data(W)
	assign M_AXI_WDATA	= din;
	//All bursts are complete and aligned
	assign M_AXI_WSTRB	= {(C_M_AXI_DATA_WIDTH/8){1'b1}};
	assign M_AXI_WLAST	= axi_wlast;
	assign M_AXI_WVALID	= need_data & (r_dvalid | r_soft_restting);
	//Write Response (B)
	assign M_AXI_BREADY	= M_AXI_BVALID;

	//--------------------
	//Write Address Channel
	//--------------------
	always @(posedge M_AXI_ACLK) begin
		if (M_AXI_ARESETN == 0)
			axi_awvalid <= 1'b0;
		else if (~axi_awvalid && start_burst_pulse_d2)
			axi_awvalid <= 1'b1;
		else if (M_AXI_AWREADY && axi_awvalid)
			axi_awvalid <= 1'b0;
		else
			axi_awvalid <= axi_awvalid;
	end

	always @(posedge M_AXI_ACLK) begin
		if (M_AXI_ARESETN == 0)
			axi_awaddr <= 'b0;
		else if (start_burst_pulse_d2) begin
			/// avoid cross buffer boundary
			if (final_data)
				axi_awaddr <= base_addr;
			else
				axi_awaddr <= axi_awaddr + C_BURST_SIZE_BYTES;
		end
		else
			axi_awaddr <= axi_awaddr;
	end


	//--------------------
	//Write Data Channel
	//--------------------

	always @(posedge M_AXI_ACLK) begin
		if (M_AXI_ARESETN == 0)
			need_data <= 1'b0;
		else if (~need_data && start_burst_pulse)
			need_data <= 1'b1;
		else if (wnext && axi_wlast)
			need_data <= 1'b0;
		else
			need_data <= need_data;
	end

	always @(posedge M_AXI_ACLK) begin
		if (M_AXI_ARESETN == 0)
			axi_wlast <= 1'b0;
		else if (C_M_AXI_BURST_LEN == 1)
			axi_wlast <= 1'b1;
		else if (wnext)
			axi_wlast <= (write_index == 1);
		else
			axi_wlast <= axi_wlast;
	end

	always @(posedge M_AXI_ACLK) begin
		if (M_AXI_ARESETN == 0 || start_burst_pulse == 1'b1)
			write_index <= C_M_AXI_BURST_LEN-1;
		else if (wnext && (write_index != 0))
			write_index <= write_index - 1;
		else
			write_index <= write_index;
	end

	//----------------------------
	//Write Response (B) Channel
	//----------------------------

	//Interface response error flags
	wire  	write_resp_error;
	assign write_resp_error = M_AXI_BVALID & M_AXI_BRESP[1];

	always @(posedge M_AXI_ACLK) begin
		if (M_AXI_ARESETN == 1'b0)
			start_burst_pulse <= 1'b0;
		else if (~start_burst_pulse && ~burst_active && r_dvalid
			&& soft_resetn
			&& (rd_data_count >= C_M_AXI_BURST_LEN))
			start_burst_pulse <= 1'b1;
		else
			start_burst_pulse = 1'b0;
	end

	always @ ( * ) begin
		if (M_AXI_ARESETN == 1'b0)
			start_burst_pulse_d1 <= 1'b0;
		else
			start_burst_pulse_d1 <= start_burst_pulse;
	end
	always @ ( * ) begin
		if (M_AXI_ARESETN == 1'b0)
			start_burst_pulse_d2 <= 1'b0;
		else
			start_burst_pulse_d2 <= start_burst_pulse_d1;
	end

	always @(posedge M_AXI_ACLK) begin
		if (M_AXI_ARESETN == 0)
			burst_active <= 1'b0;
		else if (start_burst_pulse)
			burst_active <= 1'b1;
		else if (M_AXI_BVALID)
			burst_active <= 0;
	end

	wire final_data;
	assign final_data = (r_img_col_idx == 0 && r_img_row_idx == 0);

	always @(posedge M_AXI_ACLK) begin
		if (M_AXI_ARESETN == 1'b0) begin
			r_img_col_idx <= 0;
			r_img_row_idx <= 0;
		end
		else if (start_burst_pulse_d2 && final_data) begin
			r_img_col_idx <= img_width - C_ADATA_PIXELS;
			r_img_row_idx <= img_height - 1;
		end
		else if (wnext) begin
			if (r_img_col_idx != 0) begin
				r_img_col_idx <= r_img_col_idx - C_ADATA_PIXELS;
				r_img_row_idx <= r_img_row_idx;
			end
			else if (r_img_row_idx != 0) begin
				r_img_col_idx <= img_width - C_ADATA_PIXELS;
				r_img_row_idx <= r_img_row_idx - 1;
			end
			else begin	/// @note: keep zero, reserve for start_burst_pulse
				r_img_col_idx <= r_img_col_idx;
				r_img_row_idx <= r_img_row_idx;
			end
		end
		else begin
			r_img_col_idx <= r_img_col_idx;
			r_img_row_idx <= r_img_row_idx;
		end
	end
endmodule
