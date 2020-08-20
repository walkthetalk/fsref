`timescale 1 ns / 1 ps

module mm2s_adv #
(
	// Users to add parameters here
	parameter integer C_PIXEL_WIDTH	= 8,
	parameter integer C_PIXEL_STORE_WIDTH = 8,
	parameter integer C_IMG_STRIDE_WIDTH = 10,

	parameter integer C_IMG_WBITS	= 12,
	parameter integer C_IMG_HBITS	= 12,
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

	input wire [C_IMG_WBITS-1:0] win_left,
	input wire [C_IMG_WBITS-1:0] win_width,
	input wire [C_IMG_HBITS-1:0] win_top,
	input wire [C_IMG_HBITS-1:0] win_height,

	input wire [C_IMG_WBITS-1:0] dst_width,
	input wire [C_IMG_HBITS-1:0] dst_height,

	input wire fsync,

	output wire sof,
	input wire [C_M_AXI_ADDR_WIDTH-1:0] frame_addr,

	// Ports of Axi Master Bus Interface M_AXI
	output wire [C_M_AXI_ADDR_WIDTH-1 : 0] m_axi_araddr,
	output wire [7 : 0] m_axi_arlen,
	output wire [2 : 0] m_axi_arsize,
	output wire [1 : 0] m_axi_arburst,
	output wire         m_axi_arlock,
	output wire [3 : 0] m_axi_arcache,
	output wire [2 : 0] m_axi_arprot,
	output wire [3 : 0] m_axi_arqos,
	output wire         m_axi_arvalid,
	input  wire         m_axi_arready,
	input  wire [C_M_AXI_DATA_WIDTH-1 : 0] m_axi_rdata,
	input  wire [1 : 0] m_axi_rresp,
	input  wire         m_axi_rlast,
	input  wire         m_axi_rvalid,
	output wire         m_axi_rready,

	output wire m_axis_tvalid,
	output wire [C_PIXEL_WIDTH-1:0] m_axis_tdata,
	output wire m_axis_tuser,
	output wire m_axis_tlast,
	input wire m_axis_tready
);
	function integer log2;
		input integer value;

		integer shifted;
		integer res;
		begin
			shifted = value-1;
			for (res=0; shifted>0; res=res+1)
				shifted = shifted>>1;
			log2 = res;
		end
	endfunction
	localparam integer C_ADATA_PIXELS = C_M_AXI_DATA_WIDTH / C_PIXEL_STORE_WIDTH;
	localparam integer C_BURST_PIXELS = C_ADATA_PIXELS * C_M_AXI_BURST_LEN;
	localparam integer C_BURST_PIXEL_INDEX_BITS = log2(C_BURST_PIXELS);
	localparam integer C_WRITE_INDEX_BITS = C_IMG_WBITS - log2(C_ADATA_PIXELS);
	localparam integer C_IMG_STRIDE_SIZE = 2**C_IMG_STRIDE_WIDTH;
	localparam integer C_BYTES_PER_PIXEL = (C_PIXEL_STORE_WIDTH / 8);

	wire [C_M_AXI_ADDR_WIDTH-1:0] line_addr;
	wire eol_write;
	line_reader # (
		.C_IMG_WBITS(C_IMG_WBITS),
		.C_WRITE_INDEX_BITS(C_WRITE_INDEX_BITS),

		.C_M_AXI_BURST_LEN(C_M_AXI_BURST_LEN),
		.C_M_AXI_ADDR_WIDTH(C_M_AXI_ADDR_WIDTH),
		.C_M_AXI_DATA_WIDTH(C_M_AXI_DATA_WIDTH)
	) read4mm_inst (
		.img_width(mm_pixel_per_line),

		.soft_resetn(soft_resetn),
		.resetting(resetting),

		.sol(line_addr_valid && line_addr_ready),
		.line_addr(line_addr),

		.end_of_line_pulse(eol_write),
		.wr_en(write_enable),
		.wr_addr(write_address),
		.wr_data(write_data),

		.M_AXI_ACLK(clk),
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

	/// @todo consider soft reset
	reg sof_d1;
	always @(posedge clk) begin
		if (resetn == 1'b0)
			sof_d1 <= 0;
		else
			sof_d1 <= fsync;
	end
	/// @note we can tell mutex buffer controller for reading done
	assign sof = (eol_write && line_addr_last);

	// reg [C_IMG_WBITS-1:0] mm_pixel_offset;	// align with burst size
	`define mm_line_pixel_offset `align_mm(win_left, C_IMG_WBITS, C_BURST_PIXEL_INDEX_BITS)
	reg [C_M_AXI_ADDR_WIDTH-1:0] frame_addr_offset;

	reg [C_IMG_WBITS-1:0] mm_pixel_per_line;		// align with mm data width
	reg [C_IMG_WBITS-1:0] read_offset;
	`define align_mm(x, hbits, lbits) {x[(hbits)-1: (lbits)], {(lbits){1'b0}}}
	wire [C_IMG_WBITS-1:0] __mm_width_with_head;
	assign __mm_width_with_head = win_left[C_BURST_PIXEL_INDEX_BITS-1:0] + win_width + C_ADATA_PIXELS - 1;
	always @(posedge clk) begin
		if (resetn == 1'b0) begin
			frame_addr_offset <= 0;
			mm_pixel_per_line  <= 0;
			read_offset <= 0;
		end
		else if (fsync) begin
			frame_addr_offset <= `mm_line_pixel_offset * C_BYTES_PER_PIXEL
						+ {win_top, {(C_IMG_STRIDE_WIDTH){1'b0}}};
			mm_pixel_per_line <= `align_mm(__mm_width_with_head, C_IMG_WBITS, log2(C_ADATA_PIXELS));
			read_offset <= win_left[C_BURST_PIXEL_INDEX_BITS-1:0];
		end
	end

	// ping-pong line buffer
	wire write_enable;
	wire [C_WRITE_INDEX_BITS-1:0] write_address;
	wire [C_M_AXI_DATA_WIDTH-1:0] write_data;

	wire read_enable;
	wire [C_IMG_WBITS-1:0] read_address;
	wire [C_PIXEL_STORE_WIDTH-1:0] read_data;
	assign read_enable = (pixel_addr_valid && pixel_addr_ready);

	wire [C_PIXEL_STORE_WIDTH-1:0] read_data0;
	wire [C_PIXEL_STORE_WIDTH-1:0] read_data1;
	reg  [BUF_NUM-1:0] buffer_reading_d1;
	always @(posedge clk) begin
		buffer_reading_d1 <= buffer_reading;
	end
	assign read_data = (buffer_reading_d1 == 1 ? read_data0 : read_data1);

	asym_ram # (
		.WR_DATA_WIDTH(C_M_AXI_DATA_WIDTH)
		, .WR_ADDR_WIDTH(C_WRITE_INDEX_BITS)
		, .RD_DATA_WIDTH(C_PIXEL_STORE_WIDTH)
		, .RD_ADDR_WIDTH(C_IMG_WBITS)
	) lineA (
		.clkW(clk)
		, .we(buffer_writing[0] && write_enable)
		, .wa(write_address)
		, .wd(write_data)
		
		, .clkR(clk)
		, .re(buffer_reading[0] && read_enable)
		, .ra(read_address)
		, .rd(read_data0)
	);
	asym_ram # (
		.WR_DATA_WIDTH(C_M_AXI_DATA_WIDTH)
		, .WR_ADDR_WIDTH(C_WRITE_INDEX_BITS)
		, .RD_DATA_WIDTH(C_PIXEL_STORE_WIDTH)
		, .RD_ADDR_WIDTH(C_IMG_WBITS)
	) lineB (
		.clkW(clk)
		, .we(buffer_writing[1] && write_enable)
		, .wa(write_address)
		, .wd(write_data)
		
		, .clkR(clk)
		, .re(buffer_reading[1] && read_enable)
		, .ra(read_address)
		, .rd(read_data1)
	);

	/////////////////////////////////////// buffer control /////////////////
	localparam integer BUF_NUM = 2;
	reg[BUF_NUM-1:0] buffer_full;		// only full flag
	reg[BUF_NUM-1:0] buffer_writing;	// only index bitmap
	reg[BUF_NUM-1:0] buffer_reading;	// only index bitmap

	reg eol_read;

	always @(posedge clk) begin
		if (resetn == 0)
			buffer_writing <= 0;
		else if (fsync)
			buffer_writing <= 1;
		else if (eol_write)
			buffer_writing <= {buffer_writing[BUF_NUM-2:0], buffer_writing[BUF_NUM-1]};
	end
	always @(posedge clk) begin
		if (resetn == 0)
			buffer_reading <= 0;
		else if (fsync)
			buffer_reading <= 1;
		else if (eol_read)
			buffer_reading <= {buffer_reading[BUF_NUM-2:0], buffer_reading[BUF_NUM-1]};
	end

	always @(posedge clk) begin
		if (resetn == 0)
			eol_read <= 0;
		else if (eol_read)
			eol_read <= 0;
		else if (m_axis_tvalid && m_axis_tready && m_axis_tlast)
			eol_read <= 1;
	end

	generate
		genvar i;
		for (i = 0; i < BUF_NUM; i=i+1) begin
			always @(posedge clk) begin
				if (resetn == 0)
					buffer_full[i] <= 0;
				else if (fsync)
					buffer_full[i] <= 0;
				else if ((eol_read & buffer_reading[i]) != (eol_write & buffer_writing[i]))
					buffer_full[i] <= (eol_write & buffer_writing[i]);
			end
		end
	endgenerate

	////////////////////////////////////// scaler //////////////////////////
	wire line_addr_valid;
	wire line_addr_ready;
	wire line_addr_last;
	assign line_addr_ready = ((buffer_writing & buffer_full) == 0 && ~is_writing);
	reg is_writing;
	always @(posedge clk) begin
		if (resetn == 0)
			is_writing <= 0;
		else if (fsync)
			is_writing <= 0;
		else if (line_addr_ready && line_addr_valid)
			is_writing <= 1;
		else if (eol_write)
			is_writing <= 0;
	end

	scale_1d # (
		.C_M_WIDTH(C_IMG_HBITS),
		.C_S_WIDTH(C_IMG_HBITS),
		.C_S_ADDR_WIDTH(C_M_AXI_ADDR_WIDTH)
	) height_scaler (
		.clk(clk),
		.resetn(resetn),
		.s_width(win_height),
		.m_width(dst_height),

		// @note delay 1 clock from fsync to wait for mm_pixel_offset ready
		//       we think the frame_address (1 clock delay after output sof) if ready before fsync
		.start(sof_d1),
		.o_valid(line_addr_valid),
		.o_ready(line_addr_ready),
		.o_last(line_addr_last),

		.s_base_addr(frame_addr),
		.s_off_addr(frame_addr_offset),
		.s_inc_addr(C_IMG_STRIDE_SIZE),
		.s_addr(line_addr)
	);

	wire pixel_addr_valid;
	wire pixel_addr_ready;
	wire pixel_addr_last;
	reg is_reading;
	reg sol_read;
	always @(posedge clk) begin
		if (resetn == 0)
			sol_read <= 0;
		else if (fsync)
			sol_read <= 0;
		else if (sol_read)
			sol_read <= 0;
		else if ((buffer_full & buffer_reading) && ~is_reading)
			sol_read <= 1;
	end
	always @(posedge clk) begin
		if (resetn == 0)
			is_reading <= 0;
		else if (fsync)
			is_reading <= 0;
		else if (sol_read)
			is_reading <= 1;
		else if (eol_read)
			is_reading <= 0;
	end
	scale_1d # (
		.C_M_WIDTH(C_IMG_WBITS),
		.C_S_WIDTH(C_IMG_WBITS),
		.C_S_ADDR_WIDTH(C_IMG_WBITS)
	) width_scaler (
		.clk(clk),
		.resetn(resetn),
		.s_width(win_width),
		.m_width(dst_width),

		.start(sol_read),

		.o_valid(pixel_addr_valid),
		.o_ready(pixel_addr_ready),
		.o_last(pixel_addr_last),

		.s_base_addr(0),
		.s_off_addr(read_offset),
		.s_inc_addr(1),
		.s_addr(read_address)
	);

	////////////////////////////// master axi stream ///////////////////////
	reg axis_tvalid;
	assign m_axis_tvalid = axis_tvalid;
	assign m_axis_tdata = read_data;
	reg axis_tuser;
	assign m_axis_tuser = axis_tuser;
	reg axis_tlast;
	assign m_axis_tlast = axis_tlast;
	wire axis_tready;
	assign axis_tready = m_axis_tready;

	/// @note buffer_reading will change after eol_read
	assign pixel_addr_ready = (is_reading && (~axis_tvalid || axis_tready));
	always @(posedge clk) begin
		if (resetn == 0) begin
			axis_tvalid <= 0;
		end
		else if (pixel_addr_valid && pixel_addr_ready) begin
			axis_tvalid <= 1;
		end
		else if (axis_tready) begin
			axis_tvalid <= 0;
		end
	end
	always @(posedge clk) begin
		if (resetn == 0) begin
			axis_tuser <= 0;
		end
		else if (fsync) begin
			axis_tuser <= 1;
		end
		else if (axis_tvalid && axis_tready) begin
			axis_tuser <= 0;
		end
	end
	always @(posedge clk) begin
		if (resetn == 0) begin
			axis_tlast <= 0;
		end
		else if (pixel_addr_valid && pixel_addr_ready) begin
			axis_tlast <= pixel_addr_last;
		end
	end

endmodule
