module single_step_motor #(
	parameter integer C_STEP_NUMBER_WIDTH = 16,
	parameter integer C_SPEED_DATA_WIDTH = 16,
	parameter integer C_SPEED_ADDRESS_WIDTH = 9,
	parameter integer C_ZPD = 0
)(
	input  wire clk,
	input  wire resetn,

	input  wire i_clk_en,

	output wire o_interrupt,

	/// valid when C_ZPD == 1
	input  wire zpd,	/// zero position detection
	output wire tpd,	/// terminal position detection
	input  wire [C_STEP_NUMBER_WIDTH-1:0]   stroke,

	input  wire [C_SPEED_ADDRESS_WIDTH-1:0] acce_addr_max,
	input  wire [C_SPEED_ADDRESS_WIDTH-1:0] deac_addr_max,

	output wire acce_en,
	output wire [C_SPEED_ADDRESS_WIDTH-1:0] acce_addr,
	input  wire [C_SPEED_DATA_WIDTH-1:0]    acce_data,
	output wire deac_en,
	output wire [C_SPEED_ADDRESS_WIDTH-1:0] deac_addr,
	input  wire [C_SPEED_DATA_WIDTH-1:0]    deac_data,

	output reg  o_drive,
	output reg  o_dir,
	output reg  [1:0] o_ms,
	output wire o_xen,
	output wire o_xrst,

	input  wire [C_SPEED_DATA_WIDTH-1:0]	i_speed,
	input  wire [C_STEP_NUMBER_WIDTH-1:0]	i_step,
	input  wire i_start,
	input  wire i_stop,
	input  wire i_dir,
	input  wire [1:0] i_ms,
	input  wire i_xen,
	input  wire i_xrst
);
	/// state macro
	localparam integer IDLE = 1'b0;
	localparam integer RUNNING = 1'b1;

	/// motor logic
	reg [C_SPEED_DATA_WIDTH-1:0]	speed_max;
	reg [C_SPEED_DATA_WIDTH-1:0]    speed_cur;
	reg [C_SPEED_DATA_WIDTH-1:0]    speed_cnt;
	reg [C_STEP_NUMBER_WIDTH-1:0]   step_cnt;	/// begin with '1'
	reg [C_STEP_NUMBER_WIDTH-1:0]	step_remain;
	reg step_done;	/// keep one between final half step
	reg motor_state;
	reg rd_en;
	/// reg [C_SPEED_ADDRESS_WIDTH-1:0] rd_addr;
	assign acce_en = rd_en;
	assign acce_addr = (step_cnt > acce_addr_max ? acce_addr_max : step_cnt);
	assign deac_en = rd_en;
	assign deac_addr = (step_remain > deac_addr_max ? deac_addr_max : step_remain);

	/// for zpd
	wire needAutoStop;
	generate
	if (C_ZPD) begin
		reg r_tpd;
		assign tpd = r_tpd;
		assign needAutoStop = ((step_done && (speed_cnt == 0))
			|| (r_tpd && o_dir)
			|| (zpd && ~o_dir));
	end
	else begin
		assign needAutoStop = (step_done && (speed_cnt == 0));
	end
	endgenerate

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
			if (i_clk_en)
				start_pulse <= 0;
		end
		else begin
			if (i_start && ~start_d1 && (motor_state == IDLE))
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
			if (i_clk_en)
				stop_pulse <= 0;
		end
		else begin
			if (i_stop && ~stop_d1 && (motor_state == RUNNING))
				stop_pulse <= 1;
		end
	end

	/// rd_en
	always @ (posedge clk) begin
		if (resetn == 1'b0)
			rd_en <= 0;
		else if (rd_en)
			rd_en <= 0;
		else if (i_clk_en) begin
			case (motor_state)
			IDLE:	rd_en <= start_pulse;
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

	/// motor_state
	always @ (posedge clk) begin
		if (resetn == 1'b0)
			motor_state <= IDLE;
		else if (i_clk_en) begin
			case (motor_state)
			IDLE: begin
				if (start_pulse) begin
					speed_max <= i_speed;
					o_ms <= i_ms;
					o_dir <= i_dir;
					motor_state <= RUNNING;
				end
			end
			RUNNING: begin
				if (needAutoStop)
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
		else if (i_clk_en) begin
			case (motor_state)
			IDLE: begin
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
		else if (i_clk_en) begin
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
		else if (i_clk_en) begin
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
		else if (i_clk_en) begin
			case (motor_state)
			IDLE:	o_drive <= 0;
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
		localparam integer C_INIT_POSITION = 1;
		reg [C_STEP_NUMBER_WIDTH-1:0] cur_position;//stroke,
		reg o_drive_d1;
		always @ (posedge clk) begin
			o_drive_d1 <= o_drive;
		end
		wire posedge_drive;
		assign posedge_drive = o_drive_d1 && ~o_drive;
		always @ (posedge clk) begin
			if (resetn == 1'b0 || zpd)
				cur_position <= C_INIT_POSITION;
			else if (posedge_drive) begin
				if (o_dir)
					cur_position <= cur_position + 1;
				else
					cur_position <= cur_position - 1;
			end
		end
		always @ (posedge clk) begin
			if (resetn == 1'b0 || zpd)
				r_tpd <= 0;
			else if (posedge_drive) begin
				if (o_dir) begin
					if (cur_position == stroke)
						r_tpd <= 1;
				end
				else
					r_tpd <= 0;
			end
		end
	end
	endgenerate

endmodule
