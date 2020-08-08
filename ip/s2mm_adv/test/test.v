`timescale 1ns / 1ps

/// 2. first line output : if f0 valid
/// 3. sof for reset

module test();
parameter integer C_PIXEL_WIDTH	= 8;
parameter integer C_IMG_WBITS = 12;
parameter integer C_IMG_HBITS = 12;
parameter integer C_DATACOUNT_BITS = 10;

// User parameters ends

// Parameters of Axi Master Bus Interface M_AXI
parameter integer C_M_AXI_BURST_LEN    = 16;
parameter integer C_M_AXI_ID_WIDTH    = 1;
parameter integer C_M_AXI_ADDR_WIDTH    = 32;
parameter integer C_M_AXI_DATA_WIDTH    = 32;

wire [C_M_AXI_ID_WIDTH-1 : 0] m_axi_awid;
wire [C_M_AXI_ADDR_WIDTH-1 : 0] m_axi_awaddr;
wire [7 : 0] m_axi_awlen;
wire [2 : 0] m_axi_awsize;
wire [1 : 0] m_axi_awburst;
wire  m_axi_awlock;
wire [3 : 0] m_axi_awcache;
wire [2 : 0] m_axi_awprot;
wire [3 : 0] m_axi_awqos;
wire  m_axi_awvalid;
reg  m_axi_awready = 1;

wire [C_M_AXI_DATA_WIDTH-1 : 0] m_axi_wdata;
wire [C_M_AXI_DATA_WIDTH/8-1 : 0] m_axi_wstrb;
wire  m_axi_wlast;
wire  m_axi_wvalid;
reg m_axi_wready = 1;
reg [C_M_AXI_ID_WIDTH-1 : 0] m_axi_bid;
reg [1 : 0] m_axi_bresp;
reg m_axi_bvalid;
wire  m_axi_bready;

wire[31:0] S_AXIS_tdata;
wire S_AXIS_tlast;
wire S_AXIS_tready;
wire S_AXIS_tuser;
reg S_AXIS_tvalid;

reg[11:0] height = 240;
reg[11:0] width = 320;

wire[31:0] addr;
assign addr = 32'h3FF80000;

reg clk;
reg resetn;

localparam RANDOMOUTPUT = 1;
localparam RANDOMINPUT = 1;

wire[9:0] rd_data_count;

s2mmbd_wrapper uut(
	.M_AXI_awid(m_axi_awid),
	.M_AXI_awaddr(m_axi_awaddr),
	.M_AXI_awlen(m_axi_awlen),
	.M_AXI_awsize(m_axi_awsize),
	.M_AXI_awburst(m_axi_awburst),
	.M_AXI_awlock(m_axi_awlock),
	.M_AXI_awcache(m_axi_awcache),
	.M_AXI_awprot(m_axi_awprot),
	.M_AXI_awqos(m_axi_awqos),
	.M_AXI_awvalid(m_axi_awvalid),
	.M_AXI_awready(m_axi_awready),

	.M_AXI_wdata(m_axi_wdata),
	.M_AXI_wstrb(m_axi_wstrb),
	.M_AXI_wlast(m_axi_wlast),
	.M_AXI_wvalid(m_axi_wvalid),
	.M_AXI_wready(m_axi_wready),
	.M_AXI_bid(m_axi_bid),
	.M_AXI_bresp(m_axi_bresp),
	.M_AXI_bvalid(m_axi_bvalid),
	.M_AXI_bready(m_axi_bready),

	.S_AXIS_tdata(S_AXIS_tdata),
	.S_AXIS_tlast(S_AXIS_tlast),
	.S_AXIS_tready(S_AXIS_tready),
	.S_AXIS_tuser(S_AXIS_tuser),
	.S_AXIS_tvalid(S_AXIS_tvalid),

	.addr(addr),
	.clk(clk),
	.img_height(height),
	.img_width(width),
	.resetn(resetn),
	.soft_resetn(1'b1),
	.rd_data_count(rd_data_count)
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

reg[11:0] col;
reg[11:0] row;
wire final_data;
assign final_data = (col == 0 && row == 0);
assign S_AXIS_tuser = (col == width-1 && row == height-1);
assign S_AXIS_tlast = (col == 0);
assign S_AXIS_tdata = ((row << 16) | col);

reg randominput;
always @(posedge clk) begin
	if (resetn == 1'b0)
		randominput <= 1'b0;
	else
		randominput <= (RANDOMINPUT ? {$random}%2 : 1);

	if (resetn == 1'b0) begin
	   col <= width-1;
	   row <= height -1;
	end
	else if (S_AXIS_tvalid && S_AXIS_tready) begin
	   if (col != 0) begin
	       col <= col - 1;
	       row <= row;
	   end
	   else if (row != 0) begin
	       col <= width - 1;
	       row <= row - 1;
	   end
	   else begin
	       col <= width-1;
	       row <= height-1;
	   end
	end
	else begin
	   col <= col;
	   row <= row;
	end

    if (resetn == 1'b0)
        S_AXIS_tvalid <= 1'b0;
    else
        S_AXIS_tvalid <= randominput;
end

endmodule
