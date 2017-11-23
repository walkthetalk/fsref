`timescale 1 ns / 1 ps

module axis_generator #
(
	parameter integer C_WIN_NUM = 2,
	parameter integer C_PIXEL_WIDTH = 8,
	parameter integer C_IMG_WBITS = 12,
	parameter integer C_IMG_HBITS = 12
)
(
	input wire clk,
	input wire resetn,

	input wire [C_IMG_WBITS-1:0] width,
	input wire [C_IMG_HBITS-1:0] height,

	input wire [C_IMG_WBITS-1:0] win0_left,
	input wire [C_IMG_HBITS-1:0] win0_top,
	input wire [C_IMG_WBITS-1:0] win0_width,
	input wire [C_IMG_HBITS-1:0] win0_height,
	input wire [C_IMG_WBITS-1:0] win0_righte,
	input wire [C_IMG_HBITS-1:0] win0_bottome,

	input wire [C_IMG_WBITS-1:0] win1_left,
	input wire [C_IMG_HBITS-1:0] win1_top,
	input wire [C_IMG_WBITS-1:0] win1_width,
	input wire [C_IMG_HBITS-1:0] win1_height,
	input wire [C_IMG_WBITS-1:0] win1_righte,
	input wire [C_IMG_HBITS-1:0] win1_bottome,

	input wire [C_IMG_WBITS-1:0] win2_left,
	input wire [C_IMG_HBITS-1:0] win2_top,
	input wire [C_IMG_WBITS-1:0] win2_width,
	input wire [C_IMG_HBITS-1:0] win2_height,
	input wire [C_IMG_WBITS-1:0] win2_righte,
	input wire [C_IMG_HBITS-1:0] win2_bottome,

	input wire [C_IMG_WBITS-1:0] win3_left,
	input wire [C_IMG_HBITS-1:0] win3_top,
	input wire [C_IMG_WBITS-1:0] win3_width,
	input wire [C_IMG_HBITS-1:0] win3_height,
	input wire [C_IMG_WBITS-1:0] win3_righte,
	input wire [C_IMG_HBITS-1:0] win3_bottome,

	input wire [C_IMG_WBITS-1:0] win4_left,
	input wire [C_IMG_HBITS-1:0] win4_top,
	input wire [C_IMG_WBITS-1:0] win4_width,
	input wire [C_IMG_HBITS-1:0] win4_height,
	input wire [C_IMG_WBITS-1:0] win4_righte,
	input wire [C_IMG_HBITS-1:0] win4_bottome,

	input wire [C_IMG_WBITS-1:0] win5_left,
	input wire [C_IMG_HBITS-1:0] win5_top,
	input wire [C_IMG_WBITS-1:0] win5_width,
	input wire [C_IMG_HBITS-1:0] win5_height,
	input wire [C_IMG_WBITS-1:0] win5_righte,
	input wire [C_IMG_HBITS-1:0] win5_bottome,

	input wire [C_IMG_WBITS-1:0] win6_left,
	input wire [C_IMG_HBITS-1:0] win6_top,
	input wire [C_IMG_WBITS-1:0] win6_width,
	input wire [C_IMG_HBITS-1:0] win6_height,
	input wire [C_IMG_WBITS-1:0] win6_righte,
	input wire [C_IMG_HBITS-1:0] win6_bottome,

	input wire [C_IMG_WBITS-1:0] win7_left,
	input wire [C_IMG_HBITS-1:0] win7_top,
	input wire [C_IMG_WBITS-1:0] win7_width,
	input wire [C_IMG_HBITS-1:0] win7_height,
	input wire [C_IMG_WBITS-1:0] win7_righte,
	input wire [C_IMG_HBITS-1:0] win7_bottome,

	/// M_AXIS
	output reg  m_axis_tvalid,
	output wire [C_PIXEL_WIDTH-1:0] m_axis_tdata,
	output reg  m_axis_tuser,
	output reg  m_axis_tlast,
	input  wire m_axis_tready,

	output wire [C_WIN_NUM-1:0]     win_pixel_need
);
	localparam integer C_MAX_WIN_NUM = 8;

	reg [C_IMG_WBITS-1:0] cidx;
	reg [C_IMG_WBITS-1:0] cidx_next;
	reg [C_IMG_HBITS-1:0] ridx;
	reg [C_IMG_HBITS-1:0] ridx_next;

	always @ (posedge clk) begin
		if (resetn == 1'b0)
			m_axis_tvalid <= 0;
		else
			m_axis_tvalid <= 1;
	end

	always @ (posedge clk) begin
		if (resetn == 1'b0)
			m_axis_tuser <= 0;
		else if (cidx == 0 && ridx == 0)
			m_axis_tuser <= 1;
		else
			m_axis_tuser <= 0;
	end

	wire cupdate;
	wire rupdate;
	assign cupdate = ~m_axis_tvalid || m_axis_tready;
	assign rupdate = ~m_axis_tvalid || (m_axis_tready && m_axis_tlast);

	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			cidx <= 0;
			cidx_next <= 0;
		end
		else if (cupdate) begin
			cidx <= cidx_next;
			if (cidx_next == width - 1)
				cidx_next <= 0;
			else
				cidx_next <= cidx_next + 1;
		end
	end

	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			ridx <= 0;
			ridx_next <= 0;
		end
		else if (rupdate) begin
			ridx <= ridx_next;
			if (ridx_next == height - 1)
				ridx_next <= 0;
			else
				ridx_next <= ridx_next + 1;
		end
	end

	always @ (posedge clk) begin
		if (resetn == 1'b0)
			m_axis_tlast <= 0;
		else if (cupdate)
			m_axis_tlast <= (cidx_next == width - 1);
	end
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			m_axis_tuser <= 1;
		end
		else if (cupdate) begin
			if (ridx_next == 0
			    && cidx_next == 0)
				m_axis_tuser <= 1;
			else
				m_axis_tuser <= 0;
		end
	end
	assign m_axis_tdata = 0;

	/// window calc
	wire [C_IMG_WBITS-1 : 0] win_left   [C_MAX_WIN_NUM-1 : 0];
	wire [C_IMG_HBITS-1 : 0] win_top    [C_MAX_WIN_NUM-1 : 0];
	wire [C_IMG_WBITS-1 : 0] win_width  [C_MAX_WIN_NUM-1 : 0];
	wire [C_IMG_HBITS-1 : 0] win_height [C_MAX_WIN_NUM-1 : 0];
	wire [C_IMG_WBITS-1 : 0] win_righte [C_MAX_WIN_NUM-1 : 0];
	wire [C_IMG_HBITS-1 : 0] win_bottome[C_MAX_WIN_NUM-1 : 0];

`define ASSIGN_WIN(i) \
	assign win_left   [i] = win``i``_left   ; \
	assign win_top    [i] = win``i``_top    ; \
	assign win_width  [i] = win``i``_width  ; \
	assign win_height [i] = win``i``_height ; \
	assign win_righte [i] = win``i``_righte ; \
	assign win_bottome[i] = win``i``_bottome;

	`ASSIGN_WIN(0)
	`ASSIGN_WIN(1)
	`ASSIGN_WIN(2)
	`ASSIGN_WIN(3)
	`ASSIGN_WIN(4)
	`ASSIGN_WIN(5)
	`ASSIGN_WIN(6)
	`ASSIGN_WIN(7)


	generate
		genvar i;
		reg  cpixel_need[C_WIN_NUM-1:0];
		reg  rpixel_need[C_WIN_NUM-1:0];
		for (i = 0; i < C_WIN_NUM; i = i + 1) begin: single_win
			always @ (posedge clk) begin
				if (resetn == 1'b0)
					cpixel_need[i] <= 0;
				else if (cupdate) begin
					if (cidx_next == win_left[i])
						cpixel_need[i] <= 1;
					else if (cidx == win_righte[i])
						cpixel_need[i] <= 0;
				end
			end
			always @ (posedge clk) begin
				if (resetn == 1'b0)
					rpixel_need[i] <= 0;
				else if (rupdate) begin
					if (ridx_next == win_top[i])
						rpixel_need[i] <= 1;
					else if (ridx == win_bottome[i])
						rpixel_need[i] <= 0;
				end
			end
			assign win_pixel_need[i] = (cpixel_need[i] & rpixel_need[i]);
		end
	endgenerate
endmodule
