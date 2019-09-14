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

	output wire [31:0]                    test1,
	output wire [31:0]                    test2,
	output wire [31:0]                    test3,
	output wire [31:0]                    test4

);
	wire [31:0] req_par0;	assign req_par0 = req_param[ 31: 0];
	wire [31:0] req_par1;	assign req_par1 = req_param[ 63:32];
	wire [31:0] req_par2;	assign req_par2 = req_param[ 95:64];
	wire [31:0] req_par3;	assign req_par3 = req_param[127:96];

	reg  [31:0] dev_oper_bmp;
	wire [31:0] req_done_bmp;

	reg  [31:0] cfg_img_delay_cnt;
	reg  [1:0]  cfg_img_delay_frm;
	localparam integer DBIT_MOTOR_LFT = 0;
	localparam integer DBIT_MOTOR_RT  = 1;
	localparam integer DBIT_MOTOR_X   = 2;
	localparam integer DBIT_MOTOR_Y   = 3;

	`define DIDX(_x) DBIT_``_x
	`define DBIT(_x) (1 << DBIT_``_x)
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			dev_oper_bmp <= 0;
			cfg_img_delay_frm <= 0;
			cfg_img_delay_cnt <= 0;
		end
		else if (req_en) begin
			case (req_cmd)
			0: begin
				dev_oper_bmp      <= 0;
				cfg_img_delay_frm <= req_par0;
				cfg_img_delay_cnt <= req_par1;
			end
			1: dev_oper_bmp <= `DBIT(MOTOR_LFT);
			2: dev_oper_bmp <= `DBIT(MOTOR_RT);
			3: dev_oper_bmp <= (`DBIT(MOTOR_LFT) | `DBIT(MOTOR_RT));
			4: dev_oper_bmp <= `DBIT(MOTOR_X);
			5: dev_oper_bmp <= `DBIT(MOTOR_Y);
			6: dev_oper_bmp <= (`DBIT(MOTOR_X) | `DBIT(MOTOR_Y));
			default:
				dev_oper_bmp <= 0;
			endcase
		end
		else if (req_done_bmp == dev_oper_bmp)	/// ensure one clock reset at least
			dev_oper_bmp <= 0;
	end
	reg r_req_done;
	assign req_done = r_req_done;
	assign req_err  = 0;	/// TODO: fix it
	always @ (posedge clk) begin
		if (resetn == 1'b0)
			r_req_done <= 0;
		else if (req_en)
			r_req_done <= 0;
		else if (req_done_bmp == dev_oper_bmp && dev_oper_bmp != 0)
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
		.resetn       (dev_oper_bmp[`DIDX(MOTOR_LFT)]),
		.exe_done     (req_done_bmp[`DIDX(MOTOR_LFT)]),

		.img_delay_cnt(cfg_img_delay_cnt),
		.img_delay_frm(cfg_img_delay_frm),

		.req_single_dir(req_par0[0]),
		.req_dir_back  (req_par0[1]),
		.req_dep_img   (req_par0[2]),
		.req_img_tol   (req_par0[C_IMG_WW-1+16        :16]),
		.req_speed     (req_par1[C_SPEED_DATA_WIDTH-1 : 0]),

		.req_img_dst   (req_par2[C_IMG_WW-1           : 0]),
		.req_step      (req_par2[C_STEP_NUMBER_WIDTH-1: 0]),

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
		.rd_data(bpm_qA   )/*,

		.test1(test1),
		.test2(test2),
		.test3(test3),
		.test4(test4)*/
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
		.resetn       (dev_oper_bmp[`DIDX(MOTOR_RT)]),
		.exe_done     (req_done_bmp[`DIDX(MOTOR_RT)]),

		.img_delay_cnt(cfg_img_delay_cnt),
		.img_delay_frm(cfg_img_delay_frm),

		.req_single_dir(req_par0[0]),
		.req_dir_back  (req_par0[1]),
		.req_dep_img   (req_par0[2]),
		.req_img_tol   (req_par0[C_IMG_WW-1+16        :16]),
		.req_speed     (req_par1[C_SPEED_DATA_WIDTH-1 : 0]),

		.req_img_dst   (req_par3[C_IMG_WW-1           : 0]),
		.req_step      (req_par3[C_STEP_NUMBER_WIDTH-1: 0]),

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
		.resetn       (dev_oper_bmp[`DIDX(MOTOR_X)]),
		.exe_done     (req_done_bmp[`DIDX(MOTOR_X)]),

		.req_ecf       (req_par0[0]),
		.req_dir_back  (req_par0[1]),
		.req_dep_img   (req_par0[2]),
		.req_img_tol   (req_par0[C_IMG_WW-1+16        :16]),
		.req_speed     (req_par1[C_SPEED_DATA_WIDTH-1 : 0]),

		.req_img_dst   (req_par2[C_IMG_WW-1           : 0]),
		.req_step      (req_par2[C_STEP_NUMBER_WIDTH-1: 0]),

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

		.m_other_state(my_state    ),

		//.rd_en  (bam_reA  ),
		.rd_addr(bam_addrA),
		.rd_data(bam_qA   ),

		.test1(test1),
		.test2(test2),
		.test3(test3),
		.test4(test4)
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
		.resetn       (dev_oper_bmp[`DIDX(MOTOR_Y)]),
		.exe_done     (req_done_bmp[`DIDX(MOTOR_Y)]),

		.req_ecf       (req_par0[0]),
		.req_dir_back  (req_par0[1]),
		.req_dep_img   (req_par0[2]),
		.req_img_tol   (req_par0[C_IMG_WW-1+16        :16]),
		.req_speed     (req_par1[C_SPEED_DATA_WIDTH-1 : 0]),

		.req_img_dst   (req_par3[C_IMG_WW-1           : 0]),
		.req_step      (req_par3[C_STEP_NUMBER_WIDTH-1: 0]),

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

		.m_other_state(mx_state    ),

		//.rd_en  (bam_reA  ),
		.rd_addr(bam_addrB),
		.rd_data(bam_qB   )
	);

endmodule
