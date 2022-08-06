`timescale 1ns / 1ps

module AM_ctl # (
	parameter integer C_IMG_WW = 12,
	parameter integer C_IMG_HW = 12,
	parameter integer C_STEP_NUMBER_WIDTH = 32,
	parameter integer C_SPEED_DATA_WIDTH = 32,
	parameter integer C_L2R = 1
) (
	input wire clk,
	input wire resetn,

	output reg          exe_done,

	input wire                req_ecf,
	input wire                req_abs,
	input wire                req_dep_img,
	input wire [C_IMG_HW-1:0] req_img_dst,
	input wire [C_IMG_HW-1:0] req_img_tol,
	input wire [C_SPEED_DATA_WIDTH-1:0]  req_speed,
	input wire signed [C_STEP_NUMBER_WIDTH-1:0] req_step,

	input wire                img_pulse,
	input wire                img_l_valid,
	input wire                img_r_valid,

	input wire                img_lo_valid,
	input wire [C_IMG_HW-1:0] img_lo_y    ,
	input wire                img_ro_valid,
	input wire [C_IMG_HW-1:0] img_ro_y    ,

	input wire                img_li_valid,
	input wire [C_IMG_HW-1:0] img_li_y    ,
	input wire                img_ri_valid,
	input wire [C_IMG_HW-1:0] img_ri_y    ,

	output wire                                  m_sel     ,
	input  wire                                  m_ntsign  ,
	input  wire                                  m_zpsign  ,
	input  wire                                  m_ptsign  ,
	input  wire                                  m_state   ,
	input  wire                                  m_rt_dir  ,
	input  wire signed [C_STEP_NUMBER_WIDTH-1:0] m_position,
	output reg                                   m_start   ,
	output reg                                   m_stop    ,
	output reg  [C_SPEED_DATA_WIDTH-1:0]         m_speed   ,
	output reg  signed [C_STEP_NUMBER_WIDTH-1:0] m_step    ,
	output reg                                   m_abs     ,
	output reg                                   m_mod_remain,
	output reg  signed [C_STEP_NUMBER_WIDTH-1:0] m_new_remain,

	input  wire                           m_dep_state,

	//output reg                 rd_en,
	output wire [C_IMG_HW-1:0] rd_addr,
	input  wire [C_STEP_NUMBER_WIDTH-1:0] rd_data,

	output reg [31:0]          test1,
	output reg [31:0]          test2,
	output reg [31:0]          test3,
	output reg [31:0]          test4
);

	wire img_final_pulse;
	wire signed [C_STEP_NUMBER_WIDTH-1:0] img_final_step;
	wire img_final_ok;
	wire img_should_start;
	AM_img # (
		.C_IMG_WW(C_IMG_WW),
		.C_IMG_HW(C_IMG_HW),
		.C_STEP_NUMBER_WIDTH(C_STEP_NUMBER_WIDTH),
		.C_L2R(C_L2R)
	) img2step (
		.clk          (clk   ),
		.resetn       (resetn),

		.req_ecf       (req_ecf),
		.req_dep_img   (req_dep_img),
		.req_img_tol   (req_img_tol),
		.req_img_dst   (req_img_dst),

		.img_pulse   (img_pulse   ),
		.img_l_valid (img_l_valid ),
		.img_r_valid (img_r_valid ),
		.img_lo_valid(img_lo_valid),
		.img_lo_y    (img_lo_y    ),
		.img_ro_valid(img_ro_valid),
		.img_ro_y    (img_ro_y    ),
		.img_li_valid(img_li_valid),
		.img_li_y    (img_li_y    ),
		.img_ri_valid(img_ri_valid),
		.img_ri_y    (img_ri_y    ),

		.m_state     (m_state),
		.m_dep_state(m_dep_state),

		//.rd_en  (bam_reA  ),
		.rd_addr(rd_addr),
		.rd_data(rd_data),
		
		.o_pulse(img_final_pulse),
		.o_step(img_final_step),
		.o_ok(img_final_ok),
		.o_should_start(img_should_start)
	);

	wire m_running;
	assign m_running = m_state;

	reg m_started;
	always @ (posedge clk) begin
		if (resetn == 1'b0)
			m_started <= 1'b0;
		else if (m_start)
			m_started <= 1'b1;
	end

	reg m_run_over;
	always @ (posedge clk) begin
		if (resetn == 1'b0)
			m_run_over <= 1'b0;
		else if (m_running)
			m_run_over <= 1'b1;
	end
	wire m_stopped;
	assign m_stopped = (m_run_over && ~m_running);

	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			exe_done <= 0;
		end
		else if (req_dep_img) begin
			if (img_final_pulse)
				exe_done <= img_final_ok;
		end
		else begin
			if (m_stopped)
				exe_done <= 1;
		end
	end

	/// start
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			m_start  <= 1'b0;
		end
		else if (m_start == 1'b1) begin
			m_start  <= 1'b0;
		end
		else if (req_dep_img) begin
			if (img_final_pulse && img_should_start) begin
				m_start <= 1'b1;
				m_speed <= req_speed;
				m_step  <= img_final_step;
				m_abs   <= 1'b0;
			end
		end
		else begin
			if (m_started == 1'b0) begin
				m_start <= 1'b1;
				m_speed <= req_speed;
				m_step  <= req_step;
				m_abs   <= req_abs;
			end
		end
	end
	/// stop
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			m_stop  <= 1'b0;
		end
		else if (m_stop == 1'b1) begin
			m_stop  <= 1'b0;
		end
		else if (req_dep_img) begin
			if (img_final_pulse) begin
				/// @note need change direction, stop it first
				if (m_running && (m_rt_dir != img_final_step[C_STEP_NUMBER_WIDTH-1])) begin
					m_stop <= 1'b1;
				end
			end
		end
	end
	/// modify remain
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			m_mod_remain  <= 1'b0;
		end
		else if (m_mod_remain == 1'b1) begin
			m_mod_remain  <= 1'b0;
		end
		else if (req_dep_img) begin
			if (img_final_pulse) begin
				/// @note not need change direction, change remain
				if (m_running && (m_rt_dir == img_final_step[C_STEP_NUMBER_WIDTH-1])) begin
					m_mod_remain <= 1'b1;
					m_new_remain <= img_final_step;
				end
			end
		end
	end

	reg processed;
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			test1 <= 0;
			test2 <= 0;
			test3 <= 0;
			test4 <= 0;
			processed <= 0;
		end
		else if (~processed) begin
			if (img_final_pulse) begin
				processed <= 1;

				test1 <= req_speed;
				test2 <= rd_data;

				test3[15:0]  <= 0;//img_pos_d3;
				test3[31:16] <= 0;//img_dst_d4;
				test4[15:0]  <= 0;//img_dst_d5;
				test4[31:16] <= 0;//rd_addr;
			end
		end
	end

	assign m_sel = resetn;
endmodule
