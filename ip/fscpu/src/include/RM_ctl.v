`timescale 1ns / 1ps

module RM_ctl # (
	parameter integer C_STEP_NUMBER_WIDTH = 32,
	parameter integer C_SPEED_DATA_WIDTH  = 32
) (
	input wire clk,
	input wire resetn,

	output reg          exe_done,

	input wire                req_dir_back,
	input wire [C_SPEED_DATA_WIDTH-1:0]  req_speed,
	input wire [C_STEP_NUMBER_WIDTH-1:0] req_step,

	output wire                           m_sel     ,
	input  wire                           m_zpsign  ,
	input  wire                           m_tpsign  ,
	input  wire                           m_state   ,
	input  wire [C_STEP_NUMBER_WIDTH-1:0] m_position,
	output reg                            m_start   ,
	output reg                            m_stop    ,
	output reg  [C_SPEED_DATA_WIDTH-1:0]  m_speed   ,
	output reg  [C_STEP_NUMBER_WIDTH-1:0] m_step    ,
	output reg                            m_dir     ,
	output reg                            m_mod_remain,
	output reg  [C_STEP_NUMBER_WIDTH-1:0] m_new_remain
);

	reg m_started;
	wire m_running;
	assign m_running = m_state;
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

	/// stop
	always @ (posedge clk) begin
		if (resetn == 1'b0)
			m_stop <= 1'b0;
		else if (m_stop == 1'b1)
			m_stop <= 1'b0;
		/// @todo always 0 now
	end

	/// start
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			m_start  <= 1'b0;
		end
		else if (m_start == 1'b1) begin
			m_start  <= 1'b0;
		end
		else if (m_started == 1'b0) begin
			m_start <= 1'b1;
			m_speed <= req_speed;
			m_step  <= req_step;
			m_dir   <= req_dir_back;
		end
	end

	/// change remain step
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			m_mod_remain  <= 1'b0;
			m_new_remain  <= 0;
		end
	end

	//////////////// exe_done
	always @ (posedge clk) begin
		if (resetn == 1'b0)
			exe_done <= 1'b0;
		else if (m_stopped)
			exe_done <= 1'b1;
	end

	assign m_sel = resetn;
endmodule
