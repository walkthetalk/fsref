`timescale 1 ns / 1 ps

module mm2s #
(
	// Users to add parameters here
	parameter integer C_PIXEL_WIDTH	= 8,
	parameter integer C_PIXEL_STORE_WIDTH = 8,

	parameter integer C_IMG_WBITS	= 12,
	parameter integer C_IMG_HBITS	= 12,
	parameter integer C_DATACOUNT_BITS = 12,
	// User parameters ends

	// Parameters of Axi Master Bus Interface M_AXI
	parameter integer C_M_AXI_BURST_LEN	= 16,
	parameter integer C_M_AXI_ADDR_WIDTH	= 32,
	parameter integer C_M_AXI_DATA_WIDTH	= 32
)
(
	input wire  clk,
	input wire  resetn,

	/// @NOTE: resetting will keep until current transaction done.
	///        if under idle state when negedge of soft_resetn,
	///        don't need resetting, i.e. resetting will keep zero.
	input wire  soft_resetn,
	output wire resetting,

/// mm to fifo
	input wire [C_IMG_WBITS-1:0] img_width,
	input wire [C_IMG_HBITS-1:0] img_height,

	input wire fsync,

	output wire r_sof,
	input wire [C_M_AXI_ADDR_WIDTH-1:0] r_addr,

	// Ports of Axi Master Bus Interface M_AXI
	output wire [C_M_AXI_ADDR_WIDTH-1 : 0] m_axi_araddr,
	output wire [7 : 0] m_axi_arlen,
	output wire [2 : 0] m_axi_arsize,
	output wire [1 : 0] m_axi_arburst,
	output wire  m_axi_arlock,
	output wire [3 : 0] m_axi_arcache,
	output wire [2 : 0] m_axi_arprot,
	output wire [3 : 0] m_axi_arqos,
	output wire  m_axi_arvalid,
	input wire  m_axi_arready,
	input wire [C_M_AXI_DATA_WIDTH-1 : 0] m_axi_rdata,
	input wire [1 : 0] m_axi_rresp,
	input wire  m_axi_rlast,
	input wire  m_axi_rvalid,
	output wire  m_axi_rready,

	input wire mm2s_full,
	output wire [C_M_AXI_DATA_WIDTH/C_PIXEL_STORE_WIDTH*(C_PIXEL_WIDTH+2)-1 : 0] mm2s_wr_data,
	output wire mm2s_wr_en,
	input wire [C_DATACOUNT_BITS-1:0] mm2s_wr_data_count,

/// fifo to stream
	input wire	mm2s_empty,
	input wire [C_PIXEL_WIDTH+1 : 0] mm2s_rd_data,
	output wire	mm2s_rd_en,

	output wire m_axis_tvalid,
	output wire [C_PIXEL_WIDTH-1:0] m_axis_tdata,
	output wire m_axis_tuser,
	output wire m_axis_tlast,
	input wire m_axis_tready
);

	localparam C_PM1 = C_PIXEL_WIDTH - 1;
	localparam C_PP1 = C_PIXEL_WIDTH + 1;
	localparam C_PP2 = C_PIXEL_WIDTH + 2;

	localparam C_ADATA_PIXELS = C_M_AXI_DATA_WIDTH/C_PIXEL_STORE_WIDTH;

	wire m2f_aclk; assign m2f_aclk = clk;
	wire f2s_aclk; assign f2s_aclk = clk;

// mm to fifo
	/// use m2f_aclk
	wire [C_M_AXI_DATA_WIDTH-1 : 0] mm2s_pixel_data;
	wire mm2s_sof;
	wire mm2s_eol;

	function integer reverseI(input integer i);
	begin
		reverseI = C_ADATA_PIXELS-1-i;
	end
	endfunction
	function integer sofIdx(input integer i);
	begin
		sofIdx = i * C_PP2 + C_PIXEL_WIDTH;
	end
	endfunction
	function integer eolIdx(input integer i);
	begin
		eolIdx = i * C_PP2 + C_PP1;
	end
	endfunction

	generate
		genvar i;
		for (i = 0; i < C_ADATA_PIXELS; i = i+1) begin: wr_pixel
			assign mm2s_wr_data[i*C_PP2+C_PM1 : i*C_PP2]
				= mm2s_pixel_data[reverseI(i) * C_PIXEL_STORE_WIDTH + C_PM1 : reverseI(i) * C_PIXEL_STORE_WIDTH];
		end
		for (i = 0; i < C_ADATA_PIXELS; i = i+1) begin: wr_sof
			if (i == C_ADATA_PIXELS-1)
				assign mm2s_wr_data[sofIdx(i)] = mm2s_sof;
			else
				assign mm2s_wr_data[sofIdx(i)] = 1'b0;
		end
		for (i = 0; i < C_ADATA_PIXELS; i = i+1) begin: wr_eol
			if (i == 0)
				assign mm2s_wr_data[eolIdx(i)] = mm2s_eol;
			else
				assign mm2s_wr_data[eolIdx(i)] = 1'b0;
		end
	endgenerate

	MM2FIFO # (
		.C_ADATA_PIXELS(C_ADATA_PIXELS),
		.C_DATACOUNT_BITS(C_DATACOUNT_BITS),

		.C_M_AXI_BURST_LEN(C_M_AXI_BURST_LEN),
		.C_M_AXI_ADDR_WIDTH(C_M_AXI_ADDR_WIDTH),
		.C_M_AXI_DATA_WIDTH(C_M_AXI_DATA_WIDTH)
	) read4mm_inst (
		.img_width(img_width),
		.img_height(img_height),

		.soft_resetn(soft_resetn),
		.resetting(resetting),
		.fsync(fsync),

		.sof(mm2s_sof),
		.eol(mm2s_eol),
		.dout(mm2s_pixel_data),
		.wr_en(mm2s_wr_en),
		.full(mm2s_full),
		.wr_data_count(mm2s_wr_data_count),

		.frame_pulse(r_sof),
		.base_addr(r_addr),

		.M_AXI_ACLK(m2f_aclk),
		.M_AXI_ARESETN(resetn),
		.M_AXI_ARADDR(m_axi_araddr),
		.M_AXI_ARLEN(m_axi_arlen),
		.M_AXI_ARSIZE(m_axi_arsize),
		.M_AXI_ARBURST(m_axi_arburst),
		.M_AXI_ARLOCK(m_axi_arlock),
		.M_AXI_ARCACHE(m_axi_arcache),
		.M_AXI_ARPROT(m_axi_arprot),
		.M_AXI_ARQOS(m_axi_arqos),
		.M_AXI_ARVALID(m_axi_arvalid),
		.M_AXI_ARREADY(m_axi_arready),
		.M_AXI_RDATA(m_axi_rdata),
		.M_AXI_RRESP(m_axi_rresp),
		.M_AXI_RLAST(m_axi_rlast),
		.M_AXI_RVALID(m_axi_rvalid),
		.M_AXI_RREADY(m_axi_rready)
	);

// FIFO to stream
	/// use f2s_aclk
	reg mm2s_dvalid;
	assign m_axis_tdata = mm2s_rd_data[C_PIXEL_WIDTH-1:0];
	assign m_axis_tuser = mm2s_rd_data[C_PIXEL_WIDTH];
	assign m_axis_tlast = mm2s_rd_data[C_PIXEL_WIDTH+1];
	assign m_axis_tvalid = mm2s_dvalid;
	assign mm2s_rd_en = (~m_axis_tvalid | m_axis_tready) && ~(mm2s_empty | resetting);
	always @(posedge f2s_aclk) begin
		if (resetn == 1'b0 || resetting) begin
			mm2s_dvalid <= 0;
		end
		else if (mm2s_rd_en) begin
			mm2s_dvalid <= 1;
		end
		else if (m_axis_tready) begin
			mm2s_dvalid <= 0;
		end
		else begin
			mm2s_dvalid <= mm2s_dvalid;
		end
	end
/*
	reg mm2s_dvalid;

	reg [C_IMG_WBITS-1:0] r_img_width;
	reg [C_IMG_HBITS-1:0] r_img_height;
	always @(posedge f2s_aclk) begin
		if (resetn == 1'b0) begin
			r_img_width <= img_width-1;
			r_img_height <= img_height-1;
		end
		else if (m_axis_tvalid & m_axis_tready) begin
			if (r_img_width == 0 && r_img_height == 0) begin
				r_img_width <= img_width-1;
				r_img_height <= img_height-1;
			end
			else if (r_img_width == 0) begin
				r_img_width <= img_width-1;
				r_img_height <= r_img_height - 1;
			end
			else begin
				r_img_width <= r_img_width - 1;
				r_img_height <= r_img_height;
			end
		end
		else begin
			r_img_width <= r_img_width;
			r_img_height <= r_img_height;
		end
	end

	wire sof_err; assign sof_err = (m_axis_tuser != mm2s_rd_data[C_PIXEL_WIDTH]);
	wire eol_err; assign eol_err = (m_axis_tlast != mm2s_rd_data[C_PIXEL_WIDTH+1]);

	//assign m_axis_tdata = sof_err ? {C_PIXEL_WIDTH{1'b0}} : {C_PIXEL_WIDTH{1'b1}};//mm2s_rd_data[C_PIXEL_WIDTH-1:0];
	assign m_axis_tdata = eol_err ? redpixel : (sof_err ? greenpixel : mm2s_rd_data[C_PIXEL_WIDTH-1:0]);
	assign m_axis_tuser = (r_img_width == img_width-1 && r_img_height == img_height-1);
	//assign m_axis_tuser = mm2s_rd_data[C_PIXEL_WIDTH];
	assign m_axis_tlast = (r_img_width == 0);
	//assign m_axis_tlast = mm2s_rd_data[C_PIXEL_WIDTH+1];
	assign m_axis_tvalid = mm2s_dvalid;
	assign mm2s_rd_en = (~m_axis_tvalid | m_axis_tready) && ~mm2s_empty & ~resetting;
	always @(posedge f2s_aclk) begin
		if (resetn == 1'b0) begin
			mm2s_dvalid <= 0;
		end
		else if (mm2s_rd_en) begin
			mm2s_dvalid <= 1;
		end
		else if (m_axis_tready) begin
			mm2s_dvalid <= 0;
		end
		else begin
			mm2s_dvalid <= mm2s_dvalid;
		end
	end

	wire [C_PM1:0] blackpixel; assign blackpixel = {C_PIXEL_WIDTH{1'b0}};
	wire [C_PM1:0] whitepixel; assign whitepixel = {C_PIXEL_WIDTH{1'b1}};
	wire [C_PM1:0] greenpixel; assign greenpixel = 32'h0000FF00;
	wire [C_PM1:0] bluepixel;  assign bluepixel  = 32'h000000FF;
	wire [C_PM1:0] redpixel;   assign redpixel   = 32'h00FF0000;
*/

/*
	//assign resetting = ~resetn;
	wire wr_en; assign mm2s_wr_en = wr_en;
	reg [C_IMG_WBITS-1:0] w_img_width;
	reg [C_IMG_HBITS-1:0] w_img_height;

	assign wr_en = ~mm2s_full & ~resetting;
	assign wr_data[C_ADATA_PIXELS*C_PP2-1] = (wr_en && w_img_width == 0);
	assign wr_data[C_PIXEL_WIDTH] = (wr_en && (w_img_width == img_width - C_ADATA_PIXELS) && (w_img_height == img_height - 1));
	generate
		genvar i;
		for (i = 0; i < C_ADATA_PIXELS; i = i+1) begin: wr_pixel
			//$display("data %d: [%d : %d]", i, (i*C_PP2+C_PM1), (i*C_PP2));
			assign wr_data[i*C_PP2+C_PM1 : i*C_PP2] = whitepixel;//(i == 0) ? (w_img_height[0] == 0 ? redpixel : bluepixel) : greenpixel;
		end
		//$display("sof 0: [%d]", (C_PIXEL_WIDTH));
		for (i = 1; i < C_ADATA_PIXELS; i = i+1) begin: wr_sof
			//$display("sof %d: [%d]", i, (i*C_PP2+C_PIXEL_WIDTH));
			assign wr_data[i*C_PP2+C_PIXEL_WIDTH] = 1'b0;
		end
		for (i = 0; i < (C_ADATA_PIXELS-1); i = i+1) begin: wr_eol
			//$display("eol %d: [%d]", i, (i*C_PP2+C_PP1));
			assign wr_data[i*C_PP2+C_PP1] = 1'b0;
		end
		//$display("eol %d: [%d]", (C_ADATA_PIXELS-1), (C_ADATA_PIXELS*C_PP2-1));
		for (i = 0; i < C_ADATA_PIXELS; i = i+1) begin: endianmap
			assign mm2s_wr_data[i*C_PP2+C_PP1 : i*C_PP2] = wr_data[(C_ADATA_PIXELS-1-i)*C_PP2+C_PP1 : (C_ADATA_PIXELS-1-i)*C_PP2];
		end
		//assign mm2s_wr_data = wr_data;
	endgenerate
	always @(posedge f2s_aclk) begin
		if (resetn == 1'b0) begin
			w_img_width <= img_width-C_ADATA_PIXELS;
			w_img_height <= img_height-1;
		end
		else if (wr_en) begin
			if (w_img_width == 0 && w_img_height == 0) begin
				w_img_width <= img_width-C_ADATA_PIXELS;
				w_img_height <= img_height-1;
			end
			else if (w_img_width == 0) begin
				w_img_width <= img_width-C_ADATA_PIXELS;
				w_img_height <= w_img_height - 1;
			end
			else begin
				w_img_width <= w_img_width - C_ADATA_PIXELS;
				w_img_height <= w_img_height;
			end
		end
		else begin
			w_img_width <= w_img_width;
			w_img_height <= w_img_height;
		end
	end
*/
endmodule
