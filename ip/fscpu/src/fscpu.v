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
	input  wire [159:0] req_param,
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

	output wire                                  mlp_sel     ,
	input  wire                                  mlp_ntsign  ,
	input  wire                                  mlp_zpsign  ,
	input  wire                                  mlp_ptsign  ,
	input  wire                                  mlp_state   ,
	input  wire [C_SPEED_DATA_WIDTH-1:0]         mlp_rt_speed,
	input  wire                                  mlp_rt_dir  ,
	input  wire signed [C_STEP_NUMBER_WIDTH-1:0] mlp_position,
	output wire                                  mlp_start   ,
	output wire                                  mlp_stop    ,
	output wire [C_SPEED_DATA_WIDTH-1:0]         mlp_speed   ,
	output wire signed [C_STEP_NUMBER_WIDTH-1:0] mlp_step    ,
	output wire                                  mlp_abs     ,
	output wire                                  mlp_mod_remain,
	output wire signed [C_STEP_NUMBER_WIDTH-1:0] mlp_new_remain,

	output wire                                  mrp_sel     ,
	input  wire                                  mrp_ntsign  ,
	input  wire                                  mrp_zpsign  ,
	input  wire                                  mrp_ptsign  ,
	input  wire                                  mrp_state   ,
	input  wire [C_SPEED_DATA_WIDTH-1:0]         mrp_rt_speed,
	input  wire                                  mrp_rt_dir  ,
	input  wire signed [C_STEP_NUMBER_WIDTH-1:0] mrp_position,
	output wire                                  mrp_start   ,
	output wire                                  mrp_stop    ,
	output wire [C_SPEED_DATA_WIDTH-1:0]         mrp_speed   ,
	output wire signed [C_STEP_NUMBER_WIDTH-1:0] mrp_step    ,
	output wire                                  mrp_abs     ,
	output wire                                  mrp_mod_remain,
	output wire signed [C_STEP_NUMBER_WIDTH-1:0] mrp_new_remain,

	output wire                                  mxa_sel     ,
	input  wire                                  mxa_ntsign  ,
	input  wire                                  mxa_zpsign  ,
	input  wire                                  mxa_ptsign  ,
	input  wire                                  mxa_state   ,
	input  wire [C_SPEED_DATA_WIDTH-1:0]         mxa_rt_speed,
	input  wire                                  mxa_rt_dir  ,
	input  wire signed [C_STEP_NUMBER_WIDTH-1:0] mxa_position,
	output wire                                  mxa_start   ,
	output wire                                  mxa_stop    ,
	output wire [C_SPEED_DATA_WIDTH-1:0]         mxa_speed   ,
	output wire signed [C_STEP_NUMBER_WIDTH-1:0] mxa_step    ,
	output wire                                  mxa_abs     ,
	output wire                                  mxa_mod_remain,
	output wire signed [C_STEP_NUMBER_WIDTH-1:0] mxa_new_remain,

	output wire                                  mya_sel     ,
	input  wire                                  mya_ntsign  ,
	input  wire                                  mya_zpsign  ,
	input  wire                                  mya_ptsign  ,
	input  wire                                  mya_state   ,
	input  wire [C_SPEED_DATA_WIDTH-1:0]         mya_rt_speed,
	input  wire                                  mya_rt_dir  ,
	input  wire signed [C_STEP_NUMBER_WIDTH-1:0] mya_position,
	output wire                                  mya_start   ,
	output wire                                  mya_stop    ,
	output wire [C_SPEED_DATA_WIDTH-1:0]         mya_speed   ,
	output wire signed [C_STEP_NUMBER_WIDTH-1:0] mya_step    ,
	output wire                                  mya_abs     ,
	output wire                                  mya_mod_remain,
	output wire signed [C_STEP_NUMBER_WIDTH-1:0] mya_new_remain,

	output wire                                  mlr_sel     ,
	input  wire                                  mlr_ntsign  ,
	input  wire                                  mlr_zpsign  ,
	input  wire                                  mlr_ptsign  ,
	input  wire                                  mlr_state   ,
	input  wire [C_SPEED_DATA_WIDTH-1:0]         mlr_rt_speed,
	input  wire                                  mlr_rt_dir  ,
	input  wire signed [C_STEP_NUMBER_WIDTH-1:0] mlr_position,
	output wire                                  mlr_start   ,
	output wire                                  mlr_stop    ,
	output wire [C_SPEED_DATA_WIDTH-1:0]         mlr_speed   ,
	output wire signed [C_STEP_NUMBER_WIDTH-1:0] mlr_step    ,
	output wire                                  mlr_abs     ,
	output wire                                  mlr_mod_remain,
	output wire signed [C_STEP_NUMBER_WIDTH-1:0] mlr_new_remain,

	output wire                                  mrr_sel     ,
	input  wire                                  mrr_ntsign  ,
	input  wire                                  mrr_zpsign  ,
	input  wire                                  mrr_ptsign  ,
	input  wire                                  mrr_state   ,
	input  wire [C_SPEED_DATA_WIDTH-1:0]         mrr_rt_speed,
	input  wire                                  mrr_rt_dir  ,
	input  wire signed [C_STEP_NUMBER_WIDTH-1:0] mrr_position,
	output wire                                  mrr_start   ,
	output wire                                  mrr_stop    ,
	output wire [C_SPEED_DATA_WIDTH-1:0]         mrr_speed   ,
	output wire signed [C_STEP_NUMBER_WIDTH-1:0] mrr_step    ,
	output wire                                  mrr_abs     ,
	output wire                                  mrr_mod_remain,
	output wire signed [C_STEP_NUMBER_WIDTH-1:0] mrr_new_remain,

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
	localparam integer REQ_UPDATE_DIST = 28;
	localparam integer REQ_CFG       = 29;
	localparam integer REQ_EXE       = 30;
	localparam integer REQ_STOP      = 31;

	wire [31:0] req_par0;	assign req_par0 = req_param[ 31: 0];
	wire [31:0] req_par1;	assign req_par1 = req_param[ 63:32];
	wire [31:0] req_par2;	assign req_par2 = req_param[ 95:64];
	wire [31:0] req_par3;	assign req_par3 = req_param[127:96];
	wire [31:0] req_par4;	assign req_par4 = req_param[159:128];

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
	reg        req_abs       [`DIDX(MOTOR_RR):`DIDX(MOTOR_LP)];	// par0[1]
	reg        req_dep_img   [`DIDX(MOTOR_RR):`DIDX(MOTOR_LP)];	// par0[2]
	reg        req_ecf       [`DIDX(MOTOR_RR):`DIDX(MOTOR_LP)];	// par0[3]
	reg        req_wait_push [`DIDX(MOTOR_RR):`DIDX(MOTOR_LP)];	// par0[4]
	reg        req_sw_img    [`DIDX(MOTOR_RR):`DIDX(MOTOR_LP)];	// par0[5]
	reg [`DIDX(MOTOR_RR):`DIDX(MOTOR_LP)] req_can_ignore;	// par0[6]
	reg [31:0] req_speed     [`DIDX(MOTOR_RR):`DIDX(MOTOR_LP)];	// par1[C_SPEED_DATA_WIDTH-1 : 0]
	reg signed [31:0] req_step      [`DIDX(MOTOR_RR):`DIDX(MOTOR_LP)];	// par2[C_STEP_NUMBER_WIDTH-1: 0]
	reg [15:0] req_img_tol   [`DIDX(MOTOR_RR):`DIDX(MOTOR_LP)];	// par3[C_IMG_WW-1+16 : 16]
	reg [15:0] req_img_dst   [`DIDX(MOTOR_RR):`DIDX(MOTOR_LP)];	// par3[C_IMG_WW-1 : 0]
	reg [31:0] req_delay_push[`DIDX(MOTOR_RR):`DIDX(MOTOR_LP)];	// par4[31: 0]
	reg        req_delay_resetn[`DIDX(MOTOR_RR):`DIDX(MOTOR_LP)];
