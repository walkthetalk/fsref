`timescale 1 ns / 1 ps

`include "aux_macro.v"

module fsctl #
(
	parameter integer C_CORE_VERSION   = 32'hFF00FF00,
	parameter integer C_TS_WIDTH       = 64,

	parameter integer C_DATA_WIDTH     = 32,
	parameter integer C_REG_IDX_WIDTH  = 8,

	parameter integer C_IMG_WBITS      = 12,
	parameter integer C_IMG_HBITS      = 12,

	parameter integer C_IMG_WDEF       = 320,
	parameter integer C_IMG_HDEF       = 240,

	parameter integer C_STREAM_NBR     = 2,

	parameter integer C_BUF_ADDR_WIDTH = 32,
	parameter integer C_BUF_IDX_WIDTH  = 2,
	parameter integer C_ST_ADDR = 'h3D000000,
	parameter integer C_S0_ADDR = 'h3E000000,
	parameter integer C_S0_SIZE = 'h00100000,
	parameter integer C_S1_ADDR = 'h3E400000,
	parameter integer C_S1_SIZE = 'h00100000,
	parameter integer C_S2_ADDR = 'h3E800000,
	parameter integer C_S2_SIZE = 'h00100000,
	parameter integer C_S3_ADDR = 'h3EB00000,
	parameter integer C_S3_SIZE = 'h00100000,
	parameter integer C_S4_ADDR = 'h3F000000,
	parameter integer C_S4_SIZE = 'h00100000,
	parameter integer C_S5_ADDR = 'h3F400000,
	parameter integer C_S5_SIZE = 'h00100000,
	parameter integer C_S6_ADDR = 'h3F800000,
	parameter integer C_S6_SIZE = 'h00100000,
	parameter integer C_S7_ADDR = 'h3FC00000,
	parameter integer C_S7_SIZE = 'h00100000,

	parameter integer C_BR_INITOR_NBR = 2, /// <= 8
	parameter integer C_BR_ADDR_WIDTH = 9,
	parameter integer C_MOTOR_NBR = 4, /// <= 8
	parameter integer C_ZPD_SEQ = 8'b00000011,
	parameter integer C_SPEED_DATA_WIDTH = 16,
	parameter integer C_STEP_NUMBER_WIDTH = 16,
	parameter integer C_MICROSTEP_WIDTH = 3,

	parameter integer C_PWM_NBR = 8,
	parameter integer C_PWM_CNT_WIDTH = 16,

	parameter integer C_TEST = 0
)
(
	input clk,
	input resetn,

	/// read/write interface
	input rd_en,
	input [C_REG_IDX_WIDTH-1:0]   rd_addr,
	output reg [C_DATA_WIDTH-1:0] rd_data,

	input wr_en,
	input [C_REG_IDX_WIDTH-1:0] wr_addr,
	input [C_DATA_WIDTH-1:0] wr_data,

	//// controller
	input o_clk,
	input o_resetn,

	output wire soft_resetn,
	input  wire fsync,
	output reg  o_fsync,

	output wire intr,

	output wire [C_IMG_WBITS-1:0] out_width,
	output wire [C_IMG_HBITS-1:0] out_height,

	output reg                    out_ce,
/// stream top
	output reg                         st_soft_resetn,

	output wire [C_BUF_ADDR_WIDTH-1:0] st_addr,

	output wire [C_IMG_WBITS-1:0]      st_width,
	output wire [C_IMG_HBITS-1:0]      st_height,

/// stream 0
	output wire                        s0_soft_resetn,

	output wire [C_STREAM_NBR -1:0]    s0_dst_bmp,
	output wire [C_IMG_WBITS-1:0]      s0_width,
	output wire [C_IMG_HBITS-1:0]      s0_height,

	output wire [C_BUF_ADDR_WIDTH-1:0] s0_buf0_addr,
	output wire [C_BUF_ADDR_WIDTH-1:0] s0_buf1_addr,
	output wire [C_BUF_ADDR_WIDTH-1:0] s0_buf2_addr,
	output wire [C_BUF_ADDR_WIDTH-1:0] s0_buf3_addr,

	output wire [C_IMG_WBITS-1:0]      s0_win_left,
	output wire [C_IMG_WBITS-1:0]      s0_win_width,
	output wire [C_IMG_HBITS-1:0]      s0_win_top,
	output wire [C_IMG_HBITS-1:0]      s0_win_height,

	output wire [C_IMG_WBITS-1:0]      s0_scale_src_width,
	output wire [C_IMG_HBITS-1:0]      s0_scale_src_height,
	output wire [C_IMG_WBITS-1:0]      s0_scale_dst_width,
	output wire [C_IMG_HBITS-1:0]      s0_scale_dst_height,

	output wire [C_IMG_WBITS-1:0]      s0_dst_left,
	output wire [C_IMG_WBITS-1:0]      s0_dst_width,
	output wire [C_IMG_HBITS-1:0]      s0_dst_top,
	output wire [C_IMG_HBITS-1:0]      s0_dst_height,

	input  wire                        s0_wr_done,
	output wire                        s0_rd_en,
	input  wire [C_BUF_IDX_WIDTH-1:0]  s0_rd_buf_idx,
	input  wire [C_TS_WIDTH-1:0]       s0_rd_buf_ts,
/// stream 1
	output wire                        s1_soft_resetn,

	output wire [C_STREAM_NBR -1:0]    s1_dst_bmp,
	output wire [C_IMG_WBITS-1:0]      s1_width,
	output wire [C_IMG_HBITS-1:0]      s1_height,

	output wire [C_BUF_ADDR_WIDTH-1:0] s1_buf0_addr,
	output wire [C_BUF_ADDR_WIDTH-1:0] s1_buf1_addr,
	output wire [C_BUF_ADDR_WIDTH-1:0] s1_buf2_addr,
	output wire [C_BUF_ADDR_WIDTH-1:0] s1_buf3_addr,

	output wire [C_IMG_WBITS-1:0]      s1_win_left,
	output wire [C_IMG_WBITS-1:0]      s1_win_width,
	output wire [C_IMG_HBITS-1:0]      s1_win_top,
	output wire [C_IMG_HBITS-1:0]      s1_win_height,

	output wire [C_IMG_WBITS-1:0]      s1_scale_src_width,
	output wire [C_IMG_HBITS-1:0]      s1_scale_src_height,
	output wire [C_IMG_WBITS-1:0]      s1_scale_dst_width,
	output wire [C_IMG_HBITS-1:0]      s1_scale_dst_height,

	output wire [C_IMG_WBITS-1:0]      s1_dst_left,
	output wire [C_IMG_WBITS-1:0]      s1_dst_width,
	output wire [C_IMG_HBITS-1:0]      s1_dst_top,
	output wire [C_IMG_HBITS-1:0]      s1_dst_height,

	input  wire                        s1_wr_done,
	output wire                        s1_rd_en,
	input  wire [C_BUF_IDX_WIDTH-1:0]  s1_rd_buf_idx,
	input  wire [C_TS_WIDTH-1:0]       s1_rd_buf_ts,
/// stream 2
	output wire                        s2_soft_resetn,

	output wire [C_STREAM_NBR -1:0]    s2_dst_bmp,
	output wire [C_IMG_WBITS-1:0]      s2_width,
	output wire [C_IMG_HBITS-1:0]      s2_height,

	output wire [C_BUF_ADDR_WIDTH-1:0] s2_buf0_addr,
	output wire [C_BUF_ADDR_WIDTH-1:0] s2_buf1_addr,
	output wire [C_BUF_ADDR_WIDTH-1:0] s2_buf2_addr,
	output wire [C_BUF_ADDR_WIDTH-1:0] s2_buf3_addr,

	output wire [C_IMG_WBITS-1:0]      s2_win_left,
	output wire [C_IMG_WBITS-1:0]      s2_win_width,
	output wire [C_IMG_HBITS-1:0]      s2_win_top,
	output wire [C_IMG_HBITS-1:0]      s2_win_height,

	output wire [C_IMG_WBITS-1:0]      s2_scale_src_width,
	output wire [C_IMG_HBITS-1:0]      s2_scale_src_height,
	output wire [C_IMG_WBITS-1:0]      s2_scale_dst_width,
	output wire [C_IMG_HBITS-1:0]      s2_scale_dst_height,

	output wire [C_IMG_WBITS-1:0]      s2_dst_left,
	output wire [C_IMG_WBITS-1:0]      s2_dst_width,
	output wire [C_IMG_HBITS-1:0]      s2_dst_top,
	output wire [C_IMG_HBITS-1:0]      s2_dst_height,

	input  wire                        s2_wr_done,
	output wire                        s2_rd_en,
	input  wire [C_BUF_IDX_WIDTH-1:0]  s2_rd_buf_idx,
	input  wire [C_TS_WIDTH-1:0]       s2_rd_buf_ts,
/// stream 3
	output wire                        s3_soft_resetn,

	output wire [C_STREAM_NBR -1:0]    s3_dst_bmp,
	output wire [C_IMG_WBITS-1:0]      s3_width,
	output wire [C_IMG_HBITS-1:0]      s3_height,

	output wire [C_BUF_ADDR_WIDTH-1:0] s3_buf0_addr,
	output wire [C_BUF_ADDR_WIDTH-1:0] s3_buf1_addr,
	output wire [C_BUF_ADDR_WIDTH-1:0] s3_buf2_addr,
	output wire [C_BUF_ADDR_WIDTH-1:0] s3_buf3_addr,

	output wire [C_IMG_WBITS-1:0]      s3_win_left,
	output wire [C_IMG_WBITS-1:0]      s3_win_width,
	output wire [C_IMG_HBITS-1:0]      s3_win_top,
	output wire [C_IMG_HBITS-1:0]      s3_win_height,

	output wire [C_IMG_WBITS-1:0]      s3_scale_src_width,
	output wire [C_IMG_HBITS-1:0]      s3_scale_src_height,
	output wire [C_IMG_WBITS-1:0]      s3_scale_dst_width,
	output wire [C_IMG_HBITS-1:0]      s3_scale_dst_height,

	output wire [C_IMG_WBITS-1:0]      s3_dst_left,
	output wire [C_IMG_WBITS-1:0]      s3_dst_width,
	output wire [C_IMG_HBITS-1:0]      s3_dst_top,
	output wire [C_IMG_HBITS-1:0]      s3_dst_height,

	input  wire                        s3_wr_done,
	output wire                        s3_rd_en,
	input  wire [C_BUF_IDX_WIDTH-1:0]  s3_rd_buf_idx,
	input  wire [C_TS_WIDTH-1:0]       s3_rd_buf_ts,
/// stream 4
	output wire                        s4_soft_resetn,

	output wire [C_STREAM_NBR -1:0]    s4_dst_bmp,
	output wire [C_IMG_WBITS-1:0]      s4_width,
	output wire [C_IMG_HBITS-1:0]      s4_height,

	output wire [C_BUF_ADDR_WIDTH-1:0] s4_buf0_addr,
	output wire [C_BUF_ADDR_WIDTH-1:0] s4_buf1_addr,
	output wire [C_BUF_ADDR_WIDTH-1:0] s4_buf2_addr,
	output wire [C_BUF_ADDR_WIDTH-1:0] s4_buf3_addr,

	output wire [C_IMG_WBITS-1:0]      s4_win_left,
	output wire [C_IMG_WBITS-1:0]      s4_win_width,
	output wire [C_IMG_HBITS-1:0]      s4_win_top,
	output wire [C_IMG_HBITS-1:0]      s4_win_height,

	output wire [C_IMG_WBITS-1:0]      s4_scale_src_width,
	output wire [C_IMG_HBITS-1:0]      s4_scale_src_height,
	output wire [C_IMG_WBITS-1:0]      s4_scale_dst_width,
	output wire [C_IMG_HBITS-1:0]      s4_scale_dst_height,

	output wire [C_IMG_WBITS-1:0]      s4_dst_left,
	output wire [C_IMG_WBITS-1:0]      s4_dst_width,
	output wire [C_IMG_HBITS-1:0]      s4_dst_top,
	output wire [C_IMG_HBITS-1:0]      s4_dst_height,

	input  wire                        s4_wr_done,
	output wire                        s4_rd_en,
	input  wire [C_BUF_IDX_WIDTH-1:0]  s4_rd_buf_idx,
	input  wire [C_TS_WIDTH-1:0]       s4_rd_buf_ts,
/// stream 5
	output wire                        s5_soft_resetn,

	output wire [C_STREAM_NBR -1:0]    s5_dst_bmp,
	output wire [C_IMG_WBITS-1:0]      s5_width,
	output wire [C_IMG_HBITS-1:0]      s5_height,

	output wire [C_BUF_ADDR_WIDTH-1:0] s5_buf0_addr,
	output wire [C_BUF_ADDR_WIDTH-1:0] s5_buf1_addr,
	output wire [C_BUF_ADDR_WIDTH-1:0] s5_buf2_addr,
	output wire [C_BUF_ADDR_WIDTH-1:0] s5_buf3_addr,

	output wire [C_IMG_WBITS-1:0]      s5_win_left,
	output wire [C_IMG_WBITS-1:0]      s5_win_width,
	output wire [C_IMG_HBITS-1:0]      s5_win_top,
	output wire [C_IMG_HBITS-1:0]      s5_win_height,

	output wire [C_IMG_WBITS-1:0]      s5_scale_src_width,
	output wire [C_IMG_HBITS-1:0]      s5_scale_src_height,
	output wire [C_IMG_WBITS-1:0]      s5_scale_dst_width,
	output wire [C_IMG_HBITS-1:0]      s5_scale_dst_height,

	output wire [C_IMG_WBITS-1:0]      s5_dst_left,
	output wire [C_IMG_WBITS-1:0]      s5_dst_width,
	output wire [C_IMG_HBITS-1:0]      s5_dst_top,
	output wire [C_IMG_HBITS-1:0]      s5_dst_height,

	input  wire                        s5_wr_done,
	output wire                        s5_rd_en,
	input  wire [C_BUF_IDX_WIDTH-1:0]  s5_rd_buf_idx,
	input  wire [C_TS_WIDTH-1:0]       s5_rd_buf_ts,
/// stream 6
	output wire                        s6_soft_resetn,

	output wire [C_STREAM_NBR -1:0]    s6_dst_bmp,
	output wire [C_IMG_WBITS-1:0]      s6_width,
	output wire [C_IMG_HBITS-1:0]      s6_height,

	output wire [C_BUF_ADDR_WIDTH-1:0] s6_buf0_addr,
	output wire [C_BUF_ADDR_WIDTH-1:0] s6_buf1_addr,
	output wire [C_BUF_ADDR_WIDTH-1:0] s6_buf2_addr,
	output wire [C_BUF_ADDR_WIDTH-1:0] s6_buf3_addr,

	output wire [C_IMG_WBITS-1:0]      s6_win_left,
	output wire [C_IMG_WBITS-1:0]      s6_win_width,
	output wire [C_IMG_HBITS-1:0]      s6_win_top,
	output wire [C_IMG_HBITS-1:0]      s6_win_height,

	output wire [C_IMG_WBITS-1:0]      s6_scale_src_width,
	output wire [C_IMG_HBITS-1:0]      s6_scale_src_height,
	output wire [C_IMG_WBITS-1:0]      s6_scale_dst_width,
	output wire [C_IMG_HBITS-1:0]      s6_scale_dst_height,

	output wire [C_IMG_WBITS-1:0]      s6_dst_left,
	output wire [C_IMG_WBITS-1:0]      s6_dst_width,
	output wire [C_IMG_HBITS-1:0]      s6_dst_top,
	output wire [C_IMG_HBITS-1:0]      s6_dst_height,

	input  wire                        s6_wr_done,
	output wire                        s6_rd_en,
	input  wire [C_BUF_IDX_WIDTH-1:0]  s6_rd_buf_idx,
	input  wire [C_TS_WIDTH-1:0]       s6_rd_buf_ts,
/// stream 7
	output wire                        s7_soft_resetn,

	output wire [C_STREAM_NBR -1:0]    s7_dst_bmp,
	output wire [C_IMG_WBITS-1:0]      s7_width,
	output wire [C_IMG_HBITS-1:0]      s7_height,

	output wire [C_BUF_ADDR_WIDTH-1:0] s7_buf0_addr,
	output wire [C_BUF_ADDR_WIDTH-1:0] s7_buf1_addr,
	output wire [C_BUF_ADDR_WIDTH-1:0] s7_buf2_addr,
	output wire [C_BUF_ADDR_WIDTH-1:0] s7_buf3_addr,

	output wire [C_IMG_WBITS-1:0]      s7_win_left,
	output wire [C_IMG_WBITS-1:0]      s7_win_width,
	output wire [C_IMG_HBITS-1:0]      s7_win_top,
	output wire [C_IMG_HBITS-1:0]      s7_win_height,

	output wire [C_IMG_WBITS-1:0]      s7_scale_src_width,
	output wire [C_IMG_HBITS-1:0]      s7_scale_src_height,
	output wire [C_IMG_WBITS-1:0]      s7_scale_dst_width,
	output wire [C_IMG_HBITS-1:0]      s7_scale_dst_height,

	output wire [C_IMG_WBITS-1:0]      s7_dst_left,
	output wire [C_IMG_WBITS-1:0]      s7_dst_width,
	output wire [C_IMG_HBITS-1:0]      s7_dst_top,
	output wire [C_IMG_HBITS-1:0]      s7_dst_height,

	input  wire                        s7_wr_done,
	output wire                        s7_rd_en,
	input  wire [C_BUF_IDX_WIDTH-1:0]  s7_rd_buf_idx,
	input  wire [C_TS_WIDTH-1:0]       s7_rd_buf_ts,

/// blockram initor 0
	output wire                          br0_init,
	output wire                          br0_wr_en,
	output wire [C_SPEED_DATA_WIDTH-1:0] br0_data,
	input  wire [C_BR_ADDR_WIDTH:0]      br0_size,
/// blockram initor 1
	output wire                          br1_init,
	output wire                          br1_wr_en,
	output wire [C_SPEED_DATA_WIDTH-1:0] br1_data,
	input  wire [C_BR_ADDR_WIDTH:0]      br1_size,
/// blockram initor 2
	output wire                          br2_init,
	output wire                          br2_wr_en,
	output wire [C_SPEED_DATA_WIDTH-1:0] br2_data,
	input  wire [C_BR_ADDR_WIDTH:0]      br2_size,
/// blockram initor 3
	output wire                          br3_init,
	output wire                          br3_wr_en,
	output wire [C_SPEED_DATA_WIDTH-1:0] br3_data,
	input  wire [C_BR_ADDR_WIDTH:0]      br3_size,
/// blockram initor 4
	output wire                          br4_init,
	output wire                          br4_wr_en,
	output wire [C_SPEED_DATA_WIDTH-1:0] br4_data,
	input  wire [C_BR_ADDR_WIDTH:0]      br4_size,
/// blockram initor 5
	output wire                          br5_init,
	output wire                          br5_wr_en,
	output wire [C_SPEED_DATA_WIDTH-1:0] br5_data,
	input  wire [C_BR_ADDR_WIDTH:0]      br5_size,
/// blockram initor 6
	output wire                          br6_init,
	output wire                          br6_wr_en,
	output wire [C_SPEED_DATA_WIDTH-1:0] br6_data,
	input  wire [C_BR_ADDR_WIDTH:0]      br6_size,
/// blockram initor 7
	output wire                          br7_init,
	output wire                          br7_wr_en,
	output wire [C_SPEED_DATA_WIDTH-1:0] br7_data,
	input  wire [C_BR_ADDR_WIDTH:0]      br7_size,
/// step motor 0
	output wire                           motor0_xen,
	output wire                           motor0_xrst,
	input  wire                           motor0_zpsign,
	input  wire                           motor0_tpsign,	/// terminal position detection
	input  wire                           motor0_state,
	input  wire [C_SPEED_DATA_WIDTH-1:0]  motor0_rt_speed,
	output wire [C_STEP_NUMBER_WIDTH-1:0] motor0_stroke,
	output wire                           motor0_start,
	output wire                           motor0_stop,
	output wire [C_MICROSTEP_WIDTH-1:0]   motor0_ms,
	output wire [C_SPEED_DATA_WIDTH-1:0]  motor0_speed,
	output wire [C_STEP_NUMBER_WIDTH-1:0] motor0_step,
	output wire                           motor0_dir,
/// step motor 1
	output wire                           motor1_xen,
	output wire                           motor1_xrst,
	input  wire                           motor1_zpsign,
	input  wire                           motor1_tpsign,	/// terminal position detection
	input  wire                           motor1_state,
	input  wire [C_SPEED_DATA_WIDTH-1:0]  motor1_rt_speed,
	output wire [C_STEP_NUMBER_WIDTH-1:0] motor1_stroke,
	output wire                           motor1_start,
	output wire                           motor1_stop,
	output wire [C_MICROSTEP_WIDTH-1:0]   motor1_ms,
	output wire [C_SPEED_DATA_WIDTH-1:0]  motor1_speed,
	output wire [C_STEP_NUMBER_WIDTH-1:0] motor1_step,
	output wire                           motor1_dir,
/// step motor 2
	output wire                           motor2_xen,
	output wire                           motor2_xrst,
	input  wire                           motor2_zpsign,
	input  wire                           motor2_tpsign,	/// terminal position detection
	input  wire                           motor2_state,
	input  wire [C_SPEED_DATA_WIDTH-1:0]  motor2_rt_speed,
	output wire [C_STEP_NUMBER_WIDTH-1:0] motor2_stroke,
	output wire                           motor2_start,
	output wire                           motor2_stop,
	output wire [C_MICROSTEP_WIDTH-1:0]   motor2_ms,
	output wire [C_SPEED_DATA_WIDTH-1:0]  motor2_speed,
	output wire [C_STEP_NUMBER_WIDTH-1:0] motor2_step,
	output wire                           motor2_dir,
/// step motor 3
	output wire                           motor3_xen,
	output wire                           motor3_xrst,
	input  wire                           motor3_zpsign,
	input  wire                           motor3_tpsign,	/// terminal position detection
	input  wire                           motor3_state,
	input  wire [C_SPEED_DATA_WIDTH-1:0]  motor3_rt_speed,
	output wire [C_STEP_NUMBER_WIDTH-1:0] motor3_stroke,
	output wire                           motor3_start,
	output wire                           motor3_stop,
	output wire [C_MICROSTEP_WIDTH-1:0]   motor3_ms,
	output wire [C_SPEED_DATA_WIDTH-1:0]  motor3_speed,
	output wire [C_STEP_NUMBER_WIDTH-1:0] motor3_step,
	output wire                           motor3_dir,
/// step motor 4
	output wire                           motor4_xen,
	output wire                           motor4_xrst,
	input  wire                           motor4_zpsign,
	input  wire                           motor4_tpsign,	/// terminal position detection
	input  wire                           motor4_state,
	input  wire [C_SPEED_DATA_WIDTH-1:0]  motor4_rt_speed,
	output wire [C_STEP_NUMBER_WIDTH-1:0] motor4_stroke,
	output wire                           motor4_start,
	output wire                           motor4_stop,
	output wire [C_MICROSTEP_WIDTH-1:0]   motor4_ms,
	output wire [C_SPEED_DATA_WIDTH-1:0]  motor4_speed,
	output wire [C_STEP_NUMBER_WIDTH-1:0] motor4_step,
	output wire                           motor4_dir,
/// step motor 5
	output wire                           motor5_xen,
	output wire                           motor5_xrst,
	input  wire                           motor5_zpsign,
	input  wire                           motor5_tpsign,	/// terminal position detection
	input  wire                           motor5_state,
	input  wire [C_SPEED_DATA_WIDTH-1:0]  motor5_rt_speed,
	output wire [C_STEP_NUMBER_WIDTH-1:0] motor5_stroke,
	output wire                           motor5_start,
	output wire                           motor5_stop,
	output wire [C_MICROSTEP_WIDTH-1:0]   motor5_ms,
	output wire [C_SPEED_DATA_WIDTH-1:0]  motor5_speed,
	output wire [C_STEP_NUMBER_WIDTH-1:0] motor5_step,
	output wire                           motor5_dir,
/// step motor 6
	output wire                           motor6_xen,
	output wire                           motor6_xrst,
	input  wire                           motor6_zpsign,
	input  wire                           motor6_tpsign,	/// terminal position detection
	input  wire                           motor6_state,
	input  wire [C_SPEED_DATA_WIDTH-1:0]  motor6_rt_speed,
	output wire [C_STEP_NUMBER_WIDTH-1:0] motor6_stroke,
	output wire                           motor6_start,
	output wire                           motor6_stop,
	output wire [C_MICROSTEP_WIDTH-1:0]   motor6_ms,
	output wire [C_SPEED_DATA_WIDTH-1:0]  motor6_speed,
	output wire [C_STEP_NUMBER_WIDTH-1:0] motor6_step,
	output wire                           motor6_dir,
/// step motor 7
	output wire                           motor7_xen,
	output wire                           motor7_xrst,
	input  wire                           motor7_zpsign,
	input  wire                           motor7_tpsign,	/// terminal position detection
	input  wire                           motor7_state,
	input  wire [C_SPEED_DATA_WIDTH-1:0]  motor7_rt_speed,
	output wire [C_STEP_NUMBER_WIDTH-1:0] motor7_stroke,
	output wire                           motor7_start,
	output wire                           motor7_stop,
	output wire [C_MICROSTEP_WIDTH-1:0]   motor7_ms,
	output wire [C_SPEED_DATA_WIDTH-1:0]  motor7_speed,
	output wire [C_STEP_NUMBER_WIDTH-1:0] motor7_step,
	output wire                           motor7_dir,

/// pwm 0
	input  wire                       pwm0_def,
	output wire                       pwm0_en,
	output wire [C_PWM_CNT_WIDTH-1:0] pwm0_numerator,
	output wire [C_PWM_CNT_WIDTH-1:0] pwm0_denominator,
/// pwm 1
	input  wire                       pwm1_def,
	output wire                       pwm1_en,
	output wire [C_PWM_CNT_WIDTH-1:0] pwm1_numerator,
	output wire [C_PWM_CNT_WIDTH-1:0] pwm1_denominator,
/// pwm 2
	input  wire                       pwm2_def,
	output wire                       pwm2_en,
	output wire [C_PWM_CNT_WIDTH-1:0] pwm2_numerator,
	output wire [C_PWM_CNT_WIDTH-1:0] pwm2_denominator,
/// pwm 3
	input  wire                       pwm3_def,
	output wire                       pwm3_en,
	output wire [C_PWM_CNT_WIDTH-1:0] pwm3_numerator,
	output wire [C_PWM_CNT_WIDTH-1:0] pwm3_denominator,
/// pwm 4
	input  wire                       pwm4_def,
	output wire                       pwm4_en,
	output wire [C_PWM_CNT_WIDTH-1:0] pwm4_numerator,
	output wire [C_PWM_CNT_WIDTH-1:0] pwm4_denominator,
/// pwm 5
	input  wire                       pwm5_def,
	output wire                       pwm5_en,
	output wire [C_PWM_CNT_WIDTH-1:0] pwm5_numerator,
	output wire [C_PWM_CNT_WIDTH-1:0] pwm5_denominator,
/// pwm 6
	input  wire                       pwm6_def,
	output wire                       pwm6_en,
	output wire [C_PWM_CNT_WIDTH-1:0] pwm6_numerator,
	output wire [C_PWM_CNT_WIDTH-1:0] pwm6_denominator,
/// pwm 7
	input  wire                       pwm7_def,
	output wire                       pwm7_en,
	output wire [C_PWM_CNT_WIDTH-1:0] pwm7_numerator,
	output wire [C_PWM_CNT_WIDTH-1:0] pwm7_denominator
);

	localparam C_BR_SIZE_WIDTH = C_BR_ADDR_WIDTH + 1;

	assign st_addr = C_ST_ADDR;

	wire [C_REG_IDX_WIDTH-1:0] rd_index;
	assign rd_index = rd_addr;
	wire [C_REG_IDX_WIDTH-1:0] wr_index;
	assign wr_index = wr_addr;

	//----------------------------------------------
	//-- Signals for user logic register space example
	//------------------------------------------------
	localparam  C_REG_NUM = 2**C_REG_IDX_WIDTH;
	wire [C_DATA_WIDTH-1:0]	slv_reg[C_REG_NUM-1 : 0];
	/// read logic
	always @ (posedge clk) begin
		if (rd_en)
			rd_data <= slv_reg[rd_index];
	end

	assign out_width = C_IMG_WDEF;
	assign out_height = C_IMG_HDEF;

	assign st_width = out_width;
	assign st_height = out_height;

	wire [C_REG_NUM-1:0] s_wr_en;
	generate
		genvar i;
		for (i = 0; i < C_REG_NUM; i = i+1) begin: signgle_s_wr_en
			assign s_wr_en[i] = (wr_en && wr_index == i);
		end
	endgenerate

