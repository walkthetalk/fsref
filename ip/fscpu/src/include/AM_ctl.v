`timescale 1ns / 1ps

module AM_ctl # (
	parameter integer C_STEP_NUMBER_WIDTH = 32,
	parameter integer C_SPEED_DATA_WIDTH = 32
) (
	input wire clk,
	input wire resetn,

	output reg          exe_done,

	input wire                req_abs,
	input wire                req_dep_img,
	input wire [C_SPEED_DATA_WIDTH-1:0]  req_speed,
	input wire signed [C_STEP_NUMBER_WIDTH-1:0] req_step,

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

	input wire img_pulse,
	input wire signed [C_STEP_NUMBER_WIDTH-1:0] img_step,
	input wire img_ok,
	input wire img_should_start
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
			if (img_pulse)
				exe_done <= img_ok;
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
			if (img_pulse && img_should_start) begin
				m_start <= 1'b1;
				m_speed <= req_speed;
				m_step  <= img_step;
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
			if (img_pulse) begin
				/// @note need change direction, stop it first
				if (m_running && (m_rt_dir != img_step[C_STEP_NUMBER_WIDTH-1])) begin
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
			if (img_pulse) begin
				/// @note not need change direction, change remain
				if (m_running && (m_rt_dir == img_step[C_STEP_NUMBER_WIDTH-1])) begin
					m_mod_remain <= 1'b1;
					m_new_remain <= img_step;
				end
			end
		end
	end

	assign m_sel = resetn;
endmodule
