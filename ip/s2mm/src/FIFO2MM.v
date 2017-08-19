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
	parameter integer C_ADATA_PIXELS = 4
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

	// C_TRANSACTIONS_NUM is the width of the index counter for
	// number of write or read transaction.
	localparam integer C_TRANSACTIONS_NUM	= clogb2(C_M_AXI_BURST_LEN-1);
	//Burst size in bytes
	localparam integer C_BURST_SIZE_BYTES	= C_M_AXI_BURST_LEN * C_M_AXI_DATA_WIDTH/8;

	// @note: do not cause bursts across 4K address boundaries.
	reg [C_M_AXI_ADDR_WIDTH-1 : 0] 	axi_awaddr;
	reg	axi_awvalid;
	reg	axi_wlast;
	reg     axi_bready;
	//write beat count in a burst
	reg [C_TRANSACTIONS_NUM : 0] 	write_index;
	reg	start_burst_pulse;
	reg	burst_active;
	wire	wnext;
	reg	need_data;
	reg	r_dvalid;
 	reg [C_IMG_WBITS-1:0] r_img_col_idx;
 	reg [C_IMG_HBITS-1:0] r_img_row_idx;

	assign wnext = M_AXI_WREADY & M_AXI_WVALID;

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
		else if (~(start_burst_pulse | burst_active))
			r_soft_resetting <= 1'b0;
		else if (M_AXI_BVALID & M_AXI_BREADY)
			r_soft_resetting <= 1'b0;
		else if (~soft_resetn && soft_resetn_d1)	/// soft_resetn_negedge
			r_soft_resetting <= 1'b1;
		else
			r_soft_resetting <= r_soft_resetting;
	end

	// I/O Connections assignments
	reg r_frame_pulse;
	assign frame_pulse = r_frame_pulse;
	always @ (posedge M_AXI_ACLK) begin
		if (M_AXI_ARESETN == 0)
			r_frame_pulse <= 1'b0;
		else if (M_AXI_BVALID && final_data)
			r_frame_pulse <= 1'b1;
		else
			r_frame_pulse <= 1'b0;
	end

	wire try_read_en;
	assign try_read_en = need_data && (~r_dvalid | M_AXI_WREADY);
	assign rd_en	   = try_read_en && ~resetting;
	always @(posedge M_AXI_ACLK) begin
		if (M_AXI_ARESETN == 0)
			r_dvalid <= 1'b0;
		else if (try_read_en)
			r_dvalid <= 1'b1;
		else if (M_AXI_WREADY)
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
	assign M_AXI_WVALID	= r_dvalid | r_soft_resetting;
	//Write Response (B)
	assign M_AXI_BREADY	= axi_bready;

	always @ (posedge M_AXI_ACLK) begin
		if (M_AXI_ARESETN == 1'b0)
			axi_bready <= 1'b0;
		else if (M_AXI_BVALID)
			axi_bready <= 1'b1;
		else
			axi_bready <= 1'b0;
	end

	//--------------------
	//Write Address Channel
	//--------------------
	always @(posedge M_AXI_ACLK) begin
		if (M_AXI_ARESETN == 0)
			axi_awvalid <= 1'b0;
		else if (~axi_awvalid && start_burst_pulse)
			axi_awvalid <= 1'b1;
		else if (M_AXI_AWREADY && axi_awvalid)
			axi_awvalid <= 1'b0;
		else
			axi_awvalid <= axi_awvalid;
	end

	always @(posedge M_AXI_ACLK) begin
		if (M_AXI_ARESETN == 0)
			axi_awaddr <= 'b0;
		else if (start_burst_pulse) begin
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
		else if (~need_data && M_AXI_AWREADY && M_AXI_AWVALID)
			need_data <= 1'b1;
		else if (wnext && (write_index == 1))
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
		if (M_AXI_ARESETN == 1'b0)
			write_index <= 0;
		else if (start_burst_pulse == 1'b1)
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

	/// @TODO: just for not overriding uboot code, delete it.
	reg[31:0] idle_cnt;
	always @ ( posedge M_AXI_ACLK ) begin
		if (M_AXI_ARESETN == 1'b0)
			idle_cnt <= 'hFFFFFFFF;
		else if (idle_cnt > 0)
			idle_cnt <= idle_cnt - 1;
		else
			idle_cnt <= idle_cnt;
	end

	always @(posedge M_AXI_ACLK) begin
		if (M_AXI_ARESETN == 1'b0)
			start_burst_pulse <= 1'b0;
		else if (~start_burst_pulse && ~burst_active
			&& soft_resetn
			&& (rd_data_count >= C_M_AXI_BURST_LEN)
			&& idle_cnt == 0)
			start_burst_pulse <= 1'b1;
		else
			start_burst_pulse <= 1'b0;
	end

	always @(posedge M_AXI_ACLK) begin
		if (M_AXI_ARESETN == 1'b0)
			burst_active <= 1'b0;
		else if (start_burst_pulse)
			burst_active <= 1'b1;
		else if (M_AXI_BVALID && M_AXI_BREADY)
			burst_active <= 0;
		else
			burst_active <= burst_active;
	end

	wire final_data;
	assign final_data = (r_img_col_idx == 0 && r_img_row_idx == 0);

	always @(posedge M_AXI_ACLK) begin
		if (M_AXI_ARESETN == 1'b0 || soft_resetn == 1'b0) begin
			r_img_col_idx <= 0;
			r_img_row_idx <= 0;
		end
		else if (start_burst_pulse && final_data) begin
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
