`timescale 1ns / 1ps

module AM_sw_img # (
	parameter integer C_STEP_NUMBER_WIDTH = 32
) (
	input wire clk,
	input wire resetn,

	input wire  req_dep_img,

	input wire  img_pulse,
	input wire  signed [C_STEP_NUMBER_WIDTH-1:0] img_step,
	input wire  img_ok,

	input  wire m_state,
	input  wire m_dep_state,
	
	output reg o_pulse,
	output reg signed [C_STEP_NUMBER_WIDTH-1:0] o_step,
	output reg o_ok,
	output reg o_should_start
);

//////////////////////////////// delay1 ////////////////////////////////////////
	reg [1:0] m_self_running_hist;
	reg [1:0] m_dep_running_hist;
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			m_self_running_hist <= 0;
			m_dep_running_hist <= 0;
		end
		else if (img_pulse) begin
			m_self_running_hist <= {m_self_running_hist[0], m_state};
			m_dep_running_hist <= {m_dep_running_hist[0], m_dep_state};
		end
		else begin
			if (m_state)
				m_self_running_hist[0]  <= 1'b1;
			if (m_dep_state)
				m_dep_running_hist[0] <= 1'b1;
		end
	end
	
	reg pen_d1;
	always @ (posedge clk) begin
		if (resetn == 1'b0)
			pen_d1 <= 0;
		else
			pen_d1 <= img_pulse;
	end

	reg signed [C_STEP_NUMBER_WIDTH-1:0] img_step_d1;
	reg img_ok_d1;
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			img_step_d1 <= 0;
			img_ok_d1   <= 0;
		end
		else if (img_pulse) begin
			img_step_d1 <= img_step;
			img_ok_d1   <= img_ok;
		end
	end
//////////////////////////////// delay2 ////////////////////////////////////////
	reg img_self_valid;
	reg img_real_valid;
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			img_self_valid <= 0;
			img_real_valid <= 0;
		end
		else if (pen_d1) begin
			/// @note 两帧图像间当前电机一直处于静止状态
			img_self_valid <= (m_self_running_hist == 2'b00);
			/// @note 两帧图像间所有电机一直处于静止状态
			img_real_valid <= (m_dep_running_hist == 2'b00);
		end
	end

	reg pen_d2;
	always @ (posedge clk) begin
		if (resetn == 1'b0)
			pen_d2 <= 0;
		else
			pen_d2 <= pen_d1;
	end

	reg signed [C_STEP_NUMBER_WIDTH-1:0] img_step_d2;
	reg img_ok_d2;
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			img_step_d2 <= 0;
			img_ok_d2   <= 0;
		end
		else if (pen_d1) begin
			img_step_d2 <= img_step_d1;
			img_ok_d2   <= img_ok_d1;
		end
	end
//////////////////////////////// delay3 ////////////////////////////////////////
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			o_pulse <= 0;
			o_step  <= 0;
			o_ok    <= 0;
			o_should_start <= 0;
		end
		else if (pen_d2) begin
			o_pulse <= 1;
			o_step  <= img_step_d2;
			o_ok    <= (img_real_valid && img_ok_d2);
			o_should_start <= (img_self_valid && ~img_ok_d2);
		end
		else begin
			o_pulse <= 0;
			o_step <= 0;
		end
	end
endmodule
