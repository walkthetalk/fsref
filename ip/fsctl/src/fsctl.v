`timescale 1 ns / 1 ps

`include "aux_macro.v"

module fsctl #
(
	parameter integer C_CORE_VERSION = 32'hFF00FF00,

	parameter integer C_DATA_WIDTH	= 32,
	parameter integer C_REG_IDX_WIDTH	= 8,

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
	parameter integer C_CMOS1BUF3_ADDR = 'h3F700000,

	parameter integer C_BR_INITOR_NBR = 2, /// <= 8
	parameter integer C_MOTOR_NBR = 4, /// <= 8
	parameter integer C_ZPD_SEQ = 8'b00000011,
	parameter integer C_SPEED_DATA_WIDTH = 16,
	parameter integer C_STEP_NUMBER_WIDTH = 16,
	parameter integer C_MICROSTEP_WIDTH = 3,

	parameter integer C_PWM_NBR = 8,
	parameter integer C_PWM_CNT_WIDTH = 16
)
(
	input clk,
	input resetn,

	/// read/write interface
	input rd_en,
	input [C_REG_IDX_WIDTH-1:0] rd_addr,
	output reg [C_DATA_WIDTH-1:0] rd_data,

	input wr_en,
	input [C_REG_IDX_WIDTH-1:0] wr_addr,
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
	output reg s0_soft_resetn,
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
	output reg s1_soft_resetn,
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
	output reg s2_soft_resetn,
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
	output reg [C_IMG_HBITS-1:0] s2_dst_height,

/// blockram initor 0
	output reg                           br0_init,
	output wire                          br0_wr_en,
	output wire [C_SPEED_DATA_WIDTH-1:0] br0_data,
/// blockram initor 1
	output reg                           br1_init,
	output wire                          br1_wr_en,
	output wire [C_SPEED_DATA_WIDTH-1:0] br1_data,
/// blockram initor 2
	output reg                           br2_init,
	output wire                          br2_wr_en,
	output wire [C_SPEED_DATA_WIDTH-1:0] br2_data,
/// blockram initor 3
	output reg                           br3_init,
	output wire                          br3_wr_en,
	output wire [C_SPEED_DATA_WIDTH-1:0] br3_data,
/// blockram initor 4
	output reg                           br4_init,
	output wire                          br4_wr_en,
	output wire [C_SPEED_DATA_WIDTH-1:0] br4_data,
/// blockram initor 5
	output reg                           br5_init,
	output wire                          br5_wr_en,
	output wire [C_SPEED_DATA_WIDTH-1:0] br5_data,
/// blockram initor 6
	output reg                           br6_init,
	output wire                          br6_wr_en,
	output wire [C_SPEED_DATA_WIDTH-1:0] br6_data,
/// blockram initor 7
	output reg                           br7_init,
	output wire                          br7_wr_en,
	output wire [C_SPEED_DATA_WIDTH-1:0] br7_data,
/// step motor 0
	output wire                           motor0_xen,
	output wire                           motor0_xrst,
	input  wire                           motor0_zpsign,
	input  wire                           motor0_tpsign,	/// terminal position detection
	input  wire                           motor0_state,
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
	assign dispbuf0_addr = C_DISPBUF0_ADDR;
	assign cmos0buf0_addr = C_CMOS0BUF0_ADDR;
	assign cmos0buf1_addr = C_CMOS0BUF1_ADDR;
	assign cmos0buf2_addr = C_CMOS0BUF2_ADDR;
	assign cmos0buf3_addr = C_CMOS0BUF3_ADDR;
	assign cmos1buf0_addr = C_CMOS1BUF0_ADDR;
	assign cmos1buf1_addr = C_CMOS1BUF1_ADDR;
	assign cmos1buf2_addr = C_CMOS1BUF2_ADDR;
	assign cmos1buf3_addr = C_CMOS1BUF3_ADDR;

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

	wire [C_REG_NUM-1:0] s_wr_en;
	generate
		genvar i;
		for (i = 0; i < C_REG_NUM; i = i+1) begin: signgle_s_wr_en
			assign s_wr_en[i] = (wr_en && wr_index == i);
		end
	endgenerate

/// fsync
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
	wire fsync_posedge;
	assign fsync_posedge = fsync_d1 && ~fsync_d2;
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

/// start register definition
	`DEFREG_EXTERNAL(0, 0, 1, soft_resetn, 0)
	`DEFREG_INTERNAL(0, 1, 1, display_cfging, 0)

	wire update_display_cfg;
	assign update_display_cfg = fsync_posedge && ~display_cfging;

	`DEFREG_DISP(1, 0, 1, order_1over2, 0)
	`DEFREG_INTERNAL(1, 1, 1, s0_running, 1)
	`DEFREG_INTERNAL(1, 2, 1, s1_running, 0)
	`DEFREG_INTERNAL(1, 3, 1, s2_running, 0)

	`DEFREG_IMGSIZE( 2, s1_width,              0,  s1_height,              0)
	`DEFREG_IMGSIZE( 3, s1_win_left,           0,  s1_win_top,             0)
	`DEFREG_IMGSIZE( 4, s1_win_width,          0,  s1_win_height,          0)
	`DEFREG_IMGSIZE( 5, s1_dst_left,           0,  s1_dst_top,             0)
	`DEFREG_IMGSIZE( 6, s1_dst_width,          0,  s1_dst_height,          0)

	`DEFREG_IMGSIZE( 7, s2_width,              0,  s2_height,              0)
	`DEFREG_IMGSIZE( 8, s2_win_left,           0,  s2_win_top,             0)
	`DEFREG_IMGSIZE( 9, s2_win_width,          0,  s2_win_height,          0)
	`DEFREG_IMGSIZE(10, s2_dst_left,           0,  s2_dst_top,             0)
	`DEFREG_IMGSIZE(11, s2_dst_width,          0,  s2_dst_height,          0)

/// blockram initor
	reg br_wr_en;
	reg [C_SPEED_DATA_WIDTH-1:0] br_data;
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

	`COND((C_BR_INITOR_NBR >= 1), `DEFREG_EXTERNAL(30, 0, 1, br0_init, 0))
	`COND((C_BR_INITOR_NBR >= 2), `DEFREG_EXTERNAL(30, 1, 1, br1_init, 0))
	`COND((C_BR_INITOR_NBR >= 3), `DEFREG_EXTERNAL(30, 2, 1, br2_init, 0))
	`COND((C_BR_INITOR_NBR >= 4), `DEFREG_EXTERNAL(30, 3, 1, br3_init, 0))
	`COND((C_BR_INITOR_NBR >= 5), `DEFREG_EXTERNAL(30, 4, 1, br4_init, 0))
	`COND((C_BR_INITOR_NBR >= 6), `DEFREG_EXTERNAL(30, 5, 1, br5_init, 0))
	`COND((C_BR_INITOR_NBR >= 7), `DEFREG_EXTERNAL(30, 6, 1, br6_init, 0))
	`COND((C_BR_INITOR_NBR >= 8), `DEFREG_EXTERNAL(30, 7, 1, br7_init, 0))

	`WR_TRIG(31, br_wr_en, 0, 1)
	`WR_SYNC_REG(31, 0, C_SPEED_DATA_WIDTH, br_data, 0, 0)

