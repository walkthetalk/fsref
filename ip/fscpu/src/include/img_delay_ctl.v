`timescale 1ns / 1ps

module img_delay_ctl # (
	parameter integer C_STEP_NUMBER_WIDTH = 32,
	parameter integer C_FRMN_WIDTH = 2,
	parameter integer C_TEST = 0
) (
	input clk,
	input eof,

	input  wire [31:0]              delay0_cnt,
	input  wire [C_FRMN_WIDTH-1:0]  delay0_frm,
	output reg         delay0_pulse,

	input wire [C_STEP_NUMBER_WIDTH-1:0] cur_pos,
	output reg [C_STEP_NUMBER_WIDTH-1:0] movie_pos
);

	reg [31:0] time_cnt;
	always @ (posedge clk) begin
		if (eof)
			time_cnt <= 0;
		else
			time_cnt <= time_cnt + 1;
	end
	always @ (posedge clk) begin
		if (eof)
			delay0_pulse <= 0;
		else if (time_cnt == delay0_cnt)
			delay0_pulse <= 1'b1;
		else
			delay0_pulse <= 0;
	end

	localparam integer C_MAX_FRMN = 2**C_FRMN_WIDTH;
	reg [C_STEP_NUMBER_WIDTH-1:0]	history_pos[C_MAX_FRMN-1:1];
	wire [C_STEP_NUMBER_WIDTH-1:0] hisAcur_pos[C_MAX_FRMN-1:0];
	always @ (posedge clk) begin
		if (delay0_pulse)
			history_pos[1] <= cur_pos;
	end
	genvar i;
	generate
		for (i = 2; i < C_MAX_FRMN; i = i+1) begin
			always @ (posedge clk) begin
				if (delay0_pulse)
					history_pos[i] <= history_pos[i-1];
			end
		end

		for (i = 1; i < C_MAX_FRMN; i = i+1) begin
			assign hisAcur_pos[i] = history_pos[i];
		end
		assign hisAcur_pos[0] = cur_pos;
	endgenerate

	always @ (posedge clk) begin
		if (delay0_pulse)
			movie_pos <= hisAcur_pos[delay0_frm];
	end
endmodule
