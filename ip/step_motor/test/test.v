`include "../src/include/abs.v"
`include "../src/include/single_step_motor.v"
`include "../src/include/block_ram.v"
`include "../src/step_motor.v"

module test_step_motor();

parameter integer C_STEP_NUMBER_WIDTH = 16;
parameter integer C_SPEED_DATA_WIDTH = 16;
parameter integer C_SPEED_ADDRESS_WIDTH = 4;
parameter integer C_MICROSTEP_WIDTH = 3;
parameter integer C_CLK_DIV_NBR = 16;
parameter integer C_MOTOR_NBR = 2;
parameter integer C_ZPD_SEQ = 8'b01;

localparam integer C_MS = 2;

reg	clk;
reg	resetn;

reg			       br_init;
reg			       br_wr_en;
reg [C_SPEED_DATA_WIDTH-1:0]   br_data;

reg			       m0_zpd;
wire			       m0_drive;
wire			       m0_dir;
wire [C_MICROSTEP_WIDTH-1:0]   m0_ms;
wire			       m0_xen;
wire			       m0_xrst;

wire                   s0_ntsign;
wire			       s0_zpsign;
wire			       s0_ptsign;
wire			       s0_state;
reg  [C_STEP_NUMBER_WIDTH-1:0] s0_min_pos = 0;
reg  [C_STEP_NUMBER_WIDTH-1:0] s0_max_pos = 100;
wire [C_SPEED_DATA_WIDTH-1:0]  s0_rt_speed;
wire [C_STEP_NUMBER_WIDTH-1:0] s0_position;
reg  [C_SPEED_DATA_WIDTH-1:0]  s0_speed;
reg  [C_STEP_NUMBER_WIDTH-1:0] s0_step;
reg			       s0_start;
reg			       s0_stop;
reg			       s0_abs;
reg  [C_MICROSTEP_WIDTH-1:0]   s0_ms = 0;
reg			       s0_xen = 0;
reg			       s0_xrst = 0;

reg			       m1_zpd = 0;
wire			       m1_drive;
wire			       m1_dir;
wire [C_MICROSTEP_WIDTH-1:0]   m1_ms;
wire			       m1_xen;
wire			       m1_xrst;

wire                   s1_ntsign;
wire			       s1_zpsign;
wire			       s1_ptsign;
wire			       s1_state;
reg  [C_STEP_NUMBER_WIDTH-1:0] s1_min_pos = 0;
reg  [C_STEP_NUMBER_WIDTH-1:0] s1_max_pos = 100;
wire [C_SPEED_DATA_WIDTH-1:0]  s1_rt_speed;
reg  [C_SPEED_DATA_WIDTH-1:0]  s1_speed;
reg  [C_STEP_NUMBER_WIDTH-1:0] s1_step;
reg			       s1_start;
reg			       s1_stop;
reg			       s1_abs;
reg  [C_MICROSTEP_WIDTH-1:0]   s1_ms = 0;
reg			       s1_xen = 0;
reg			       s1_xrst = 0;

step_motor # (
	.C_STEP_NUMBER_WIDTH  (C_STEP_NUMBER_WIDTH  ),
	.C_SPEED_DATA_WIDTH   (C_SPEED_DATA_WIDTH   ),
	.C_SPEED_ADDRESS_WIDTH(C_SPEED_ADDRESS_WIDTH),
	.C_MICROSTEP_WIDTH    (C_MICROSTEP_WIDTH    ),
	.C_CLK_DIV_NBR	      (C_CLK_DIV_NBR	    ),
	.C_MOTOR_NBR	      (C_MOTOR_NBR	    ),
	.C_ZPD_SEQ	      (C_ZPD_SEQ	    )
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
	.s0_ntsign(s0_ntsign),
	.s0_zpsign(s0_zpsign),
	.s0_ptsign(s0_ptsign),
	.s0_min_pos(s0_min_pos),
	.s0_max_pos(s0_max_pos),
	.s0_speed (s0_speed ),
	.s0_rt_speed(s0_rt_speed),
	.s0_position(s0_position),
	.s0_step  (s0_step  ),
	.s0_start (s0_start ),
	.s0_stop  (s0_stop  ),
	.s0_abs   (s0_abs   ),
	.s0_ms    (s0_ms    ),
	.s0_state (s0_state ),
	.s0_xen   (s0_xen   ),
	.s0_xrst  (s0_xrst  ),
	.s0_ext_sel(1'b0),

	.m1_zpd   (m1_zpd   ),
	.m1_drive (m1_drive ),
	.m1_dir   (m1_dir   ),
	.m1_ms    (m1_ms    ),
	.m1_xen   (m1_xen   ),
	.m1_xrst  (m1_xrst  ),
	.s1_ntsign(s1_ntsign),
	.s1_zpsign(s1_zpsign),
	.s1_ptsign(s1_ptsign),
	.s1_min_pos(s1_min_pos),
	.s1_max_pos(s1_max_pos),
	.s1_speed (s1_speed ),
	.s1_rt_speed(s1_rt_speed),
	.s1_step  (s1_step  ),
	.s1_start (s1_start ),
	.s1_stop  (s1_stop  ),
	.s1_abs   (s1_abs   ),
	.s1_ms    (s1_ms    ),
	.s1_state (s1_state ),
	.s1_xen   (s1_xen   ),
	.s1_xrst  (s1_xrst  ),
	.s1_ext_sel(1'b0)
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
	else if (s0_state == 1'b0 && ~s0_start && ({$random}%1000 == 0) && ~br_init) begin
		s0_speed <= 15;
		s0_step  <= 30;
		s0_abs   <= 0;
		s0_start <= 1;
		s0_ms    <= C_MS;
	end
	else begin
		s0_start <= 0;
	end
end

reg [31:0] clk_cnt = 0;
always @ (posedge ctl_clk) begin
	if (resetn == 1'b0)
		clk_cnt <= 0;
	else
		clk_cnt <= clk_cnt + 1;
end

always @ (posedge ctl_clk) begin
	if (resetn == 1'b0)
		m0_zpd <= 0;
	else if (clk_cnt == 1000)
		m0_zpd <= 0;
end

reg [31:0] s1_cnt = 1000;
always @ (posedge ctl_clk) begin
	if (~br_init && s1_cnt != 0)
		s1_cnt <= s1_cnt - 1;
end

always @ (posedge ctl_clk) begin
	if (resetn == 1'b0) begin
		s1_start <= 0;
	end
	else if (s1_state == 1'b0 && ~s1_start && s1_cnt == 1) begin
		s1_speed <= 2;
		s1_step  <= 30;
		//s1_abs   <= 0;
		s1_start <= 1;
	end
	else begin
		s1_start <= 0;
	end
end

endmodule
