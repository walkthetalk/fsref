`timescale 1 ns / 1 ps

module scale_1d #
(
	parameter integer C_M_WIDTH = 12,
	parameter integer C_S_WIDTH = 10,

	parameter integer C_S_ADDR_WIDTH = 32
)
(
	input wire clk,
	input wire resetn,

	input wire [C_S_WIDTH-1:0] s_width,
	input wire [C_M_WIDTH-1:0] m_width,

	input wire start,

	output wire o_valid,
	output wire [C_S_WIDTH-1:0] s_index,
	output wire [C_M_WIDTH-1:0] m_index,
	output wire o_last,
	input wire  o_ready,

	input  wire [C_S_ADDR_WIDTH-1:0] s_base_addr,
	input  wire [C_S_ADDR_WIDTH-1:0] s_off_addr,
	input  wire [C_S_ADDR_WIDTH-1:0] s_inc_addr,
	output reg  [C_S_ADDR_WIDTH-1:0] s_addr
);

	localparam integer C_CNT_WIDTH = C_M_WIDTH + C_S_WIDTH;

	wire progress;
	assign progress = ~o_valid || o_ready;
	wire next;
	assign next = o_valid && o_ready;

	reg [C_CNT_WIDTH-1 : 0] s_cnt;
	reg [C_CNT_WIDTH-1 : 0] m_cnt;

	reg [C_S_WIDTH-1 : 0] s_idx;
	assign s_index = s_idx;
	reg [C_M_WIDTH-1 : 0] m_idx;
	assign m_index = m_idx;

	reg running;
	always @(posedge clk) begin
		if (resetn == 0) begin
			running <= 0;
		end
		else if (start) begin
			running <= 1;
		end
		else if (next && m_idx == m_width - 1) begin
			running <= 0;
		end
	end

	assign o_valid = (running && s_cnt >= m_cnt);
	always @(posedge clk) begin
		if (resetn == 0) begin
			s_cnt <= 0;
			s_idx <= 0;
			s_addr <= 0;

			m_cnt <= 0;
			m_idx <= 0;
		end
		else if (start) begin
			s_cnt <= m_width;
			s_idx <= 0;
			s_addr <= s_base_addr + s_off_addr;

			m_cnt <= s_width;
			m_idx <= 0;
		end
		else if (running) begin
			if (progress) begin
				if (s_cnt <= m_cnt) begin
					s_cnt <= s_cnt + m_width;
					s_idx <= s_idx + 1;
					s_addr <= s_addr + s_inc_addr;
				end
				if (s_cnt >= m_cnt) begin
					m_cnt <= m_cnt + s_width;
					m_idx <= m_idx + 1;
				end
			end
		end
	end

	reg last;
	assign o_last = last;
	always @(posedge clk) begin
		if (resetn == 0) begin
			last <= 0;
		end
		else if (start) begin
			last <= 0;
		end
		else if (next && m_idx == m_width - 2) begin
			last <= 1;
		end
	end

endmodule
