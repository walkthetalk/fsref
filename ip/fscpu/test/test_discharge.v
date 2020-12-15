`include "../src/include/DISCHARGE_ctl.v"

module test_discharge # (
	parameter integer C_DEFAULT_VALUE = 0,
	parameter integer C_PWM_CNT_WIDTH = 16,
	parameter integer C_FRACTIONAL_WIDTH = 16,
	parameter integer C_NUMBER_WIDTH = 32
) (
);

	reg clk;
	reg resetn;

	wire                       def_val ;
	wire                       exe_done;

	reg [C_PWM_CNT_WIDTH-1:0] denominator;	// >= 3
	reg [C_PWM_CNT_WIDTH-1:0] numerator0 ;
	reg [C_PWM_CNT_WIDTH-1:0] numerator1 ;
	reg [C_NUMBER_WIDTH-1:0]  number0    ;
	reg [C_NUMBER_WIDTH-1:0]  number1    ;
	reg [C_PWM_CNT_WIDTH+C_FRACTIONAL_WIDTH-1:0] inc0;

	wire                      drive;

	DISCHARGE_ctl # (
		.C_DEFAULT_VALUE(C_DEFAULT_VALUE),
		.C_PWM_CNT_WIDTH(C_PWM_CNT_WIDTH),
		.C_FRACTIONAL_WIDTH(C_FRACTIONAL_WIDTH),
		.C_NUMBER_WIDTH(C_NUMBER_WIDTH)
	) discharge_ctl_inst (
		.clk(clk),
		.resetn(resetn),
		.def_val(def_val),
		.exe_done(exe_done),

		.denominator(denominator),
		.numerator0 (numerator0),
		.numerator1 (numerator1),
		.number0    (number0),
		.number1    (number1),
		.inc0       (inc0),
		.drive      (drive)
	);

initial begin
	clk <= 1'b1;
	forever #2.5 clk <= ~clk;
end

initial begin
	resetn <= 1'b0;
	repeat (5) #5 resetn <= 1'b0;
	forever #5 resetn <= 1'b1;
end

always @ (posedge clk) begin
	if (resetn == 1'b0) begin
		denominator <= 23;
		numerator0  <= 19;
		numerator1  <= 7;
		number0     <= 5;
		number1     <= 9;
		inc0        <= (19 - 7) * 65536 / 9;
	end
end

endmodule
