module single_step_motor #(
	parameter integer C_STEP_NUMBER_WIDTH = 16,
	parameter integer C_SPEED_DATA_WIDTH = 16,
	parameter integer C_SPEED_ADDRESS_WIDTH = 9,
	parameter integer C_MICROSTEP_WIDTH = 3,
	parameter integer C_ZPD = 0,
	parameter integer C_REVERSE_DELAY = 4	/// >= 2
)(
	input  wire clk,
	input  wire resetn,

	input  wire clk_en,

	input  wire [C_SPEED_ADDRESS_WIDTH-1:0] acce_addr_max,
	input  wire [C_SPEED_ADDRESS_WIDTH-1:0] deac_addr_max,

	output wire acce_en,
	output wire [C_SPEED_ADDRESS_WIDTH-1:0] acce_addr,
	input  wire [C_SPEED_DATA_WIDTH-1:0]    acce_data,
	output wire deac_en,
	output wire [C_SPEED_ADDRESS_WIDTH-1:0] deac_addr,
	input  wire [C_SPEED_DATA_WIDTH-1:0]    deac_data,

	/// valid when C_ZPD == 1
	input  wire zpd,	/// zero position detection
	output reg  o_drive,
	output reg  o_dir,
	output reg  [C_MICROSTEP_WIDTH-1:0] o_ms,
	output wire o_xen,
	output wire o_xrst,

	/// valid when C_ZPD == 1
	output wire zpsign,
	output wire tpsign,	/// terminal position detection
	input  wire [C_STEP_NUMBER_WIDTH-1:0]   stroke,
	input  wire [C_SPEED_DATA_WIDTH-1:0]	i_speed,
	input  wire [C_STEP_NUMBER_WIDTH-1:0]	i_step,
	input  wire i_start,
	input  wire i_stop,
	input  wire i_dir,
	input  wire [C_MICROSTEP_WIDTH-1:0] i_ms,
	output wire o_state,
	input  wire i_xen,
	input  wire i_xrst
);
	/// state macro
	localparam integer IDLE = 2'b00;
	localparam integer PREPARE = 2'b10;
	localparam integer RUNNING = 2'b11;

	/// motor logic
	reg [C_SPEED_DATA_WIDTH-1:0]	speed_max;
	reg [C_SPEED_DATA_WIDTH-1:0]    speed_cur;
	reg [C_SPEED_DATA_WIDTH-1:0]    speed_cnt;
	reg [C_STEP_NUMBER_WIDTH-1:0]   step_cnt;	/// begin with '1'
	reg [C_STEP_NUMBER_WIDTH-1:0]	step_remain;
	reg step_done;	/// keep one between final half step
	reg[1:0] motor_state;
	assign o_state = motor_state[1];
	wire is_idle; assign is_idle = (o_state == 0);
	wire is_running; assign is_running = (o_state);
	reg rd_en;
	/// reg [C_SPEED_ADDRESS_WIDTH-1:0] rd_addr;
	assign acce_en = rd_en;
	assign acce_addr = (step_cnt > acce_addr_max ? acce_addr_max : step_cnt);
	assign deac_en = rd_en;
	assign deac_addr = (step_remain > deac_addr_max ? deac_addr_max : step_remain);

	/// for zpd
	wire shouldStop;

	/// start_pulse
	reg start_d1;
	reg start_pulse;
	always @ (posedge clk) begin
		if (resetn == 0)
			start_d1 <= 0;
		else
			start_d1 <= i_start;
	end
	always @ (posedge clk) begin
		if (resetn == 1'b0)
			start_pulse <= 0;
		else if (start_pulse) begin
			if (clk_en)
				start_pulse <= 0;
		end
		else begin
			if (i_start && ~start_d1 && is_idle)
				start_pulse <= 1;
		end
	end

	/// stop
	reg stop_d1;
	reg stop_pulse;
	always @ (posedge clk) begin
		if (resetn == 0)
			stop_d1 <= 0;
		else
			stop_d1 <= i_stop;
	end
	always @ (posedge clk) begin
		if (resetn == 1'b0)
			stop_pulse <= 0;
		else if (stop_pulse) begin
			if (clk_en)
				stop_pulse <= 0;
		end
		else begin
			if (i_stop && ~stop_d1 && is_running)
				stop_pulse <= 1;
		end
	end

	/// rd_en
	always @ (posedge clk) begin
		if (resetn == 1'b0)
			rd_en <= 0;
		else if (rd_en)
			rd_en <= 0;
		else if (clk_en) begin
			case (motor_state)
			IDLE:	rd_en <= start_pulse;
			PREPARE: rd_en <= 0;
			RUNNING: rd_en <= ((speed_cnt == 0) && o_drive);
			endcase
		end
	end
	reg rd_en_d1;
	reg rd_en_d2;
	reg rd_en_d3;
	reg [C_SPEED_DATA_WIDTH-1:0] speed_var;
	always @ (posedge clk) begin
		rd_en_d1 <= rd_en;
		rd_en_d2 <= rd_en_d1;
		rd_en_d3 <= rd_en_d2;
	end
	/// minimum of acce_data_final / deac_data_final / speed_max
	always @ (posedge clk) begin
		if (rd_en_d2) begin
			if (acce_data > deac_data)
				speed_var <= acce_data;
			else
				speed_var <= deac_data;
		end
	end
	always @ (posedge clk) begin
		if (rd_en_d3) begin
			if (speed_var > speed_max)
				speed_cur <= speed_var;
			else
				speed_cur <= speed_max;
		end
	end

	reg [31:0] reverse_delay_cnt;
	always @ (posedge clk) begin
		if (resetn == 1'b0)
			reverse_delay_cnt <= 0;
		else if (clk_en) begin
			case (motor_state)
			IDLE: reverse_delay_cnt <= 0;
			PREPARE: reverse_delay_cnt <= reverse_delay_cnt + 1;
			endcase
		end
	end

	/// store instruction
	always @ (posedge clk) begin
		if (clk_en && start_pulse && is_idle) begin
			speed_max <= i_speed;
			o_ms <= i_ms;
			o_dir <= i_dir;
		end
	end

	/// motor_state
	always @ (posedge clk) begin
		if (resetn == 1'b0)
			motor_state <= IDLE;
		else if (clk_en) begin
			case (motor_state)
			IDLE: begin
				if (start_pulse) begin
					if (o_dir == i_dir)
						motor_state <= RUNNING;
					else
						motor_state <= PREPARE;
				end
			end
			PREPARE: begin
				if (stop_pulse)
					motor_state <= IDLE;
				else if (reverse_delay_cnt == C_REVERSE_DELAY - 2)
					motor_state <= RUNNING;
			end
			RUNNING: begin
				if (stop_pulse)
					motor_state <= IDLE;
				else if (shouldStop)
					motor_state <= IDLE;
			end
			endcase
		end
	end
	assign o_xen = i_xen;
	assign o_xrst = i_xrst;

	/// step_done
	always @ (posedge clk) begin
		if (resetn == 1'b0)
			step_done <= 0;
		else if (clk_en) begin
			case (motor_state)
			IDLE, PREPARE: begin
				step_done <= 0;
			end
			RUNNING: begin
				if (o_drive == 1 && step_remain == 0)
					step_done <= 1;
			end
			endcase
		end
	end

	/// step counter (i.e. block ram address)
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			step_cnt <= 0;
			step_remain <= 0;
		end
		else if (clk_en) begin
			case (motor_state)
			IDLE: begin
				if (start_pulse) begin
					step_cnt <= 0;
					step_remain <= i_step - 1;
				end
			end
			RUNNING: begin
				if (speed_cnt == 0 && o_drive == 1) begin
					step_cnt <= step_cnt + 1;
					step_remain <= step_remain - 1;
				end
			end
			endcase
		end
	end

	/// speed counter result in output driver
	always @ (posedge clk) begin
		if (resetn == 1'b0)
			speed_cnt <= 0;
		else if (clk_en) begin
			case (motor_state)
			IDLE: begin
				speed_cnt <= 0;
			end
			RUNNING: begin
				if (speed_cnt == 0)
					speed_cnt <= speed_cur;
				else
					speed_cnt <= speed_cnt - 1;
			end
			endcase
		end
	end
	always @ (posedge clk) begin
		if (resetn == 1'b0)
			o_drive <= 0;
		else if (clk_en) begin
			case (motor_state)
			IDLE, PREPARE:	o_drive <= 0;
			RUNNING: begin
				if (speed_cnt == 0 && ~step_done)
					o_drive <= ~o_drive;
			end
			endcase
		end
	end

	/// zero position process
	generate
	if (C_ZPD) begin
		wire reach_zero_position;
		assign reach_zero_position = (zpd == 1'b1);
		wire forwarding;
		assign forwarding = (o_dir == 1'b0);
		wire backwarding;
		assign backwarding = o_dir;
		/// for shouldStop
		assign zpsign = zpd;
		reg r_tpsign;
		assign tpsign = r_tpsign;
		assign shouldStop = ((step_done && (speed_cnt == 0))
			|| (r_tpsign && forwarding)
			|| (reach_zero_position && backwarding));

		localparam integer C_INIT_POSITION = 1;
		reg [C_STEP_NUMBER_WIDTH-1:0] cur_position;//stroke,
		wire reached_terminal_position;
		assign reached_terminal_position = (cur_position == stroke);

		/// posedge of out drive
		reg o_drive_d1;
		always @ (posedge clk) begin
			o_drive_d1 <= o_drive;
		end
		wire posedge_drive;
		assign posedge_drive = o_drive_d1 && ~o_drive;

		/// current position
		always @ (posedge clk) begin
			if (resetn == 1'b0 || reach_zero_position)
				cur_position <= C_INIT_POSITION;
			else if (posedge_drive) begin
				if (forwarding) begin
					if (~reached_terminal_position)
						cur_position <= cur_position + 1;
				end
				else begin
					if (cur_position > C_INIT_POSITION)
						cur_position <= cur_position - 1;
				end
			end
		end

		/// terminal sign
		always @ (posedge clk) begin
			if (resetn == 1'b0)
				r_tpsign <= 0;
			else if (posedge_drive)
				r_tpsign <= reached_terminal_position;
		end
	end
	else begin
		assign shouldStop = (step_done && (speed_cnt == 0));
	end
	endgenerate

endmodule