/// step motor
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
	`COND(EN_MT0, `DEFREG_DIRECT_OUT(32,  ( 0+0), 1, motor0_xen, 0, 0))
	`COND(EN_MT0, `DEFREG_DIRECT_OUT(32,  ( 0+1), 1, motor0_xrst, 0, 0))
	`COND(EN_MT1, `DEFREG_DIRECT_OUT(32,  ( 4+0), 1, motor1_xen, 0, 0))
	`COND(EN_MT1, `DEFREG_DIRECT_OUT(32,  ( 4+1), 1, motor1_xrst, 0, 0))
	`COND(EN_MT2, `DEFREG_DIRECT_OUT(32,  ( 8+0), 1, motor2_xen, 0, 0))
	`COND(EN_MT2, `DEFREG_DIRECT_OUT(32,  ( 8+1), 1, motor2_xrst, 0, 0))
	`COND(EN_MT3, `DEFREG_DIRECT_OUT(32,  (12+0), 1, motor3_xen, 0, 0))
	`COND(EN_MT3, `DEFREG_DIRECT_OUT(32,  (12+1), 1, motor3_xrst, 0, 0))
	`COND(EN_MT4, `DEFREG_DIRECT_OUT(32,  (16+0), 1, motor4_xen, 0, 0))
	`COND(EN_MT4, `DEFREG_DIRECT_OUT(32,  (16+1), 1, motor4_xrst, 0, 0))
	`COND(EN_MT5, `DEFREG_DIRECT_OUT(32,  (20+0), 1, motor5_xen, 0, 0))
	`COND(EN_MT5, `DEFREG_DIRECT_OUT(32,  (20+1), 1, motor5_xrst, 0, 0))
	`COND(EN_MT6, `DEFREG_DIRECT_OUT(32,  (24+0), 1, motor6_xen, 0, 0))
	`COND(EN_MT6, `DEFREG_DIRECT_OUT(32,  (24+1), 1, motor6_xrst, 0, 0))
	`COND(EN_MT7, `DEFREG_DIRECT_OUT(32,  (28+0), 1, motor7_xen, 0, 0))
	`COND(EN_MT7, `DEFREG_DIRECT_OUT(32,  (28+1), 1, motor7_xrst, 0, 0))

	/// MOTOR INT ENABLE 33
	/// MOTOR INT STATE  34
	/// MOTOR STATE  35