generate
	genvar i;
	for (i = DBIT_MOTOR_LP; i <= DBIT_MOTOR_RR; i=i+1) begin : record_motor_params
		always @ (posedge clk) begin
			if (resetn == 1'b0) begin
				req_single_dir[i] <= 0;
				req_abs       [i] <= 0;
				req_dep_img   [i] <= 0;
				req_ecf       [i] <= 0;
				req_wait_push [i] <= 0;
				req_sw_img    [i] <= 0;
				req_can_ignore[i] <= 0;
				req_speed     [i] <= 0;
				req_step      [i] <= 0;
				req_img_tol   [i] <= 0;
				req_img_dst   [i] <= 0;
				req_delay_push[i] <= 0;
				req_delay_resetn[i] <= 0;
			end
			else if (req_en && (req_cmd == i)) begin
				req_single_dir[i] <= req_par0[0];
				req_abs       [i] <= req_par0[1];
				req_dep_img   [i] <= req_par0[2];
				req_ecf       [i] <= req_par0[3];
				req_wait_push [i] <= req_par0[4];
				req_sw_img    [i] <= req_par0[5];
				req_can_ignore[i] <= req_par0[6];
				req_speed     [i] <= req_par1;
				req_step      [i] <= req_par2;
				req_img_tol   [i] <= req_par3[31:16];
				req_img_dst   [i] <= req_par3[15: 0];
				req_delay_push[i] <= req_par4[31:0];
				req_delay_resetn[i] <= (req_par4[31:0] == 0);
			end
			else begin
				if (req_delay_push[i] != 0)
					req_delay_push[i] <= req_delay_push[i] - 1;
				if (req_delay_push[i] == 1)
					req_delay_resetn[i] <= 1;
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

	///////////////////////////// update dist by software ////////////////////generate
	reg sw_img_pulse[`DIDX(MOTOR_YA):`DIDX(MOTOR_XA)];
	reg [C_STEP_NUMBER_WIDTH-1:0] sw_img_step[`DIDX(MOTOR_YA):`DIDX(MOTOR_XA)];
	reg sw_img_ok[`DIDX(MOTOR_YA):`DIDX(MOTOR_XA)];
generate
	for (i = DBIT_MOTOR_XA; i <= DBIT_MOTOR_YA; i=i+1) begin : accept_sw_img_info
		always @ (posedge clk) begin
			if (resetn == 1'b0) begin
				sw_img_pulse[i] <= 0;
				sw_img_step [i] <= 0;
				sw_img_ok   [i] <= 0;
			end
			else if (req_en && (req_cmd == REQ_UPDATE_DIST) && (req_par0 == i)) begin
				sw_img_pulse[i] <= 1'b1;
				sw_img_ok   [i] <= req_par1[0];
				sw_img_step [i] <= req_par2[C_STEP_NUMBER_WIDTH-1:0];
			end
			else begin
				sw_img_pulse[i] <= 0;
			end
		end
	end
endgenerate
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
		.resetn       (dev_oper_bmp[`DIDX(MOTOR_LP)] && req_delay_resetn[`DIDX(MOTOR_LP)]),
		.exe_done     (req_done_bmp[`DIDX(MOTOR_LP)]),

		.img_delay_cnt(cfg_img_delay_cnt),
		.img_delay_frm(cfg_img_delay_frm),

		.req_single_dir(req_single_dir[`DIDX(MOTOR_LP)]),
		.req_abs       (req_abs       [`DIDX(MOTOR_LP)]),
		.req_dep_img   (req_dep_img   [`DIDX(MOTOR_LP)]),
		.req_speed     (req_speed     [`DIDX(MOTOR_LP)][C_SPEED_DATA_WIDTH-1 :0]),
		.req_step      (req_step      [`DIDX(MOTOR_LP)][C_STEP_NUMBER_WIDTH-1:0]),
		.req_img_tol   (req_img_tol   [`DIDX(MOTOR_LP)][C_IMG_WW-1           :0]),
		.req_img_dst   (req_img_dst   [`DIDX(MOTOR_LP)][C_IMG_WW-1           :0]),

		.img_pulse(x_ana_done ),
		.img_valid(x_lft_valid),
		.img_pos  (x_lft_edge ),

		.m_sel       (mlp_sel       ),
		.m_ntsign    (mlp_ntsign    ),
		.m_zpsign    (mlp_zpsign    ),
		.m_ptsign    (mlp_ptsign    ),
		.m_state     (mlp_state     ),
		.m_position  (mlp_position  ),
		.m_start     (mlp_start     ),
		.m_stop      (mlp_stop      ),
		.m_speed     (mlp_speed     ),
		.m_step      (mlp_step      ),
		.m_abs       (mlp_abs       ),
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
		.resetn       (dev_oper_bmp[`DIDX(MOTOR_RP)] && req_delay_resetn[`DIDX(MOTOR_RP)]),
		.exe_done     (req_done_bmp[`DIDX(MOTOR_RP)]),

		.img_delay_cnt(cfg_img_delay_cnt),
		.img_delay_frm(cfg_img_delay_frm),

		.req_single_dir(req_single_dir[`DIDX(MOTOR_RP)]),
		.req_abs       (req_abs       [`DIDX(MOTOR_RP)]),
		.req_dep_img   (req_dep_img   [`DIDX(MOTOR_RP)]),
		.req_speed     (req_speed     [`DIDX(MOTOR_RP)][C_SPEED_DATA_WIDTH-1 :0]),
		.req_step      (req_step      [`DIDX(MOTOR_RP)][C_STEP_NUMBER_WIDTH-1:0]),
		.req_img_tol   (req_img_tol   [`DIDX(MOTOR_RP)][C_IMG_WW-1           :0]),
		.req_img_dst   (req_img_dst   [`DIDX(MOTOR_RP)][C_IMG_WW-1           :0]),

		.img_pulse(x_ana_done ),
		.img_valid(x_rt_valid ),
		.img_pos  (x_rt_edge  ),

		.m_sel       (mrp_sel       ),
		.m_ntsign    (mrp_ntsign    ),
		.m_zpsign    (mrp_zpsign    ),
		.m_ptsign    (mrp_ptsign    ),
		.m_state     (mrp_state     ),
		.m_position  (mrp_position  ),
		.m_start     (mrp_start     ),
		.m_stop      (mrp_stop      ),
		.m_speed     (mrp_speed     ),
		.m_step      (mrp_step      ),
		.m_abs       (mrp_abs       ),
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
	wire mxa_resetn;
	assign mxa_resetn = (dev_oper_bmp[`DIDX(MOTOR_XA)] && (~req_wait_push[`DIDX(MOTOR_XA)] || push_done));
	wire mxa_dep_state;
	assign mxa_dep_state = (mlp_state | mrp_state | mxa_state | mya_state);
	
	wire mxa_img_pulse[1:0];
	wire signed [C_STEP_NUMBER_WIDTH-1:0] mxa_img_step[1:0];
	wire mxa_img_ok[1:0];
	wire mxa_img_should_start[1:0];
	AM_img # (
		.C_IMG_WW(C_IMG_WW),
		.C_IMG_HW(C_IMG_HW),
		.C_STEP_NUMBER_WIDTH(C_STEP_NUMBER_WIDTH),
		.C_L2R(1)
	) hw_x_img2step (
		.clk          (clk   ),
		.resetn       (mxa_resetn),

		.done_if_img_invalid(req_can_ignore[`DIDX(MOTOR_XA)]),

		.req_ecf       (req_ecf    [`DIDX(MOTOR_XA)]),
		.req_dep_img   (req_dep_img[`DIDX(MOTOR_XA)]),
		.req_img_tol   (req_img_tol[`DIDX(MOTOR_XA)][C_IMG_HW-1:0]),
		.req_img_dst   (req_img_dst[`DIDX(MOTOR_XA)][C_IMG_HW-1:0]),

		.img_pulse   (x_ana_done),
		.img_l_valid (x_lft_valid),
		.img_r_valid (x_rt_valid),
		.img_lo_valid(x_lft_header_outer_valid),
		.img_lo_y    (x_lft_header_outer_y    ),
		.img_ro_valid(x_rt_header_outer_valid ),
		.img_ro_y    (x_rt_header_outer_y     ),
		.img_li_valid(x_lft_header_inner_valid),
		.img_li_y    (x_lft_header_inner_y    ),
		.img_ri_valid(x_rt_header_inner_valid ),
		.img_ri_y    (x_rt_header_inner_y     ),

		.m_state     (mxa_state),
		.m_dep_state (mxa_dep_state),

		//.rd_en  (bam_reA  ),
		.rd_addr(bam_addrA),
		.rd_data(bam_qA),

		.o_pulse       (mxa_img_pulse[0]),
		.o_step        (mxa_img_step [0]),
		.o_ok          (mxa_img_ok   [0]),
		.o_should_start(mxa_img_should_start[0])
	);
	AM_sw_img # (
		.C_STEP_NUMBER_WIDTH(C_STEP_NUMBER_WIDTH)
	) sw_x_img2step (
		.clk          (clk   ),
		.resetn       (mxa_resetn),

		.req_dep_img   (req_sw_img[`DIDX(MOTOR_XA)]),

		.img_pulse(sw_img_pulse[`DIDX(MOTOR_XA)]),
		.img_step (sw_img_step [`DIDX(MOTOR_XA)]),
		.img_ok   (sw_img_ok   [`DIDX(MOTOR_XA)]),

		.m_state     (mxa_state),
		.m_dep_state (mxa_dep_state),

		.o_pulse       (mxa_img_pulse[1]),
		.o_step        (mxa_img_step [1]),
		.o_ok          (mxa_img_ok   [1]),
		.o_should_start(mxa_img_should_start[1])
	);
	
	wire mxa_final_img_pulse;
	wire signed [C_STEP_NUMBER_WIDTH-1:0] mxa_final_img_step;
	wire mxa_final_img_ok;
	wire mxa_final_img_should_start;
	AM_sel_img # (
		.C_STEP_NUMBER_WIDTH(C_STEP_NUMBER_WIDTH)
	) sel_x_img2step (
		.clk (clk),
		.resetn (mxa_resetn),

		.i0_pulse(mxa_img_pulse[0]),
		.i0_step (mxa_img_step [0]),
		.i0_ok   (mxa_img_ok   [0]),
		.i0_should_start(mxa_img_should_start[0]),

		.i1_pulse(mxa_img_pulse[1]),
		.i1_step (mxa_img_step [1]),
		.i1_ok   (mxa_img_ok   [1]),
		.i1_should_start(mxa_img_should_start[1]),
		
		.o_pulse(mxa_final_img_pulse),
		.o_step (mxa_final_img_step),
		.o_ok   (mxa_final_img_ok),
		.o_should_start(mxa_final_img_should_start)
	);

	AM_ctl # (
		.C_STEP_NUMBER_WIDTH(C_STEP_NUMBER_WIDTH),
		.C_SPEED_DATA_WIDTH (C_SPEED_DATA_WIDTH )
	) x_motor_ctl (
		.clk          (clk   ),
		.resetn       (mxa_resetn),
		.exe_done     (req_done_bmp[`DIDX(MOTOR_XA)]),

		.req_abs       (req_abs       [`DIDX(MOTOR_XA)]),
		.req_dep_img   (req_dep_img   [`DIDX(MOTOR_XA)] | req_sw_img   [`DIDX(MOTOR_XA)]),
		.req_speed     (req_speed     [`DIDX(MOTOR_XA)][C_SPEED_DATA_WIDTH-1 :0]),
		.req_step      (req_step      [`DIDX(MOTOR_XA)][C_STEP_NUMBER_WIDTH-1:0]),

		.m_sel       (mxa_sel       ),
		.m_ntsign    (mxa_ntsign    ),
		.m_zpsign    (mxa_zpsign    ),
		.m_ptsign    (mxa_ptsign    ),
		.m_state     (mxa_state     ),
		.m_rt_dir    (mxa_rt_dir    ),
		.m_position  (mxa_position  ),
		.m_start     (mxa_start     ),
		.m_stop      (mxa_stop      ),
		.m_speed     (mxa_speed     ),
		.m_step      (mxa_step      ),
		.m_abs       (mxa_abs       ),
		.m_mod_remain(mxa_mod_remain),
		.m_new_remain(mxa_new_remain),

		.m_dep_state(mxa_dep_state),

		.img_pulse       (mxa_final_img_pulse),
		.img_step        (mxa_final_img_step),
		.img_ok          (mxa_final_img_ok),
		.img_should_start(mxa_final_img_should_start)
	);

	////////////////// y motor //////////////////////////////
	wire mya_resetn;
	assign mya_resetn = (dev_oper_bmp[`DIDX(MOTOR_YA)] && (~req_wait_push[`DIDX(MOTOR_YA)] || push_done));
	wire mya_dep_state;
	assign mya_dep_state = (mlp_state | mrp_state | mxa_state | mya_state);

	wire mya_img_pulse[1:0];
	wire signed [C_STEP_NUMBER_WIDTH-1:0] mya_img_step[1:0];
	wire mya_img_ok[1:0];
	wire mya_img_should_start[1:0];

	AM_img # (
		.C_IMG_WW(C_IMG_WW),
		.C_IMG_HW(C_IMG_HW),
		.C_STEP_NUMBER_WIDTH(C_STEP_NUMBER_WIDTH),
		.C_L2R(0)
	) hw_y_img2step (
		.clk          (clk   ),
		.resetn       (mya_resetn),

		.done_if_img_invalid(req_can_ignore[`DIDX(MOTOR_YA)]),

		.req_ecf       (req_ecf    [`DIDX(MOTOR_YA)]),
		.req_dep_img   (req_dep_img[`DIDX(MOTOR_YA)]),
		.req_img_tol   (req_img_tol[`DIDX(MOTOR_YA)][C_IMG_HW-1:0]),
		.req_img_dst   (req_img_dst[`DIDX(MOTOR_YA)][C_IMG_HW-1:0]),

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

		.m_state     (mya_state),
		.m_dep_state (mya_dep_state),

		//.rd_en  (bam_reA  ),
		.rd_addr(bam_addrB),
		.rd_data(bam_qB),

		.o_pulse       (mya_img_pulse[0]),
		.o_step        (mya_img_step [0]),
		.o_ok          (mya_img_ok   [0]),
		.o_should_start(mya_img_should_start[0])
	);
	AM_sw_img # (
		.C_STEP_NUMBER_WIDTH(C_STEP_NUMBER_WIDTH)
	) sw_y_img2step (
		.clk          (clk   ),
		.resetn       (mya_resetn),

		.req_dep_img   (req_sw_img[`DIDX(MOTOR_YA)]),

		.img_pulse(sw_img_pulse[`DIDX(MOTOR_YA)]),
		.img_step (sw_img_step [`DIDX(MOTOR_YA)]),
		.img_ok   (sw_img_ok   [`DIDX(MOTOR_YA)]),

		.m_state     (mya_state),
		.m_dep_state (mya_dep_state),

		.o_pulse       (mya_img_pulse[1]),
		.o_step        (mya_img_step [1]),
		.o_ok          (mya_img_ok   [1]),
		.o_should_start(mya_img_should_start[1])
	);
	
	wire mya_final_img_pulse;
	wire signed [C_STEP_NUMBER_WIDTH-1:0] mya_final_img_step;
	wire mya_final_img_ok;
	wire mya_final_img_should_start;
	AM_sel_img # (
		.C_STEP_NUMBER_WIDTH(C_STEP_NUMBER_WIDTH)
	) sel_y_img2step (
		.clk (clk),
		.resetn (mya_resetn),

		.i0_pulse(mya_img_pulse[0]),
		.i0_step (mya_img_step [0]),
		.i0_ok   (mya_img_ok   [0]),
		.i0_should_start(mya_img_should_start[0]),

		.i1_pulse(mya_img_pulse[1]),
		.i1_step (mya_img_step [1]),
		.i1_ok   (mya_img_ok   [1]),
		.i1_should_start(mya_img_should_start[1]),
		
		.o_pulse(mya_final_img_pulse),
		.o_step (mya_final_img_step),
		.o_ok   (mya_final_img_ok),
		.o_should_start(mya_final_img_should_start)
	);

	AM_ctl # (
		.C_STEP_NUMBER_WIDTH(C_STEP_NUMBER_WIDTH),
		.C_SPEED_DATA_WIDTH (C_SPEED_DATA_WIDTH )
	) y_motor_ctl (
		.clk          (clk   ),
		.resetn       (mya_resetn),
		.exe_done     (req_done_bmp[`DIDX(MOTOR_YA)]),

		.req_abs       (req_abs       [`DIDX(MOTOR_YA)]),
		.req_dep_img   (req_dep_img   [`DIDX(MOTOR_YA)] | req_sw_img   [`DIDX(MOTOR_YA)]),
		.req_speed     (req_speed     [`DIDX(MOTOR_YA)][C_SPEED_DATA_WIDTH-1 :0]),
		.req_step      (req_step      [`DIDX(MOTOR_YA)][C_STEP_NUMBER_WIDTH-1:0]),

		.m_sel       (mya_sel       ),
		.m_ntsign    (mya_ntsign    ),
		.m_zpsign    (mya_zpsign    ),
		.m_ptsign    (mya_ptsign    ),
		.m_state     (mya_state     ),
		.m_rt_dir    (mya_rt_dir    ),
		.m_position  (mya_position  ),
		.m_start     (mya_start     ),
		.m_stop      (mya_stop      ),
		.m_speed     (mya_speed     ),
		.m_step      (mya_step      ),
		.m_abs       (mya_abs       ),
		.m_mod_remain(mya_mod_remain),
		.m_new_remain(mya_new_remain),

		.m_dep_state(mya_dep_state),

		.img_pulse       (mya_final_img_pulse),
		.img_step        (mya_final_img_step),
		.img_ok          (mya_final_img_ok),
		.img_should_start(mya_final_img_should_start)
	);

	////////////////// left rotate motor //////////////////////////////
	RM_ctl # (
		.C_STEP_NUMBER_WIDTH(C_STEP_NUMBER_WIDTH),
		.C_SPEED_DATA_WIDTH (C_SPEED_DATA_WIDTH )
	) lr_motor_ctl (
		.clk          (clk   ),
		.resetn       (dev_oper_bmp[`DIDX(MOTOR_LR)]),
		.exe_done     (req_done_bmp[`DIDX(MOTOR_LR)]),

		.req_abs       (req_abs       [`DIDX(MOTOR_LR)]),
		.req_speed     (req_speed     [`DIDX(MOTOR_LR)][C_SPEED_DATA_WIDTH-1 :0]),
		.req_step      (req_step      [`DIDX(MOTOR_LR)][C_STEP_NUMBER_WIDTH-1:0]),

		.m_sel       (mlr_sel       ),
		.m_ntsign    (mlr_ntsign    ),
		.m_zpsign    (mlr_zpsign    ),
		.m_ptsign    (mlr_ptsign    ),
		.m_state     (mlr_state     ),
		.m_position  (mlr_position  ),
		.m_start     (mlr_start     ),
		.m_stop      (mlr_stop      ),
		.m_speed     (mlr_speed     ),
		.m_step      (mlr_step      ),
		.m_abs       (mlr_abs       ),
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

		.req_abs       (req_abs       [`DIDX(MOTOR_RR)]),
		.req_speed     (req_speed     [`DIDX(MOTOR_RR)][C_SPEED_DATA_WIDTH-1 :0]),
		.req_step      (req_step      [`DIDX(MOTOR_RR)][C_STEP_NUMBER_WIDTH-1:0]),

		.m_sel       (mrr_sel       ),
		.m_ntsign    (mrr_ntsign    ),
		.m_zpsign    (mrr_zpsign    ),
		.m_ptsign    (mrr_ptsign    ),
		.m_state     (mrr_state     ),
		.m_position  (mrr_position  ),
		.m_start     (mrr_start     ),
		.m_stop      (mrr_stop      ),
		.m_speed     (mrr_speed     ),
		.m_step      (mrr_step      ),
		.m_abs       (mrr_abs       ),
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
