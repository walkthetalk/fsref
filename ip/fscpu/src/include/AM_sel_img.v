module AM_sel_img # (
	parameter integer C_STEP_NUMBER_WIDTH = 32
) (
	input wire clk,
	input wire resetn,

	input wire i0_pulse,
	input wire signed [C_STEP_NUMBER_WIDTH-1:0] i0_step,
	input wire i0_ok,
	input wire i0_should_start,

	input wire i1_pulse,
	input wire signed [C_STEP_NUMBER_WIDTH-1:0] i1_step,
	input wire i1_ok,
	input wire i1_should_start,
	
	output reg o_pulse,
	output reg signed [C_STEP_NUMBER_WIDTH-1:0] o_step,
	output reg o_ok,
	output reg o_should_start
);

	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			o_pulse <= 1'b0;
		end
		else if (i0_pulse) begin
			o_pulse <= 1'b1;
			o_step  <= i0_step;
			o_ok    <= i0_ok;
			o_should_start <= i0_should_start;
		end
		else if (i1_pulse) begin
			o_pulse <= 1'b1;
			o_step  <= i1_step;
			o_ok    <= i1_ok;
			o_should_start <= i1_should_start;
		end
		else begin
			o_pulse <= 1'b0;
		end
	end

endmodule
