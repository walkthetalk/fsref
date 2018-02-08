`include "./block_ram.v"
`include "./single_step_motor.v"

module step_motor #(
	parameter integer C_STEP_NUMBER_WIDTH = 16,
	parameter integer C_SPEED_DATA_WIDTH = 16,
	parameter integer C_SPEED_ADDRESS_WIDTH = 9,
	parameter integer C_MICROSTEP_WIDTH = 3,

	parameter integer C_CLK_DIV_NBR = 32,	/// >= 4 (block_ram read delay)
	parameter integer C_MOTOR_NBR = 4,
	parameter integer C_ZPD_SEQ = 32'hFFFFFFFF,
	parameter integer C_MICROSTEP_PASSTHOUGH_SEQ = 32'h0
)(
	input	clk,
	input	resetn,

	input  wire                           br_init,
	input  wire                           br_wr_en,
	input  wire [C_SPEED_DATA_WIDTH-1:0]  br_data,
	output wire [C_SPEED_ADDRESS_WIDTH:0] br_size,

	input  wire                           m0_zpd,	/// zero position detection
	output wire                           m0_drive,
	output wire                           m0_dir,
	output wire [C_MICROSTEP_WIDTH-1:0]   m0_ms,
	output wire                           m0_xen,
	output wire                           m0_xrst,

	output wire                           s0_zpsign,
	output wire                           s0_tpsign,	/// terminal position detection
	input  wire [C_STEP_NUMBER_WIDTH-1:0] s0_stroke,
	input  wire [C_SPEED_DATA_WIDTH-1:0]  s0_speed,
	input  wire [C_STEP_NUMBER_WIDTH-1:0] s0_step,
	input  wire                           s0_start,
	input  wire                           s0_stop,
	input  wire                           s0_dir,
	input  wire [C_MICROSTEP_WIDTH-1:0]   s0_ms,
	output wire                           s0_state,
	input  wire                           s0_xen,
	input  wire                           s0_xrst,

	input  wire                           m1_zpd,	/// zero position detection
	output wire                           m1_drive,
	output wire                           m1_dir,
	output wire [C_MICROSTEP_WIDTH-1:0]   m1_ms,
	output wire                           m1_xen,
	output wire                           m1_xrst,

	output wire                           s1_zpsign,
	output wire                           s1_tpsign,	/// terminal position detection
	input  wire [C_STEP_NUMBER_WIDTH-1:0] s1_stroke,
	input  wire [C_SPEED_DATA_WIDTH-1:0]  s1_speed,
	input  wire [C_STEP_NUMBER_WIDTH-1:0] s1_step,
	input  wire                           s1_start,
	input  wire                           s1_stop,
	input  wire                           s1_dir,
	input  wire [C_MICROSTEP_WIDTH-1:0]   s1_ms,
	output wire                           s1_state,
	input  wire                           s1_xen,
	input  wire                           s1_xrst,

	input  wire                           m2_zpd,	/// zero position detection
	output wire                           m2_drive,
	output wire                           m2_dir,
	output wire [C_MICROSTEP_WIDTH-1:0]   m2_ms,
	output wire                           m2_xen,
	output wire                           m2_xrst,

	output wire                           s2_zpsign,
	output wire                           s2_tpsign,	/// terminal position detection
	input  wire [C_STEP_NUMBER_WIDTH-1:0] s2_stroke,
	input  wire [C_SPEED_DATA_WIDTH-1:0]  s2_speed,
	input  wire [C_STEP_NUMBER_WIDTH-1:0] s2_step,
	input  wire                           s2_start,
	input  wire                           s2_stop,
	input  wire                           s2_dir,
	input  wire [C_MICROSTEP_WIDTH-1:0]   s2_ms,
	output wire                           s2_state,
	input  wire                           s2_xen,
	input  wire                           s2_xrst,

	input  wire                           m3_zpd,	/// zero position detection
	output wire                           m3_drive,
	output wire                           m3_dir,
	output wire [C_MICROSTEP_WIDTH-1:0]   m3_ms,
	output wire                           m3_xen,
	output wire                           m3_xrst,

	output wire                           s3_zpsign,
	output wire                           s3_tpsign,	/// terminal position detection
	input  wire [C_STEP_NUMBER_WIDTH-1:0] s3_stroke,
	input  wire [C_SPEED_DATA_WIDTH-1:0]  s3_speed,
	input  wire [C_STEP_NUMBER_WIDTH-1:0] s3_step,
	input  wire                           s3_start,
	input  wire                           s3_stop,
	input  wire                           s3_dir,
	input  wire [C_MICROSTEP_WIDTH-1:0]   s3_ms,
	output wire                           s3_state,
	input  wire                           s3_xen,
	input  wire                           s3_xrst,

	input  wire                           m4_zpd,	/// zero position detection
	output wire                           m4_drive,
	output wire                           m4_dir,
	output wire [C_MICROSTEP_WIDTH-1:0]   m4_ms,
	output wire                           m4_xen,
	output wire                           m4_xrst,

	output wire                           s4_zpsign,
	output wire                           s4_tpsign,	/// terminal position detection
	input  wire [C_STEP_NUMBER_WIDTH-1:0] s4_stroke,
	input  wire [C_SPEED_DATA_WIDTH-1:0]  s4_speed,
	input  wire [C_STEP_NUMBER_WIDTH-1:0] s4_step,
	input  wire                           s4_start,
	input  wire                           s4_stop,
	input  wire                           s4_dir,
	input  wire [C_MICROSTEP_WIDTH-1:0]   s4_ms,
	output wire                           s4_state,
	input  wire                           s4_xen,
	input  wire                           s4_xrst,

	input  wire                           m5_zpd,	/// zero position detection
	output wire                           m5_drive,
	output wire                           m5_dir,
	output wire [C_MICROSTEP_WIDTH-1:0]   m5_ms,
	output wire                           m5_xen,
	output wire                           m5_xrst,

	output wire                           s5_zpsign,
	output wire                           s5_tpsign,	/// terminal position detection
	input  wire [C_STEP_NUMBER_WIDTH-1:0] s5_stroke,
	input  wire [C_SPEED_DATA_WIDTH-1:0]  s5_speed,
	input  wire [C_STEP_NUMBER_WIDTH-1:0] s5_step,
	input  wire                           s5_start,
	input  wire                           s5_stop,
	input  wire                           s5_dir,
	input  wire [C_MICROSTEP_WIDTH-1:0]   s5_ms,
	output wire                           s5_state,
	input  wire                           s5_xen,
	input  wire                           s5_xrst,

	input  wire                           m6_zpd,	/// zero position detection
	output wire                           m6_drive,
	output wire                           m6_dir,
	output wire [C_MICROSTEP_WIDTH-1:0]   m6_ms,
	output wire                           m6_xen,
	output wire                           m6_xrst,

	output wire                           s6_zpsign,
	output wire                           s6_tpsign,	/// terminal position detection
	input  wire [C_STEP_NUMBER_WIDTH-1:0] s6_stroke,
	input  wire [C_SPEED_DATA_WIDTH-1:0]  s6_speed,
	input  wire [C_STEP_NUMBER_WIDTH-1:0] s6_step,
	input  wire                           s6_start,
	input  wire                           s6_stop,
	input  wire                           s6_dir,
	input  wire [C_MICROSTEP_WIDTH-1:0]   s6_ms,
	output wire                           s6_state,
	input  wire                           s6_xen,
	input  wire                           s6_xrst,

	input  wire                           m7_zpd,	/// zero position detection
	output wire                           m7_drive,
	output wire                           m7_dir,
	output wire [C_MICROSTEP_WIDTH-1:0]   m7_ms,
	output wire                           m7_xen,
	output wire                           m7_xrst,

	output wire                           s7_zpsign,
	output wire                           s7_tpsign,	/// terminal position detection
	input  wire [C_STEP_NUMBER_WIDTH-1:0] s7_stroke,
	input  wire [C_SPEED_DATA_WIDTH-1:0]  s7_speed,
	input  wire [C_STEP_NUMBER_WIDTH-1:0] s7_step,
	input  wire                           s7_start,
	input  wire                           s7_stop,
	input  wire                           s7_dir,
	input  wire [C_MICROSTEP_WIDTH-1:0]   s7_ms,
	output wire                           s7_state,
	input  wire                           s7_xen,
	input  wire                           s7_xrst
);
	function integer clogb2(input integer bit_depth);
		for(clogb2=0; bit_depth>0; clogb2=clogb2+1) begin
			bit_depth = bit_depth>>1;
		end
	endfunction

	function integer istart(input integer i, input integer width);
		istart = width * i;
	endfunction

	function integer istop(input integer i, input integer width);
		istop = width * (i+1) - 1;
	endfunction

