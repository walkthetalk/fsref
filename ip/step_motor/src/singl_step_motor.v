module single_step_motor #(
	parameter integer C_STEP_NUMBER_WIDTH = 16,
	parameter integer C_SPEED_DATA_WIDTH = 16,
	parameter integer C_SPEED_ADDRESS_WIDTH = 9,

)(
	input	clk,
	input	resetn,

	input	i_clk_en,

	output	o_interrupt,

	output reg o_drive,
	output reg o_dir,
	output reg o_ms0,
	output reg o_ms1,
	output wire o_xen,
	output wire o_xrst,

	input wire [C_SPEED_DATA_WIDTH-1:0]	i_speed,
	input wire [C_STEP_NUMBER_WIDTH-1:0]	i_step,
	input wire i_start,
	input wire i_stop,
	input wire i_dir,
	input wire i_en,
	input wire i_rst,
	input wire [1:0] i_ms
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
	assign acce_en_array[i] = rd_en;
	assign acce_addr_array[i] = (step_cnt > acce_addr_max ? acce_addr_max : step_cnt);
	assign deac_en_array[i] = rd_en;
	assign deac_addr_array[i] = (step_remain > deac_addr_max ? deac_addr_max : step_remain);

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
		else if (start_pulse && i_clk_en)
			start_pulse <= 0;
		else if (i_start && ~start_d1 && (motor_state == IDLE))
			start_pulse <= 1;
	end
	always @ (posedge clk) begin
		if (resetn == 1'b0)
			rd_en <= 0;
		else if (rd_en)
			rd_en <= 0;
		else if (i_clk_en) begin
			case (motor_state)
			IDLE:	rd_en <= start_pulse;
			default: rd_en <= ((speed_cnt == 0) && o_drive);
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
			if (acce_data_final > deac_data_final)
				speed_var <= acce_data_final;
			else
				speed_var <= deac_data_final;
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

	always @ (posedge clk) begin
		if (resetn == 1'b0)
			motor_state <= IDLE;
		else if (i_clk_en) begin
			case (motor_state)
			IDLE: begin
				if (start_pulse) begin
					speed_max <= i_speed;
					motor_state <= RUNNING;
				end
			end
			default: begin
				if (step_done && (speed_cnt == 0))
					motor_state <= IDLE;
			end
			endcase
		end
	end

	always @ (posedge clk) begin
		if (resetn == 1'b0)
			step_done <= 0;
		else if (i_clk_en) begin
			case (motor_state)
			IDLE: begin
				step_done <= 0;
			end
			default: begin
				if (o_drive == 1 && step_remain == 0)
					step_done <= 1;
			end
			endcase
		end
	end

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
			default: begin
				if (speed_cnt == 0 && o_drive == 1) begin
					step_cnt <= step_cnt + 1;
					step_remain <= step_remain - 1;
				end
			end
			endcase
		end
	end

	always @ (posedge clk) begin
		if (resetn == 1'b0)
			speed_cnt <= 0;
		else if (i_clk_en) begin
			case (motor_state)
			IDLE: begin
				speed_cnt <= 0;
			end
			default: begin
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
			default: begin
				if (speed_cnt == 0 && ~step_done)
					o_drive <= ~o_drive;
			end
			endcase
		end
	end

endmodule
