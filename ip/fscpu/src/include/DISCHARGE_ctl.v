`timescale 1ns / 1ps
/**
 * C_PWM_CNT_WIDTH: 16bits, [0,65535], if using mV as units, range to 65V
 * with 150M clock, 60K denominator means 0.4ms, frequency: 2.5kHZ,
 * climbing time can reach 60K * 60K / 150M = 25s.
 * if inc/dec has 32bits (16bits fractional part), climbing time can reach
 * 25s * 60K = 40hours
 */

module DISCHARGE_ctl #
(
	parameter integer C_DEFAULT_VALUE = 0,
	parameter integer C_PWM_CNT_WIDTH = 16,
	parameter integer C_FRACTIONAL_WIDTH = 16,
	parameter integer C_NUMBER_WIDTH = 32
) (
	input  wire                       clk,
	input  wire                       resetn,

	output wire                       def_val,

	output wire                       exe_done,

	input  wire [C_PWM_CNT_WIDTH-1:0] denominator,	// >= 3
	input  wire [C_PWM_CNT_WIDTH-1:0] numerator0,
	input  wire [C_PWM_CNT_WIDTH-1:0] numerator1,
	input  wire [C_NUMBER_WIDTH-1:0]  number0,
	input  wire [C_NUMBER_WIDTH-1:0]  number1,
	input  wire [C_PWM_CNT_WIDTH+C_FRACTIONAL_WIDTH-1:0] inc0,

	output wire                       o_resetn,
	output wire                       drive
);

	parameter integer STATE_IDLE = 0;
	parameter integer STATE_PRE  = 1;
	parameter integer STATE_INC  = 2;
	parameter integer STATE_KEEP = 3;
	reg[1:0] pwm_state;

	assign def_val = C_DEFAULT_VALUE;

	assign o_resetn = resetn;

	reg[C_PWM_CNT_WIDTH+C_FRACTIONAL_WIDTH-1:0] numerator_ext;
	reg[C_PWM_CNT_WIDTH-1:0] cnt;
	reg eop;	// end of period
	reg eop_p1;
	always @ (posedge clk) begin
		if (resetn == 0)
			cnt <= 0;
		else begin
			if (cnt == 0)
				cnt <= denominator - 1;
			else
				cnt <= cnt - 1;
		end
	end
	always @ (posedge clk) begin
		if (resetn == 0)
			eop_p1 <= 0;
		else if (eop_p1)
			eop_p1 <= 0;
		else if (cnt == 2)
			eop_p1 <= 1;
	end
	always @ (posedge clk) begin
		if (resetn == 0)
			eop <= 0;
		else
			eop <= eop_p1;
	end

	reg out_drive;
	assign drive = out_drive;
	wire[C_PWM_CNT_WIDTH-1:0] numerator;
	assign numerator = numerator_ext[C_PWM_CNT_WIDTH+C_FRACTIONAL_WIDTH-1:C_FRACTIONAL_WIDTH];
	always @ (posedge clk) begin
		if (resetn == 0)
			out_drive <= C_DEFAULT_VALUE;
		else if (pwm_state != STATE_IDLE) begin
			if (cnt == 0) begin
				if (numerator != denominator)
					out_drive <= ~C_DEFAULT_VALUE;
			end
			else if (cnt == numerator)
				out_drive <= C_DEFAULT_VALUE;
		end
	end

	reg[C_NUMBER_WIDTH-1:0] peroid_cnt;
	always @ (posedge clk) begin
		if (resetn == 0)
			pwm_state <= STATE_IDLE;
		else if (eop_p1 && ~exe_done) begin
			case (pwm_state)
				STATE_IDLE:
					pwm_state <= STATE_PRE;
				STATE_PRE: begin
					if (peroid_cnt <= 1) begin
						pwm_state <= STATE_INC;
					end
				end
				STATE_INC: begin
					if (numerator <= numerator1) begin
						pwm_state <= STATE_KEEP;
					end
				end
				STATE_KEEP: begin
					if (peroid_cnt <= 1) begin
						pwm_state <= STATE_IDLE;
					end
				end
			endcase
		end
	end

	always @ (posedge clk) begin
		if (resetn == 0)
			numerator_ext <= 0;
		else if (eop_p1 && ~exe_done) begin
			case (pwm_state)
				STATE_IDLE: begin
					numerator_ext <= {numerator0, {(C_FRACTIONAL_WIDTH){1'b0}}};
					peroid_cnt   <= number0;
				end
				STATE_PRE: begin
					numerator_ext <= {numerator0, {(C_FRACTIONAL_WIDTH){1'b0}}};
					peroid_cnt <= peroid_cnt - 1;
				end
				STATE_INC: begin
					if (numerator <= numerator1) begin
						numerator_ext <= {numerator1, {(C_FRACTIONAL_WIDTH){1'b0}}};
						peroid_cnt <= number1;
					end
					else begin
						numerator_ext <= numerator_ext - inc0;
						peroid_cnt <= 0;
					end
				end
				STATE_KEEP: begin
					numerator_ext <= {numerator1, {(C_FRACTIONAL_WIDTH){1'b0}}};
					peroid_cnt <= peroid_cnt - 1;
				end
			endcase
		end
	end

	reg end_of_transaction;
	assign exe_done = end_of_transaction;
	always @ (posedge clk) begin
		if (resetn == 0)
			end_of_transaction <= 0;
		else if (eop_p1 && pwm_state == STATE_KEEP && peroid_cnt <= 1)
			end_of_transaction <= 1;
	end
endmodule
