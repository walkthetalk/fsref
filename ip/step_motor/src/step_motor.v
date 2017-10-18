module block_ram #(
	parameter C_STEP_NUMBER_WIDTH = 16,
	parameter C_SPEED_DATA_WIDTH = 16,
	parameter C_SPEED_ADDRESS_WIDTH = 9,
	parameter C_CLK_DIV_BITS = 5
)(
	input	clk,
	input	resetn,

	input	i_clk_en,

	output	o_interrupt,

	output	o_drive,
	output	o_dir,
	output	o_ms0,
	output	o_ms1,
	output	o_xen,
	output	o_xrst,

	input[C_SPEED_DATA_WIDTH-1:0]	i_velocity,
	input[C_STEP_NUMBER_WIDTH-1:0]	i_step_nbr,
	input		i_start,
	input		i_stop,
	input		i_dir,
	input		i_en,
	input		i_rst,
	input[1:0]	i_ms
);

	reg [C_CLK_DIV_BITS-1:0] clk_div_cnt;
	reg clk_en;
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			clk_div_cnt <= 0;
			clk_en <= 0;
		end
		else begin
			clk_div_cnt <= clk_div_cnt + 1;
			clk_en <= (clk_div_cnt == 0);
		end
	end

endmodule
