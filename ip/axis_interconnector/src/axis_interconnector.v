`timescale 1 ns / 1 ps

module axis_interconnector #
(
	parameter integer C_PIXEL_WIDTH	 = 8,
	parameter integer C_S_STREAM_NUM = 8,
	parameter integer C_M_STREAM_NUM = 8,
	parameter integer C_ONE2MANY     = 0
)
(
	input wire clk,
	input wire resetn,

	/// S0_AXIS
	input  wire                        s0_axis_tvalid,
	input  wire [C_PIXEL_WIDTH-1:0]    s0_axis_tdata,
	input  wire                        s0_axis_tuser,
	input  wire                        s0_axis_tlast,
	output wire                        s0_axis_tready,
	input  wire [C_M_STREAM_NUM-1:0]   s0_dst_bmp,

	/// M0_AXIS
	output wire                        m0_axis_tvalid,
	output wire [C_PIXEL_WIDTH-1:0]    m0_axis_tdata,
	output wire                        m0_axis_tuser,
	output wire                        m0_axis_tlast,
	input  wire                        m0_axis_tready,

	/// S1_AXIS
	input  wire                        s1_axis_tvalid,
	input  wire [C_PIXEL_WIDTH-1:0]    s1_axis_tdata,
	input  wire                        s1_axis_tuser,
	input  wire                        s1_axis_tlast,
	output wire                        s1_axis_tready,
	input  wire [C_M_STREAM_NUM-1:0]   s1_dst_bmp,

	/// M1_AXIS
	output wire                        m1_axis_tvalid,
	output wire [C_PIXEL_WIDTH-1:0]    m1_axis_tdata,
	output wire                        m1_axis_tuser,
	output wire                        m1_axis_tlast,
	input  wire                        m1_axis_tready,

	/// S2_AXIS
	input  wire                        s2_axis_tvalid,
	input  wire [C_PIXEL_WIDTH-1:0]    s2_axis_tdata,
	input  wire                        s2_axis_tuser,
	input  wire                        s2_axis_tlast,
	output wire                        s2_axis_tready,
	input  wire [C_M_STREAM_NUM-1:0]   s2_dst_bmp,

	/// M2_AXIS
	output wire                        m2_axis_tvalid,
	output wire [C_PIXEL_WIDTH-1:0]    m2_axis_tdata,
	output wire                        m2_axis_tuser,
	output wire                        m2_axis_tlast,
	input  wire                        m2_axis_tready,

	/// S3_AXIS
	input  wire                        s3_axis_tvalid,
	input  wire [C_PIXEL_WIDTH-1:0]    s3_axis_tdata,
	input  wire                        s3_axis_tuser,
	input  wire                        s3_axis_tlast,
	output wire                        s3_axis_tready,
	input  wire [C_M_STREAM_NUM-1:0]   s3_dst_bmp,

	/// M3_AXIS
	output wire                        m3_axis_tvalid,
	output wire [C_PIXEL_WIDTH-1:0]    m3_axis_tdata,
	output wire                        m3_axis_tuser,
	output wire                        m3_axis_tlast,
	input  wire                        m3_axis_tready,

	/// S4_AXIS
	input  wire                        s4_axis_tvalid,
	input  wire [C_PIXEL_WIDTH-1:0]    s4_axis_tdata,
	input  wire                        s4_axis_tuser,
	input  wire                        s4_axis_tlast,
	output wire                        s4_axis_tready,
	input  wire [C_M_STREAM_NUM-1:0]   s4_dst_bmp,

	/// M4_AXIS
	output wire                        m4_axis_tvalid,
	output wire [C_PIXEL_WIDTH-1:0]    m4_axis_tdata,
	output wire                        m4_axis_tuser,
	output wire                        m4_axis_tlast,
	input  wire                        m4_axis_tready,

	/// S5_AXIS
	input  wire                        s5_axis_tvalid,
	input  wire [C_PIXEL_WIDTH-1:0]    s5_axis_tdata,
	input  wire                        s5_axis_tuser,
	input  wire                        s5_axis_tlast,
	output wire                        s5_axis_tready,
	input  wire [C_M_STREAM_NUM-1:0]   s5_dst_bmp,

	/// M5_AXIS
	output wire                        m5_axis_tvalid,
	output wire [C_PIXEL_WIDTH-1:0]    m5_axis_tdata,
	output wire                        m5_axis_tuser,
	output wire                        m5_axis_tlast,
	input  wire                        m5_axis_tready,

	/// S6_AXIS
	input  wire                        s6_axis_tvalid,
	input  wire [C_PIXEL_WIDTH-1:0]    s6_axis_tdata,
	input  wire                        s6_axis_tuser,
	input  wire                        s6_axis_tlast,
	output wire                        s6_axis_tready,
	input  wire [C_M_STREAM_NUM-1:0]   s6_dst_bmp,

	/// M6_AXIS
	output wire                        m6_axis_tvalid,
	output wire [C_PIXEL_WIDTH-1:0]    m6_axis_tdata,
	output wire                        m6_axis_tuser,
	output wire                        m6_axis_tlast,
	input  wire                        m6_axis_tready,

	/// S7_AXIS
	input  wire                        s7_axis_tvalid,
	input  wire [C_PIXEL_WIDTH-1:0]    s7_axis_tdata,
	input  wire                        s7_axis_tuser,
	input  wire                        s7_axis_tlast,
	output wire                        s7_axis_tready,
	input  wire [C_M_STREAM_NUM-1:0]   s7_dst_bmp,

	/// M7_AXIS
	output wire                        m7_axis_tvalid,
	output wire [C_PIXEL_WIDTH-1:0]    m7_axis_tdata,
	output wire                        m7_axis_tuser,
	output wire                        m7_axis_tlast,
	input  wire                        m7_axis_tready
);
	localparam integer C_MAX_STREAM_NUM = 8;
	generate
		genvar i;
		genvar j;
	endgenerate

	wire                        s_tvalid [C_MAX_STREAM_NUM-1:0];
	wire [C_PIXEL_WIDTH-1:0]    s_tdata  [C_MAX_STREAM_NUM-1:0];
	wire                        s_tuser  [C_MAX_STREAM_NUM-1:0];
	wire                        s_tlast  [C_MAX_STREAM_NUM-1:0];
	wire                        s_tready [C_MAX_STREAM_NUM-1:0];
	wire [C_M_STREAM_NUM-1:0]   s_dst_bmp[C_MAX_STREAM_NUM-1:0];

	wire                        m_tvalid [C_MAX_STREAM_NUM-1:0];
	wire [C_PIXEL_WIDTH-1:0]    m_tdata  [C_MAX_STREAM_NUM-1:0];
	wire                        m_tuser  [C_MAX_STREAM_NUM-1:0];
	wire                        m_tlast  [C_MAX_STREAM_NUM-1:0];
	wire                        m_tready [C_MAX_STREAM_NUM-1:0];

`define ASSIGN_STREAM(i) \
	assign s_tvalid[i]        = s``i``_axis_tvalid; \
	assign s_tdata[i]         = s``i``_axis_tdata; \
	assign s_tuser[i]         = s``i``_axis_tuser; \
	assign s_tlast[i]         = s``i``_axis_tlast; \
	assign s``i``_axis_tready = s_tready[i]; \
	assign s_dst_bmp[i]       = s``i``_dst_bmp; \
	assign m``i``_axis_tvalid = m_tvalid[i]; \
	assign m``i``_axis_tdata  = m_tdata[i] ; \
	assign m``i``_axis_tuser  = m_tuser[i] ; \
	assign m``i``_axis_tlast  = m_tlast[i] ; \
	assign m_tready[i]        = m``i``_axis_tready; \

	`ASSIGN_STREAM(0)
	`ASSIGN_STREAM(1)
	`ASSIGN_STREAM(2)
	`ASSIGN_STREAM(3)
	`ASSIGN_STREAM(4)
	`ASSIGN_STREAM(5)
	`ASSIGN_STREAM(6)
	`ASSIGN_STREAM(7)

	/// convert
	wire [C_S_STREAM_NUM-1:0]  sc_tvalid                   ;
	wire [C_S_STREAM_NUM-1:0]  sc_tdata [C_PIXEL_WIDTH-1:0];
	wire [C_S_STREAM_NUM-1:0]  sc_tuser                    ;
	wire [C_S_STREAM_NUM-1:0]  sc_tlast                    ;
	wire [C_S_STREAM_NUM-1:0]  sc_tready                   ;

	reg                        m_valid[C_M_STREAM_NUM-1:0];
	reg [C_PIXEL_WIDTH-1:0]    m_data [C_M_STREAM_NUM-1:0];
	reg                        m_user [C_M_STREAM_NUM-1:0];
	reg                        m_last [C_M_STREAM_NUM-1:0];
	wire [C_M_STREAM_NUM-1:0]  m_4s_ready;
	wire [C_M_STREAM_NUM-1:0]  s_2m_valid;
	wire [C_M_STREAM_NUM-1:0]  s_2m_next;
	wire [C_S_STREAM_NUM-1:0]  m_src_bmp[C_M_STREAM_NUM-1:0];

	generate
		for (i = 0; i < C_S_STREAM_NUM; i = i+1) begin: single_stream_convert
			assign sc_tvalid[i] = s_tvalid[i];
			assign sc_tuser [i] = s_tuser [i];
			assign sc_tlast [i] = s_tlast [i];
			assign s_tready[i]  = sc_tready[i];
			for (j = 0; j < C_PIXEL_WIDTH; j = j + 1) begin: single_stream_bit_convert
				assign sc_tdata [j][i] = s_tdata [i][j];
			end

			if (C_ONE2MANY)
				assign sc_tready[i]   = ((m_4s_ready & s_dst_bmp[i]) == s_dst_bmp[i]);
			else
				assign sc_tready[i]   = ((m_4s_ready & s_dst_bmp[i]) != 0);
		end
		for (i = C_S_STREAM_NUM; i < C_MAX_STREAM_NUM; i = i+1) begin: disabled_s_stream
			assign s_tready[i] = 0;
		end
	endgenerate
	generate
		for (i = 0; i < C_M_STREAM_NUM; i = i+1) begin: single_out
			for (j = 0; j < C_S_STREAM_NUM; j = j+1) begin: single_in_bmp
				assign m_src_bmp[i][j] = s_dst_bmp[j][i];
			end

			assign m_4s_ready[i]   = (~m_tvalid[i] | m_tready[i]);
			assign m_tvalid[i] = m_valid[i];
			assign m_tdata [i] = m_data[i];
			assign m_tuser [i] = m_user[i];
			assign m_tlast [i] = m_last[i];

			assign s_2m_valid[i] = ((sc_tvalid & m_src_bmp[i]) != 0);

			if (C_ONE2MANY) begin
				assign s_2m_next[i]  = (s_2m_valid[i] && ((sc_tready & m_src_bmp[i]) != 0));
				always @ (posedge clk) begin
					if (resetn == 1'b0)
						m_valid[i] <= 0;
					else if (s_2m_next[i])
						m_valid[i] <= 1;
					else if (m_tready[i])
						m_valid[i] <= 0;
				end
			end
			else begin
				assign s_2m_next[i]  = (s_2m_valid[i] && m_4s_ready[i]);
				always @ (posedge clk) begin
					if (resetn == 1'b0)
						m_valid[i] <= 0;
					else if (s_2m_valid[i])
						m_valid[i] <= 1;
					else if (m_tready[i])
						m_valid[i] <= 0;
				end
			end

			always @ (posedge clk) begin
				if (resetn == 1'b0) begin
					m_user[i] <= 0;
					m_last[i] <= 0;
				end
				else if (s_2m_next[i]) begin
					m_user[i] <= ((sc_tuser & m_src_bmp[i]) != 0);
					m_last[i] <= ((sc_tlast & m_src_bmp[i]) != 0);
				end
			end

			for (j = 0; j < C_PIXEL_WIDTH; j=j+1) begin: single_bit_assign
				always @ (posedge clk) begin
					if (resetn == 1'b0) begin
						m_data[i][j] <= 0;
					end
					else if (s_2m_next[i]) begin
						m_data[i][j] <= ((sc_tdata[j] & m_src_bmp[i]) != 0);
					end
				end
			end
		end
		for (i = C_M_STREAM_NUM; i < C_MAX_STREAM_NUM; i = i+1) begin: disabled_m_stream
			assign m_tvalid[i] = 0;
			assign m_tdata [i] = 0;
			assign m_tuser [i] = 0;
			assign m_tlast [i] = 0;
		end
	endgenerate

endmodule
