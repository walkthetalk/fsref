`include "../src/include/asym_ram.v"
`include "../src/include/line_reader.v"
`include "../src/include/scale_1d.v"
`include "../src/mm2s_adv.v"

`timescale 1ns / 1ps

module test();
	localparam integer C_PIXEL_WIDTH	= 8;
	localparam integer C_PIXEL_STORE_WIDTH  = 8;
	localparam integer C_IMG_STRIDE_WIDTH   = 10;

	localparam integer C_IMG_WBITS = 12;
	localparam integer C_IMG_HBITS = 12;

	localparam integer C_M_AXI_BURST_LEN    = 4;
	localparam integer C_M_AXI_ADDR_WIDTH   = 32;
	localparam integer C_M_AXI_DATA_WIDTH   = 32;

	reg   clk;
	reg   resetn;

	reg   soft_resetn;
	wire  resetting;

/// mm to fifo
	reg [C_IMG_WBITS-1:0] img_width;
	reg [C_IMG_HBITS-1:0] img_height;

	wire [C_IMG_WBITS-1:0] win_left;
	wire [C_IMG_WBITS-1:0] win_width;
	wire [C_IMG_HBITS-1:0] win_top;
	wire [C_IMG_HBITS-1:0] win_height;

	wire [C_IMG_WBITS-1:0] dst_width;
	wire [C_IMG_HBITS-1:0] dst_height;

	reg  fsync;

	wire sof;
	wire  [C_M_AXI_ADDR_WIDTH-1:0] frame_addr;

	// Ports of Axi Master Bus Interface M_AXI
	wire [C_M_AXI_ADDR_WIDTH-1 : 0] m_axi_araddr;
	wire [7 : 0] m_axi_arlen;
	wire [2 : 0] m_axi_arsize;
	wire [1 : 0] m_axi_arburst;
	wire         m_axi_arlock;
	wire [3 : 0] m_axi_arcache;
	wire [2 : 0] m_axi_arprot;
	wire [3 : 0] m_axi_arqos;
	wire         m_axi_arvalid;
	wire         m_axi_arready;
	reg  [C_M_AXI_DATA_WIDTH-1 : 0] m_axi_rdata;
	reg  [1 : 0] m_axi_rresp;
	wire         m_axi_rlast;
	reg          m_axi_rvalid;
	wire         m_axi_rready;

	wire m_axis_tvalid;
	wire [C_PIXEL_WIDTH-1:0] m_axis_tdata;
	wire m_axis_tuser;
	wire m_axis_tlast;
	reg  m_axis_tready;

localparam RANDOMOUTPUT = 1;
localparam RANDOMINPUT = 1;

mm2s_adv #(
	.C_PIXEL_WIDTH(C_PIXEL_WIDTH),
	.C_PIXEL_STORE_WIDTH(C_PIXEL_STORE_WIDTH),
	.C_IMG_STRIDE_WIDTH(C_IMG_STRIDE_WIDTH),
	.C_IMG_WBITS(C_IMG_WBITS),
	.C_IMG_HBITS(C_IMG_HBITS),
	.C_M_AXI_BURST_LEN(C_M_AXI_BURST_LEN),
	.C_M_AXI_ADDR_WIDTH(C_M_AXI_ADDR_WIDTH),
	.C_M_AXI_DATA_WIDTH(C_M_AXI_DATA_WIDTH)
) uut (
	.clk(clk),
	.resetn(resetn),
	.soft_resetn(soft_resetn),
	.resetting(resetting),

	.img_width(img_width),
	.img_height(img_height),

	.win_left(win_left),
	.win_width(win_width),
	.win_top(win_top),
	.win_height(win_height),

	.dst_width(dst_width),
	.dst_height(dst_height),

	.fsync(fsync),

	.sof(sof),
	.frame_addr(frame_addr),

	.m_axi_araddr(m_axi_araddr),
	.m_axi_arlen(m_axi_arlen),
	.m_axi_arsize(m_axi_arsize),
	.m_axi_arburst(m_axi_arburst),
	.m_axi_arlock(m_axi_arlock),
	.m_axi_arcache(m_axi_arcache),
	.m_axi_arprot(m_axi_arprot),
	.m_axi_arqos(m_axi_arqos),
	.m_axi_arvalid(m_axi_arvalid),
	.m_axi_arready(m_axi_arready),
	.m_axi_rdata(m_axi_rdata),
	.m_axi_rresp(m_axi_rresp),
	.m_axi_rlast(m_axi_rlast),
	.m_axi_rvalid(m_axi_rvalid),
	.m_axi_rready(m_axi_rready),

	.m_axis_tvalid(m_axis_tvalid),
	.m_axis_tdata(m_axis_tdata),
	.m_axis_tuser(m_axis_tuser),
	.m_axis_tlast(m_axis_tlast),
	.m_axis_tready(m_axis_tready)
);

initial begin
	clk <= 1'b1;
	forever #1 clk <= ~clk;
end

initial begin
	resetn <= 1'b0;
	repeat (5) #2 resetn <= 1'b0;
	forever #2 resetn <= 1'b1;
end

initial begin
	soft_resetn <= 0;
	repeat (10) #2 soft_resetn <= 0;
	forever #2 soft_resetn <= 1;
end

reg running;
initial begin
	running <= 0;
	repeat (20) #2 running <= 0;
	repeat (1) #2 running <= 1;
	forever #2 running <= 0;
end

always @(posedge clk) begin
	if (resetn == 0)
		fsync <= 0;
	else if (fsync)
		fsync <= 0;
	else if (running)
		fsync <= 1;
end

assign win_left = img_width/4;
assign win_width = img_width/2;
assign win_top = img_height/4;
assign win_height = img_height/2;

assign dst_width = img_width;
assign dst_height = img_height;

assign frame_addr = 32'h3FF80000;

assign m_axi_arready = 1;

////////////////////////////////// file ////////////////////////////////////////
integer fileR, picType, dataPosition, grayDepth;
reg[80*8:0] outputFileName;
reg[11:0] outputFileIdx = 0;
integer fileW = 0;
initial begin
	fileR=$fopen("a.pgm", "r");
	$fscanf(fileR, "P%d\n%d %d\n%d\n", picType, img_width, img_height, grayDepth);
	dataPosition=$ftell(fileR);
	$display("header: %dx%d, %d", img_width, img_height, grayDepth);
end

////////////////////////////////////////////////////////////////////////////////
localparam integer C_IMG_STRIDE_SIZE = 2**C_IMG_STRIDE_WIDTH;
reg [C_M_AXI_ADDR_WIDTH-1:0] img_offset;


reg[7 : 0] burstIdx;
reg[C_M_AXI_ADDR_WIDTH-1:0] burstAddr;
always @(posedge clk) begin: readfile
	integer i;
	if (resetn == 0) begin
		burstIdx = 0;
		burstAddr = 0;
		m_axi_rdata = 0;
	end
	else if (m_axi_arvalid && m_axi_arready) begin
		burstIdx = m_axi_arlen;
		burstAddr = m_axi_araddr;
		img_offset = (burstAddr - frame_addr) / C_IMG_STRIDE_SIZE * img_width + (burstAddr - frame_addr) % C_IMG_STRIDE_SIZE;
		$fseek(fileR, dataPosition + img_offset, 0);
		for (i = 0; i < C_M_AXI_DATA_WIDTH; i = i+8) begin
			m_axi_rdata[i+7 -: 8] = $fgetc(fileR);
		end
	end
	else if (m_axi_rready && m_axi_rvalid && ~m_axi_rlast) begin
		burstIdx = burstIdx - 1;
		burstAddr = burstAddr + (C_M_AXI_DATA_WIDTH / 8);
		img_offset = (burstAddr - frame_addr) / C_IMG_STRIDE_SIZE * img_width + (burstAddr - frame_addr) % C_IMG_STRIDE_SIZE;
		$fseek(fileR, dataPosition + img_offset, 0);
		for (i = 0; i < C_M_AXI_DATA_WIDTH; i = i+8) begin
			m_axi_rdata[i+7 -: 8] = $fgetc(fileR);
		end
	end
end
assign m_axi_rlast = (burstIdx == 0);

reg readingmm;
always @(posedge clk) begin
	if (resetn == 0) begin
		readingmm <= 0;
	end
	else if (m_axi_arvalid && m_axi_arready) begin
		readingmm <= 1;
	end
	else if (m_axi_rready && m_axi_rvalid && m_axi_rlast) begin
		readingmm <= 0;
	end
end
always @(posedge clk) begin
	if (resetn == 0) begin
		m_axi_rvalid <= 0;
	end
	else
		m_axi_rvalid = (readingmm && (RANDOMINPUT ? {$random}%2 : 1));
end

//////////////////////////////////////////// output ////////////////////////////
always @(posedge clk) begin
	if (resetn == 0) begin
		m_axis_tready <= 0;
	end
	else if (~m_axis_tready || m_axis_tvalid)
		m_axis_tready <= (RANDOMOUTPUT ? {$random}%2 : 1);
end

reg [C_IMG_WBITS-1:0] m_axis_width;
reg [C_IMG_HBITS-1:0] m_axis_height;
reg [C_IMG_WBITS-1:0] m_axis_col;
reg [C_IMG_HBITS-1:0] m_axis_row;
reg [C_M_AXI_ADDR_WIDTH-1:0] outputFileIdx;
reg[80*8:0] outputFileName;
integer fileW = 0;
always @ (posedge clk) begin
	if (resetn == 0) begin
		m_axis_width <= 0;
		m_axis_height <= 0;
		outputFileIdx <= 0;
	end
	else if (fsync) begin
		m_axis_width <= dst_width;
		m_axis_height <= dst_height;
		m_axis_col <= 1;
		m_axis_row <= 1;

		outputFileIdx <= outputFileIdx + 1;
		$sformat(outputFileName, "output%0d.pgm", outputFileIdx);
		fileW=$fopen(outputFileName, "w");
		$display("outputFileName: %s - %0d", outputFileName, fileW);
		$fwrite(fileW, "P%0d\n%0d %0d\n%0d\n", picType, dst_width, dst_height, grayDepth);
	end
	else if (m_axis_tvalid && m_axis_tready) begin
		if (m_axis_col > m_axis_width || m_axis_row > m_axis_height) begin
			$error("too big frame!\n");
		end
		if (m_axis_tuser) begin
			if (m_axis_col != 1 || m_axis_row != 1) begin
				$error("start frame col/row index error!\n");
			end
			else begin
				$write("start frame\n");
			end
		end
		$write("%0d ", m_axis_tdata);
		if (m_axis_tlast) begin
			if (m_axis_col != m_axis_width) begin
				$error("\nline end error!\n");
			end
			else begin
				$write("\n");
			end
		end

		$fwrite(fileW, "%c", m_axis_tdata);
		if (m_axis_col == m_axis_width && m_axis_row == m_axis_height) begin
			$fclose(fileW);
		end

		if (m_axis_tlast) begin
			m_axis_row <= m_axis_row + 1;
			m_axis_col <= 1;
		end
		else begin
			m_axis_col <= m_axis_col + 1;
		end
	end
end

endmodule
