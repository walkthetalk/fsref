`timescale 1ns / 1ps

module fscpu #(
	parameter integer C_IMG_HW = 12,
	parameter integer C_IMG_WW = 12,
	parameter integer C_SPEED_DATA_WIDTH = 32,
	parameter integer C_STEP_NUMBER_WIDTH = 32
)(
	input  wire clk,
	input  wire resetn,

	input  wire                           bpm_init,
	input  wire                           bpm_wr_en,
	input  wire [C_STEP_NUMBER_WIDTH-1:0] bpm_data,
	output wire [C_IMG_WW:0]              bpm_size,

	input  wire                           bam_init,
	input  wire                           bam_wr_en,
	input  wire [C_STEP_NUMBER_WIDTH-1:0] bam_data,
	output wire [C_IMG_WW:0]              bam_size,

	input  wire         req_en  ,
	input  wire [ 31:0] req_cmd ,
	input  wire [127:0] req_param,
	output wire         req_done,
	output wire [ 31:0] req_err,

	input wire                     x_ana_done              ,
	input wire                     x_lft_valid             ,
	input wire [C_IMG_WW-1:0]      x_lft_edge              ,
	input wire                     x_lft_header_outer_valid,
	input wire [C_IMG_WW-1:0]      x_lft_header_outer_y    ,
	input wire                     x_lft_header_inner_valid,
	input wire [C_IMG_WW-1:0]      x_lft_header_inner_y    ,
	input wire                     x_rt_valid              ,
	input wire [C_IMG_WW-1:0]      x_rt_edge               ,
	input wire                     x_rt_header_outer_valid ,
	input wire [C_IMG_WW-1:0]      x_rt_header_outer_y     ,
	input wire                     x_rt_header_inner_valid ,
	input wire [C_IMG_WW-1:0]      x_rt_header_inner_y     ,

	input wire                     y_ana_done              ,
	input wire                     y_lft_valid             ,
	input wire [C_IMG_WW-1:0]      y_lft_edge              ,
	input wire                     y_lft_header_outer_valid,
	input wire [C_IMG_WW-1:0]      y_lft_header_outer_y    ,
	input wire                     y_lft_header_inner_valid,
	input wire [C_IMG_WW-1:0]      y_lft_header_inner_y    ,
	input wire                     y_rt_valid              ,
	input wire [C_IMG_WW-1:0]      y_rt_edge               ,
	input wire                     y_rt_header_outer_valid ,
	input wire [C_IMG_WW-1:0]      y_rt_header_outer_y     ,
	input wire                     y_rt_header_inner_valid ,
	input wire [C_IMG_WW-1:0]      y_rt_header_inner_y     ,

	output wire                           ml_sel     ,
	input  wire                           ml_zpsign  ,
	input  wire                           ml_tpsign  ,
	input  wire                           ml_state   ,
	input  wire [C_SPEED_DATA_WIDTH-1:0]  ml_rt_speed,
	input  wire [C_STEP_NUMBER_WIDTH-1:0] ml_position,
	output wire                           ml_start   ,
	output wire                           ml_stop    ,
	output wire [C_SPEED_DATA_WIDTH-1:0]  ml_speed   ,
	output wire [C_STEP_NUMBER_WIDTH-1:0] ml_step    ,
	output wire                           ml_dir     ,
	output wire                           ml_mod_remain,
	output wire [C_STEP_NUMBER_WIDTH-1:0] ml_new_remain,

	output wire                           mr_sel     ,
	input  wire                           mr_zpsign  ,
	input  wire                           mr_tpsign  ,
	input  wire                           mr_state   ,
	input  wire [C_SPEED_DATA_WIDTH-1:0]  mr_rt_speed,
	input  wire [C_STEP_NUMBER_WIDTH-1:0] mr_position,
	output wire                           mr_start   ,
	output wire                           mr_stop    ,
	output wire [C_SPEED_DATA_WIDTH-1:0]  mr_speed   ,
	output wire [C_STEP_NUMBER_WIDTH-1:0] mr_step    ,
	output wire                           mr_dir     ,
	output wire                           mr_mod_remain,
	output wire [C_STEP_NUMBER_WIDTH-1:0] mr_new_remain,

	output wire                           mx_sel     ,
	input  wire                           mx_zpsign  ,
	input  wire                           mx_tpsign  ,
	input  wire                           mx_state   ,
	input  wire [C_SPEED_DATA_WIDTH-1:0]  mx_rt_speed,
	input  wire [C_STEP_NUMBER_WIDTH-1:0] mx_position,
	output wire                           mx_start   ,
	output wire                           mx_stop    ,
	output wire [C_SPEED_DATA_WIDTH-1:0]  mx_speed   ,
	output wire [C_STEP_NUMBER_WIDTH-1:0] mx_step    ,
	output wire                           mx_dir     ,
	output wire                           mx_mod_remain,
	output wire [C_STEP_NUMBER_WIDTH-1:0] mx_new_remain,

	output wire                           my_sel     ,
	input  wire                           my_zpsign  ,
	input  wire                           my_tpsign  ,
	input  wire                           my_state   ,
	input  wire [C_SPEED_DATA_WIDTH-1:0]  my_rt_speed,
	input  wire [C_STEP_NUMBER_WIDTH-1:0] my_position,
	output wire                           my_start   ,
	output wire                           my_stop    ,
	output wire [C_SPEED_DATA_WIDTH-1:0]  my_speed   ,
	output wire [C_STEP_NUMBER_WIDTH-1:0] my_step    ,
	output wire                           my_dir     ,
	output wire                           my_mod_remain,
	output wire [C_STEP_NUMBER_WIDTH-1:0] my_new_remain,

	output wire                           discharge_drive
);
	localparam integer C_DISCHARGE_DEFAULT_VALUE = 0;
	localparam integer C_DISCHARGE_PWM_CNT_WIDTH = 16;
	localparam integer C_DISCHARGE_FRACTIONAL_WIDTH = 16;
	localparam integer C_DISCHARGE_PWM_NUM_WIDTH = 32;

	`define DIDX(_x) DBIT_``_x
	`define DBIT(_x) (1 << DBIT_``_x)
	localparam integer DBIT_MOTOR_LP = 0;
	localparam integer DBIT_MOTOR_RP = 1;
	localparam integer DBIT_MOTOR_XA = 2;
	localparam integer DBIT_MOTOR_YA = 3;
	localparam integer DBIT_MOTOR_LR = 4;
	localparam integer DBIT_MOTOR_RR = 5;

	localparam integer DBIT_DISCHARGE = 8;

	// @todo add new req command
	localparam integer REQ_CFG       = 29;
	localparam integer REQ_EXE       = 30;
	localparam integer REQ_STOP      = 31;

	wire [31:0] req_par0;	assign req_par0 = req_param[ 31: 0];
	wire [31:0] req_par1;	assign req_par1 = req_param[ 63:32];
	wire [31:0] req_par2;	assign req_par2 = req_param[ 95:64];
	wire [31:0] req_par3;	assign req_par3 = req_param[127:96];

	reg  [31:0] dev_oper_bmp;
	wire [31:0] req_done_bmp;
	/// @note only assign for empty device index
	assign req_done_bmp[7:6] = 0;
	assign req_done_bmp[31:9] = 0;

	reg  [31:0] cfg_img_delay_cnt;
	reg  [1:0]  cfg_img_delay_frm;
	reg  [C_DISCHARGE_PWM_CNT_WIDTH-1:0] cfg_discharge_denominator;

	/////////////////////////// record parameters for motor ////////////////
	reg        req_single_dir[`DIDX(MOTOR_RR):`DIDX(MOTOR_LP)];	// par0[0]
	reg        req_dir_back  [`DIDX(MOTOR_RR):`DIDX(MOTOR_LP)];	// par0[1]
	reg        req_dep_img   [`DIDX(MOTOR_RR):`DIDX(MOTOR_LP)];	// par0[2]
	reg        req_ecf       [`DIDX(MOTOR_RR):`DIDX(MOTOR_LP)];	// par0[3]
	reg [31:0] req_speed     [`DIDX(MOTOR_RR):`DIDX(MOTOR_LP)];	// par1[C_SPEED_DATA_WIDTH-1 : 0]
	reg [31:0] req_step      [`DIDX(MOTOR_RR):`DIDX(MOTOR_LP)];	// par2[C_STEP_NUMBER_WIDTH-1: 0]
	reg [15:0] req_img_tol   [`DIDX(MOTOR_RR):`DIDX(MOTOR_LP)];	// par3[C_IMG_WW-1+16 : 16]
	reg [15:0] req_img_dst   [`DIDX(MOTOR_RR):`DIDX(MOTOR_LP)];	// par3[C_IMG_WW-1 : 0]
generate
	genvar i;
	for (i = DBIT_MOTOR_LP; i <= DBIT_MOTOR_RR; i=i+1) begin : record_motor_params
		always @ (posedge clk) begin
			if (resetn == 1'b0) begin
				req_single_dir[i] <= 0;
				req_dir_back  [i] <= 0;
				req_dep_img   [i] <= 0;
				req_ecf       [i] <= 0;
				req_speed     [i] <= 0;
				req_step      [i] <= 0;
				req_img_tol   [i] <= 0;
				req_img_dst   [i] <= 0;
			end
			else if (req_en && (req_cmd == i)) begin
				req_single_dir[i] <= req_par0[0];
				req_dir_back  [i] <= req_par0[1];
				req_dep_img   [i] <= req_par0[2];
				req_ecf       [i] <= req_par0[3];
				req_speed     [i] <= req_par1;
				req_step      [i] <= req_par2;
				req_img_tol   [i] <= req_par3[31:16];
				req_img_dst   [i] <= req_par3[15: 0];
			end
		end
	end
endgenerate
	wire wire_done;
	assign wire_done = ((req_done_bmp & dev_oper_bmp) == dev_oper_bmp && dev_oper_bmp != 0);
	///////////////////////////// record devices ///////////////////////////
	reg [31:0] dev_oper_bmp_stage;
	`define RECORD_DEV(_x) `DIDX(_x): dev_oper_bmp_stage <= dev_oper_bmp_stage | `DBIT(_x)
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			dev_oper_bmp_stage <= 0;
		end
		else if (req_en) begin
			case (req_cmd)
			`RECORD_DEV(MOTOR_LP);
			`RECORD_DEV(MOTOR_RP);
			`RECORD_DEV(MOTOR_XA);
			`RECORD_DEV(MOTOR_YA);
			`RECORD_DEV(MOTOR_LR);
			`RECORD_DEV(MOTOR_RR);
			`RECORD_DEV(DISCHARGE);
			REQ_STOP: dev_oper_bmp_stage <= 0;
			default:  dev_oper_bmp_stage <= 0;
			endcase
		end
		else if (wire_done)	/// ensure one clock reset at least
			dev_oper_bmp_stage <= 0;
	end

	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			dev_oper_bmp <= 0;
		end
		else if (req_en) begin
			case (req_cmd)
			REQ_EXE:   dev_oper_bmp <= dev_oper_bmp_stage;
			REQ_STOP:  dev_oper_bmp <= 0;
			endcase
		end
		else if (wire_done)	/// ensure one clock reset at least
			dev_oper_bmp <= 0;
	end

	//////////////////////////// record discharge //////////////////////////
	reg[C_DISCHARGE_PWM_CNT_WIDTH-1:0] discharge_numerator0;
	reg[C_DISCHARGE_PWM_CNT_WIDTH-1:0] discharge_numerator1;
	reg[C_DISCHARGE_PWM_NUM_WIDTH-1:0] discharge_number0;
	reg[C_DISCHARGE_PWM_NUM_WIDTH-1:0] discharge_number1;
	reg[C_DISCHARGE_PWM_CNT_WIDTH+C_DISCHARGE_FRACTIONAL_WIDTH-1:0] discharge_inc0;
	always @ (posedge clk) begin
		if (resetn == 0) begin
			discharge_numerator0 <= 0;
			discharge_numerator1 <= 0;
			discharge_number0 <= 0;
			discharge_number1 <= 0;
			discharge_inc0 <= 0;
		end
		else if (req_en && req_cmd == `DIDX(DISCHARGE)) begin
			discharge_numerator0 <= req_par0[C_DISCHARGE_PWM_CNT_WIDTH-1:0];
			discharge_numerator1 <= req_par0[C_DISCHARGE_PWM_CNT_WIDTH + 15 : 16];
			discharge_number0    <= req_par1;
			discharge_number1    <= req_par2;
			discharge_inc0       <= req_par3;
		end
	end

	//////////////////////////// record configs ////////////////////////////
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			cfg_img_delay_frm <= 0;
			cfg_img_delay_cnt <= 0;
			cfg_discharge_denominator <= 0;
		end
		else if (req_en) begin
			case (req_cmd)
			REQ_CFG: begin
				cfg_img_delay_frm <= req_par0;
				cfg_img_delay_cnt <= req_par1;
				cfg_discharge_denominator <= req_par2[C_DISCHARGE_PWM_CNT_WIDTH-1:0];
			end
			endcase
		end
	end

	reg r_req_done;
	assign req_done = r_req_done;
	assign req_err  = 0;	/// TODO: fix it
	always @ (posedge clk) begin
		if (resetn == 1'b0)
			r_req_done <= 0;
		else if (req_en)
			r_req_done <= 0;
		else if (wire_done)
			r_req_done <= 1;
	end
	////////////////// block ram //////////////////////////////
	//wire                          bpm_reA  ;	/// blockram for push motor
	wire [C_IMG_WW-1:0]           bpm_addrA;
	wire[C_STEP_NUMBER_WIDTH-1:0] bpm_qA   ;
	//wire                          bpm_reB  ;
	wire[C_IMG_WW-1:0]            bpm_addrB;
	wire[C_STEP_NUMBER_WIDTH-1:0] bpm_qB   ;

	block_ram_container # (
		.C_DATA_WIDTH(C_STEP_NUMBER_WIDTH),
		.C_ADDRESS_WIDTH(C_IMG_WW)
	) br4pushmotor (
		.clk(clk),

		.wr_resetn(bpm_init ),
		.wr_en    (bpm_wr_en),
		.wr_data  (bpm_data ),
		.size     (bpm_size ),

		//.reA  (bpm_reA  ),
		.addrA(bpm_addrA),
		.qA   (bpm_qA   ),

		//.reB  (bpm_reB  ),
		.addrB(bpm_addrB),
		.qB   (bpm_qB   )
	);

	//wire                          bpm_reA  ;	/// blockram for align motor
	wire [C_IMG_HW-1:0]           bam_addrA;
	wire[C_STEP_NUMBER_WIDTH-1:0] bam_qA   ;
	//wire                          bpm_reB  ;
	wire[C_IMG_HW-1:0]            bam_addrB;
	wire[C_STEP_NUMBER_WIDTH-1:0] bam_qB   ;

	block_ram_container # (
		.C_DATA_WIDTH(C_STEP_NUMBER_WIDTH),
		.C_ADDRESS_WIDTH(C_IMG_HW)
	) br4alignmotor (
		.clk(clk),

		.wr_resetn(bam_init ),
		.wr_en    (bam_wr_en),
		.wr_data  (bam_data ),
		.size     (bam_size ),

		//.reA  (bam_reA  ),
		.addrA(bam_addrA),
		.qA   (bam_qA   ),

		//.reB  (bam_reB  ),
		.addrB(bam_addrB),
		.qB   (bam_qB   )
	);

	////////////////// lft motor //////////////////////////////
	PM_ctl # (
		.C_IMG_WW(C_IMG_WW),
		.C_IMG_HW(C_IMG_HW),
		.C_STEP_NUMBER_WIDTH(C_STEP_NUMBER_WIDTH),
		.C_SPEED_DATA_WIDTH (C_SPEED_DATA_WIDTH ),
		.C_L2R(1)
	) lft_motor_ctl (
		.clk          (clk   ),
		.resetn       (dev_oper_bmp[`DIDX(MOTOR_LP)]),
		.exe_done     (req_done_bmp[`DIDX(MOTOR_LP)]),

		.img_delay_cnt(cfg_img_delay_cnt),
		.img_delay_frm(cfg_img_delay_frm),

		.req_single_dir(req_single_dir[`DIDX(MOTOR_LP)]),
		.req_dir_back  (req_dir_back  [`DIDX(MOTOR_LP)]),
		.req_dep_img   (req_dep_img   [`DIDX(MOTOR_LP)]),
		.req_speed     (req_speed     [`DIDX(MOTOR_LP)][C_SPEED_DATA_WIDTH-1 :0]),
		.req_step      (req_step      [`DIDX(MOTOR_LP)][C_STEP_NUMBER_WIDTH-1:0]),
		.req_img_tol   (req_img_tol   [`DIDX(MOTOR_LP)][C_IMG_WW-1           :0]),
		.req_img_dst   (req_img_dst   [`DIDX(MOTOR_LP)][C_IMG_WW-1           :0]),

		.img_pulse(x_ana_done ),
		.img_valid(x_lft_valid),
		.img_pos  (x_lft_edge ),

		.m_sel       (ml_sel       ),
		.m_zpsign    (ml_zpsign    ),
		.m_tpsign    (ml_tpsign    ),
		.m_state     (ml_state     ),
		.m_position  (ml_position  ),
		.m_start     (ml_start     ),
		.m_stop      (ml_stop      ),
		.m_speed     (ml_speed     ),
		.m_step      (ml_step      ),
		.m_dir       (ml_dir       ),
		.m_mod_remain(ml_mod_remain),
		.m_new_remain(ml_new_remain),

		//.rd_en  (bpm_reA  ),
		.rd_addr(bpm_addrA),
		.rd_data(bpm_qA   )
	);

	/////////////////// rt motor //////////////////////////////
	PM_ctl # (
		.C_IMG_WW(C_IMG_WW),
		.C_IMG_HW(C_IMG_HW),
		.C_STEP_NUMBER_WIDTH(C_STEP_NUMBER_WIDTH),
		.C_SPEED_DATA_WIDTH (C_SPEED_DATA_WIDTH ),
		.C_L2R(0)
	) rt_motor_ctl (
		.clk          (clk   ),
		.resetn       (dev_oper_bmp[`DIDX(MOTOR_RP)]),
		.exe_done     (req_done_bmp[`DIDX(MOTOR_RP)]),

		.img_delay_cnt(cfg_img_delay_cnt),
		.img_delay_frm(cfg_img_delay_frm),

		.req_single_dir(req_single_dir[`DIDX(MOTOR_RP)]),
		.req_dir_back  (req_dir_back  [`DIDX(MOTOR_RP)]),
		.req_dep_img   (req_dep_img   [`DIDX(MOTOR_RP)]),
		.req_speed     (req_speed     [`DIDX(MOTOR_RP)][C_SPEED_DATA_WIDTH-1 :0]),
		.req_step      (req_step      [`DIDX(MOTOR_RP)][C_STEP_NUMBER_WIDTH-1:0]),
		.req_img_tol   (req_img_tol   [`DIDX(MOTOR_RP)][C_IMG_WW-1           :0]),
		.req_img_dst   (req_img_dst   [`DIDX(MOTOR_RP)][C_IMG_WW-1           :0]),

		.img_pulse(x_ana_done ),
		.img_valid(x_rt_valid ),
		.img_pos  (x_rt_edge  ),

		.m_sel       (mr_sel       ),
		.m_zpsign    (mr_zpsign    ),
		.m_tpsign    (mr_tpsign    ),
		.m_state     (mr_state     ),
		.m_position  (mr_position  ),
		.m_start     (mr_start     ),
		.m_stop      (mr_stop      ),
		.m_speed     (mr_speed     ),
		.m_step      (mr_step      ),
		.m_dir       (mr_dir       ),
		.m_mod_remain(mr_mod_remain),
		.m_new_remain(mr_new_remain),

		//.rd_en  (bpm_reB  ),
		.rd_addr(bpm_addrB),
		.rd_data(bpm_qB   )
	);

	////////////////// x motor //////////////////////////////
	AM_ctl # (
		.C_IMG_WW(C_IMG_WW),
		.C_IMG_HW(C_IMG_HW),
		.C_STEP_NUMBER_WIDTH(C_STEP_NUMBER_WIDTH),
		.C_SPEED_DATA_WIDTH (C_SPEED_DATA_WIDTH ),
		.C_L2R(1)
	) x_motor_ctl (
		.clk          (clk   ),
		.resetn       (dev_oper_bmp[`DIDX(MOTOR_XA)]),
		.exe_done     (req_done_bmp[`DIDX(MOTOR_XA)]),

		.req_ecf       (req_ecf       [`DIDX(MOTOR_XA)]),
		.req_dir_back  (req_dir_back  [`DIDX(MOTOR_XA)]),
		.req_dep_img   (req_dep_img   [`DIDX(MOTOR_XA)]),
		.req_speed     (req_speed     [`DIDX(MOTOR_XA)][C_SPEED_DATA_WIDTH-1 :0]),
		.req_step      (req_step      [`DIDX(MOTOR_XA)][C_STEP_NUMBER_WIDTH-1:0]),
		.req_img_tol   (req_img_tol   [`DIDX(MOTOR_XA)][C_IMG_HW-1           :0]),
		.req_img_dst   (req_img_dst   [`DIDX(MOTOR_XA)][C_IMG_HW-1           :0]),

		.img_pulse   (x_ana_done),
		.img_lo_valid(x_lft_header_outer_valid),
		.img_lo_y    (x_lft_header_outer_y    ),
		.img_ro_valid(x_rt_header_outer_valid ),
		.img_ro_y    (x_rt_header_outer_y     ),
		.img_li_valid(x_lft_header_inner_valid),
		.img_li_y    (x_lft_header_inner_y    ),
		.img_ri_valid(x_rt_header_inner_valid ),
		.img_ri_y    (x_rt_header_inner_y     ),

		.m_sel       (mx_sel       ),
		.m_zpsign    (mx_zpsign    ),
		.m_tpsign    (mx_tpsign    ),
		.m_state     (mx_state     ),
		.m_position  (mx_position  ),
		.m_start     (mx_start     ),
		.m_stop      (mx_stop      ),
		.m_speed     (mx_speed     ),
		.m_step      (mx_step      ),
		.m_dir       (mx_dir       ),
		.m_mod_remain(mx_mod_remain),
		.m_new_remain(mx_new_remain),

		.m_dep_state(ml_state | mr_state | mx_state | my_state),

		//.rd_en  (bam_reA  ),
		.rd_addr(bam_addrA),
		.rd_data(bam_qA   )
	);

	////////////////// y motor //////////////////////////////
	AM_ctl # (
		.C_IMG_WW(C_IMG_WW),
		.C_IMG_HW(C_IMG_HW),
		.C_STEP_NUMBER_WIDTH(C_STEP_NUMBER_WIDTH),
		.C_SPEED_DATA_WIDTH (C_SPEED_DATA_WIDTH ),
		.C_L2R(0)
	) y_motor_ctl (
		.clk          (clk   ),
		.resetn       (dev_oper_bmp[`DIDX(MOTOR_YA)]),
		.exe_done     (req_done_bmp[`DIDX(MOTOR_YA)]),

		.req_ecf       (req_ecf       [`DIDX(MOTOR_YA)]),
		.req_dir_back  (req_dir_back  [`DIDX(MOTOR_YA)]),
		.req_dep_img   (req_dep_img   [`DIDX(MOTOR_YA)]),
		.req_speed     (req_speed     [`DIDX(MOTOR_YA)][C_SPEED_DATA_WIDTH-1 :0]),
		.req_step      (req_step      [`DIDX(MOTOR_YA)][C_STEP_NUMBER_WIDTH-1:0]),
		.req_img_tol   (req_img_tol   [`DIDX(MOTOR_YA)][C_IMG_HW-1           :0]),
		.req_img_dst   (req_img_dst   [`DIDX(MOTOR_YA)][C_IMG_HW-1           :0]),

		.img_pulse   (y_ana_done),
		.img_lo_valid(y_lft_header_outer_valid),
		.img_lo_y    (y_lft_header_outer_y    ),
		.img_ro_valid(y_rt_header_outer_valid ),
		.img_ro_y    (y_rt_header_outer_y     ),
		.img_li_valid(y_lft_header_inner_valid),
		.img_li_y    (y_lft_header_inner_y    ),
		.img_ri_valid(y_rt_header_inner_valid ),
		.img_ri_y    (y_rt_header_inner_y     ),

		.m_sel       (my_sel       ),
		.m_zpsign    (my_zpsign    ),
		.m_tpsign    (my_tpsign    ),
		.m_state     (my_state     ),
		.m_position  (my_position  ),
		.m_start     (my_start     ),
		.m_stop      (my_stop      ),
		.m_speed     (my_speed     ),
		.m_step      (my_step      ),
		.m_dir       (my_dir       ),
		.m_mod_remain(my_mod_remain),
		.m_new_remain(my_new_remain),

		.m_dep_state(ml_state | mr_state | mx_state | my_state),

		//.rd_en  (bam_reA  ),
		.rd_addr(bam_addrB),
		.rd_data(bam_qB   )
	);

	///////////////////// discharge ////////////////////////////////////////
	DISCHARGE_ctl # (
		.C_DEFAULT_VALUE(C_DISCHARGE_DEFAULT_VALUE),
		.C_PWM_CNT_WIDTH(C_DISCHARGE_PWM_CNT_WIDTH),
		.C_FRACTIONAL_WIDTH(C_DISCHARGE_FRACTIONAL_WIDTH),
		.C_NUMBER_WIDTH(C_DISCHARGE_PWM_NUM_WIDTH)
	) discharge_ctl (
		.clk          (clk   ),
		.resetn       (dev_oper_bmp[`DIDX(DISCHARGE)]),
		.exe_done     (req_done_bmp[`DIDX(DISCHARGE)]),

		.denominator  (cfg_discharge_denominator),
		.numerator0   (discharge_numerator0),
		.numerator1   (discharge_numerator1),
		.number0      (discharge_number0),
		.number1      (discharge_number1),
		.inc0         (discharge_inc0),

		.drive        (discharge_drive)
	);

endmodule
