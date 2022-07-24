module single_step_motor #(
	parameter integer C_OPT_BR_TIME = 0,
	parameter integer C_STEP_NUMBER_WIDTH = 16,
	parameter integer C_SPEED_DATA_WIDTH = 16,
	parameter integer C_SPEED_ADDRESS_WIDTH = 9,
	parameter integer C_MICROSTEP_WIDTH = 3,
	parameter integer C_ZPD = 0,
	parameter integer C_MICROSTEP_PASSTHOUGH = 0,
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
	output wire [C_MICROSTEP_WIDTH-1:0] o_ms,
	output wire o_xen,
	output wire o_xrst,

	input  wire                                    i_xen    ,
	input  wire                                    i_xrst   ,
	input  wire signed [C_STEP_NUMBER_WIDTH-1:0]   i_min_pos,
	input  wire signed [C_STEP_NUMBER_WIDTH-1:0]   i_max_pos,
	input  wire [C_MICROSTEP_WIDTH-1:0]            i_ms     ,

	/// valid when C_ZPD == 1
	output wire                                    pri_zpsign ,	/// zero position sign
	output wire                                    pri_ntsign ,	/// negative terminal sign
	output wire                                    pri_ptsign ,	/// positive terminal sign
	output wire                                    pri_state  ,
	output wire [C_SPEED_DATA_WIDTH-1:0]           pri_rt_speed,
	output wire signed [C_STEP_NUMBER_WIDTH-1:0]   pri_position,
	input  wire                                    pri_start,	/// pulse sync to clk
	input  wire                                    pri_stop ,	/// pulse sync to clk
	input  wire [C_SPEED_DATA_WIDTH-1:0]	       pri_speed,
	input  wire signed [C_STEP_NUMBER_WIDTH-1:0]   pri_step ,
	input  wire                                    pri_abs  ,

	input  wire                                    ext_sel ,

	output wire                                    ext_zpsign ,	/// zero position sign
	output wire                                    ext_ntsign ,	/// negative terminal sign
	output wire                                    ext_ptsign ,	/// positive terminal sign
	output wire                                    ext_state  ,
	output wire [C_SPEED_DATA_WIDTH-1:0]           ext_rt_speed,
	output wire signed [C_STEP_NUMBER_WIDTH-1:0]   ext_position,	/// signed integer
	input  wire                                    ext_start,	/// pulse sync to clk
	input  wire                                    ext_stop ,	/// pulse sync to clk
	input  wire [C_SPEED_DATA_WIDTH-1:0]           ext_speed,
	input  wire signed [C_STEP_NUMBER_WIDTH-1:0]   ext_step ,	/// signed intger (sign -> direction)
	input  wire                                    ext_abs,
	input  wire                                    ext_mod_remain,
	input  wire signed [C_STEP_NUMBER_WIDTH-1:0]   ext_new_remain,

	output reg [31:0] test0,
	output reg [31:0] test1,
	output reg [31:0] test2,
	output reg [31:0] test3
);
	/// state macro
	localparam integer IDLE = 2'b00;
	localparam integer PREPARE = 2'b10;
	localparam integer RUNNING = 2'b11;

	/// motor logic
	reg [C_SPEED_DATA_WIDTH-1:0]	speed_max;
	reg [C_SPEED_DATA_WIDTH-1:0]    speed_cur;
	reg [C_SPEED_DATA_WIDTH-1:0]    speed_cnt;
	reg [C_STEP_NUMBER_WIDTH-1:0]   step_cnt;
	reg signed [C_STEP_NUMBER_WIDTH-1:0]	step_remain;
	reg step_done;	/// keep one between final half step
	reg[1:0] motor_state;
	assign pri_state = motor_state[1];
	wire is_idle; assign is_idle = (pri_state == 0);
	wire is_running; assign is_running = (pri_state);
	reg rd_en;
	/// posedge of out drive
	reg o_drive_d1;
	always @ (posedge clk) begin
		o_drive_d1 <= o_drive;
	end
	wire posedge_drive;
	assign posedge_drive = o_drive_d1 && ~o_drive;

	/// backwarding
	wire backwarding;
	assign backwarding = o_dir;

	/// for zpd
	reg signed [C_STEP_NUMBER_WIDTH-1:0] cur_position;
	wire reach_neg_term;
	wire reach_pos_term;
	wire reach_zero_position;
	wire shouldStop;

	/// control selection
	reg [C_SPEED_DATA_WIDTH-1:0]    req_speed;
	reg signed [C_STEP_NUMBER_WIDTH-1:0]   req_step ;
	reg                             req_dir  ;
	reg                             req_abs  ;
	/// @note only for C_ZPD
	reg                             req_reset2zero;

	/// start_pulse
	reg start_pulse;
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			start_pulse <= 0;
			req_reset2zero <= 0;
		end
		else if (start_pulse) begin
			if (clk_en)
				start_pulse <= 0;
		end
		else begin
			if (is_idle) begin
				if (ext_sel == 1'b0) begin
					if (pri_start) begin
						start_pulse <= 1'b1;
						req_speed   <= pri_speed;
						req_step    <= pri_step;
						req_abs     <= pri_abs;
						if ((pri_abs == 1'b1) && (pri_step == 0) && C_ZPD) begin
							req_reset2zero <= 1'b1;
						end
						else begin
							req_reset2zero <= 1'b0;
						end
						req_dir <= pri_abs
								? (pri_step > cur_position ? 0 : 1)
								: pri_step[C_STEP_NUMBER_WIDTH-1];
					end
				end
				else begin
					if (ext_start) begin
						start_pulse <= 1'b1;
						req_speed   <= ext_speed;
						req_step    <= ext_step;
						req_abs     <= ext_abs;
						if ((ext_abs == 1'b1) && (ext_step == 0) && C_ZPD) begin
							req_reset2zero <= 1'b1;
						end
						else begin
							req_reset2zero <= 1'b0;
						end
						req_dir <= ext_abs
								? (ext_step > cur_position ? 0 : 1)
								: ext_step[C_STEP_NUMBER_WIDTH-1];
					end
				end
			end
		end
	end

	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			test0 <= 32'b1;
			test1 <= 32'b1;
			test2 <= 32'b1;
			test3 <= 32'b1;
		end
		else begin
			if (clk_en) begin
				case (motor_state)
				RUNNING: begin
					if (shouldStop) begin
						test3 <= cur_position;
						test2 <= reach_neg_term;
						test1 <= reach_pos_term;
						test0 <= backwarding;
					end
				end
				endcase
			end
		end
	end

	/// stop
	reg last_ext_sel;
	always @ (posedge clk) begin
		if (resetn == 1'b0)
			last_ext_sel <= 0;
		else
			last_ext_sel <= ext_sel;
	end

	reg stop_pulse;
	always @ (posedge clk) begin
		if (resetn == 1'b0)
			stop_pulse <= 0;
		else if (stop_pulse) begin
			if (clk_en)
				stop_pulse <= 0;
		end
		else begin
			if (is_running) begin
				/**
				 * auto stop when swith control interface
				 */
				if (last_ext_sel != ext_sel) begin
					stop_pulse <= 1'b1;
				end
				else if (ext_sel == 1'b0) begin
					if (pri_stop)
						stop_pulse <= 1'b1;
				end
				else begin
					if (ext_stop)
						stop_pulse <= 1'b1;
				end
			end
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

	/// should start
	wire should_start;
	assign should_start = (clk_en && start_pulse && is_idle);

	generate
		if (C_MICROSTEP_PASSTHOUGH) begin
			assign o_ms = i_ms;
		end
		else begin
			reg [C_MICROSTEP_WIDTH-1:0] r_ms;
			assign o_ms = r_ms;
			always @ (posedge clk) begin
				if (should_start) begin
					r_ms <= i_ms;
				end
			end
		end
	endgenerate
	/// store instruction
	always @ (posedge clk) begin
		if (should_start) begin
			speed_max <= req_speed;
			o_dir <= req_dir;
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
					if (o_dir == req_dir)
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
				if (o_drive == 1 && speed_cnt == 0) begin
				/// @note not simplify it, the cur_position is not stable
					if (req_abs) begin
						if (req_step == 0) begin
							if (reach_zero_position)
								step_done <= 1;
						end
						else begin
							if (cur_position == req_step)
								step_done <= 1;
						end
					end
					else begin
					 	if (step_remain == 0)
						 	step_done <= 1;
					end
				end
			end
			endcase
		end
	end

	/// step counter (i.e. block ram address)
	always @ (posedge clk) begin
		if (resetn == 1'b0)
			step_cnt    <= 0;
		else if (clk_en) begin
			case (motor_state)
			IDLE: begin
				if (start_pulse)
					step_cnt    <= 0;
			end
			RUNNING: begin
				if (speed_cnt == 0 && o_drive == 1)
					step_cnt <= step_cnt + 1;
			end
			endcase
		end
	end

	wire [C_STEP_NUMBER_WIDTH-1:0] abs_remain;
	abs #(
		.C_WIDTH(C_STEP_NUMBER_WIDTH)
	) abs_inst (
		.din(step_remain),
		.dout(abs_remain)
	);

	always @ (posedge clk) begin
		if (resetn == 1'b0)
			step_remain <= 0;
		else if (ext_mod_remain)
			step_remain <= ext_new_remain;
		else if (clk_en) begin
			case (motor_state)
			IDLE: begin
				if (start_pulse) begin
					if (req_dir)
						step_remain <= req_step + 1;
					else
						step_remain <= req_step - 1;
				end
			end
			RUNNING: begin
				if (speed_cnt == 0 && o_drive == 1) begin
					if (req_dir)
						step_remain <= step_remain + 1;
					else
						step_remain <= step_remain - 1;
				end
			end
			endcase
		end
	end

////////////////////////////// read block ram logic ////////////////////////////
	reg rd_en_d1;
	reg rd_en_d2;
	reg rd_en_d3;
	reg rd_en_d4;
	reg rd_en_d5;
	reg [C_SPEED_DATA_WIDTH-1:0] speed_var;
	always @ (posedge clk) begin
		rd_en_d1 <= rd_en;
		rd_en_d2 <= rd_en_d1;
		rd_en_d3 <= rd_en_d2;
		rd_en_d4 <= rd_en_d3;
		rd_en_d5 <= rd_en_d4;
	end

	reg   acce_ing;
	reg   deac_ing;
	always @ (posedge clk) begin
		if (rd_en) begin
			acce_ing <= (step_cnt   < acce_addr_max);
			deac_ing <= (abs_remain < deac_addr_max);
		end
	end

	/// rd_en_d2: read address for block ram
	reg [C_SPEED_ADDRESS_WIDTH-1:0] r_acce_addr;
	reg [C_SPEED_ADDRESS_WIDTH-1:0] r_deac_addr;
	assign acce_en = rd_en_d2;
	assign acce_addr = r_acce_addr;
	assign deac_en = rd_en_d2;
	assign deac_addr = r_deac_addr;
	always @ (posedge clk) begin
		if (rd_en_d1) begin
			r_acce_addr <= (acce_ing ? step_cnt   : acce_addr_max);
			r_deac_addr <= (deac_ing ? abs_remain : deac_addr_max);
		end
	end

	/// minimum of acce_data_final / deac_data_final / speed_max
generate
if (C_OPT_BR_TIME == 0) begin
	always @ (posedge clk) begin
		if (rd_en_d4) begin
			if (acce_data > deac_data)
				speed_var <= acce_data;
			else
				speed_var <= deac_data;
		end
	end

	assign pri_rt_speed = speed_cur;
	always @ (posedge clk) begin
		if (rd_en_d5) begin
			if (speed_var > speed_max)
				speed_cur <= speed_var;
			else
				speed_cur <= speed_max;
		end
	end
end
else begin
	reg [C_SPEED_DATA_WIDTH-1:0] acce_data_d1;
	reg [C_SPEED_DATA_WIDTH-1:0] deac_data_d1;
	reg acceBdeac;
	always @ (posedge clk) begin
		if (rd_en_d4) begin
			acceBdeac <= (acce_data > deac_data);
			acce_data_d1 <= acce_data;
			deac_data_d1 <= deac_data;
		end
	end
	always @ (posedge clk) begin
		if (rd_en_d5) begin
			speed_var <= (acceBdeac ? acce_data_d1 : deac_data_d1);
		end
	end

	reg rd_en_d6;
	always @ (posedge clk) rd_en_d6 <= rd_en_d5;
	reg varBmax;
	reg [C_SPEED_DATA_WIDTH-1:0] speed_var_d1;
	always @ (posedge clk) begin
		if (rd_en_d6) begin
			speed_var_d1 <= speed_var;
			varBmax      <= (speed_var > speed_max);
		end
	end

	reg rd_en_d7;
	always @ (posedge clk) rd_en_d7 <= rd_en_d6;
	assign pri_rt_speed = speed_cur;
	always @ (posedge clk) begin
		if (rd_en_d7) begin
			speed_cur <= (varBmax ? speed_var_d1 : speed_max);
		end
	end
end
endgenerate
//////////////////////////////////// read block ram end ////////////////////////
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

		//reg internal_zpd;
		//reg internal_ptd;
		//reg internal_ntd;
		//always @ (posedge clk) begin
		//	if (resetn == 1'b0) begin
		//		internal_zpd <= 0;
		//		internal_ptd <= 0;
		//		internal_ntd <= 0;
		//	end
		//	else begin
		//		internal_zpd <= zpd;
		//		internal_ptd <= (cur_position >= i_max_pos);
		//		internal_ntd <= (cur_position <= i_min_pos);
		//	end
		//end

		/// for shouldStop
		assign shouldStop = (req_reset2zero
				? reach_zero_position
				: (((step_done && (speed_cnt == 0))
					|| (backwarding ? reach_neg_term : reach_pos_term))));

		/// current position
		always @ (posedge clk) begin
			if (resetn == 1'b0)
				cur_position <= 0;
			else if (reach_zero_position)
				cur_position <= 0;
			else if (posedge_drive) begin
				if (backwarding) begin
					if (cur_position > i_min_pos)
						cur_position <= cur_position - 1;
				end
				else begin
					if (cur_position < i_max_pos)
						cur_position <= cur_position + 1;
				end
			end
		end

		assign reach_neg_term = cur_position <= i_min_pos;
		assign reach_pos_term = cur_position >= i_max_pos;
		assign reach_zero_position = (zpd == 1'b1);

		assign pri_zpsign = reach_zero_position;
		assign pri_ptsign = reach_pos_term;
		assign pri_ntsign = reach_neg_term;
		assign pri_position = cur_position;
	end
	else begin
		assign reach_neg_term = cur_position <= i_min_pos;
		assign reach_pos_term = cur_position >= i_max_pos;
		assign reach_zero_position = (cur_position == 0);
		/// current position
		always @ (posedge clk) begin
			if (resetn == 1'b0)
				cur_position <= 0;
			else if (posedge_drive) begin
				if (backwarding) begin
					if (cur_position > i_min_pos)
						cur_position <= cur_position - 1;
				end
				else begin
					if (cur_position < i_max_pos)
						cur_position <= cur_position + 1;
				end
			end
		end

		assign pri_zpsign = 0;
		assign pri_ptsign = 0;
		assign pri_ntsign = 0;
		assign pri_position = 0;
		assign shouldStop = (step_done && (speed_cnt == 0));
	end
	endgenerate

	assign ext_zpsign   = pri_zpsign  ;
	assign ext_ntsign   = pri_ntsign  ;
	assign ext_ptsign   = pri_ptsign  ;
	assign ext_state    = pri_state   ;
	assign ext_rt_speed = pri_rt_speed;
	assign ext_position = pri_position;

endmodule