/// sync display config when fsync
	reg fsync_d1;
	reg fsync_d2;
	always @ (posedge o_clk) begin
		if (o_resetn == 1'b0) begin
			fsync_d1 <= 1'b0;
			fsync_d2 <= 1'b0;
		end
		else begin
			fsync_d1 <= fsync;
			fsync_d2 <= fsync_d1;
		end
	end

	wire display_cfging;
	reg  update_display_cfg;
	reg  fsync_posedge;
	always @ (posedge o_clk) begin
		if (o_resetn == 1'b0) begin
			fsync_posedge <= 0;
			update_display_cfg <= 0;
		end
		else if (fsync_d1 && ~fsync_d2) begin
			fsync_posedge <= 1;
			update_display_cfg <= ~display_cfging;
		end
		else begin
			fsync_posedge <= 0;
			update_display_cfg <= 0;
		end
	end
	/// @NOTE: o_fsync is delay 1 clock comparing with fsync_posedge, i.e.
	///        moving config is appeared same time as o_fsync
	always @ (posedge o_clk) begin
		if (o_resetn == 1'b0)
			o_fsync <= 1'b0;
		else
			o_fsync <= fsync_posedge;
	end

/// write sync
	reg clk_d1;
	reg wr_en_d1;
	reg [C_DATA_WIDTH-1:0] wr_data_d1;
	reg [C_REG_IDX_WIDTH-1:0] wr_index_d1;
	wire wr_sync;
	assign wr_sync = (clk && ~clk_d1 && wr_en_d1);
	always @ (posedge o_clk) begin
		clk_d1      <= clk;
		wr_en_d1    <= wr_en;
		wr_data_d1  <= wr_data;
		wr_index_d1 <= wr_index;
	end

	wire wr_sync_reg[C_REG_NUM-1 : 0];
	generate
		for (i = 0; i < C_REG_NUM; i = i + 1) begin: single_wr_sync
			assign wr_sync_reg[i] = (wr_sync && (wr_index_d1 == i));
		end
	endgenerate

///////////////////////////////// start register definition ////////////////////
generate
	`DEFREG_DIRECT_OUT(3, 0, 1, display_cfging, 0, 0)

	localparam EN_ST0 = (C_STREAM_NBR > 0);
	localparam EN_ST1 = (C_STREAM_NBR > 1);
	localparam EN_ST2 = (C_STREAM_NBR > 2);
	localparam EN_ST3 = (C_STREAM_NBR > 3);
	localparam EN_ST4 = (C_STREAM_NBR > 4);
	localparam EN_ST5 = (C_STREAM_NBR > 5);
	localparam EN_ST6 = (C_STREAM_NBR > 6);
	localparam EN_ST7 = (C_STREAM_NBR > 7);

`define DEFINE_STREAM(_idx) \
	`DEFREG_INT_EN   (0, (_idx * 4), s``_idx``_wr_done) \
	`DEFREG_INT_STATE(1, (_idx * 4), s``_idx``_wr_done, 1) \
		`WR_SYNC_WIRE(1, (_idx * 4), 1, s``_idx``_rd_en, 0, 1) \
	`DEFREG_DIRECT_IN(2, (_idx * 4), C_BUF_IDX_WIDTH, s``_idx``_rd_buf_idx) \
 \
	`DEFREG_INTERNAL(4, (_idx * 4), 1, s``_idx``_op_en, 0, 0, 1) \
	`DEFREG_STREAM_INDIRECT( 5, 0,            1, s``_idx``_soft_resetn, s``_idx``_op_en, 0) \
	`DEFREG_STREAM_INDIRECT( 6, 0, C_STREAM_NBR, s``_idx``_dst_bmp,     s``_idx``_op_en, 0) \
	`DEFREG_STREAM_INDIRECT( 7, 0,  C_IMG_HBITS, s``_idx``_height,      s``_idx``_op_en, 0) \
	`DEFREG_STREAM_INDIRECT( 7,16,  C_IMG_WBITS, s``_idx``_width,       s``_idx``_op_en, 0) \
	`DEFREG_STREAM_INDIRECT( 8, 0,  C_IMG_HBITS, s``_idx``_win_top,     s``_idx``_op_en, 0) \
	`DEFREG_STREAM_INDIRECT( 8,16,  C_IMG_WBITS, s``_idx``_win_left,    s``_idx``_op_en, 0) \
	`DEFREG_STREAM_INDIRECT( 9, 0,  C_IMG_HBITS, s``_idx``_win_height,  s``_idx``_op_en, 0) \
	`DEFREG_STREAM_INDIRECT( 9,16,  C_IMG_WBITS, s``_idx``_win_width,   s``_idx``_op_en, 0) \
	`DEFREG_STREAM_INDIRECT(10, 0,  C_IMG_HBITS, s``_idx``_dst_top,     s``_idx``_op_en, 0) \
	`DEFREG_STREAM_INDIRECT(10,16,  C_IMG_WBITS, s``_idx``_dst_left,    s``_idx``_op_en, 0) \
	`DEFREG_STREAM_INDIRECT(11, 0,  C_IMG_HBITS, s``_idx``_dst_height,  s``_idx``_op_en, 0) \
	`DEFREG_STREAM_INDIRECT(11,16,  C_IMG_WBITS, s``_idx``_dst_width,   s``_idx``_op_en, 0) \
 \
	assign s``_idx``_buf0_addr = C_S``_idx``_ADDR; \
	assign s``_idx``_buf1_addr = C_S``_idx``_ADDR + C_S``_idx``_SIZE; \
	assign s``_idx``_buf2_addr = C_S``_idx``_ADDR + C_S``_idx``_SIZE * 2; \
	assign s``_idx``_buf3_addr = C_S``_idx``_ADDR + C_S``_idx``_SIZE * 3; \
 \
	assign s``_idx``_scale_src_width  = s``_idx``_win_width; \
	assign s``_idx``_scale_src_height = s``_idx``_win_height; \
	assign s``_idx``_scale_dst_width  = s``_idx``_dst_width; \
	assign s``_idx``_scale_dst_height = s``_idx``_dst_height; \

	`COND(EN_ST0, `DEFINE_STREAM(0))
	`COND(EN_ST1, `DEFINE_STREAM(1))
	`COND(EN_ST2, `DEFINE_STREAM(2))
	`COND(EN_ST3, `DEFINE_STREAM(3))
	`COND(EN_ST4, `DEFINE_STREAM(4))
	`COND(EN_ST5, `DEFINE_STREAM(5))
	`COND(EN_ST6, `DEFINE_STREAM(6))
	`COND(EN_ST7, `DEFINE_STREAM(7))

/// blockram initor
	localparam integer EN_BR0 = (C_BR_INITOR_NBR > 0);
	localparam integer EN_BR1 = (C_BR_INITOR_NBR > 1);
	localparam integer EN_BR2 = (C_BR_INITOR_NBR > 2);
	localparam integer EN_BR3 = (C_BR_INITOR_NBR > 3);
	localparam integer EN_BR4 = (C_BR_INITOR_NBR > 4);
	localparam integer EN_BR5 = (C_BR_INITOR_NBR > 5);
	localparam integer EN_BR6 = (C_BR_INITOR_NBR > 6);
	localparam integer EN_BR7 = (C_BR_INITOR_NBR > 7);
	reg br_wr_en;
	wire [C_SPEED_DATA_WIDTH-1:0] br_data;
	assign br0_wr_en = br_wr_en;
	assign br1_wr_en = br_wr_en;
	assign br2_wr_en = br_wr_en;
	assign br3_wr_en = br_wr_en;
	assign br4_wr_en = br_wr_en;
	assign br5_wr_en = br_wr_en;
	assign br6_wr_en = br_wr_en;
	assign br7_wr_en = br_wr_en;
	assign br0_data = br_data;
	assign br1_data = br_data;
	assign br2_data = br_data;
	assign br3_data = br_data;
	assign br4_data = br_data;
	assign br5_data = br_data;
	assign br6_data = br_data;
	assign br7_data = br_data;

	`COND(EN_BR0, `DEFREG_EXTERNAL(16, 0, 1, br0_init, 0))
	`COND(EN_BR1, `DEFREG_EXTERNAL(16, 1, 1, br1_init, 0))
	`COND(EN_BR2, `DEFREG_EXTERNAL(16, 2, 1, br2_init, 0))
	`COND(EN_BR3, `DEFREG_EXTERNAL(16, 3, 1, br3_init, 0))
	`COND(EN_BR4, `DEFREG_EXTERNAL(16, 4, 1, br4_init, 0))
	`COND(EN_BR5, `DEFREG_EXTERNAL(16, 5, 1, br5_init, 0))
	`COND(EN_BR6, `DEFREG_EXTERNAL(16, 6, 1, br6_init, 0))
	`COND(EN_BR7, `DEFREG_EXTERNAL(16, 7, 1, br7_init, 0))

	`WR_TRIG(17, br_wr_en, 0, 1)
	`WR_SYNC_WIRE(17, 0, C_SPEED_DATA_WIDTH, br_data, 0, 0)

	`COND(EN_BR0, `DEFREG_DIRECT_IN(18, 0, C_BR_SIZE_WIDTH, br0_size))
	`COND(EN_BR1, `DEFREG_DIRECT_IN(19, 0, C_BR_SIZE_WIDTH, br0_size))
	`COND(EN_BR2, `DEFREG_DIRECT_IN(20, 0, C_BR_SIZE_WIDTH, br0_size))
	`COND(EN_BR3, `DEFREG_DIRECT_IN(21, 0, C_BR_SIZE_WIDTH, br0_size))
	`COND(EN_BR4, `DEFREG_DIRECT_IN(22, 0, C_BR_SIZE_WIDTH, br0_size))
	`COND(EN_BR5, `DEFREG_DIRECT_IN(23, 0, C_BR_SIZE_WIDTH, br0_size))
	`COND(EN_BR6, `DEFREG_DIRECT_IN(24, 0, C_BR_SIZE_WIDTH, br0_size))
	`COND(EN_BR7, `DEFREG_DIRECT_IN(25, 0, C_BR_SIZE_WIDTH, br0_size))

///////////////////////////////////// step motor /////////////////////////
	localparam EN_MT0 = (C_MOTOR_NBR > 0);
	localparam EN_MT1 = (C_MOTOR_NBR > 1);
	localparam EN_MT2 = (C_MOTOR_NBR > 2);
	localparam EN_MT3 = (C_MOTOR_NBR > 3);
	localparam EN_MT4 = (C_MOTOR_NBR > 4);
	localparam EN_MT5 = (C_MOTOR_NBR > 5);
	localparam EN_MT6 = (C_MOTOR_NBR > 6);
	localparam EN_MT7 = (C_MOTOR_NBR > 7);
	localparam EN_ZP0 = ((C_ZPD_SEQ >> 0) & 1) & EN_MT0;
	localparam EN_ZP1 = ((C_ZPD_SEQ >> 1) & 1) & EN_MT1;
	localparam EN_ZP2 = ((C_ZPD_SEQ >> 2) & 1) & EN_MT2;
	localparam EN_ZP3 = ((C_ZPD_SEQ >> 3) & 1) & EN_MT3;
	localparam EN_ZP4 = ((C_ZPD_SEQ >> 4) & 1) & EN_MT4;
	localparam EN_ZP5 = ((C_ZPD_SEQ >> 5) & 1) & EN_MT5;
	localparam EN_ZP6 = ((C_ZPD_SEQ >> 6) & 1) & EN_MT6;
	localparam EN_ZP7 = ((C_ZPD_SEQ >> 7) & 1) & EN_MT7;

	/// MOTOR EN_RST
	`COND(EN_MT0, `DEFREG_DIRECT_OUT(32,  ( 0+0), 1, motor0_xen,  0, 0))
	`COND(EN_MT0, `DEFREG_DIRECT_OUT(32,  ( 0+1), 1, motor0_xrst, 0, 0))
	`COND(EN_MT1, `DEFREG_DIRECT_OUT(32,  ( 4+0), 1, motor1_xen,  0, 0))
	`COND(EN_MT1, `DEFREG_DIRECT_OUT(32,  ( 4+1), 1, motor1_xrst, 0, 0))
	`COND(EN_MT2, `DEFREG_DIRECT_OUT(32,  ( 8+0), 1, motor2_xen,  0, 0))
	`COND(EN_MT2, `DEFREG_DIRECT_OUT(32,  ( 8+1), 1, motor2_xrst, 0, 0))
	`COND(EN_MT3, `DEFREG_DIRECT_OUT(32,  (12+0), 1, motor3_xen,  0, 0))
	`COND(EN_MT3, `DEFREG_DIRECT_OUT(32,  (12+1), 1, motor3_xrst, 0, 0))
	`COND(EN_MT4, `DEFREG_DIRECT_OUT(32,  (16+0), 1, motor4_xen,  0, 0))
	`COND(EN_MT4, `DEFREG_DIRECT_OUT(32,  (16+1), 1, motor4_xrst, 0, 0))
	`COND(EN_MT5, `DEFREG_DIRECT_OUT(32,  (20+0), 1, motor5_xen,  0, 0))
	`COND(EN_MT5, `DEFREG_DIRECT_OUT(32,  (20+1), 1, motor5_xrst, 0, 0))
	`COND(EN_MT6, `DEFREG_DIRECT_OUT(32,  (24+0), 1, motor6_xen,  0, 0))
	`COND(EN_MT6, `DEFREG_DIRECT_OUT(32,  (24+1), 1, motor6_xrst, 0, 0))
	`COND(EN_MT7, `DEFREG_DIRECT_OUT(32,  (28+0), 1, motor7_xen,  0, 0))
	`COND(EN_MT7, `DEFREG_DIRECT_OUT(32,  (28+1), 1, motor7_xrst, 0, 0))

	/// MOTOR INT ENABLE 33
	/// MOTOR INT STATE  34
	/// MOTOR STATE  35
`define DEFREG_FOR_MOTOR_INT(_idx, _trigV, _name) \
	`DEFREG_DIRECT_IN(35,  _idx, 1, _name) \
	`DEFREG_INT_STATE(34, _idx, _name, _trigV) \
	`DEFREG_INT_EN(33, _idx, _name)

	`COND(EN_ZP0, `DEFREG_FOR_MOTOR_INT(( 0+0), 1, motor0_zpsign))
	`COND(EN_ZP0, `DEFREG_FOR_MOTOR_INT(( 0+1), 1, motor0_tpsign))
	`COND(EN_MT0, `DEFREG_FOR_MOTOR_INT(( 0+2), 0, motor0_state ))
	`COND(EN_ZP1, `DEFREG_FOR_MOTOR_INT(( 4+0), 1, motor1_zpsign))
	`COND(EN_ZP1, `DEFREG_FOR_MOTOR_INT(( 4+1), 1, motor1_tpsign))
	`COND(EN_MT1, `DEFREG_FOR_MOTOR_INT(( 4+2), 0, motor1_state ))
	`COND(EN_ZP2, `DEFREG_FOR_MOTOR_INT(( 8+0), 1, motor2_zpsign))
	`COND(EN_ZP2, `DEFREG_FOR_MOTOR_INT(( 8+1), 1, motor2_tpsign))
	`COND(EN_MT2, `DEFREG_FOR_MOTOR_INT(( 8+2), 0, motor2_state ))
	`COND(EN_ZP3, `DEFREG_FOR_MOTOR_INT((12+0), 1, motor3_zpsign))
	`COND(EN_ZP3, `DEFREG_FOR_MOTOR_INT((12+1), 1, motor3_tpsign))
	`COND(EN_MT3, `DEFREG_FOR_MOTOR_INT((12+2), 0, motor3_state ))
	`COND(EN_ZP4, `DEFREG_FOR_MOTOR_INT((16+0), 1, motor4_zpsign))
	`COND(EN_ZP4, `DEFREG_FOR_MOTOR_INT((16+1), 1, motor4_tpsign))
	`COND(EN_MT4, `DEFREG_FOR_MOTOR_INT((16+2), 0, motor4_state ))
	`COND(EN_ZP5, `DEFREG_FOR_MOTOR_INT((20+0), 1, motor5_zpsign))
	`COND(EN_ZP5, `DEFREG_FOR_MOTOR_INT((20+1), 1, motor5_tpsign))
	`COND(EN_MT5, `DEFREG_FOR_MOTOR_INT((20+2), 0, motor5_state ))
	`COND(EN_ZP6, `DEFREG_FOR_MOTOR_INT((24+0), 1, motor6_zpsign))
	`COND(EN_ZP6, `DEFREG_FOR_MOTOR_INT((24+1), 1, motor6_tpsign))
	`COND(EN_MT6, `DEFREG_FOR_MOTOR_INT((24+2), 0, motor6_state ))
	`COND(EN_ZP7, `DEFREG_FOR_MOTOR_INT((28+0), 1, motor7_zpsign))
	`COND(EN_ZP7, `DEFREG_FOR_MOTOR_INT((28+1), 1, motor7_tpsign))
	`COND(EN_MT7, `DEFREG_FOR_MOTOR_INT((28+2), 0, motor7_state ))

	/// MOTOR START_STOP
	`COND(EN_MT0, `DEFREG_DIRECT_OUT(36,  ( 0+0), 1, motor0_start, 0, 1))
	`COND(EN_MT0, `DEFREG_DIRECT_OUT(36,  ( 0+1), 1, motor0_stop,  0, 1))
	`COND(EN_MT1, `DEFREG_DIRECT_OUT(36,  ( 4+0), 1, motor1_start, 0, 1))
	`COND(EN_MT1, `DEFREG_DIRECT_OUT(36,  ( 4+1), 1, motor1_stop,  0, 1))
	`COND(EN_MT2, `DEFREG_DIRECT_OUT(36,  ( 8+0), 1, motor2_start, 0, 1))
	`COND(EN_MT2, `DEFREG_DIRECT_OUT(36,  ( 8+1), 1, motor2_stop,  0, 1))
	`COND(EN_MT3, `DEFREG_DIRECT_OUT(36,  (12+0), 1, motor3_start, 0, 1))
	`COND(EN_MT3, `DEFREG_DIRECT_OUT(36,  (12+1), 1, motor3_stop,  0, 1))
	`COND(EN_MT4, `DEFREG_DIRECT_OUT(36,  (16+0), 1, motor4_start, 0, 1))
	`COND(EN_MT4, `DEFREG_DIRECT_OUT(36,  (16+1), 1, motor4_stop,  0, 1))
	`COND(EN_MT5, `DEFREG_DIRECT_OUT(36,  (20+0), 1, motor5_start, 0, 1))
	`COND(EN_MT5, `DEFREG_DIRECT_OUT(36,  (20+1), 1, motor5_stop,  0, 1))
	`COND(EN_MT6, `DEFREG_DIRECT_OUT(36,  (24+0), 1, motor6_start, 0, 1))
	`COND(EN_MT6, `DEFREG_DIRECT_OUT(36,  (24+1), 1, motor6_stop,  0, 1))
	`COND(EN_MT7, `DEFREG_DIRECT_OUT(36,  (28+0), 1, motor7_start, 0, 1))
	`COND(EN_MT7, `DEFREG_DIRECT_OUT(36,  (28+1), 1, motor7_stop,  0, 1))

	/// MOTOR MICROSTEP
	`COND(EN_MT0, `DEFREG_DIRECT_OUT(37, ( 0+0), C_MICROSTEP_WIDTH, motor0_ms, 0, 0))
	`COND(EN_MT1, `DEFREG_DIRECT_OUT(37, ( 4+0), C_MICROSTEP_WIDTH, motor1_ms, 0, 0))
	`COND(EN_MT2, `DEFREG_DIRECT_OUT(37, ( 8+0), C_MICROSTEP_WIDTH, motor2_ms, 0, 0))
	`COND(EN_MT3, `DEFREG_DIRECT_OUT(37, (12+0), C_MICROSTEP_WIDTH, motor3_ms, 0, 0))
	`COND(EN_MT4, `DEFREG_DIRECT_OUT(37, (16+0), C_MICROSTEP_WIDTH, motor4_ms, 0, 0))
	`COND(EN_MT5, `DEFREG_DIRECT_OUT(37, (20+0), C_MICROSTEP_WIDTH, motor5_ms, 0, 0))
	`COND(EN_MT6, `DEFREG_DIRECT_OUT(37, (24+0), C_MICROSTEP_WIDTH, motor6_ms, 0, 0))
	`COND(EN_MT7, `DEFREG_DIRECT_OUT(37, (28+0), C_MICROSTEP_WIDTH, motor7_ms, 0, 0))

	/// MOTOR DIR
	`COND(EN_MT0, `DEFREG_DIRECT_OUT(38, ( 0+0), 1, motor0_dir, 0, 0))
	`COND(EN_MT1, `DEFREG_DIRECT_OUT(38, ( 4+0), 1, motor1_dir, 0, 0))
	`COND(EN_MT2, `DEFREG_DIRECT_OUT(38, ( 8+0), 1, motor2_dir, 0, 0))
	`COND(EN_MT3, `DEFREG_DIRECT_OUT(38, (12+0), 1, motor3_dir, 0, 0))
	`COND(EN_MT4, `DEFREG_DIRECT_OUT(38, (16+0), 1, motor4_dir, 0, 0))
	`COND(EN_MT5, `DEFREG_DIRECT_OUT(38, (20+0), 1, motor5_dir, 0, 0))
	`COND(EN_MT6, `DEFREG_DIRECT_OUT(38, (24+0), 1, motor6_dir, 0, 0))
	`COND(EN_MT7, `DEFREG_DIRECT_OUT(38, (28+0), 1, motor7_dir, 0, 0))

	/// MOTOR STROKE
	`COND(EN_ZP0, `DEFREG_DIRECT_OUT(39, 0, C_STEP_NUMBER_WIDTH, motor0_stroke, 0, 0))
	`COND(EN_ZP1, `DEFREG_DIRECT_OUT(40, 0, C_STEP_NUMBER_WIDTH, motor1_stroke, 0, 0))
	`COND(EN_ZP2, `DEFREG_DIRECT_OUT(41, 0, C_STEP_NUMBER_WIDTH, motor2_stroke, 0, 0))
	`COND(EN_ZP3, `DEFREG_DIRECT_OUT(42, 0, C_STEP_NUMBER_WIDTH, motor3_stroke, 0, 0))
	`COND(EN_ZP4, `DEFREG_DIRECT_OUT(43, 0, C_STEP_NUMBER_WIDTH, motor4_stroke, 0, 0))
	`COND(EN_ZP5, `DEFREG_DIRECT_OUT(44, 0, C_STEP_NUMBER_WIDTH, motor5_stroke, 0, 0))
	`COND(EN_ZP6, `DEFREG_DIRECT_OUT(45, 0, C_STEP_NUMBER_WIDTH, motor6_stroke, 0, 0))
	`COND(EN_ZP7, `DEFREG_DIRECT_OUT(46, 0, C_STEP_NUMBER_WIDTH, motor7_stroke, 0, 0))

	/// MOTOR STEP
	`COND(EN_MT0, `DEFREG_DIRECT_OUT(47, 0, C_STEP_NUMBER_WIDTH, motor0_step, 0, 0))
	`COND(EN_MT1, `DEFREG_DIRECT_OUT(48, 0, C_STEP_NUMBER_WIDTH, motor1_step, 0, 0))
	`COND(EN_MT2, `DEFREG_DIRECT_OUT(49, 0, C_STEP_NUMBER_WIDTH, motor2_step, 0, 0))
	`COND(EN_MT3, `DEFREG_DIRECT_OUT(50, 0, C_STEP_NUMBER_WIDTH, motor3_step, 0, 0))
	`COND(EN_MT4, `DEFREG_DIRECT_OUT(51, 0, C_STEP_NUMBER_WIDTH, motor4_step, 0, 0))
	`COND(EN_MT5, `DEFREG_DIRECT_OUT(52, 0, C_STEP_NUMBER_WIDTH, motor5_step, 0, 0))
	`COND(EN_MT6, `DEFREG_DIRECT_OUT(53, 0, C_STEP_NUMBER_WIDTH, motor6_step, 0, 0))
	`COND(EN_MT7, `DEFREG_DIRECT_OUT(54, 0, C_STEP_NUMBER_WIDTH, motor7_step, 0, 0))

	/// MOTOR SPEED
	`COND(EN_MT0, `DEFREG_DIRECT_OUT(55, 0, C_SPEED_DATA_WIDTH, motor0_speed, 0, 0))
	`COND(EN_MT1, `DEFREG_DIRECT_OUT(56, 0, C_SPEED_DATA_WIDTH, motor1_speed, 0, 0))
	`COND(EN_MT2, `DEFREG_DIRECT_OUT(57, 0, C_SPEED_DATA_WIDTH, motor2_speed, 0, 0))
	`COND(EN_MT3, `DEFREG_DIRECT_OUT(58, 0, C_SPEED_DATA_WIDTH, motor3_speed, 0, 0))
	`COND(EN_MT4, `DEFREG_DIRECT_OUT(59, 0, C_SPEED_DATA_WIDTH, motor4_speed, 0, 0))
	`COND(EN_MT5, `DEFREG_DIRECT_OUT(60, 0, C_SPEED_DATA_WIDTH, motor5_speed, 0, 0))
	`COND(EN_MT6, `DEFREG_DIRECT_OUT(61, 0, C_SPEED_DATA_WIDTH, motor6_speed, 0, 0))
	`COND(EN_MT7, `DEFREG_DIRECT_OUT(62, 0, C_SPEED_DATA_WIDTH, motor7_speed, 0, 0))

/////////////////////////////////////////// PWM //////////////////////////
	localparam EN_PWM0 = (C_PWM_NBR > 0);
	localparam EN_PWM1 = (C_PWM_NBR > 1);
	localparam EN_PWM2 = (C_PWM_NBR > 2);
	localparam EN_PWM3 = (C_PWM_NBR > 3);
	localparam EN_PWM4 = (C_PWM_NBR > 4);
	localparam EN_PWM5 = (C_PWM_NBR > 5);
	localparam EN_PWM6 = (C_PWM_NBR > 6);
	localparam EN_PWM7 = (C_PWM_NBR > 7);
	`COND(EN_PWM0, `DEFREG_DIRECT_IN(64, 0, 1, pwm0_def))
	`COND(EN_PWM1, `DEFREG_DIRECT_IN(64, 1, 1, pwm1_def))
	`COND(EN_PWM2, `DEFREG_DIRECT_IN(64, 2, 1, pwm2_def))
	`COND(EN_PWM3, `DEFREG_DIRECT_IN(64, 3, 1, pwm3_def))
	`COND(EN_PWM4, `DEFREG_DIRECT_IN(64, 4, 1, pwm4_def))
	`COND(EN_PWM5, `DEFREG_DIRECT_IN(64, 5, 1, pwm5_def))
	`COND(EN_PWM6, `DEFREG_DIRECT_IN(64, 6, 1, pwm6_def))
	`COND(EN_PWM7, `DEFREG_DIRECT_IN(64, 7, 1, pwm7_def))
	`COND(EN_PWM0, `DEFREG_DIRECT_OUT(65, 0, 1, pwm0_en, 0, 0))
	`COND(EN_PWM1, `DEFREG_DIRECT_OUT(65, 1, 1, pwm1_en, 0, 0))
	`COND(EN_PWM2, `DEFREG_DIRECT_OUT(65, 2, 1, pwm2_en, 0, 0))
	`COND(EN_PWM3, `DEFREG_DIRECT_OUT(65, 3, 1, pwm3_en, 0, 0))
	`COND(EN_PWM4, `DEFREG_DIRECT_OUT(65, 4, 1, pwm4_en, 0, 0))
	`COND(EN_PWM5, `DEFREG_DIRECT_OUT(65, 5, 1, pwm5_en, 0, 0))
	`COND(EN_PWM6, `DEFREG_DIRECT_OUT(65, 6, 1, pwm6_en, 0, 0))
	`COND(EN_PWM7, `DEFREG_DIRECT_OUT(65, 7, 1, pwm7_en, 0, 0))

	`COND(EN_PWM0, `DEFREG_DIRECT_OUT(66,  0, C_PWM_CNT_WIDTH, pwm0_denominator, 0, 0))
	`COND(EN_PWM0, `DEFREG_DIRECT_OUT(67,  0, C_PWM_CNT_WIDTH, pwm0_numerator,   0, 0))

	`COND(EN_PWM1, `DEFREG_DIRECT_OUT(68,  0, C_PWM_CNT_WIDTH, pwm1_denominator, 0, 0))
	`COND(EN_PWM1, `DEFREG_DIRECT_OUT(69,  0, C_PWM_CNT_WIDTH, pwm1_numerator,   0, 0))

	`COND(EN_PWM2, `DEFREG_DIRECT_OUT(70,  0, C_PWM_CNT_WIDTH, pwm2_denominator, 0, 0))
	`COND(EN_PWM2, `DEFREG_DIRECT_OUT(71,  0, C_PWM_CNT_WIDTH, pwm2_numerator,   0, 0))

	`COND(EN_PWM3, `DEFREG_DIRECT_OUT(72,  0, C_PWM_CNT_WIDTH, pwm3_denominator, 0, 0))
	`COND(EN_PWM3, `DEFREG_DIRECT_OUT(73,  0, C_PWM_CNT_WIDTH, pwm3_numerator,   0, 0))

	`COND(EN_PWM4, `DEFREG_DIRECT_OUT(74,  0, C_PWM_CNT_WIDTH, pwm4_denominator, 0, 0))
	`COND(EN_PWM4, `DEFREG_DIRECT_OUT(75,  0, C_PWM_CNT_WIDTH, pwm4_numerator,   0, 0))

	`COND(EN_PWM5, `DEFREG_DIRECT_OUT(76,  0, C_PWM_CNT_WIDTH, pwm5_denominator, 0, 0))
	`COND(EN_PWM5, `DEFREG_DIRECT_OUT(77,  0, C_PWM_CNT_WIDTH, pwm5_numerator,   0, 0))

	`COND(EN_PWM6, `DEFREG_DIRECT_OUT(78,  0, C_PWM_CNT_WIDTH, pwm6_denominator, 0, 0))
	`COND(EN_PWM6, `DEFREG_DIRECT_OUT(79,  0, C_PWM_CNT_WIDTH, pwm6_numerator,   0, 0))

	`COND(EN_PWM7, `DEFREG_DIRECT_OUT(80,  0, C_PWM_CNT_WIDTH, pwm7_denominator, 0, 0))
	`COND(EN_PWM7, `DEFREG_DIRECT_OUT(81,  0, C_PWM_CNT_WIDTH, pwm7_numerator,   0, 0))

/// VERSION
	`DEFREG_EXTERNAL(254, 0, 1, soft_resetn, 0)
	`DEFREG_FIXED(255, 0, 32, core_version, C_CORE_VERSION)

	assign s0_scale_src_width  = s0_win_width;
	assign s0_scale_src_height = s0_win_height;
	assign s0_scale_dst_width  = s0_dst_width;
	assign s0_scale_dst_height = s0_dst_height;

	assign s1_scale_src_width  = s1_win_width;
	assign s1_scale_src_height = s1_win_height;
	assign s1_scale_dst_width  = s1_dst_width;
	assign s1_scale_dst_height = s1_dst_height;

	always @ (posedge o_clk) begin
		st_soft_resetn <= 1'b1;
	end

	always @ (posedge o_clk) begin
		if (o_resetn == 1'b0)
			out_ce <= 0;
		else if (o_fsync)
			out_ce <= 1;
	end

	wire stream_intr;
	assign stream_intr = ((slv_reg[2] & slv_reg[3]) != 0);
	wire motor_intr;
	assign motor_intr = ((slv_reg[33] & slv_reg[34]) != 0);
	assign intr = (stream_intr | motor_intr);
endgenerate
endmodule
