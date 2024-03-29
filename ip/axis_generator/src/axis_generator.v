`timescale 1 ns / 1 ps

module axis_generator #
(
	parameter integer C_WIN_NUM = 2,
	parameter integer C_PIXEL_WIDTH = 8,
	parameter integer C_EXT_FSYNC = 0,
	parameter integer C_IMG_WBITS = 12,
	parameter integer C_IMG_HBITS = 12,
	parameter integer C_VAR_DATA = 0
)
(
	input wire clk,
	input wire resetn,
	input wire fsync,

	input wire [C_IMG_WBITS-1:0] width,
	input wire [C_IMG_HBITS-1:0] height,

	input  wire [C_IMG_WBITS-1:0] s0_left,
	input  wire [C_IMG_HBITS-1:0] s0_top,
	input  wire [C_IMG_WBITS-1:0] s0_width,
	input  wire [C_IMG_HBITS-1:0] s0_height,
	input  wire [C_WIN_NUM-1:0]   s0_dst_bmp,
	output wire [C_WIN_NUM-1:0]   s0_dst_bmp_o,

	input  wire [C_IMG_WBITS-1:0] s1_left,
	input  wire [C_IMG_HBITS-1:0] s1_top,
	input  wire [C_IMG_WBITS-1:0] s1_width,
	input  wire [C_IMG_HBITS-1:0] s1_height,
	input  wire [C_WIN_NUM-1:0]   s1_dst_bmp,
	output wire [C_WIN_NUM-1:0]   s1_dst_bmp_o,

	input  wire [C_IMG_WBITS-1:0] s2_left,
	input  wire [C_IMG_HBITS-1:0] s2_top,
	input  wire [C_IMG_WBITS-1:0] s2_width,
	input  wire [C_IMG_HBITS-1:0] s2_height,
	input  wire [C_WIN_NUM-1:0]   s2_dst_bmp,
	output wire [C_WIN_NUM-1:0]   s2_dst_bmp_o,

	input  wire [C_IMG_WBITS-1:0] s3_left,
	input  wire [C_IMG_HBITS-1:0] s3_top,
	input  wire [C_IMG_WBITS-1:0] s3_width,
	input  wire [C_IMG_HBITS-1:0] s3_height,
	input  wire [C_WIN_NUM-1:0]   s3_dst_bmp,
	output wire [C_WIN_NUM-1:0]   s3_dst_bmp_o,

	input  wire [C_IMG_WBITS-1:0] s4_left,
	input  wire [C_IMG_HBITS-1:0] s4_top,
	input  wire [C_IMG_WBITS-1:0] s4_width,
	input  wire [C_IMG_HBITS-1:0] s4_height,
	input  wire [C_WIN_NUM-1:0]   s4_dst_bmp,
	output wire [C_WIN_NUM-1:0]   s4_dst_bmp_o,

	input  wire [C_IMG_WBITS-1:0] s5_left,
	input  wire [C_IMG_HBITS-1:0] s5_top,
	input  wire [C_IMG_WBITS-1:0] s5_width,
	input  wire [C_IMG_HBITS-1:0] s5_height,
	input  wire [C_WIN_NUM-1:0]   s5_dst_bmp,
	output wire [C_WIN_NUM-1:0]   s5_dst_bmp_o,

	input  wire [C_IMG_WBITS-1:0] s6_left,
	input  wire [C_IMG_HBITS-1:0] s6_top,
	input  wire [C_IMG_WBITS-1:0] s6_width,
	input  wire [C_IMG_HBITS-1:0] s6_height,
	input  wire [C_WIN_NUM-1:0]   s6_dst_bmp,
	output wire [C_WIN_NUM-1:0]   s6_dst_bmp_o,

	input  wire [C_IMG_WBITS-1:0] s7_left,
	input  wire [C_IMG_HBITS-1:0] s7_top,
	input  wire [C_IMG_WBITS-1:0] s7_width,
	input  wire [C_IMG_HBITS-1:0] s7_height,
	input  wire [C_WIN_NUM-1:0]   s7_dst_bmp,
	output wire [C_WIN_NUM-1:0]   s7_dst_bmp_o,

	/// M_AXIS
	output reg  m_axis_tvalid,
	output wire [C_PIXEL_WIDTH-1:0] m_axis_tdata,
	output wire [C_WIN_NUM:0]       m_axis_tuser,
	output wire m_axis_tlast,
	input  wire m_axis_tready
);
	localparam integer C_MAX_WIN_NUM = 8;

	//reg [C_IMG_WBITS-1:0] cidx;
	reg [C_IMG_WBITS-1:0] cidx_next;
	//reg [C_IMG_HBITS-1:0] ridx;
	reg [C_IMG_HBITS-1:0] ridx_next;

	reg m_tuser;
	assign m_axis_tuser[0] = m_tuser;

	wire cupdate;
	wire rupdate;

	reg m_clast;
	reg m_rlast;
	assign m_axis_tlast = m_clast;
	reg m_clast_next;
	reg m_rlast_next;
	always @ (posedge clk) begin
		if (resetn == 1'b0)
			m_rlast <= 1;
		else if (rupdate)
			m_rlast <= m_rlast_next;
	end
	always @ (posedge clk) begin
		if (resetn == 1'b0)
			m_clast <= 1;
		else if (cupdate)
			m_clast <= m_clast_next;
	end

	wire m_plast;
	assign m_plast = m_clast & m_rlast;
generate
if (C_EXT_FSYNC) begin
	assign cupdate = ((m_clast & m_rlast) ? fsync : m_axis_tready);
	assign rupdate = m_clast && (m_rlast ? fsync : m_axis_tready);

	always @ (posedge clk) begin
		if (resetn == 1'b0)
			m_axis_tvalid <= 0;
		else if (fsync)
			m_axis_tvalid <= 1;
		else if (m_axis_tready && m_plast)
			m_axis_tvalid <= 0;
	end
end
else begin
	assign cupdate = (~m_axis_tvalid || m_axis_tready);
	assign rupdate = m_clast && (~m_axis_tvalid || m_axis_tready);

	always @ (posedge clk) begin
		if (resetn == 1'b0)
			m_axis_tvalid <= 0;
		else
			m_axis_tvalid <= 1;
	end
end
endgenerate

	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			cidx_next <= 0;
			m_clast_next <= (width == 1);
		end
		else if (cupdate) begin
			if (m_clast_next)
				cidx_next <= 0;
			else
				cidx_next <= cidx_next + 1;
			m_clast_next <= (width == 1 || cidx_next == (width - 2));
		end
	end

	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			ridx_next <= 0;
			m_rlast_next <= (height == 1);
		end
		else if (rupdate) begin
			if (m_rlast_next)
				ridx_next <= 0;
			else
				ridx_next <= ridx_next + 1;
			m_rlast_next <= (height == 1 || ridx_next == (height - 2));
		end
	end

	//always @ (posedge clk) begin
	//	if (resetn == 1'b0)
	//		cidx <= 0;
	//	else if (cupdate)
	//		cidx <= cidx_next;
	//end

	//always @ (posedge clk) begin
	//	if (resetn == 1'b0)
	//		ridx <= 0;
	//	else if (rupdate)
	//		ridx <= ridx_next;
	//end

	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			m_tuser <= 0;
		end
		else if (cupdate) begin
			if (ridx_next == 0
			    && cidx_next == 0)
				m_tuser <= 1;
			else
				m_tuser <= 0;
		end
	end
generate
if (C_VAR_DATA) begin
	reg[7:0] out_data;
	assign m_axis_tdata = {8'b11111111, out_data[7:0], out_data[7:0], out_data[7:0]};
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			out_data <= 255;
		end
		else if (m_axis_tready & m_axis_tvalid) begin
			if (m_axis_tlast) begin
				out_data <= 255;
			end
			else begin
				out_data <= out_data - 1;
			end
		end
	end
end
else begin
	assign m_axis_tdata = 0;
end
endgenerate

	/// window calc
	wire                     s_enable   [C_WIN_NUM-1 : 0];
	wire [C_WIN_NUM-1:0]     s_dst_bmp  [C_WIN_NUM-1 : 0];
	wire [C_IMG_WBITS-1 : 0] win_left   [C_WIN_NUM-1 : 0];
	wire [C_IMG_HBITS-1 : 0] win_top    [C_WIN_NUM-1 : 0];
	wire [C_IMG_WBITS-1 : 0] win_width  [C_WIN_NUM-1 : 0];
	wire [C_IMG_HBITS-1 : 0] win_height [C_WIN_NUM-1 : 0];

	wire [C_WIN_NUM-1:0]     s_need;

`define ASSIGN_WIN(_idx) \
	if (C_WIN_NUM > _idx) begin \
		assign s_dst_bmp  [_idx] = s``_idx``_dst_bmp; \
		assign win_left   [_idx] = s``_idx``_left   ; \
		assign win_top    [_idx] = s``_idx``_top    ; \
		assign win_width  [_idx] = s``_idx``_width  ; \
		assign win_height [_idx] = s``_idx``_height ; \
		assign s``_idx``_dst_bmp_o = s``_idx``_dst_bmp; \
	end \
	else begin \
		assign s``_idx``_dst_bmp_o = 0; \
	end


	generate
	`ASSIGN_WIN(0)
	`ASSIGN_WIN(1)
	`ASSIGN_WIN(2)
	`ASSIGN_WIN(3)
	`ASSIGN_WIN(4)
	`ASSIGN_WIN(5)
	`ASSIGN_WIN(6)
	`ASSIGN_WIN(7)
	endgenerate

	generate
		genvar i;
		genvar j;
		wire [C_WIN_NUM-1:0]     m_src_bmp  [C_WIN_NUM-1 : 0];
		for (i = 0; i < C_WIN_NUM; i = i+1) begin: m_src_calc
			for (j = 0; j < C_WIN_NUM; j = j+1) begin: m_src_bit_calc
				assign m_src_bmp[i][j] = s_dst_bmp[j][i];
			end
		end

		reg  cpixel_need[C_WIN_NUM-1:0];
		reg  rpixel_need[C_WIN_NUM-1:0];
		for (i = 0; i < C_WIN_NUM; i = i + 1) begin: single_win
			always @ (posedge clk) begin
				if (resetn == 1'b0)
					cpixel_need[i] <= 0;
				else if (cupdate) begin
					if (cidx_next == win_left[i] + win_width[i])
						cpixel_need[i] <= 0;
					else if (cidx_next == win_left[i])
						cpixel_need[i] <= 1;
					/// NOTE: only need when EXT_FSYNC
					else if (m_clast)
						cpixel_need[i] <= 0;
				end
			end
			always @ (posedge clk) begin
				if (resetn == 1'b0)
					rpixel_need[i] <= 0;
				else if (rupdate) begin
					if (ridx_next == win_top[i] + win_height[i])
						rpixel_need[i] <= 0;
					else if (ridx_next == win_top[i])
						rpixel_need[i] <= 1;
					/// NOTE: only need when EXT_FSYNC
					else if (m_rlast)
						rpixel_need[i] <= 0;
				end
			end
			assign s_need[i] = (cpixel_need[i] & rpixel_need[i]);
			assign m_axis_tuser[i+1] = ((s_need & m_src_bmp[i]) != 0);
		end
	endgenerate
endmodule
