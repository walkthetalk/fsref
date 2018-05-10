module img_delay_ctl # (
	parameter integer C_TEST = 0
) (
	input clk,
	input reset,

	input  wire [31:0] delay0_cnt,
	output reg         delay0_pulse
);

	reg [31:0] time_cnt;
	always @ (posedge clk) begin
		if (reset)
			time_cnt <= 0;
		else
			time_cnt <= time_cnt + 1;
	end
	always @ (posedge clk) begin
		if (reset)
			delay0_pulse <= 0;
		else if (time_cnt == delay0_cnt)
			delay0_pulse <= 1'b1;
		else
			delay0_pulse <= 0;
	end

endmodule
