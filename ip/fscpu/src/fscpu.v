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

	output wire                           mlp_sel     ,
	input  wire                           mlp_zpsign  ,
	input  wire                           mlp_tpsign  ,
	input  wire                           mlp_state   ,
	input  wire [C_SPEED_DATA_WIDTH-1:0]  mlp_rt_speed,
	input  wire [C_STEP_NUMBER_WIDTH-1:0] mlp_position,
	output wire                           mlp_start   ,
	output wire                           mlp_stop    ,
	output wire [C_SPEED_DATA_WIDTH-1:0]  mlp_speed   ,
	output wire [C_STEP_NUMBER_WIDTH-1:0] mlp_step    ,
	output wire                           mlp_dir     ,
	output wire                           mlp_mod_remain,
	output wire [C_STEP_NUMBER_WIDTH-1:0] mlp_new_remain,

	output wire                           mrp_sel     ,
	input  wire                           mrp_zpsign  ,
	input  wire                           mrp_tpsign  ,
	input  wire                           mrp_state   ,
	input  wire [C_SPEED_DATA_WIDTH-1:0]  mrp_rt_speed,
	input  wire [C_STEP_NUMBER_WIDTH-1:0] mrp_position,
	output wire                           mrp_start   ,
	output wire                           mrp_stop    ,
	output wire [C_SPEED_DATA_WIDTH-1:0]  mrp_speed   ,
	output wire [C_STEP_NUMBER_WIDTH-1:0] mrp_step    ,
	output wire                           mrp_dir     ,
	output wire                           mrp_mod_remain,
	output wire [C_STEP_NUMBER_WIDTH-1:0] mrp_new_remain,

	output wire                           mxa_sel     ,
	input  wire                           mxa_zpsign  ,
	input  wire                           mxa_tpsign  ,
	input  wire                           mxa_state   ,
	input  wire [C_SPEED_DATA_WIDTH-1:0]  mxa_rt_speed,
	input  wire [C_STEP_NUMBER_WIDTH-1:0] mxa_position,
	output wire                           mxa_start   ,
	output wire                           mxa_stop    ,
	output wire [C_SPEED_DATA_WIDTH-1:0]  mxa_speed   ,
	output wire [C_STEP_NUMBER_WIDTH-1:0] mxa_step    ,
	output wire                           mxa_dir     ,
	output wire                           mxa_mod_remain,
	output wire [C_STEP_NUMBER_WIDTH-1:0] mxa_new_remain,

	output wire                           mya_sel     ,
	input  wire                           mya_zpsign  ,
	input  wire                           mya_tpsign  ,
	input  wire                           mya_state   ,
	input  wire [C_SPEED_DATA_WIDTH-1:0]  mya_rt_speed,
	input  wire [C_STEP_NUMBER_WIDTH-1:0] mya_position,
	output wire                           mya_start   ,
	output wire                           mya_stop    ,
	output wire [C_SPEED_DATA_WIDTH-1:0]  mya_speed   ,
	output wire [C_STEP_NUMBER_WIDTH-1:0] mya_step    ,
	output wire                           mya_dir     ,
	output wire                           mya_mod_remain,
	output wire [C_STEP_NUMBER_WIDTH-1:0] mya_new_remain,

	output wire                           mlr_sel     ,
	input  wire                           mlr_zpsign  ,
	input  wire                           mlr_tpsign  ,
	input  wire                           mlr_state   ,
	input  wire [C_SPEED_DATA_WIDTH-1:0]  mlr_rt_speed,
	input  wire [C_STEP_NUMBER_WIDTH-1:0] mlr_position,
	output wire                           mlr_start   ,
	output wire                           mlr_stop    ,
	output wire [C_SPEED_DATA_WIDTH-1:0]  mlr_speed   ,
	output wire [C_STEP_NUMBER_WIDTH-1:0] mlr_step    ,
	output wire                           mlr_dir     ,
	output wire                           mlr_mod_remain,
	output wire [C_STEP_NUMBER_WIDTH-1:0] mlr_new_remain,

	output wire                           mrr_sel     ,
	input  wire                           mrr_zpsign  ,
	input  wire                           mrr_tpsign  ,
	input  wire                           mrr_state   ,
	input  wire [C_SPEED_DATA_WIDTH-1:0]  mrr_rt_speed,
	input  wire [C_STEP_NUMBER_WIDTH-1:0] mrr_position,
	output wire                           mrr_start   ,
	output wire                           mrr_stop    ,
	output wire [C_SPEED_DATA_WIDTH-1:0]  mrr_speed   ,
	output wire [C_STEP_NUMBER_WIDTH-1:0] mrr_step    ,
	output wire                           mrr_dir     ,
	output wire                           mrr_mod_remain,
	output wire [C_STEP_NUMBER_WIDTH-1:0] mrr_new_remain,

	output wire                           discharge_resetn,
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
	reg        req_wait_push [`DIDX(MOTOR_RR):`DIDX(MOTOR_LP)];	// par0[4]
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
				req_wait_push [i] <= 0;
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
				req_wait_push [i] <= req_par0[4];
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

		.m_sel       (mlp_sel       ),
		.m_zpsign    (mlp_zpsign    ),
		.m_tpsign    (mlp_tpsign    ),
		.m_state     (mlp_state     ),
		.m_position  (mlp_position  ),
		.m_start     (mlp_start     ),
		.m_stop      (mlp_stop      ),
		.m_speed     (mlp_speed     ),
		.m_step      (mlp_step      ),
		.m_dir       (mlp_dir       ),
		.m_mod_remain(mlp_mod_remain),
		.m_new_remain(mlp_new_remain),

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

		.m_sel       (mrp_sel       ),
		.m_zpsign    (mrp_zpsign    ),
		.m_tpsign    (mrp_tpsign    ),
		.m_state     (mrp_state     ),
		.m_position  (mrp_position  ),
		.m_start     (mrp_start     ),
		.m_stop      (mrp_stop      ),
		.m_speed     (mrp_speed     ),
		.m_step      (mrp_step      ),
		.m_dir       (mrp_dir       ),
		.m_mod_remain(mrp_mod_remain),
		.m_new_remain(mrp_new_remain),

		//.rd_en  (bpm_reB  ),
		.rd_addr(bpm_addrB),
		.rd_data(bpm_qB   )
	);

	wire push_done;
	assign push_done = (~dev_oper_bmp[`DIDX(MOTOR_LP)] || req_done_bmp[`DIDX(MOTOR_LP)])
		&& (~dev_oper_bmp[`DIDX(MOTOR_RP)] || req_done_bmp[`DIDX(MOTOR_RP)]);
	////////////////// x motor //////////////////////////////
	AM_ctl # (
		.C_IMG_WW(C_IMG_WW),
		.C_IMG_HW(C_IMG_HW),
		.C_STEP_NUMBER_WIDTH(C_STEP_NUMBER_WIDTH),
		.C_SPEED_DATA_WIDTH (C_SPEED_DATA_WIDTH ),
		.C_L2R(1)
	) x_motor_ctl (
		.clk          (clk   ),
		.resetn       (dev_oper_bmp[`DIDX(MOTOR_XA)] && (~req_wait_push[`DIDX(MOTOR_XA)] || push_done)),
		.exe_done     (req_done_bmp[`DIDX(MOTOR_XA)]),

		.req_ecf       (req_ecf       [`DIDX(MOTOR_XA)]),
		.req_dir_back  (req_dir_back  [`DIDX(MOTOR_XA)]),
		.req_dep_img   (req_dep_img   [`DIDX(MOTOR_XA)]),
		.req_speed     (req_speed     [`DIDX(MOTOR_XA)][C_SPEED_DATA_WIDTH-1 :0]),
		.req_step      (req_step      [`DIDX(MOTOR_XA)][C_STEP_NUMBER_WIDTH-1:0]),
		.req_img_tol   (req_img_tol   [`DIDX(MOTOR_XA)][C_IMG_HW-1           :0]),
		.req_img_dst   (req_img_dst   [`DIDX(MOTOR_XA)][C_IMG_HW-1           :0]),

		.img_pulse   (x_ana_done),
		.img_l_valid (y_lft_valid),
		.img_r_valid (y_rt_valid),
		.img_lo_valid(x_lft_header_outer_valid),
		.img_lo_y    (x_lft_header_outer_y    ),
		.img_ro_valid(x_rt_header_outer_valid ),
		.img_ro_y    (x_rt_header_outer_y     ),
		.img_li_valid(x_lft_header_inner_valid),
		.img_li_y    (x_lft_header_inner_y    ),
		.img_ri_valid(x_rt_header_inner_valid ),
		.img_ri_y    (x_rt_header_inner_y     ),

		.m_sel       (mxa_sel       ),
		.m_zpsign    (mxa_zpsign    ),
		.m_tpsign    (mxa_tpsign    ),
		.m_state     (mxa_state     ),
		.m_position  (mxa_position  ),
		.m_start     (mxa_start     ),
		.m_stop      (mxa_stop      ),
		.m_speed     (mxa_speed     ),
		.m_step      (mxa_step      ),
		.m_dir       (mxa_dir       ),
		.m_mod_remain(mxa_mod_remain),
		.m_new_remain(mxa_new_remain),

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
		.resetn       (dev_oper_bmp[`DIDX(MOTOR_YA)] && (~req_wait_push[`DIDX(MOTOR_YA)] || push_done)),
		.exe_done     (req_done_bmp[`DIDX(MOTOR_YA)]),

		.req_ecf       (req_ecf       [`DIDX(MOTOR_YA)]),
		.req_dir_back  (req_dir_back  [`DIDX(MOTOR_YA)]),
		.req_dep_img   (req_dep_img   [`DIDX(MOTOR_YA)]),
		.req_speed     (req_speed     [`DIDX(MOTOR_YA)][C_SPEED_DATA_WIDTH-1 :0]),
		.req_step      (req_step      [`DIDX(MOTOR_YA)][C_STEP_NUMBER_WIDTH-1:0]),
		.req_img_tol   (req_img_tol   [`DIDX(MOTOR_YA)][C_IMG_HW-1           :0]),
		.req_img_dst   (req_img_dst   [`DIDX(MOTOR_YA)][C_IMG_HW-1           :0]),

		.img_pulse   (y_ana_done),
		.img_l_valid (y_lft_valid),
		.img_r_valid (y_rt_valid),
		.img_lo_valid(y_lft_header_outer_valid),
		.img_lo_y    (y_lft_header_outer_y    ),
		.img_ro_valid(y_rt_header_outer_valid ),
		.img_ro_y    (y_rt_header_outer_y     ),
		.img_li_valid(y_lft_header_inner_valid),
		.img_li_y    (y_lft_header_inner_y    ),
		.img_ri_valid(y_rt_header_inner_valid ),
		.img_ri_y    (y_rt_header_inner_y     ),

		.m_sel       (mya_sel       ),
		.m_zpsign    (mya_zpsign    ),
		.m_tpsign    (mya_tpsign    ),
		.m_state     (mya_state     ),
		.m_position  (mya_position  ),
		.m_start     (mya_start     ),
		.m_stop      (mya_stop      ),
		.m_speed     (mya_speed     ),
		.m_step      (mya_step      ),
		.m_dir       (mya_dir       ),
		.m_mod_remain(mya_mod_remain),
		.m_new_remain(mya_new_remain),

		.m_dep_state(ml_state | mr_state | mx_state | my_state),

		//.rd_en  (bam_reA  ),
		.rd_addr(bam_addrB),
		.rd_data(bam_qB   )
	);

	////////////////// left rotate motor //////////////////////////////
	RM_ctl # (
		.C_STEP_NUMBER_WIDTH(C_STEP_NUMBER_WIDTH),
		.C_SPEED_DATA_WIDTH (C_SPEED_DATA_WIDTH )
	) lr_motor_ctl (
		.clk          (clk   ),
		.resetn       (dev_oper_bmp[`DIDX(MOTOR_LR)]),
		.exe_done     (req_done_bmp[`DIDX(MOTOR_LR)]),

		.req_dir_back  (req_dir_back  [`DIDX(MOTOR_LR)]),
		.req_speed     (req_speed     [`DIDX(MOTOR_LR)][C_SPEED_DATA_WIDTH-1 :0]),
		.req_step      (req_step      [`DIDX(MOTOR_LR)][C_STEP_NUMBER_WIDTH-1:0]),

		.m_sel       (mlr_sel       ),
		.m_zpsign    (mlr_zpsign    ),
		.m_tpsign    (mlr_tpsign    ),
		.m_state     (mlr_state     ),
		.m_position  (mlr_position  ),
		.m_start     (mlr_start     ),
		.m_stop      (mlr_stop      ),
		.m_speed     (mlr_speed     ),
		.m_step      (mlr_step      ),
		.m_dir       (mlr_dir       ),
		.m_mod_remain(mlr_mod_remain),
		.m_new_remain(mlr_new_remain)
	);

	////////////////// right rotate motor //////////////////////////////
	RM_ctl # (
		.C_STEP_NUMBER_WIDTH(C_STEP_NUMBER_WIDTH),
		.C_SPEED_DATA_WIDTH (C_SPEED_DATA_WIDTH )
	) rr_motor_ctl (
		.clk          (clk   ),
		.resetn       (dev_oper_bmp[`DIDX(MOTOR_RR)]),
		.exe_done     (req_done_bmp[`DIDX(MOTOR_RR)]),

		.req_dir_back  (req_dir_back  [`DIDX(MOTOR_RR)]),
		.req_speed     (req_speed     [`DIDX(MOTOR_RR)][C_SPEED_DATA_WIDTH-1 :0]),
		.req_step      (req_step      [`DIDX(MOTOR_RR)][C_STEP_NUMBER_WIDTH-1:0]),

		.m_sel       (mrr_sel       ),
		.m_zpsign    (mrr_zpsign    ),
		.m_tpsign    (mrr_tpsign    ),
		.m_state     (mrr_state     ),
		.m_position  (mrr_position  ),
		.m_start     (mrr_start     ),
		.m_stop      (mrr_stop      ),
		.m_speed     (mrr_speed     ),
		.m_step      (mrr_step      ),
		.m_dir       (mrr_dir       ),
		.m_mod_remain(mrr_mod_remain),
		.m_new_remain(mrr_new_remain)
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

		.o_resetn     (discharge_resetn),
		.drive        (discharge_drive)
	);

endmodule
