`include "../src/step_motor.v"

module test_step_motor();

parameter integer C_STEP_NUMBER_WIDTH = 16;
parameter integer C_SPEED_DATA_WIDTH = 16;
parameter integer C_SPEED_ADDRESS_WIDTH = 9;
parameter integer C_MICROSTEP_WIDTH = 3;
parameter integer C_CLK_DIV_NBR = 5;
parameter integer C_MOTOR_NBR = 2;
parameter integer C_ZPD_SEQ = 8'b01;

reg	clk;
reg	resetn;

reg                          br_init;
reg                          br_wr_en;
reg [C_SPEED_DATA_WIDTH-1:0] br_data;

reg                            m0_zpd = 0;
wire                           m0_drive;
wire                           m0_dir;
wire [C_MICROSTEP_WIDTH-1:0]   m0_ms;
wire                           m0_xen;
wire                           m0_xrst;

wire                           s0_zpsign;
wire                           s0_tpsign;
wire                           s0_state;
reg  [C_STEP_NUMBER_WIDTH-1:0] s0_stroke = 25;
reg  [C_SPEED_DATA_WIDTH-1:0]  s0_speed;
reg  [C_STEP_NUMBER_WIDTH-1:0] s0_step;
reg                            s0_start;
reg                            s0_stop;
reg                            s0_dir;
reg  [C_MICROSTEP_WIDTH-1:0]   s0_ms = 0;
reg                            s0_xen = 1;
reg                            s0_xrst = 0;

step_motor # (
	.C_STEP_NUMBER_WIDTH  (C_STEP_NUMBER_WIDTH  ),
	.C_SPEED_DATA_WIDTH   (C_SPEED_DATA_WIDTH   ),
	.C_SPEED_ADDRESS_WIDTH(C_SPEED_ADDRESS_WIDTH),
	.C_MICROSTEP_WIDTH    (C_MICROSTEP_WIDTH    ),
	.C_CLK_DIV_NBR        (C_CLK_DIV_NBR        ),
	.C_MOTOR_NBR          (C_MOTOR_NBR          ),
	.C_ZPD_SEQ            (C_ZPD_SEQ            )
) motor_inst (
	.clk(clk),
	.resetn(resetn),

	.br_init (br_init),
	.br_wr_en(br_wr_en),
	.br_data (br_data),

	.m0_zpd   (m0_zpd   ),
	.m0_drive (m0_drive ),
	.m0_dir   (m0_dir   ),
	.m0_ms    (m0_ms    ),
	.m0_xen   (m0_xen   ),
	.m0_xrst  (m0_xrst  ),
	.s0_zpsign(s0_zpsign),
	.s0_tpsign(s0_tpsign),
	.s0_stroke(s0_stroke),
	.s0_speed (s0_speed ),
	.s0_step  (s0_step  ),
	.s0_start (s0_start ),
	.s0_stop  (s0_stop  ),
	.s0_dir   (s0_dir   ),
	.s0_ms    (s0_ms    ),
	.s0_state (s0_state ),
	.s0_xen   (s0_xen   ),
	.s0_xrst  (s0_xrst  )
);

initial begin
        clk <= 1'b1;
	forever #1 clk <= ~clk;
end

initial begin
	resetn <= 1'b0;
	repeat (5) #2 resetn <= 1'b0;
	forever #2 resetn <= 1'b1;
end

always @ (posedge clk) begin
        if (resetn == 1'b0) begin
                br_wr_en <= 0;
                br_data  <= 30;
        end
        else if (br_init && ({$random}%2)) begin
                br_wr_en <= 1;
                br_data <= br_data - 2;
        end
        else begin
                br_wr_en <= 0;
        end
end

reg ctl_clk;
initial begin
        ctl_clk <= 1'b1;
	forever #3 ctl_clk <= ~ctl_clk;
end

initial begin
        br_init <= 1'b1;
        repeat (5) #3 br_init <= 1'b1;
        repeat (10) #3 br_init <= 1'b1;
        forever #2 br_init <= 1'b0;
end

always @ (posedge ctl_clk) begin
        if (resetn == 1'b0) begin
                s0_start <= 0;
        end
        else if (s0_state == 1'b0 && ~s0_start && ({$random}%2) && ~br_init) begin
                s0_speed <= 10;
                s0_step  <= 30;
                s0_dir   <= 0;
                s0_start <= 1;
        end
        else begin
                s0_start <= 0;
        end
end

endmodule
