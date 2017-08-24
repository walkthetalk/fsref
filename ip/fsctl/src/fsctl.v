
`timescale 1 ns / 1 ps

module fsctl #
(
	parameter integer C_DATA_WIDTH	= 32,
	parameter integer C_ADDR_WIDTH	= 8,

	parameter integer C_IMG_WBITS = 12,
	parameter integer C_IMG_HBITS = 12,

	parameter integer C_IMG_WDEF = 320,
	parameter integer C_IMG_HDEF = 240,

	parameter integer C_BUF_ADDR_WIDTH = 32,
	parameter integer C_DISPBUF0_ADDR  = 'h3FF00000,
	parameter integer C_CMOS0BUF0_ADDR = 'h3F000000,
	parameter integer C_CMOS0BUF1_ADDR = 'h3F100000,
	parameter integer C_CMOS0BUF2_ADDR = 'h3F200000,
	parameter integer C_CMOS0BUF3_ADDR = 'h3F300000,
	parameter integer C_CMOS1BUF0_ADDR = 'h3F400000,
	parameter integer C_CMOS1BUF1_ADDR = 'h3F500000,
	parameter integer C_CMOS1BUF2_ADDR = 'h3F600000,
	parameter integer C_CMOS1BUF3_ADDR = 'h3F700000
)
(
	input clk,
	input resetn,

	/// read/write interface
	input rd_en,
	input [C_ADDR_WIDTH-1:0] rd_addr,
	output reg [C_DATA_WIDTH-1:0] rd_data,

	input wr_en,
	input [C_ADDR_WIDTH-1:0] wr_addr,
	input [C_DATA_WIDTH-1:0] wr_data,

	//// controller
	input o_clk,
	input o_resetn,

	output reg soft_resetn,
	output reg order_1over2,
	input wire fsync,
	output reg o_fsync,

	output wire [C_BUF_ADDR_WIDTH-1:0] dispbuf0_addr,
	output wire [C_BUF_ADDR_WIDTH-1:0] cmos0buf0_addr,
	output wire [C_BUF_ADDR_WIDTH-1:0] cmos0buf1_addr,
	output wire [C_BUF_ADDR_WIDTH-1:0] cmos0buf2_addr,
	output wire [C_BUF_ADDR_WIDTH-1:0] cmos0buf3_addr,
	output wire [C_BUF_ADDR_WIDTH-1:0] cmos1buf0_addr,
	output wire [C_BUF_ADDR_WIDTH-1:0] cmos1buf1_addr,
	output wire [C_BUF_ADDR_WIDTH-1:0] cmos1buf2_addr,
	output wire [C_BUF_ADDR_WIDTH-1:0] cmos1buf3_addr,

	output wire [C_IMG_WBITS-1:0] out_width,
	output wire [C_IMG_HBITS-1:0] out_height,
/// stream 0
	output wire [C_IMG_WBITS-1:0] s0_width,
	output wire [C_IMG_HBITS-1:0] s0_height,

	output wire [C_IMG_WBITS-1:0] s0_win_left,
	output wire [C_IMG_WBITS-1:0] s0_win_width,
	output wire [C_IMG_HBITS-1:0] s0_win_top,
	output wire [C_IMG_HBITS-1:0] s0_win_height,

	output wire [C_IMG_WBITS-1:0] s0_scale_src_width,
	output wire [C_IMG_HBITS-1:0] s0_scale_src_height,
	output wire [C_IMG_WBITS-1:0] s0_scale_dst_width,
	output wire [C_IMG_HBITS-1:0] s0_scale_dst_height,

	output wire [C_IMG_WBITS-1:0] s0_dst_left,
	output wire [C_IMG_WBITS-1:0] s0_dst_width,
	output wire [C_IMG_HBITS-1:0] s0_dst_top,
	output wire [C_IMG_HBITS-1:0] s0_dst_height,
/// stream 1
	output reg [C_IMG_WBITS-1:0] s1_width,
	output reg [C_IMG_HBITS-1:0] s1_height,

	output reg [C_IMG_WBITS-1:0] s1_win_left,
	output reg [C_IMG_WBITS-1:0] s1_win_width,
	output reg [C_IMG_HBITS-1:0] s1_win_top,
	output reg [C_IMG_HBITS-1:0] s1_win_height,

	output wire [C_IMG_WBITS-1:0] s1_scale_src_width,
	output wire [C_IMG_HBITS-1:0] s1_scale_src_height,
	output wire [C_IMG_WBITS-1:0] s1_scale_dst_width,
	output wire [C_IMG_HBITS-1:0] s1_scale_dst_height,

	output reg [C_IMG_WBITS-1:0] s1_dst_left,
	output reg [C_IMG_WBITS-1:0] s1_dst_width,
	output reg [C_IMG_HBITS-1:0] s1_dst_top,
	output reg [C_IMG_HBITS-1:0] s1_dst_height,
/// stream 2
	output reg [C_IMG_WBITS-1:0] s2_width,
	output reg [C_IMG_HBITS-1:0] s2_height,

	output reg [C_IMG_WBITS-1:0] s2_win_left,
	output reg [C_IMG_WBITS-1:0] s2_win_width,
	output reg [C_IMG_HBITS-1:0] s2_win_top,
	output reg [C_IMG_HBITS-1:0] s2_win_height,

	output wire [C_IMG_WBITS-1:0] s2_scale_src_width,
	output wire [C_IMG_HBITS-1:0] s2_scale_src_height,
	output wire [C_IMG_WBITS-1:0] s2_scale_dst_width,
	output wire [C_IMG_HBITS-1:0] s2_scale_dst_height,

	output reg [C_IMG_WBITS-1:0] s2_dst_left,
	output reg [C_IMG_WBITS-1:0] s2_dst_width,
	output reg [C_IMG_HBITS-1:0] s2_dst_top,
	output reg [C_IMG_HBITS-1:0] s2_dst_height
);
	assign dispbuf0_addr = C_DISPBUF0_ADDR;
	assign cmos0buf0_addr = C_CMOS0BUF0_ADDR;
	assign cmos0buf1_addr = C_CMOS0BUF1_ADDR;
	assign cmos0buf2_addr = C_CMOS0BUF2_ADDR;
	assign cmos0buf3_addr = C_CMOS0BUF3_ADDR;
	assign cmos1buf0_addr = C_CMOS1BUF0_ADDR;
	assign cmos1buf1_addr = C_CMOS1BUF1_ADDR;
	assign cmos1buf2_addr = C_CMOS1BUF2_ADDR;
	assign cmos1buf3_addr = C_CMOS1BUF3_ADDR;

	// Example-specific design signals
	// local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
	// ADDR_LSB is used for addressing 32/64 bit registers/memories
	// ADDR_LSB = 2 for 32 bits (n downto 2)
	// ADDR_LSB = 3 for 64 bits (n downto 3)
	localparam integer ADDR_LSB = (C_DATA_WIDTH/32) + 1;

	wire [C_ADDR_WIDTH-1-ADDR_LSB:0] rd_index;
	assign rd_index = rd_addr[C_ADDR_WIDTH-1:ADDR_LSB];
	wire [C_ADDR_WIDTH-1-ADDR_LSB:0] wr_index;
	assign wr_index = wr_addr[C_ADDR_WIDTH-1:ADDR_LSB];

	//----------------------------------------------
	//-- Signals for user logic register space example
	//------------------------------------------------
	//-- Number of Slave Registers 64

	localparam  REG_NUM = 64;
	wire [C_DATA_WIDTH-1:0]	slv_reg[REG_NUM-1 : 0];
	/// read logic
	always @ (posedge clk) begin
		if (rd_en)
			rd_data <= slv_reg[rd_index];
	end

	assign out_width = C_IMG_WDEF;
	assign out_height = C_IMG_HDEF;

	assign s0_width = out_width;
	assign s0_height = out_height;

	assign s0_win_left = 0;
	assign s0_win_width = s0_width;
	assign s0_win_top = 0;
	assign s0_win_height = s0_height;

	assign s0_scale_src_width = s0_width;
	assign s0_scale_src_height = s0_height;
	assign s0_scale_dst_width = s0_width;
	assign s0_scale_dst_height = s0_height;

	assign s0_dst_left = 0;
	assign s0_dst_width = out_width;
	assign s0_dst_top = 0;
	assign s0_dst_height = out_height;

/// aux macro
`define DEFREG(_ridx, _bstart, _bwidth, _name, _defv) \
	reg [_bwidth-1 : 0] r_``_name; \
	assign slv_reg[_ridx][_bstart + _bwidth - 1 : _bstart] = r_``_name; \
	always @ (posedge clk) begin \
		if (resetn == 1'b0) \
			r_``_name <= _defv; \
		else if (wr_en && wr_index == _ridx) \
			r_``_name <= wr_data[_bstart + _bwidth - 1 : _bstart]; \
		else \
			r_``_name <= r_``_name; \
	end

`define DEFREG_EXTERNAL(_ridx, _bstart, _bwidth, _name, _defv) \
	`DEFREG(_ridx, _bstart, _bwidth, _name, _defv) \
	always @ (posedge o_clk) begin \
		if (o_resetn == 1'b0) \
			_name <= _defv; \
		else \
			_name <= r_``_name; \
	end

`define DEFREG_INTERNAL(_ridx, _bstart, _bwidth, _name, _defv) \
	`DEFREG(_ridx, _bstart, _bwidth, _name, _defv) \
	wire _name; \
	assign _name = r_``_name;

/// fsync
	reg fsync_d1;
	always @ (posedge o_clk) begin
		if (o_resetn == 1'b0)
			fsync_d1 <= 1'b0;
		else
			fsync_d1 <= fsync;
	end
	wire fsync_posedge;
	assign fsync_posedge = (fsync && ~fsync_d1);
	always @ (posedge o_clk) begin
		if (o_resetn == 1'b0)
			o_fsync <= 1'b0;
		else
			o_fsync <= fsync_posedge;
	end
	wire fsync_movecfg;
	assign fsync_movecfg = fsync_posedge && ~display_cfging;

/// imagesize aux macro
`define DEFREG_DISP( _ridx, _bstart, _bwidth, _name, _defv) \
	`DEFREG(_ridx, _bstart, _bwidth, _name, _defv) \
	always @ (posedge o_clk) begin \
		if (o_resetn == 1'b0) \
			_name <= _defv; \
		else if (fsync_movecfg) \
			_name <= r_``_name; \
		else \
			_name <= _name; \
	end

`define DEFREG_IMGSIZE( _ridx, _name1, _defv1, _name0, _defv0) \
	`DEFREG_DISP(_ridx, 16, C_IMG_WBITS, _name1, _defv1) \
	`DEFREG_DISP(_ridx,  0, C_IMG_HBITS, _name0, _defv0)

	`DEFREG_EXTERNAL(0, 0, 1, soft_resetn, 0)
	`DEFREG_INTERNAL(0, 1, 1, display_cfging, 0)
	`DEFREG_DISP(0, 2, 1, order_1over2, 0)

	`DEFREG_IMGSIZE( 1, s1_width,     C_IMG_WDEF,  s1_height,     C_IMG_HDEF)
	`DEFREG_IMGSIZE( 2, s1_win_left,           0,  s1_win_top,             0)
	`DEFREG_IMGSIZE( 3, s1_win_width,          0,  s1_win_height,          0)
	`DEFREG_IMGSIZE( 4, s1_dst_left,           0,  s1_dst_top,             0)
	`DEFREG_IMGSIZE( 5, s1_dst_width,          0,  s1_dst_height,          0)

	`DEFREG_IMGSIZE( 6, s2_width,     C_IMG_WDEF,  s2_height,     C_IMG_HDEF)
	`DEFREG_IMGSIZE( 7, s2_win_left,           0,  s2_win_top,             0)
	`DEFREG_IMGSIZE( 8, s2_win_width,          0,  s2_win_height,          0)
	`DEFREG_IMGSIZE( 9, s2_dst_left,           0,  s2_dst_top,             0)
	`DEFREG_IMGSIZE(10, s2_dst_width,          0,  s2_dst_height,          0)

	assign s1_scale_src_width  = s1_win_width;
	assign s1_scale_src_height = s1_win_height;
	assign s1_scale_dst_width  = s1_dst_width;
	assign s1_scale_dst_height = s1_dst_height;

	assign s2_scale_src_width  = s2_win_width;
	assign s2_scale_src_height = s2_win_height;
	assign s2_scale_dst_width  = s2_dst_width;
	assign s2_scale_dst_height = s2_dst_height;

endmodule
