module heater # (
	parameter integer C_HEAT_VALUE_WIDTH  = 12,
	parameter integer C_HEAT_TIME_WIDTH   = 32
) (
	input  wire clk,
	input  wire resetn,
	
	input  wire ext_autostart,
	output wire power,
	output wire en,
	output wire fan,
	
	input  wire [15:0] s_axis_tdata,
	input  wire [4:0]  s_axis_tid,
	output wire        s_axis_tready,
	input  wire        s_axis_tvalid,

	output wire [2-1                 :0] run_state,
	output wire [C_HEAT_VALUE_WIDTH-1:0] run_value,

	input  wire                          auto_start,
	input  wire                          auto_hold ,
	input  wire [C_HEAT_VALUE_WIDTH-1:0] holdv     ,
	input  wire [C_HEAT_VALUE_WIDTH-1:0] keep_value,
	input  wire [C_HEAT_TIME_WIDTH-1 :0] keep_time ,
	input  wire [C_HEAT_VALUE_WIDTH-1:0] finishv   ,

	input  wire                          start     ,
	input  wire                          stop
);
	localparam integer IDLE    = 2'b00;
	localparam integer RUNNING = 2'b01;
	localparam integer WAITING = 2'b11;
	localparam integer C_TEST  = 1'b0;

	reg[1:0] __state;
	reg[C_HEAT_TIME_WIDTH-1:0] __time;
	reg[C_HEAT_VALUE_WIDTH-1:0] __up_v;
	reg[C_HEAT_VALUE_WIDTH-1:0] __low_v;

	reg[C_HEAT_VALUE_WIDTH-1:0] __v;
	reg __en;

	always @ (posedge clk) begin
		if (resetn == 1'b0)
			__state <= IDLE;
		else begin
			case (__state)
			IDLE: begin
				if (start /* check auto_start */)
					__state <= RUNNING;
			end
			RUNNING: begin
				if (stop || (__time >= keep_time))
					__state <= WAITING;
			end
			WAITING: begin
				if (start)
					__state <= RUNNING;
				else if (__v < finishv)
					__state <= IDLE;
				/// @todo enable fan?
			end
			endcase
		end
	end
	
	always @ (posedge clk) begin
		if (resetn == 1'b0)
			__time <= 0;
		else if (__state != RUNNING)
			__time <= 0;
		else
			__time <= __time + 1;
	end
	
	always @ (posedge clk) begin
		case (__state)
		IDLE: begin
			if (auto_hold) begin
				__up_v  <= holdv + 5;
				__low_v <= holdv;
			end
			else begin
				__up_v  <= 0;
				__low_v <= 0;
			end
		end
		RUNNING: begin
			__up_v  <= keep_value + 5;
			__low_v <= keep_value;
		end
		default: begin
			__up_v  <= 0;
			__low_v <= 0;
		end
		endcase
	end
	
	always @ (posedge clk) begin
		if (resetn == 1'b0)
			__en <= 1'b0;
		else if (__v > __up_v)
			__en <= 1'b0;
		else if (__v < __low_v)
			__en <= 1'b1;
	end

	assign en = __en;
	assign power = (resetn && (__state != IDLE || auto_hold));
	assign fan = (__state == WAITING);
	assign run_state = __state;
	assign run_value = __v;
	
if (C_TEST) begin
	always @ (posedge clk) begin
		if (resetn == 1'b0)
			__v <= 0;
		else if (__en) begin
			if (__v != {C_HEAT_VALUE_WIDTH {1'b1}})
				__v <= __v + 1;
		end
		else begin
			if (__v != {C_HEAT_VALUE_WIDTH {1'b0}})
				__v <= __v - 1;
		end
	end
end
else begin
	/// @brief for stream interface
	assign s_axis_tready = 1'b1;
	always @ (posedge clk) begin
		if (s_axis_tready && s_axis_tvalid) begin
			if (s_axis_tid == 17) begin
				__v <= s_axis_tdata[15:16-C_HEAT_VALUE_WIDTH];
			end
		end
	end
end

endmodule
