`include "../src/fsctl.v"

module test_fsctl();

parameter integer C_SPEED_DATA_WIDTH = 16;
parameter integer C_REG_IDX_WIDTH = 8;

reg	clk;
reg	resetn;

reg wr_en;
reg[C_REG_IDX_WIDTH-1:0] wr_addr = 0;
reg[31:0] wr_data;

reg o_clk;
reg o_resetn;

wire                          br0_init;
wire                          br0_wr_en;
wire [C_SPEED_DATA_WIDTH-1:0] br0_data;

reg                           motor0_zpsign;

fsctl # (
	.C_REG_IDX_WIDTH(C_REG_IDX_WIDTH),
	.C_SPEED_DATA_WIDTH(C_SPEED_DATA_WIDTH)
) fsctl_inst (
	.clk(clk),
	.resetn(resetn),
	.wr_en(wr_en),
	.wr_addr(wr_addr),
	.wr_data(wr_data),
	.o_clk(o_clk),
	.o_resetn(o_resetn),

	.br0_init(br0_init),
	.br0_wr_en(br0_wr_en),
	.br0_data(br0_data),

	.motor0_zpsign(motor0_zpsign)
);

initial begin
	clk <= 1'b1;
	forever #4 clk <= ~clk;
end
initial begin
	o_clk <= 1'b1;
	repeat (1) #1 o_clk <= 1'b1;
	forever #1 o_clk <= ~o_clk;
end

initial begin
	resetn <= 1'b0;
	repeat (5) #2 resetn <= 1'b0;
	forever #2 resetn <= 1'b1;
end

initial begin
	o_resetn <= 1'b0;
	repeat (5) #2 o_resetn <= 1'b0;
	forever #2 o_resetn <= 1'b1;
end

reg[31:0] datacnt;

always @ (posedge clk) begin
	if (resetn == 1'b0) begin
		wr_en <= 0;
		wr_addr <= 0;
		wr_data  <= 0;
		datacnt <= 0;
	end
	else if (br0_init == 0) begin
		if (datacnt == 0) begin
			wr_en <= 1;
			wr_addr <= 30;
			wr_data <= 3;
		end
		else begin
			wr_en <= 1;
			wr_addr <= 34;
			wr_data <= 32'hFFFFFFFF;
		end
	end
	else if (br0_init == 1) begin
		if (datacnt < 15) begin
			if ({$random}%2 == 1) begin
				wr_en <= 1;
				wr_addr <= 31;
				wr_data <= datacnt;
				datacnt <= datacnt + 1;
			end
			else begin
				wr_en <= 0;
			end
		end
		else begin
			wr_en <= 1;
			wr_addr <= 30;
			wr_data <= 0;
		end
	end
end

initial begin
	motor0_zpsign <= 1'b0;
	repeat (5) #2 motor0_zpsign <= 1'b0;
	repeat (1000) #2 motor0_zpsign <= 1'b1;
end

endmodule