`define __EXTRACTOR(_sig, _i, _width) _sig[istop(_i, _width):istart(_i,_width)]

	/// block ram for speed data
	reg  [C_SPEED_ADDRESS_WIDTH-1:0] acce_addr_final;
	wire [C_SPEED_DATA_WIDTH-1:0] acce_data_final;
	reg  [C_SPEED_ADDRESS_WIDTH-1:0] deac_addr_final;
	wire [C_SPEED_DATA_WIDTH-1:0] deac_data_final;

	wire acce_we_en;
	assign acce_we_en = br_init && br_wr_en;
	assign br_size = (2**C_SPEED_ADDRESS_WIDTH);
	reg  [C_SPEED_ADDRESS_WIDTH-1 : 0] acce_we_addr;
	reg  [C_SPEED_ADDRESS_WIDTH-1 : 0] acce_addr_max;
	wire [C_SPEED_ADDRESS_WIDTH-1 : 0] deac_addr_max;
	assign deac_addr_max = acce_addr_max;
	block_ram #(
		.C_DATA_WIDTH(C_SPEED_DATA_WIDTH),
		.C_ADDRESS_WIDTH(C_SPEED_ADDRESS_WIDTH)
	) speed_data (
		.clk(clk),
		.weA(acce_we_en),
		.addrA(acce_we_en ? acce_we_addr : acce_addr_final),
		.dataA(br_data),
		.qA(acce_data_final),
		.addrB(deac_addr_final),
		.qB(deac_data_final)
	);

	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			acce_we_addr <= 0;
			acce_addr_max <= 0;
		end
		else if (~br_init)
			acce_we_addr <= 0;
		else if (br_wr_en) begin
			acce_we_addr <= acce_we_addr + 1;
			acce_addr_max <= acce_we_addr;
		end
	end

	/// clock division
	reg [C_CLK_DIV_NBR-1:0] clk_en;
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			clk_en <= 1;
		end
		else begin
			clk_en <= {clk_en[C_CLK_DIV_NBR-2:0], clk_en[C_CLK_DIV_NBR-1]};
		end
	end

	/// read block ram
	wire [C_MOTOR_NBR-1:0] acce_en_array;
	wire [C_MOTOR_NBR-1:0] deac_en_array;
	wire [C_SPEED_ADDRESS_WIDTH-1:0] acce_addr_array[C_MOTOR_NBR-1:0];
	wire [C_SPEED_ADDRESS_WIDTH-1:0] deac_addr_array[C_MOTOR_NBR-1:0];
	wire [C_MOTOR_NBR-1:0] acce_addr_conv[C_SPEED_ADDRESS_WIDTH-1:0];
	wire [C_MOTOR_NBR-1:0] deac_addr_conv[C_SPEED_ADDRESS_WIDTH-1:0];
	generate
		genvar i, j;
		for (j=0; j < C_MOTOR_NBR; j = j + 1) begin: single_motor_conv
			for (i=0; i < C_SPEED_ADDRESS_WIDTH; i = i + 1) begin: single_addr_bit_conv
				assign acce_addr_conv[i][j] = acce_addr_array[j][i];
				assign deac_addr_conv[i][j] = deac_addr_array[j][i];
			end
		end

		for (i = 0; i < C_SPEED_ADDRESS_WIDTH; i = i+1) begin: single_addr_bit
			always @ (posedge clk) begin
				acce_addr_final[i] <= ((acce_en_array & acce_addr_conv[i]) != 0);
				deac_addr_final[i] <= ((deac_en_array & deac_addr_conv[i]) != 0);
			end
		end
	endgenerate

	/// motor logic
	localparam  MAX_MOTOR_NBR = 8;
	wire                           m_zpd[MAX_MOTOR_NBR-1:0];
	wire                           m_drive[MAX_MOTOR_NBR-1:0];
	wire                           m_dir[MAX_MOTOR_NBR-1:0];
	wire [C_MICROSTEP_WIDTH-1:0]   m_ms[MAX_MOTOR_NBR-1:0];
	wire                           m_xen[MAX_MOTOR_NBR-1:0];
	wire                           m_xrst[MAX_MOTOR_NBR-1:0];

	wire                           s_zpsign[MAX_MOTOR_NBR-1:0];
	wire                           s_tpsign[MAX_MOTOR_NBR-1:0];
	wire [C_STEP_NUMBER_WIDTH-1:0] s_stroke[MAX_MOTOR_NBR-1:0];
	wire [C_SPEED_DATA_WIDTH-1:0]  s_speed[MAX_MOTOR_NBR-1:0];
	wire [C_STEP_NUMBER_WIDTH-1:0] s_step[MAX_MOTOR_NBR-1:0];
	wire                           s_start[MAX_MOTOR_NBR-1:0];
	wire                           s_stop[MAX_MOTOR_NBR-1:0];
	wire                           s_dir[MAX_MOTOR_NBR-1:0];
	wire [C_MICROSTEP_WIDTH-1:0]   s_ms[MAX_MOTOR_NBR-1:0];
	wire                           s_state[MAX_MOTOR_NBR-1:0];
	wire                           s_xen[MAX_MOTOR_NBR-1:0];
	wire                           s_xrst[MAX_MOTOR_NBR-1:0];
`define ASSIGN_M_OUT(_i, _port) assign m``_i``_``_port = m_``_port[_i]
`define ASSIGN_M_IN(_i, _port) assign m_``_port[_i] = m``_i``_``_port
`define ASSIGN_S_OUT(_i, _port) assign s``_i``_``_port = s_``_port[_i]
`define ASSIGN_S_IN(_i, _port) assign s_``_port[_i] = s``_i``_``_port
`define ASSIGN_SINGLE_MOTOR(_i) \
	`ASSIGN_M_IN(_i, zpd); \
	`ASSIGN_M_OUT(_i, drive); \
	`ASSIGN_M_OUT(_i, dir); \
	`ASSIGN_M_OUT(_i, ms); \
	`ASSIGN_M_OUT(_i, xen); \
	`ASSIGN_M_OUT(_i, xrst); \
	`ASSIGN_S_IN(_i, stroke); \
	`ASSIGN_S_IN(_i, speed); \
	`ASSIGN_S_IN(_i, step); \
	`ASSIGN_S_IN(_i, start); \
	`ASSIGN_S_IN(_i, stop); \
	`ASSIGN_S_IN(_i, dir); \
	`ASSIGN_S_IN(_i, ms); \
	`ASSIGN_S_IN(_i, xen); \
	`ASSIGN_S_IN(_i, xrst); \
	`ASSIGN_S_OUT(_i, zpsign); \
	`ASSIGN_S_OUT(_i, tpsign); \
	`ASSIGN_S_OUT(_i, state)

	`ASSIGN_SINGLE_MOTOR(0);
	`ASSIGN_SINGLE_MOTOR(1);
	`ASSIGN_SINGLE_MOTOR(2);
	`ASSIGN_SINGLE_MOTOR(3);
	`ASSIGN_SINGLE_MOTOR(4);
	`ASSIGN_SINGLE_MOTOR(5);
	`ASSIGN_SINGLE_MOTOR(6);
	`ASSIGN_SINGLE_MOTOR(7);

	generate
		for (i = 0; i < C_MOTOR_NBR; i = i+1) begin: single_motor_logic
		single_step_motor #(
			.C_STEP_NUMBER_WIDTH(C_STEP_NUMBER_WIDTH),
			.C_SPEED_DATA_WIDTH(C_SPEED_DATA_WIDTH),
			.C_SPEED_ADDRESS_WIDTH(C_SPEED_ADDRESS_WIDTH),
			.C_MICROSTEP_WIDTH(C_MICROSTEP_WIDTH),
			.C_ZPD((C_ZPD_SEQ >> i) & 1),
			.C_MICROSTEP_PASSTHOUGH((C_MICROSTEP_PASSTHOUGH_SEQ >> i) & 1)
		) step_motor_inst (
			.clk(clk),
			.resetn(resetn),
			.clk_en(clk_en[i]),

			.acce_addr_max(acce_addr_max),
			.deac_addr_max(deac_addr_max),
			.acce_en(acce_en_array[i]),
			.acce_addr(acce_addr_array[i]),
			.acce_data(acce_data_final),
			.deac_en(deac_en_array[i]),
			.deac_addr(deac_addr_array[i]),
			.deac_data(deac_data_final),

			/// valid when C_ZPD == 1
			.zpd(m_zpd[i]),	/// zero position detection
			.o_drive(m_drive[i]),
			.o_dir(m_dir[i]),
			.o_ms(m_ms[i]),
			.o_xen(m_xen[i]),
			.o_xrst(m_xrst[i]),

			/// valid when C_ZPD == 1
			.zpsign(s_zpsign[i]),
			.tpsign(s_tpsign[i]),	/// terminal position detection
			.stroke(s_stroke[i]),
			.i_speed(s_speed[i]),
			.i_step(s_step[i]),
			.i_start(s_start[i]),
			.i_stop(s_stop[i]),
			.i_dir(s_dir[i]),
			.i_ms(s_ms[i]),
			.o_state(s_state[i]),
			.i_xen(s_xen[i]),
			.i_xrst(s_xrst[i])
		);
		end	/// for
	endgenerate

endmodule
