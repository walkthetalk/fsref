module block_ram #(
	parameter integer C_BRAM_ADDR_WIDTH = 9,
	parameter integer C_STEP_NUMBER_WIDTH = 16,
	parameter integer C_SPEED_DATA_WIDTH = 16,
	parameter integer C_SPEED_ADDRESS_WIDTH = 9,
	parameter integer C_CLK_DIV_NBR = 32,	/// >= 4
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
	function integer clogb2(input integer bit_depth); begin
		for(clogb2=0; bit_depth>0; clogb2=clogb2+1)
			bit_depth = bit_depth>>1;
		end
	endfunction

	//localparam integer C_CLK_DIV_BITS = clogb2(C_CLK_DIV_NBR);
	//localparam integer C_CLK_DIV_NBR = 2**C_CLK_DIV_BITS;
	reg [C_CLK_DIV_NBR-1:0] clk_en;
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			clk_en <= 1;
		end
		else begin
			clk_en <= {clk_en[C_CLK_DIV_NBR-2:0], clk_en[C_CLK_DIV_NBR-1]};
		end
	end

	reg [C_MOTOR_NBR-1:0] rd_en;
	reg [C_MOTOR_NBR-1:0] rd_en_d1;
	reg [C_MOTOR_NBR-1:0] rd_en_d2;
	reg [C_BRAM_ADDR_WIDTH-1:0] rd_addr[C_MOTOR_NBR-1:0];
	reg [C_SPEED_DATA_WIDTH-1:0] speed[C_MOTOR_NBR-1:0];
	wire [C_MOTOR_NBR-1:0] rd_addr_conv[C_BRAM_ADDR_WIDTH-1:0];
	generate
		genvar i, j;
		for (j=0; j < C_MOTOR_NBR; j = j + 1) begin: single_motor_conv
			for (i=0; i < C_BRAM_ADDR_WIDTH; i = i + 1) begin: single_addr_bit_conv
				assign rd_addr_conv[i][j] = rd_addr[j][i];
			end
			always @ (posedge clk) begin
				if (rd_en_d2[j])
					speed[j] <= xxx;
			end
		end
	endgenerate
	reg rd_en_final;
	reg [C_BRAM_ADDR_WIDTH-1:0] rd_addr_final;
	generate
		for (i = 0; i < C_BRAM_ADDR_WIDTH; i = i+1) begin: single_addr_bit
			always @ (posedge clk) begin
				rd_en_final <= rd_en;
				rd_addr_final[i] <= (rd_en & rd_addr_conv[i]);
			end
		end
	endgenerate
	always @ (posedge clk) begin
		rd_en_d1 <= rd_en;
		rd_en_d2 <= rd_en_d1;
	end

	localparam integer IDLE = 2'b00;
	localparam integer ACCE = 2'b01;
	localparam integer KEEP = 2'b11;
	localparam integer DEAC = 2'b10;

	generate
		for (i = 0; i < C_MOTOR_NBR; i = i+1) begin: single_motor_logic
			wire clk_pulse;
			assign clk_pulse = clk_en[i];
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
					rd_en[i] <= 0;
				else if (rd_en[i])
				 	rd_en[i] <= 0;
				else if ((motor_state == IDLE) && start_pulse && clk_pulse)
					rd_en[i] <= 1;
			end

			reg [C_SPEED_DATA_WIDTH-1:0]	pulse_width;	/// represent speed
			reg [C_STEP_NUMBER_WIDTH-1:0]	remain_step;
			reg[1:0] motor_state;
			reg[1:0] next_state;
			always @ (posedge clk) begin
				if (resetn == 1'b0)
					motor_state <= IDLE;
				else begin
					case (motor_state)
					IDLE: begin
						if (start_pulse) begin
							pulse_width <= i_velocity;
							remain_step <= i_step_nbr;
							next_state <= ACCE;
						end
					end
					endcase
				end
			end
		end
	endgenerate

endmodule
