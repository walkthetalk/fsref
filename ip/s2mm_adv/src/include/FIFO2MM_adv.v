/**
 * @note:
 * 1. size of image must be integral multiple of C_M_AXI_DATA_WIDTH * C_M_AXI_BURST_LEN.
 * 2. the sof [start of frame] must be 1'b1 for first image data.
 */
module FIFO2MM_adv #
(
	parameter integer C_DATACOUNT_BITS = 12,
	// Burst Length. Supports 1, 2, 4, 8, 16, 32, 64, 128, 256 burst lengths
	parameter integer C_M_AXI_BURST_LEN	= 16,
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

	input wire [C_M_AXI_ADDR_WIDTH-1:0] img_stride,

	//input wire sof,
	input wire [C_M_AXI_DATA_WIDTH-1 : 0] din,
	//input wire empty,
	output wire rd_en,
	input wire [C_DATACOUNT_BITS-1:0] rd_data_count,

	output wire frame_pulse,
	input wire [C_M_AXI_ADDR_WIDTH-1 : 0] base_addr,

	input wire  M_AXI_ACLK,
	input wire  M_AXI_ARESETN,

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

	input wire [1 : 0] M_AXI_BRESP,
	input wire  M_AXI_BVALID,
	output wire  M_AXI_BREADY,

	output wire write_resp_error
);
	// 1 -> 1, 2 -> 2, 3 -> 2, 4 -> 3
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
	reg [7:0] axi_awlen;
	reg	axi_awvalid;
	reg	axi_wlast;
	reg     axi_bready;
	//write beat count in a burst
	reg [C_TRANSACTIONS_NUM-1 : 0] 	write_index;
	reg	sob_d0;	// start burst pulse
	reg	sob_d1;
	reg	burst_active;
	wire    burst_done;
	wire	wnext;
	reg	need_data;
	reg	r_dvalid;
 	reg [C_IMG_WBITS-1:0] r_img_col_idx;
 	reg [C_IMG_HBITS-1:0] r_img_row_idx;

	reg end_of_col;
	reg end_of_row;
	wire final_data;
	assign final_data = (end_of_col && end_of_row);
	reg [C_TRANSACTIONS_NUM-1:0] next_burst_len;

	assign wnext = M_AXI_WREADY & M_AXI_WVALID;
	assign burst_done = M_AXI_BVALID && M_AXI_BREADY;

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
		else if (~(sob_d0 | burst_active))
			r_soft_resetting <= 1'b0;
		else if (burst_done)
			r_soft_resetting <= 1'b0;
		else if (~soft_resetn && soft_resetn_d1)	/// soft_resetn_negedge
			r_soft_resetting <= 1'b1;
	end

	// I/O Connections assignments
	reg r_frame_pulse;
	assign frame_pulse = r_frame_pulse;
	always @ (posedge M_AXI_ACLK) begin
		if (M_AXI_ARESETN == 0)
			r_frame_pulse <= 1'b0;
		else if (burst_done && final_data)
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
	end

	assign M_AXI_AWADDR	= axi_awaddr;
	assign M_AXI_AWLEN	= axi_awlen;
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
		else if (wnext && axi_wlast)
			axi_bready <= 1'b1;
		else if (axi_bready && M_AXI_BVALID)
			axi_bready <= 1'b0;
	end

	//--------------------
	//Write Address Channel
	//--------------------
	always @(posedge M_AXI_ACLK) begin
		if (M_AXI_ARESETN == 0)
			axi_awvalid <= 1'b0;
		else if (sob_d0)
			axi_awvalid <= 1'b1;
		else if (M_AXI_AWREADY && axi_awvalid)
			axi_awvalid <= 1'b0;
	end
	
	always @(posedge M_AXI_ACLK) begin
		if (M_AXI_ARESETN == 0)
			axi_awlen <= 0;
		else if (sob_d0)
			axi_awlen <= next_burst_len;
	end

	reg [C_M_AXI_ADDR_WIDTH-1:0] line_addr;
	always @(posedge M_AXI_ACLK) begin
		if (M_AXI_ARESETN == 0) begin
			line_addr <= 0;
			axi_awaddr <= 0;
		end
		else if (sof_d1) begin
			line_addr <= base_addr;
			axi_awaddr <= base_addr;
		end
		else if (wnext && axi_wlast) begin
			if (~end_of_col) begin
				axi_awaddr <= axi_awaddr + C_M_AXI_BURST_LEN * C_M_AXI_DATA_WIDTH / 8;
			end
			else if (~end_of_row) begin
				line_addr <= line_addr + img_stride;
				axi_awaddr <= line_addr + img_stride;
			end
		end
	end


	//--------------------
	//Write Data Channel
	//--------------------

	always @(posedge M_AXI_ACLK) begin
		if (M_AXI_ARESETN == 0)
			need_data <= 1'b0;
		else if (M_AXI_AWREADY && M_AXI_AWVALID)
			need_data <= 1'b1;
		else if (wnext && (write_index == 1))
			need_data <= 1'b0;
	end

	always @(posedge M_AXI_ACLK) begin
		if (M_AXI_ARESETN == 0)
			axi_wlast <= 1'b0;
		else if (sob_d0)
			axi_wlast <= (next_burst_len == 0);
		else if (wnext)
			axi_wlast <= (write_index == 1);
	end

	always @(posedge M_AXI_ACLK) begin
		if (M_AXI_ARESETN == 1'b0)
			write_index <= 0;
		else if (sob_d0 == 1'b1)
			write_index <= next_burst_len;
		else if (wnext && (write_index != 0))
			write_index <= write_index - 1;
	end

	//----------------------------
	//Write Response (B) Channel
	//----------------------------

	//Interface response error flags
	assign write_resp_error = M_AXI_BVALID & M_AXI_BRESP[1];

	wire sob_all;
	assign sob_all = (sob_d0);
	always @(posedge M_AXI_ACLK) begin
		if (M_AXI_ARESETN == 1'b0)
			sob_d0 <= 1'b0;
		else if (sob_d0)
			sob_d0 <= 1'b0;
		else if (framing && ~burst_active && (rd_data_count > next_burst_len))
			sob_d0 <= 1'b1;
	end

	always @(posedge M_AXI_ACLK) begin
		if (M_AXI_ARESETN == 1'b0)
			burst_active <= 1'b0;
		else if (sob_d0)
			burst_active <= 1'b1;
		else if (burst_done)
			burst_active <= 0;
	end

	// @note next_burst_len is real length - 1
	always @(posedge M_AXI_ACLK) begin
		if (M_AXI_ARESETN == 1'b0) begin
			next_burst_len <= 0;
		end
		else if (sof_d1 || burst_done) begin
			if (r_img_col_idx >= C_M_AXI_BURST_LEN * C_ADATA_PIXELS)
				next_burst_len <= C_M_AXI_BURST_LEN - 1;
			else
				next_burst_len <= r_img_col_idx / C_ADATA_PIXELS;
		end
	end

	always @(posedge M_AXI_ACLK) begin
		if (M_AXI_ARESETN == 1'b0) begin
			r_img_col_idx <= 0;
			r_img_row_idx <= 0;
		end
		else if (start_of_frame) begin
			r_img_col_idx <= img_width - C_ADATA_PIXELS;
			r_img_row_idx <= img_height - 1;
		end
		else if (wnext) begin
			if (~end_of_col) begin
				r_img_col_idx <= r_img_col_idx - C_ADATA_PIXELS;
			end
			else if (~end_of_row) begin
				r_img_col_idx <= img_width - C_ADATA_PIXELS;
				r_img_row_idx <= r_img_row_idx - 1;
			end
		end
	end

	// @note img must > 2x2
	always @(posedge M_AXI_ACLK) begin
		if (M_AXI_ARESETN == 1'b0 || soft_resetn == 1'b0) begin
			end_of_col <= 1;
			end_of_row <= 1;
		end
		else if (start_of_frame) begin
			end_of_col <= 0;
			end_of_row <= 0;
		end
		else if (wnext) begin
			if (~end_of_col) begin
				if (r_img_col_idx == C_ADATA_PIXELS) begin
					end_of_col <= 1;
				end
			end
			else if (~end_of_row) begin
				end_of_col <= 0;
				if (r_img_row_idx == 1) begin
					end_of_row <= 1;
				end
			end
		end
	end

	// @note new start
	reg start_of_frame;
	reg framing;
	always @ (posedge M_AXI_ACLK) begin
		if (M_AXI_ARESETN == 1'b0 || soft_resetn == 1'b0) begin
			start_of_frame <= 0;
		end
		else if (start_of_frame) begin
			start_of_frame <= 0;
		end
		else if (~sof_d1 && ~framing && img_width != 0 && img_height != 0) begin
			start_of_frame <= 1'b1;
		end
	end
	always @ (posedge M_AXI_ACLK) begin
		if (M_AXI_ARESETN == 1'b0) begin
			framing <= 0;
		end
		else if (sof_d1) begin
			framing <= 1'b1;
		end
		else if (burst_done && (final_data || resetting)) begin
			framing <= 1'b0;
		end
	end

	reg sof_d1;
	always @ (posedge M_AXI_ACLK) begin
		if (M_AXI_ARESETN == 1'b0)
			sof_d1 <= 0;
		else
			sof_d1 <= start_of_frame;
	end
endmodule
