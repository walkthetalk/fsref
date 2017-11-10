`timescale 1ns / 1ps

module pwm #
(
	parameter integer C_PWM_CNT_WIDTH = 16,
	parameter integer C_DEFAULT_VALUE = 0
) (
	input  wire                       clk,

	output wire                       def_val,
	input  wire                       en,
	input  wire [C_PWM_CNT_WIDTH-1:0] numerator,
	input  wire [C_PWM_CNT_WIDTH-1:0] denominator,

	output wire                        drive
);

	assign def_val = C_DEFAULT_VALUE;

	reg [C_PWM_CNT_WIDTH-1:0] cnt;
	always @ (posedge clk) begin
		if (en) begin
			if (cnt <= 1)
				cnt <= denominator;
			else
				cnt <= cnt - 1;
		end
		else
			cnt <= 0;
	end

	assign drive = (cnt <= numerator ? C_DEFAULT_VALUE : ~C_DEFAULT_VALUE);
endmodule
