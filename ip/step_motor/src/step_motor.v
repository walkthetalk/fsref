`timescale 1ns / 1ps

module step_motor #(
	parameter integer C_OPT_BR_TIME = 0,
	parameter integer C_STEP_NUMBER_WIDTH = 16,
	parameter integer C_SPEED_DATA_WIDTH = 16,
	parameter integer C_SPEED_ADDRESS_WIDTH = 9,
	parameter integer C_MICROSTEP_WIDTH = 3,

	parameter integer C_CLK_DIV_NBR = 32,	/// >= 7 (block_ram read delay)
	parameter integer C_MOTOR_NBR = 4,
	parameter integer C_ZPD_SEQ = 32'hFFFFFFFF,
	parameter integer C_MICROSTEP_PASSTHOUGH_SEQ = 32'h0
)(
	input	clk,
	input	resetn,

	input  wire                           br_init,
	input  wire                           br_wr_en,
	input  wire [C_SPEED_DATA_WIDTH-1:0]  br_data,
	output wire [C_SPEED_ADDRESS_WIDTH:0] br_size,

	input  wire                           m0_zpd,	/// zero position detection
	output wire                           m0_drive,
	output wire                           m0_dir,
	output wire [C_MICROSTEP_WIDTH-1:0]   m0_ms,
	output wire                           m0_xen,
	output wire                           m0_xrst,

	input  wire                                  s0_xen,
	input  wire                                  s0_xrst,
	input  wire signed [C_STEP_NUMBER_WIDTH-1:0] s0_min_pos,
	input  wire signed [C_STEP_NUMBER_WIDTH-1:0] s0_max_pos,
	input  wire [C_MICROSTEP_WIDTH-1:0]          s0_ms,
	output wire                                  s0_ntsign,
	output wire                                  s0_zpsign,
	output wire                                  s0_ptsign,
	output wire                                  s0_state,
	output wire [C_SPEED_DATA_WIDTH-1:0]         s0_rt_speed,
	output wire                                  s0_rt_dir,
	output wire signed [C_STEP_NUMBER_WIDTH-1:0] s0_position,
	input  wire                                  s0_start,
	input  wire                                  s0_stop,
	input  wire [C_SPEED_DATA_WIDTH-1:0]         s0_speed,
	input  wire signed [C_STEP_NUMBER_WIDTH-1:0] s0_step,
	input  wire                                  s0_abs,
	input  wire                                  s0_ext_sel,
	output wire                                  s0_ext_ntsign,
	output wire                                  s0_ext_zpsign,
	output wire                                  s0_ext_ptsign,
	output wire                                  s0_ext_state,
	output wire [C_SPEED_DATA_WIDTH-1:0]         s0_ext_rt_speed,
	output wire                                  s0_ext_rt_dir,
	output wire signed [C_STEP_NUMBER_WIDTH-1:0] s0_ext_position,
	input  wire                                  s0_ext_start,
	input  wire                                  s0_ext_stop,
	input  wire [C_SPEED_DATA_WIDTH-1:0]         s0_ext_speed,
	input  wire signed [C_STEP_NUMBER_WIDTH-1:0] s0_ext_step,
	input  wire                                  s0_ext_abs,
	input  wire                                  s0_ext_mod_remain,
	input  wire signed [C_STEP_NUMBER_WIDTH-1:0] s0_ext_new_remain,

	input  wire                           m1_zpd,	/// zero position detection
	output wire                           m1_drive,
	output wire                           m1_dir,
	output wire [C_MICROSTEP_WIDTH-1:0]   m1_ms,
	output wire                           m1_xen,
	output wire                           m1_xrst,


	input  wire                                  s1_xen,
	input  wire                                  s1_xrst,
	input  wire signed [C_STEP_NUMBER_WIDTH-1:0] s1_min_pos,
	input  wire signed [C_STEP_NUMBER_WIDTH-1:0] s1_max_pos,
	input  wire [C_MICROSTEP_WIDTH-1:0]          s1_ms,
	output wire                                  s1_ntsign,
	output wire                                  s1_zpsign,
	output wire                                  s1_ptsign,
	output wire                                  s1_state,
	output wire [C_SPEED_DATA_WIDTH-1:0]         s1_rt_speed,
	output wire                                  s1_rt_dir,
	output wire signed [C_STEP_NUMBER_WIDTH-1:0] s1_position,
	input  wire                                  s1_start,
	input  wire                                  s1_stop,
	input  wire [C_SPEED_DATA_WIDTH-1:0]         s1_speed,
	input  wire signed [C_STEP_NUMBER_WIDTH-1:0] s1_step,
	input  wire                                  s1_abs,
	input  wire                                  s1_ext_sel,
	output wire                                  s1_ext_ntsign,
	output wire                                  s1_ext_zpsign,
	output wire                                  s1_ext_ptsign,
	output wire                                  s1_ext_state,
	output wire [C_SPEED_DATA_WIDTH-1:0]         s1_ext_rt_speed,
	output wire                                  s1_ext_rt_dir,
	output wire signed [C_STEP_NUMBER_WIDTH-1:0] s1_ext_position,
	input  wire                                  s1_ext_start,
	input  wire                                  s1_ext_stop,
	input  wire [C_SPEED_DATA_WIDTH-1:0]         s1_ext_speed,
	input  wire signed [C_STEP_NUMBER_WIDTH-1:0] s1_ext_step,
	input  wire                                  s1_ext_abs,
	input  wire                                  s1_ext_mod_remain,
	input  wire signed [C_STEP_NUMBER_WIDTH-1:0] s1_ext_new_remain,

	input  wire                           m2_zpd,	/// zero position detection
	output wire                           m2_drive,
	output wire                           m2_dir,
	output wire [C_MICROSTEP_WIDTH-1:0]   m2_ms,
	output wire                           m2_xen,
	output wire                           m2_xrst,

	input  wire                                  s2_xen,
	input  wire                                  s2_xrst,
	input  wire signed [C_STEP_NUMBER_WIDTH-1:0] s2_min_pos,
	input  wire signed [C_STEP_NUMBER_WIDTH-1:0] s2_max_pos,
	input  wire [C_MICROSTEP_WIDTH-1:0]          s2_ms,
	output wire                                  s2_ntsign,
	output wire                                  s2_zpsign,
	output wire                                  s2_ptsign,
	output wire                                  s2_state,
	output wire [C_SPEED_DATA_WIDTH-1:0]         s2_rt_speed,
	output wire                                  s2_rt_dir,
	output wire signed [C_STEP_NUMBER_WIDTH-1:0] s2_position,
	input  wire                                  s2_start,
	input  wire                                  s2_stop,
	input  wire [C_SPEED_DATA_WIDTH-1:0]         s2_speed,
	input  wire signed [C_STEP_NUMBER_WIDTH-1:0] s2_step,
	input  wire                                  s2_abs,
	input  wire                                  s2_ext_sel,
	output wire                                  s2_ext_ntsign,
	output wire                                  s2_ext_zpsign,
	output wire                                  s2_ext_ptsign,
	output wire                                  s2_ext_state,
	output wire [C_SPEED_DATA_WIDTH-1:0]         s2_ext_rt_speed,
	output wire                                  s2_ext_rt_dir,
	output wire signed [C_STEP_NUMBER_WIDTH-1:0] s2_ext_position,
	input  wire                                  s2_ext_start,
	input  wire                                  s2_ext_stop,
	input  wire [C_SPEED_DATA_WIDTH-1:0]         s2_ext_speed,
	input  wire signed [C_STEP_NUMBER_WIDTH-1:0] s2_ext_step,
	input  wire                                  s2_ext_abs,
	input  wire                                  s2_ext_mod_remain,
	input  wire signed [C_STEP_NUMBER_WIDTH-1:0] s2_ext_new_remain,

	input  wire                           m3_zpd,	/// zero position detection
	output wire                           m3_drive,
	output wire                           m3_dir,
	output wire [C_MICROSTEP_WIDTH-1:0]   m3_ms,
	output wire                           m3_xen,
	output wire                           m3_xrst,

	input  wire                                  s3_xen,
	input  wire                                  s3_xrst,
	input  wire signed [C_STEP_NUMBER_WIDTH-1:0] s3_min_pos,
	input  wire signed [C_STEP_NUMBER_WIDTH-1:0] s3_max_pos,
	input  wire [C_MICROSTEP_WIDTH-1:0]          s3_ms,
	output wire                                  s3_ntsign,
	output wire                                  s3_zpsign,
	output wire                                  s3_ptsign,
	output wire                                  s3_state,
	output wire [C_SPEED_DATA_WIDTH-1:0]         s3_rt_speed,
	output wire                                  s3_rt_dir,
	output wire signed [C_STEP_NUMBER_WIDTH-1:0] s3_position,
	input  wire                                  s3_start,
	input  wire                                  s3_stop,
	input  wire [C_SPEED_DATA_WIDTH-1:0]         s3_speed,
	input  wire signed [C_STEP_NUMBER_WIDTH-1:0] s3_step,
	input  wire                                  s3_abs,
	input  wire                                  s3_ext_sel,
	output wire                                  s3_ext_ntsign,
	output wire                                  s3_ext_zpsign,
	output wire                                  s3_ext_ptsign,
	output wire                                  s3_ext_state,
	output wire [C_SPEED_DATA_WIDTH-1:0]         s3_ext_rt_speed,
	output wire                                  s3_ext_rt_dir,
	output wire signed [C_STEP_NUMBER_WIDTH-1:0] s3_ext_position,
	input  wire                                  s3_ext_start,
	input  wire                                  s3_ext_stop,
	input  wire [C_SPEED_DATA_WIDTH-1:0]         s3_ext_speed,
	input  wire signed [C_STEP_NUMBER_WIDTH-1:0] s3_ext_step,
	input  wire                                  s3_ext_abs,
	input  wire                                  s3_ext_mod_remain,
	input  wire signed [C_STEP_NUMBER_WIDTH-1:0] s3_ext_new_remain,

	input  wire                           m4_zpd,	/// zero position detection
	output wire                           m4_drive,
	output wire                           m4_dir,
	output wire [C_MICROSTEP_WIDTH-1:0]   m4_ms,
	output wire                           m4_xen,
	output wire                           m4_xrst,

	input  wire                                  s4_xen,
	input  wire                                  s4_xrst,
	input  wire signed [C_STEP_NUMBER_WIDTH-1:0] s4_min_pos,
	input  wire signed [C_STEP_NUMBER_WIDTH-1:0] s4_max_pos,
	input  wire [C_MICROSTEP_WIDTH-1:0]          s4_ms,
	output wire                                  s4_ntsign,
	output wire                                  s4_zpsign,
	output wire                                  s4_ptsign,
	output wire                                  s4_state,
	output wire [C_SPEED_DATA_WIDTH-1:0]         s4_rt_speed,
	output wire                                  s4_rt_dir,
	output wire signed [C_STEP_NUMBER_WIDTH-1:0] s4_position,
	input  wire                                  s4_start,
	input  wire                                  s4_stop,
	input  wire [C_SPEED_DATA_WIDTH-1:0]         s4_speed,
	input  wire signed [C_STEP_NUMBER_WIDTH-1:0] s4_step,
	input  wire                                  s4_abs,
	input  wire                                  s4_ext_sel,
	output wire                                  s4_ext_ntsign,
	output wire                                  s4_ext_zpsign,
	output wire                                  s4_ext_ptsign,
	output wire                                  s4_ext_state,
	output wire [C_SPEED_DATA_WIDTH-1:0]         s4_ext_rt_speed,
	output wire                                  s4_ext_rt_dir,
	output wire signed [C_STEP_NUMBER_WIDTH-1:0] s4_ext_position,
	input  wire                                  s4_ext_start,
	input  wire                                  s4_ext_stop,
	input  wire [C_SPEED_DATA_WIDTH-1:0]         s4_ext_speed,
	input  wire signed [C_STEP_NUMBER_WIDTH-1:0] s4_ext_step,
	input  wire                                  s4_ext_abs,
	input  wire                                  s4_ext_mod_remain,
	input  wire signed [C_STEP_NUMBER_WIDTH-1:0] s4_ext_new_remain,

	input  wire                           m5_zpd,	/// zero position detection
	output wire                           m5_drive,
	output wire                           m5_dir,
	output wire [C_MICROSTEP_WIDTH-1:0]   m5_ms,
	output wire                           m5_xen,
	output wire                           m5_xrst,

	input  wire                                  s5_xen,
	input  wire                                  s5_xrst,
	input  wire signed [C_STEP_NUMBER_WIDTH-1:0] s5_min_pos,
	input  wire signed [C_STEP_NUMBER_WIDTH-1:0] s5_max_pos,
	input  wire [C_MICROSTEP_WIDTH-1:0]          s5_ms,
	output wire                                  s5_ntsign,
	output wire                                  s5_zpsign,
	output wire                                  s5_ptsign,
	output wire                                  s5_state,
	output wire [C_SPEED_DATA_WIDTH-1:0]         s5_rt_speed,
	output wire                                  s5_rt_dir,
	output wire signed [C_STEP_NUMBER_WIDTH-1:0] s5_position,
	input  wire                                  s5_start,
	input  wire                                  s5_stop,
	input  wire [C_SPEED_DATA_WIDTH-1:0]         s5_speed,
	input  wire signed [C_STEP_NUMBER_WIDTH-1:0] s5_step,
	input  wire                                  s5_abs,
	input  wire                                  s5_ext_sel,
	output wire                                  s5_ext_ntsign,
	output wire                                  s5_ext_zpsign,
	output wire                                  s5_ext_ptsign,
	output wire                                  s5_ext_state,
	output wire [C_SPEED_DATA_WIDTH-1:0]         s5_ext_rt_speed,
	output wire                                  s5_ext_rt_dir,
	output wire signed [C_STEP_NUMBER_WIDTH-1:0] s5_ext_position,
	input  wire                                  s5_ext_start,
	input  wire                                  s5_ext_stop,
	input  wire [C_SPEED_DATA_WIDTH-1:0]         s5_ext_speed,
	input  wire signed [C_STEP_NUMBER_WIDTH-1:0] s5_ext_step,
	input  wire                                  s5_ext_abs,
	input  wire                                  s5_ext_mod_remain,
	input  wire signed [C_STEP_NUMBER_WIDTH-1:0] s5_ext_new_remain,

	input  wire                           m6_zpd,	/// zero position detection
	output wire                           m6_drive,
	output wire                           m6_dir,
	output wire [C_MICROSTEP_WIDTH-1:0]   m6_ms,
	output wire                           m6_xen,
	output wire                           m6_xrst,

	input  wire                                  s6_xen,
	input  wire                                  s6_xrst,
	input  wire signed [C_STEP_NUMBER_WIDTH-1:0] s6_min_pos,
	input  wire signed [C_STEP_NUMBER_WIDTH-1:0] s6_max_pos,
	input  wire [C_MICROSTEP_WIDTH-1:0]          s6_ms,
	output wire                                  s6_ntsign,
	output wire                                  s6_zpsign,
	output wire                                  s6_ptsign,
	output wire                                  s6_state,
	output wire [C_SPEED_DATA_WIDTH-1:0]         s6_rt_speed,
	output wire                                  s6_rt_dir,
	output wire signed [C_STEP_NUMBER_WIDTH-1:0] s6_position,
	input  wire                                  s6_start,
	input  wire                                  s6_stop,
	input  wire [C_SPEED_DATA_WIDTH-1:0]         s6_speed,
	input  wire signed [C_STEP_NUMBER_WIDTH-1:0] s6_step,
	input  wire                                  s6_abs,
	input  wire                                  s6_ext_sel,
	output wire                                  s6_ext_ntsign,
	output wire                                  s6_ext_zpsign,
	output wire                                  s6_ext_ptsign,
	output wire                                  s6_ext_state,
	output wire [C_SPEED_DATA_WIDTH-1:0]         s6_ext_rt_speed,
	output wire                                  s6_ext_rt_dir,
	output wire signed [C_STEP_NUMBER_WIDTH-1:0] s6_ext_position,
	input  wire                                  s6_ext_start,
	input  wire                                  s6_ext_stop,
	input  wire [C_SPEED_DATA_WIDTH-1:0]         s6_ext_speed,
	input  wire signed [C_STEP_NUMBER_WIDTH-1:0] s6_ext_step,
	input  wire                                  s6_ext_abs,
	input  wire                                  s6_ext_mod_remain,
	input  wire signed [C_STEP_NUMBER_WIDTH-1:0] s6_ext_new_remain,

	input  wire                           m7_zpd,	/// zero position detection
	output wire                           m7_drive,
	output wire                           m7_dir,
	output wire [C_MICROSTEP_WIDTH-1:0]   m7_ms,
	output wire                           m7_xen,
	output wire                           m7_xrst,

	input  wire                                  s7_xen,
	input  wire                                  s7_xrst,
	input  wire signed [C_STEP_NUMBER_WIDTH-1:0] s7_min_pos,
	input  wire signed [C_STEP_NUMBER_WIDTH-1:0] s7_max_pos,
	input  wire [C_MICROSTEP_WIDTH-1:0]          s7_ms,
	output wire                                  s7_ntsign,
	output wire                                  s7_zpsign,
	output wire                                  s7_ptsign,
	output wire                                  s7_state,
	output wire [C_SPEED_DATA_WIDTH-1:0]         s7_rt_speed,
	output wire                                  s7_rt_dir,
	output wire signed [C_STEP_NUMBER_WIDTH-1:0] s7_position,
	input  wire                                  s7_start,
	input  wire                                  s7_stop,
	input  wire [C_SPEED_DATA_WIDTH-1:0]         s7_speed,
	input  wire signed [C_STEP_NUMBER_WIDTH-1:0] s7_step,
	input  wire                                  s7_abs,
	input  wire                                  s7_ext_sel,
	output wire                                  s7_ext_ntsign,
	output wire                                  s7_ext_zpsign,
	output wire                                  s7_ext_ptsign,
	output wire                                  s7_ext_state,
	output wire [C_SPEED_DATA_WIDTH-1:0]         s7_ext_rt_speed,
	output wire                                  s7_ext_rt_dir,
	output wire signed [C_STEP_NUMBER_WIDTH-1:0] s7_ext_position,
	input  wire                                  s7_ext_start,
	input  wire                                  s7_ext_stop,
	input  wire [C_SPEED_DATA_WIDTH-1:0]         s7_ext_speed,
	input  wire signed [C_STEP_NUMBER_WIDTH-1:0] s7_ext_step,
	input  wire                                  s7_ext_abs,
	input  wire                                  s7_ext_mod_remain,
	input  wire signed [C_STEP_NUMBER_WIDTH-1:0] s7_ext_new_remain,

	output [31:0] test0,
	output [31:0] test1,
	output [31:0] test2,
	output [31:0] test3
);
	function integer clogb2(input integer bit_depth);
		for(clogb2=0; bit_depth>0; clogb2=clogb2+1) begin
			bit_depth = bit_depth>>1;
		end
	endfunction

	function integer istart(input integer i, input integer width);
		istart = width * i;
	endfunction

	function integer istop(input integer i, input integer width);
		istop = width * (i+1) - 1;
	endfunction

`define __EXTRACTOR(_sig, _i, _width) _sig[istop(_i, _width):istart(_i,_width)]

	/// block ram for speed data
	reg  [C_SPEED_ADDRESS_WIDTH-1:0] acce_addr_final;
	wire [C_SPEED_DATA_WIDTH-1:0] acce_data_final;
	reg  [C_SPEED_ADDRESS_WIDTH-1:0] deac_addr_final;
	wire [C_SPEED_DATA_WIDTH-1:0] deac_data_final;

	wire acce_we_en;
	assign acce_we_en = br_init && br_wr_en;
	assign br_size = (2**C_SPEED_ADDRESS_WIDTH);
	reg  [C_SPEED_ADDRESS_WIDTH-1 : 0] acce_we_addr;
	reg  [C_SPEED_ADDRESS_WIDTH-1 : 0] acce_addr_max;
	wire [C_SPEED_ADDRESS_WIDTH-1 : 0] deac_addr_max;
	assign deac_addr_max = acce_addr_max;
	block_ram #(
		.C_DATA_WIDTH(C_SPEED_DATA_WIDTH),
		.C_ADDRESS_WIDTH(C_SPEED_ADDRESS_WIDTH)
	) speed_data (
		.clk(clk),
		.weA(acce_we_en),
		.addrA(acce_we_en ? acce_we_addr : acce_addr_final),
		.dataA(br_data),
		.qA(acce_data_final),
		.weB(1'b0),
		.dataB({C_SPEED_DATA_WIDTH{1'b0}}),
		.addrB(deac_addr_final),
		.qB(deac_data_final)
	);

	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			acce_we_addr <= 0;
			acce_addr_max <= 0;
		end
		else if (~br_init)
			acce_we_addr <= 0;
		else if (br_wr_en) begin
			acce_we_addr <= acce_we_addr + 1;
			acce_addr_max <= acce_we_addr;
		end
	end

	/// clock division
	reg [C_CLK_DIV_NBR-1:0] clk_en;
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			clk_en <= 1;
		end
		else begin
			clk_en <= {clk_en[C_CLK_DIV_NBR-2:0], clk_en[C_CLK_DIV_NBR-1]};
		end
	end

	/// read block ram
	wire [C_MOTOR_NBR-1:0] acce_en_array;
	wire [C_MOTOR_NBR-1:0] deac_en_array;
	wire [C_SPEED_ADDRESS_WIDTH-1:0] acce_addr_array[C_MOTOR_NBR-1:0];
	wire [C_SPEED_ADDRESS_WIDTH-1:0] deac_addr_array[C_MOTOR_NBR-1:0];
	wire [C_MOTOR_NBR-1:0] acce_addr_conv[C_SPEED_ADDRESS_WIDTH-1:0];
	wire [C_MOTOR_NBR-1:0] deac_addr_conv[C_SPEED_ADDRESS_WIDTH-1:0];
	generate
		genvar i, j;
		for (j=0; j < C_MOTOR_NBR; j = j + 1) begin: single_motor_conv
			for (i=0; i < C_SPEED_ADDRESS_WIDTH; i = i + 1) begin: single_addr_bit_conv
				assign acce_addr_conv[i][j] = acce_addr_array[j][i];
				assign deac_addr_conv[i][j] = deac_addr_array[j][i];
			end
		end

		for (i = 0; i < C_SPEED_ADDRESS_WIDTH; i = i+1) begin: single_addr_bit
			always @ (posedge clk) begin
				acce_addr_final[i] <= ((acce_en_array & acce_addr_conv[i]) != 0);
				deac_addr_final[i] <= ((deac_en_array & deac_addr_conv[i]) != 0);
			end
		end
	endgenerate

	/// motor logic
	wire                           m_zpd      [C_MOTOR_NBR-1:0];
	wire                           m_drive    [C_MOTOR_NBR-1:0];
	wire                           m_dir      [C_MOTOR_NBR-1:0];
	wire [C_MICROSTEP_WIDTH-1:0]   m_ms       [C_MOTOR_NBR-1:0];
	wire                           m_xen      [C_MOTOR_NBR-1:0];
	wire                           m_xrst     [C_MOTOR_NBR-1:0];

	wire                           s_xen      [C_MOTOR_NBR-1:0];
	wire                           s_xrst     [C_MOTOR_NBR-1:0];
	wire signed [C_STEP_NUMBER_WIDTH-1:0] s_min_pos   [C_MOTOR_NBR-1:0];
	wire signed [C_STEP_NUMBER_WIDTH-1:0] s_max_pos   [C_MOTOR_NBR-1:0];
	wire [C_MICROSTEP_WIDTH-1:0]   s_ms       [C_MOTOR_NBR-1:0];

	wire                           s_ntsign   [C_MOTOR_NBR-1:0];
	wire                           s_zpsign   [C_MOTOR_NBR-1:0];
	wire                           s_ptsign   [C_MOTOR_NBR-1:0];
	wire                           s_state    [C_MOTOR_NBR-1:0];
	wire [C_SPEED_DATA_WIDTH-1:0]  s_rt_speed [C_MOTOR_NBR-1:0];
	wire                           s_rt_dir   [C_MOTOR_NBR-1:0];
	wire signed [C_STEP_NUMBER_WIDTH-1:0] s_position [C_MOTOR_NBR-1:0];
	wire                           s_start    [C_MOTOR_NBR-1:0];
	wire                           s_stop     [C_MOTOR_NBR-1:0];
	wire [C_SPEED_DATA_WIDTH-1:0]  s_speed    [C_MOTOR_NBR-1:0];
	wire signed [C_STEP_NUMBER_WIDTH-1:0] s_step     [C_MOTOR_NBR-1:0];
	wire                           s_abs      [C_MOTOR_NBR-1:0];

	wire                           s_ext_sel  [C_MOTOR_NBR-1:0];

	wire                           s_ext_ntsign   [C_MOTOR_NBR-1:0];
	wire                           s_ext_zpsign   [C_MOTOR_NBR-1:0];
	wire                           s_ext_ptsign   [C_MOTOR_NBR-1:0];
	wire                           s_ext_state    [C_MOTOR_NBR-1:0];
	wire [C_SPEED_DATA_WIDTH-1:0]  s_ext_rt_speed [C_MOTOR_NBR-1:0];
	wire                           s_ext_rt_dir   [C_MOTOR_NBR-1:0];
	wire signed [C_STEP_NUMBER_WIDTH-1:0] s_ext_position [C_MOTOR_NBR-1:0];
	wire                           s_ext_start    [C_MOTOR_NBR-1:0];
	wire                           s_ext_stop     [C_MOTOR_NBR-1:0];
	wire [C_SPEED_DATA_WIDTH-1:0]  s_ext_speed    [C_MOTOR_NBR-1:0];
	wire signed [C_STEP_NUMBER_WIDTH-1:0] s_ext_step     [C_MOTOR_NBR-1:0];
	wire                           s_ext_abs      [C_MOTOR_NBR-1:0];
	wire                           s_ext_mod_remain[C_MOTOR_NBR-1:0];
	wire signed [C_STEP_NUMBER_WIDTH-1:0] s_ext_new_remain[C_MOTOR_NBR-1:0];
`define ASSIGN_M_OUT(_i, _port) assign m``_i``_``_port = m_``_port[_i]
`define ASSIGN_M_IN(_i, _port) assign m_``_port[_i] = m``_i``_``_port
`define ASSIGN_S_OUT(_i, _port) assign s``_i``_``_port = s_``_port[_i]
`define ASSIGN_S_IN(_i, _port) assign s_``_port[_i] = s``_i``_``_port
`define ZERO_M_OUT(_i, _port) assign m``_i``_``_port = 0
`define ZERO_S_OUT(_i, _port) assign s``_i``_``_port = 0
`define ASSIGN_SINGLE_MOTOR(_i) \
	if (C_MOTOR_NBR > _i) begin \
	`ASSIGN_M_IN(_i, zpd); \
	`ASSIGN_M_OUT(_i, drive); \
	`ASSIGN_M_OUT(_i, dir); \
	`ASSIGN_M_OUT(_i, ms); \
	`ASSIGN_M_OUT(_i, xen); \
	`ASSIGN_M_OUT(_i, xrst); \
	`ASSIGN_S_IN(_i, xen); \
	`ASSIGN_S_IN(_i, xrst); \
	`ASSIGN_S_IN(_i, min_pos); \
	`ASSIGN_S_IN(_i, max_pos); \
	`ASSIGN_S_IN(_i, ms); \
	`ASSIGN_S_OUT(_i, ntsign); \
	`ASSIGN_S_OUT(_i, zpsign); \
	`ASSIGN_S_OUT(_i, ptsign); \
	`ASSIGN_S_OUT(_i, state); \
	`ASSIGN_S_OUT(_i, rt_speed); \
	`ASSIGN_S_OUT(_i, rt_dir); \
	`ASSIGN_S_OUT(_i, position); \
	`ASSIGN_S_IN(_i,  start); \
	`ASSIGN_S_IN(_i,  stop); \
	`ASSIGN_S_IN(_i,  speed); \
	`ASSIGN_S_IN(_i,  step); \
	`ASSIGN_S_IN(_i,  abs); \
	`ASSIGN_S_IN(_i,  ext_sel); \
	`ASSIGN_S_OUT(_i, ext_ntsign); \
	`ASSIGN_S_OUT(_i, ext_zpsign); \
	`ASSIGN_S_OUT(_i, ext_ptsign); \
	`ASSIGN_S_OUT(_i, ext_state); \
	`ASSIGN_S_OUT(_i, ext_rt_speed); \
	`ASSIGN_S_OUT(_i, ext_rt_dir); \
	`ASSIGN_S_OUT(_i, ext_position); \
	`ASSIGN_S_IN(_i,  ext_start); \
	`ASSIGN_S_IN(_i,  ext_stop); \
	`ASSIGN_S_IN(_i,  ext_speed); \
	`ASSIGN_S_IN(_i,  ext_step); \
	`ASSIGN_S_IN(_i,  ext_abs); \
	`ASSIGN_S_IN(_i,  ext_mod_remain); \
	`ASSIGN_S_IN(_i,  ext_new_remain); \
	end \
	else begin \
	`ZERO_M_OUT(_i, drive); \
	`ZERO_M_OUT(_i, dir); \
	`ZERO_M_OUT(_i, ms); \
	`ZERO_M_OUT(_i, xen); \
	`ZERO_M_OUT(_i, xrst); \
	`ZERO_S_OUT(_i, ntsign); \
	`ZERO_S_OUT(_i, zpsign); \
	`ZERO_S_OUT(_i, ptsign); \
	`ZERO_S_OUT(_i, state); \
	`ZERO_S_OUT(_i, rt_speed); \
	`ZERO_S_OUT(_i, rt_dir); \
	`ZERO_S_OUT(_i, position); \
	`ZERO_S_OUT(_i, ext_ntsign); \
	`ZERO_S_OUT(_i, ext_zpsign); \
	`ZERO_S_OUT(_i, ext_ptsign); \
	`ZERO_S_OUT(_i, ext_state); \
	`ZERO_S_OUT(_i, ext_rt_speed); \
	`ZERO_S_OUT(_i, ext_rt_dr); \
	`ZERO_S_OUT(_i, ext_position); \
	end
generate
	`ASSIGN_SINGLE_MOTOR(0)
	`ASSIGN_SINGLE_MOTOR(1)
	`ASSIGN_SINGLE_MOTOR(2)
	`ASSIGN_SINGLE_MOTOR(3)
	`ASSIGN_SINGLE_MOTOR(4)
	`ASSIGN_SINGLE_MOTOR(5)
	`ASSIGN_SINGLE_MOTOR(6)
	`ASSIGN_SINGLE_MOTOR(7)
endgenerate
	wire [31:0] int_test0[C_MOTOR_NBR-1:0];
	wire [31:0] int_test1[C_MOTOR_NBR-1:0];
	wire [31:0] int_test2[C_MOTOR_NBR-1:0];
	wire [31:0] int_test3[C_MOTOR_NBR-1:0];

	assign test0 = int_test0[0];
	assign test1 = int_test1[0];
	assign test2 = int_test2[0];
	assign test3 = int_test3[0];

	generate
		for (i = 0; i < C_MOTOR_NBR; i = i+1) begin: single_motor_logic
		single_step_motor #(
			.C_OPT_BR_TIME(C_OPT_BR_TIME),
			.C_STEP_NUMBER_WIDTH(C_STEP_NUMBER_WIDTH),
			.C_SPEED_DATA_WIDTH(C_SPEED_DATA_WIDTH),
			.C_SPEED_ADDRESS_WIDTH(C_SPEED_ADDRESS_WIDTH),
			.C_MICROSTEP_WIDTH(C_MICROSTEP_WIDTH),
			.C_ZPD((C_ZPD_SEQ >> i) & 1),
			.C_MICROSTEP_PASSTHOUGH((C_MICROSTEP_PASSTHOUGH_SEQ >> i) & 1)
		) step_motor_inst (
			.clk(clk),
			.resetn(resetn),
			.clk_en(clk_en[i]),

			.acce_addr_max(acce_addr_max),
			.deac_addr_max(deac_addr_max),
			.acce_en(acce_en_array[i]),
			.acce_addr(acce_addr_array[i]),
			.acce_data(acce_data_final),
			.deac_en(deac_en_array[i]),
			.deac_addr(deac_addr_array[i]),
			.deac_data(deac_data_final),

			/// valid when C_ZPD == 1
			.zpd(m_zpd[i]),	/// zero position detection
			.o_drive(m_drive[i]),
			.o_dir(m_dir[i]),
			.o_ms(m_ms[i]),
			.o_xen(m_xen[i]),
			.o_xrst(m_xrst[i]),

			.i_xen    (s_xen[i]   ),
			.i_xrst   (s_xrst[i]  ),
			.i_min_pos(s_min_pos[i]),
			.i_max_pos(s_max_pos[i]),
			.i_ms     (s_ms[i]    ),
			/// valid when C_ZPD == 1
			.pri_ntsign  (s_ntsign  [i]),
			.pri_zpsign  (s_zpsign  [i]),
			.pri_ptsign  (s_ptsign  [i]),
			.pri_state   (s_state   [i]),
			.pri_rt_speed(s_rt_speed[i]),
			.pri_rt_dir  (s_rt_dir  [i]),
			.pri_position(s_position[i]),
			.pri_start   (s_start   [i]),
			.pri_stop    (s_stop    [i]),
			.pri_speed   (s_speed   [i]),
			.pri_step    (s_step    [i]),
			.pri_abs     (s_abs     [i]),

			.ext_sel     (s_ext_sel     [i]),

			.ext_ntsign  (s_ext_ntsign  [i]),
			.ext_zpsign  (s_ext_zpsign  [i]),
			.ext_ptsign  (s_ext_ptsign  [i]),
			.ext_state   (s_ext_state   [i]),
			.ext_rt_speed(s_ext_rt_speed[i]),
			.ext_rt_dir  (s_ext_rt_dir  [i]),
			.ext_position(s_ext_position[i]),
			.ext_start   (s_ext_start   [i]),
			.ext_stop    (s_ext_stop    [i]),
			.ext_speed   (s_ext_speed   [i]),
			.ext_step    (s_ext_step    [i]),
			.ext_abs     (s_ext_abs     [i]),
			.ext_mod_remain(s_ext_mod_remain[i]),
			.ext_new_remain(s_ext_new_remain[i]),

			.test0(int_test0[i]),
			.test1(int_test1[i]),
			.test2(int_test2[i]),
			.test3(int_test3[i])
		);
		end	/// for
	endgenerate

endmodule
