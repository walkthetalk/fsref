
`timescale 1 ns / 1 ps

module fsctl #
(
	parameter integer C_DATA_WIDTH	= 32,
	parameter integer C_ADDR_WIDTH	= 8,

	parameter integer C_IMG_WBITS = 12,
	parameter integer C_IMG_HBITS = 12,

	parameter integer C_IMG_WDEF = 320,
	parameter integer C_IMG_HDEF = 240
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
	output wire soft_resetn,

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
	output wire [C_IMG_WBITS-1:0] s1_width,
	output wire [C_IMG_HBITS-1:0] s1_height,

	output wire [C_IMG_WBITS-1:0] s1_win_left,
	output wire [C_IMG_WBITS-1:0] s1_win_width,
	output wire [C_IMG_HBITS-1:0] s1_win_top,
	output wire [C_IMG_HBITS-1:0] s1_win_height,

	output wire [C_IMG_WBITS-1:0] s1_scale_src_width,
	output wire [C_IMG_HBITS-1:0] s1_scale_src_height,
	output wire [C_IMG_WBITS-1:0] s1_scale_dst_width,
	output wire [C_IMG_HBITS-1:0] s1_scale_dst_height,

	output wire [C_IMG_WBITS-1:0] s1_dst_left,
	output wire [C_IMG_WBITS-1:0] s1_dst_width,
	output wire [C_IMG_HBITS-1:0] s1_dst_top,
	output wire [C_IMG_HBITS-1:0] s1_dst_height,
/// stream 2
	output wire [C_IMG_WBITS-1:0] s2_width,
	output wire [C_IMG_HBITS-1:0] s2_height,

	output wire [C_IMG_WBITS-1:0] s2_win_left,
	output wire [C_IMG_WBITS-1:0] s2_win_width,
	output wire [C_IMG_HBITS-1:0] s2_win_top,
	output wire [C_IMG_HBITS-1:0] s2_win_height,

	output wire [C_IMG_WBITS-1:0] s2_scale_src_width,
	output wire [C_IMG_HBITS-1:0] s2_scale_src_height,
	output wire [C_IMG_WBITS-1:0] s2_scale_dst_width,
	output wire [C_IMG_HBITS-1:0] s2_scale_dst_height,

	output wire [C_IMG_WBITS-1:0] s2_dst_left,
	output wire [C_IMG_WBITS-1:0] s2_dst_width,
	output wire [C_IMG_HBITS-1:0] s2_dst_top,
	output wire [C_IMG_HBITS-1:0] s2_dst_height
);

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

	reg [C_DATA_WIDTH-1:0]	slv_reg[REG_NUM-1 : 0];

	/// read logic
	always @ (posedge clk) begin
		if (rd_en)
			rd_data <= slv_reg[rd_index];
	end
	/// write logic
	always @ (posedge clk) begin
		if (wr_en)
			slv_reg[wr_index] <= wr_data;
	end

	assign soft_resetn = slv_reg[0][0];

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
/// stream 1
	assign s1_width      = slv_reg[1][C_IMG_WBITS + 15 : 16];
	assign s1_height     = slv_reg[1][C_IMG_HBITS - 1 : 0];

	assign s1_win_left   = slv_reg[2][C_IMG_WBITS + 15 : 16];
	assign s1_win_top    = slv_reg[2][C_IMG_HBITS - 1 : 0];
	assign s1_win_width  = slv_reg[3][C_IMG_WBITS + 15 : 16];
	assign s1_win_height = slv_reg[3][C_IMG_HBITS - 1 : 0];

	assign s1_scale_src_width  = s1_win_width;
	assign s1_scale_src_height = s1_win_height;
	assign s1_scale_dst_width  = s1_dst_width;
	assign s1_scale_dst_height = s1_dst_height;

	assign s1_dst_left   = slv_reg[4][C_IMG_WBITS + 15 : 16];
	assign s1_dst_top    = slv_reg[4][C_IMG_HBITS - 1 : 0];
	assign s1_dst_width  = slv_reg[5][C_IMG_WBITS + 15 : 16];
	assign s1_dst_height = slv_reg[5][C_IMG_HBITS - 1 : 0];
/// stream 2
	assign s2_width      = slv_reg[6][C_IMG_WBITS + 15 : 16];
	assign s2_height     = slv_reg[6][C_IMG_HBITS - 1 : 0];

	assign s2_win_left   = slv_reg[7][C_IMG_WBITS + 15 : 16];
	assign s2_win_top    = slv_reg[7][C_IMG_HBITS - 1 : 0];
	assign s2_win_width  = slv_reg[8][C_IMG_WBITS + 15 : 16];
	assign s2_win_height = slv_reg[8][C_IMG_HBITS - 1 : 0];

	assign s2_scale_src_width  = s2_win_width;
	assign s2_scale_src_height = s2_win_height;
	assign s2_scale_dst_width  = s2_dst_width;
	assign s2_scale_dst_height = s2_dst_height;

	assign s2_dst_left   = slv_reg[9][C_IMG_WBITS + 15 : 16];
	assign s2_dst_top    = slv_reg[9][C_IMG_HBITS - 1 : 0];
	assign s2_dst_width  = slv_reg[10][C_IMG_WBITS + 15 : 16];
	assign s2_dst_height = slv_reg[10][C_IMG_HBITS - 1 : 0];

endmodule