`define DEFREG_FOR_MOTOR_INT(_idx, _name) \
	`DEFREG_DIRECT_IN(35,  _idx, 1, _name) \
	`DEFREG_DIRECT_IN_D1(1, _name) \
	`DEFREG_INT_STATE(34, _idx, _name) \
	`DEFREG_INT_EN(33, _idx, _name)

	`COND(EN_ZP0, `DEFREG_FOR_MOTOR_INT(( 0+0), motor0_zpsign))
	`COND(EN_ZP0, `DEFREG_FOR_MOTOR_INT(( 0+1), motor0_tpsign))
	`COND(EN_MT0, `DEFREG_FOR_MOTOR_INT(( 0+2), motor0_state))
	`COND(EN_ZP1, `DEFREG_FOR_MOTOR_INT(( 4+0), motor1_zpsign))
	`COND(EN_ZP1, `DEFREG_FOR_MOTOR_INT(( 4+1), motor1_tpsign))
	`COND(EN_MT1, `DEFREG_FOR_MOTOR_INT(( 4+2), motor1_state))
	`COND(EN_ZP2, `DEFREG_FOR_MOTOR_INT(( 8+0), motor2_zpsign))
	`COND(EN_ZP2, `DEFREG_FOR_MOTOR_INT(( 8+1), motor2_tpsign))
	`COND(EN_MT2, `DEFREG_FOR_MOTOR_INT(( 8+2), motor2_state))
	`COND(EN_ZP3, `DEFREG_FOR_MOTOR_INT((12+0), motor3_zpsign))
	`COND(EN_ZP3, `DEFREG_FOR_MOTOR_INT((12+1), motor3_tpsign))
	`COND(EN_MT3, `DEFREG_FOR_MOTOR_INT((12+2), motor3_state))
	`COND(EN_ZP4, `DEFREG_FOR_MOTOR_INT((16+0), motor4_zpsign))
	`COND(EN_ZP4, `DEFREG_FOR_MOTOR_INT((16+1), motor4_tpsign))
	`COND(EN_MT4, `DEFREG_FOR_MOTOR_INT((16+2), motor4_state))
	`COND(EN_ZP5, `DEFREG_FOR_MOTOR_INT((20+0), motor5_zpsign))
	`COND(EN_ZP5, `DEFREG_FOR_MOTOR_INT((20+1), motor5_tpsign))
	`COND(EN_MT5, `DEFREG_FOR_MOTOR_INT((20+2), motor5_state))
	`COND(EN_ZP6, `DEFREG_FOR_MOTOR_INT((24+0), motor6_zpsign))
	`COND(EN_ZP6, `DEFREG_FOR_MOTOR_INT((24+1), motor6_tpsign))
	`COND(EN_MT6, `DEFREG_FOR_MOTOR_INT((24+2), motor6_state))
	`COND(EN_ZP7, `DEFREG_FOR_MOTOR_INT((28+0), motor7_zpsign))
	`COND(EN_ZP7, `DEFREG_FOR_MOTOR_INT((28+1), motor7_tpsign))
	`COND(EN_MT7, `DEFREG_FOR_MOTOR_INT((28+2), motor7_state))

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

/// PWM
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
	`DEFREG_FIXED(C_REG_NUM-1, 0, 32, core_version, C_CORE_VERSION)

	assign s1_scale_src_width  = s1_win_width;
	assign s1_scale_src_height = s1_win_height;
	assign s1_scale_dst_width  = s1_dst_width;
	assign s1_scale_dst_height = s1_dst_height;

	assign s2_scale_src_width  = s2_win_width;
	assign s2_scale_src_height = s2_win_height;
	assign s2_scale_dst_width  = s2_dst_width;
	assign s2_scale_dst_height = s2_dst_height;

	always @ (posedge o_clk) begin
		if (o_resetn == 1'b0)
			s0_soft_resetn <= 0;
		else if (update_display_cfg)
			s0_soft_resetn <= (s0_running);
	end
	always @ (posedge o_clk) begin
		if (o_resetn == 1'b0)
			s1_soft_resetn <= 0;
		else if (update_display_cfg)
			s1_soft_resetn <= (s1_running);
	end
	always @ (posedge o_clk) begin
		if (o_resetn == 1'b0)
			s2_soft_resetn <= 0;
		else if (update_display_cfg)
			s2_soft_resetn <= (s2_running);
	end

endmodule
