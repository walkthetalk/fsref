`timescale 1ns / 1ps

module intr_filter #
(
	parameter integer C_NUMBER = 8,
	parameter integer C_FILTER_CNT = 8
) (
	input clk,
	input resetn,

	input wire intr_in0,
	input wire intr_in1,
	input wire intr_in2,
	input wire intr_in3,
	input wire intr_in4,
	input wire intr_in5,
	input wire intr_in6,
	input wire intr_in7,

	output wire intr_out0,
	output wire intr_out1,
	output wire intr_out2,
	output wire intr_out3,
	output wire intr_out4,
	output wire intr_out5,
	output wire intr_out6,
	output wire intr_out7
);
	reg[C_FILTER_CNT-1:0] filter[C_NUMBER-1:0];
	reg [C_NUMBER-1:0] intr_out;
	wire[C_NUMBER-1:0] intr_in;

	generate
	if (C_NUMBER > 0) begin
		assign intr_out0  = intr_out[0];
		assign intr_in[0] = intr_in0;
	end
	if (C_NUMBER > 1) begin
		assign intr_out1 = intr_out[1];
		assign intr_in[1] = intr_in1;
	end
	if (C_NUMBER > 2) begin
		assign intr_out2 = intr_out[2];
		assign intr_in[2] = intr_in2;
	end
	if (C_NUMBER > 3) begin
		assign intr_out3 = intr_out[3];
		assign intr_in[3] = intr_in3;
	end
	if (C_NUMBER > 4) begin
		assign intr_out4 = intr_out[4];
		assign intr_in[4] = intr_in4;
	end
	if (C_NUMBER > 5) begin
		assign intr_out5 = intr_out[5];
		assign intr_in[5] = intr_in5;
	end
	if (C_NUMBER > 6) begin
		assign intr_out6 = intr_out[6];
		assign intr_in[6] = intr_in6;
	end
	if (C_NUMBER > 7) begin
		assign intr_out7 = intr_out[7];
		assign intr_in[7] = intr_in7;
	end
	endgenerate
	
	genvar i;
	generate
	for (i = 0; i < C_NUMBER; i=i+1) begin
		always @ (posedge clk) begin
			if (resetn == 0) begin
				filter[i] <= 0;
				intr_out[i]  <= 0;
			end
			else begin
				filter[i] <= {filter[i][C_NUMBER-2:0],intr_in[i]};
				if (filter[i] == {C_NUMBER{1'b1}}) begin
					intr_out[i] <= 1;
				end
				else begin
					intr_out[i] <= 0;
				end
			end
		end
	end
	endgenerate
endmodule
