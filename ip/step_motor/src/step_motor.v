`include "./block_ram.v"

module step_motor #(
	parameter integer C_STEP_NUMBER_WIDTH = 16,
	parameter integer C_SPEED_DATA_WIDTH = 16,
	parameter integer C_SPEED_ADDRESS_WIDTH = 9,
	parameter integer C_CLK_DIV_NBR = 32,	/// >= 4 (block_ram read delay)
	parameter integer C_MOTOR_NBR = 4

)(
	input	clk,
	input	resetn,

	input	i_clk_en,

	output	o_interrupt,

	output wire o_drive,
	output wire o_dir,
	output wire o_ms0,
	output wire o_ms1,
	output wire o_xen,
	output wire o_xrst,

	input wire [C_SPEED_DATA_WIDTH-1:0]	i_velocity,
	input wire [C_STEP_NUMBER_WIDTH-1:0]	i_step_nbr,
	input wire i_start,
	input wire i_stop,
	input wire i_dir,
	input wire i_en,
	input wire i_rst,
	input wire [1:0] i_ms
);
	function integer clogb2(input integer bit_depth);
		for(clogb2=0; bit_depth>0; clogb2=clogb2+1) begin
			bit_depth = bit_depth>>1;
		end
	endfunction

	/// block ram for speed data
	reg rd_en_final;
	reg [C_SPEED_ADDRESS_WIDTH-1:0] rd_addr_final;
	wire [C_SPEED_DATA_WIDTH-1:0] rd_data_final;
	block_ram #(
		.C_DATA_WIDTH(C_SPEED_DATA_WIDTH),
		.C_ADDRESS_WIDTH(C_SPEED_ADDRESS_WIDTH)
	) speed_data (
		.clk(clk),
		.rd_en(rd_en_final),
		.rd_addr(rd_addr_final),
		.rd_data(rd_data_final)
	);

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
	wire [C_MOTOR_NBR-1:0] rd_en_array;
	wire [C_SPEED_ADDRESS_WIDTH-1:0] rd_addr_array[C_MOTOR_NBR-1:0];
	wire [C_MOTOR_NBR-1:0] rd_addr_conv[C_SPEED_ADDRESS_WIDTH-1:0];
	generate
		genvar i, j;
		for (j=0; j < C_MOTOR_NBR; j = j + 1) begin: single_motor_conv
			for (i=0; i < C_SPEED_ADDRESS_WIDTH; i = i + 1) begin: single_addr_bit_conv
				assign rd_addr_conv[i][j] = rd_addr_array[j][i];
			end
		end
	endgenerate
	generate
		for (i = 0; i < C_SPEED_ADDRESS_WIDTH; i = i+1) begin: single_addr_bit
			always @ (posedge clk) begin
				rd_en_final <= rd_en_array;
				rd_addr_final[i] <= (rd_en_array & rd_addr_conv[i]);
			end
		end
	endgenerate

	/// state macro
	localparam integer IDLE = 2'b00;
	localparam integer ACCE = 2'b01;
	localparam integer KEEP = 2'b11;
	localparam integer DEAC = 2'b10;

	/// motor logic
	generate
		for (i = 0; i < C_MOTOR_NBR; i = i+1) begin: single_motor_logic
			wire clk_pulse;
			reg [C_SPEED_DATA_WIDTH-1:0]	speed_max;
			reg [C_SPEED_DATA_WIDTH-1:0]    speed;
			reg [C_SPEED_DATA_WIDTH-1:0]    speed_cnt;
			reg [C_STEP_NUMBER_WIDTH-1:0]   step_cnt;
			reg [C_STEP_NUMBER_WIDTH-1:0]	remain_step;
			reg[1:0] motor_state;
			reg[1:0] next_state;
			assign clk_pulse = clk_en[i];
			reg rd_en;
			reg [C_SPEED_ADDRESS_WIDTH-1:0] rd_addr;
			assign rd_en_array[i] = rd_en;
			assign rd_addr_array[i] = rd_addr;

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
				else if (start_pulse && clk_pulse)
					start_pulse <= 0;
				else if (i_start && ~start_d1 && (motor_state == IDLE))
					start_pulse <= 1;
			end
			always @ (posedge clk) begin
				if (resetn == 1'b0)
					rd_en <= 0;
				else if (rd_en)
					rd_en <= 0;
				else if (clk_pulse) begin
					case (motor_state)
					IDLE:	rd_en <= start_pulse;
					default: rd_en <= (speed_cnt == 0);
					endcase
				end
			end
			reg rd_en_d1;
			reg rd_en_d2;
			always @ (posedge clk) begin
				rd_en_d1 <= rd_en;
				rd_en_d2 <= rd_en_d1;
			end
			always @ (posedge clk) begin
				if (resetn == 1'b0)
					rd_addr <= 0;
				else begin
					case (motor_state)
					IDLE:	rd_addr <= 0;
					ACCE:   if (rd_en) rd_addr <= rd_addr + 1;
					KEEP:   if (rd_en) rd_addr <= rd_addr;
					DEAC:	if (rd_en) rd_addr <= rd_addr - 1;
					endcase
				end
			end
			always @ (posedge clk) begin
				if (rd_en_d2) begin
					speed <= (rd_data_final > speed_max ? rd_data_final : speed_max);
				end
			end

			always @ (posedge clk) begin
				if (resetn == 1'b0)
					motor_state <= IDLE;
				else if (clk_pulse) begin
					case (motor_state)
					IDLE: begin
						if (start_pulse) begin
							speed_max <= i_velocity;
							remain_step <= i_step_nbr;
							motor_state <= ACCE;
							speed_cnt <= 0;
							step_cnt <= 0;
						end
					end
					ACCE: begin
						rd_addr[i] <= rd_addr[i] + 1;
					end
					endcase
				end
			end
		end	/// for
	endgenerate

endmodule
