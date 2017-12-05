`timescale 1 ns / 1 ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 11/18/2016 01:33:37 PM
// Design Name:
// Module Name: axis_blender
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//            1. valid cannot depend on ready
//            2. ready can depend on valid
//
//////////////////////////////////////////////////////////////////////////////////
module axis_blender #
(
	parameter integer C_CHN_WIDTH		=  8,
	parameter integer C_S0_CHN_NUM		=  1,
	parameter integer C_S1_CHN_NUM		=  3,
	parameter integer C_ALPHA_WIDTH		=  8,
	parameter integer C_S1_ENABLE           =  0,
	parameter integer C_IN_NEED_WIDTH	=  8,
	parameter integer C_OUT_NEED_WIDTH	=  7,	/// must be (C_IN_NEED_WIDTH - 1), min val is 0
	parameter integer C_M_WIDTH		= 24,	/// must be max(C_S0_CHN_NUM, C_S1_CHN_NUM) * C_CHN_WIDTH
	parameter integer C_TEST		= 0
)
(
	input wire clk,
	input wire resetn,

	/// S0_AXIS
	input  wire                                    s0_axis_tvalid,
	input  wire [C_CHN_WIDTH * C_S0_CHN_NUM - 1:0] s0_axis_tdata,
	input  wire [C_IN_NEED_WIDTH:0]                s0_axis_tuser,
	input  wire                                    s0_axis_tlast,
	output wire                                    s0_axis_tready,

	/// S1_AXIS
	input  wire                                    s1_enable,
	input  wire                                    s1_axis_tvalid,
	input  wire [C_CHN_WIDTH * C_S1_CHN_NUM + C_ALPHA_WIDTH - 1:0] s1_axis_tdata,
	input  wire                                    s1_axis_tuser,
	input  wire                                    s1_axis_tlast,
	output wire                                    s1_axis_tready,

	/// M_AXIS
	output wire                                    m_axis_tvalid,
	output wire [C_M_WIDTH-1:0]                    m_axis_tdata,
	output wire [C_OUT_NEED_WIDTH:0]               m_axis_tuser,
	output wire                                    m_axis_tlast,
	input  wire                                    m_axis_tready
);
	localparam integer C_S0_WIDTH = C_CHN_WIDTH * C_S0_CHN_NUM;
	localparam integer C_S1_WIDTH = C_CHN_WIDTH * C_S1_CHN_NUM;
	localparam integer C_M_CHN_NUM = (C_S0_CHN_NUM > C_S1_CHN_NUM ? C_S0_CHN_NUM : C_S1_CHN_NUM);

	wire out_ready;
	assign out_ready = (~m_axis_tvalid || m_axis_tready);
	wire needs1;
	wire input_valid;
generate
	wire original_needs1;
	if (C_IN_NEED_WIDTH > 0)
		assign original_needs1 = s0_axis_tuser[1];
	else
		assign original_needs1 = 1'b1;
	if (C_S1_ENABLE)
		assign needs1 = s1_enable & original_needs1;
	else
		assign needs1 = original_needs1;
endgenerate
	assign input_valid = (s0_axis_tvalid && (~needs1 || s1_axis_tvalid));
	assign s0_axis_tready = (out_ready && input_valid);
	assign s1_axis_tready = (out_ready && (s0_axis_tvalid && s1_axis_tvalid && needs1));

generate
	genvar i;
if (C_ALPHA_WIDTH == 0) begin: without_alpha
	reg                                    mr_axis_tvalid;
	reg [C_M_WIDTH-1:0]                    mr_axis_tdata ;
	reg [C_OUT_NEED_WIDTH:0]               mr_axis_tuser ;
	reg                                    mr_axis_tlast ;
	assign m_axis_tvalid = mr_axis_tvalid;
	assign m_axis_tdata  = mr_axis_tdata ;
	assign m_axis_tuser  = mr_axis_tuser ;
	assign m_axis_tlast  = mr_axis_tlast ;

	/// regenerate s_axis_data
	wire [C_M_WIDTH-1:0] s0_tdata;
	for (i = 0; i < C_M_WIDTH / C_S0_WIDTH; i = i+1) begin
		assign s0_tdata[C_S0_WIDTH * (i+1) - 1 : C_S0_WIDTH * i] = s0_axis_tdata;
	end
	wire [C_M_WIDTH-1:0] s1_tdata;
	for (i = 0; i < C_M_WIDTH / C_S1_WIDTH; i = i+1) begin
		assign s1_tdata[C_S1_WIDTH * (i+1) - 1 : C_S1_WIDTH * i] = s1_axis_tdata;
	end

	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			mr_axis_tvalid   <= 0;
			mr_axis_tdata    <= 0;
			mr_axis_tuser[0] <= 0;
			mr_axis_tlast    <= 0;
		end
		else if (out_ready) begin
			mr_axis_tvalid <= input_valid;
			mr_axis_tdata <= (needs1 ? s1_tdata : s0_tdata);
			mr_axis_tuser[0] <= s0_axis_tuser[0];
			mr_axis_tlast <= s0_axis_tlast;
		end
	end

	if (C_IN_NEED_WIDTH > 1) begin
		always @ (posedge clk) begin
			if (resetn == 1'b0)
				mr_axis_tuser[C_IN_NEED_WIDTH-1:1] <= 0;
			else if (out_ready)
				mr_axis_tuser[C_IN_NEED_WIDTH-1:1] <= s0_axis_tuser[C_IN_NEED_WIDTH:2];
		end
	end
end
else begin: with_alpha
	localparam integer C_DELAY = 3;
	reg                                    mr_axis_tvalid[C_DELAY-1:0];
	reg [C_OUT_NEED_WIDTH:0]               mr_axis_tuser [C_DELAY-1:0];
	reg                                    mr_axis_tlast [C_DELAY-1:0];
	assign m_axis_tvalid = mr_axis_tvalid[C_DELAY-1];
	assign m_axis_tuser  = mr_axis_tuser [C_DELAY-1];
	assign m_axis_tlast  = mr_axis_tlast [C_DELAY-1];

	for (i = 1; i < C_DELAY; i = i+1) begin: single_delay
		always @ (posedge clk) begin
			if (resetn == 1'b0) begin
				mr_axis_tvalid[i] <= 0;
				mr_axis_tlast [i] <= 0;
				mr_axis_tuser [i] <= 0;
			end
			else if (out_ready) begin
				mr_axis_tvalid[i] <= mr_axis_tvalid[i-1];
				mr_axis_tlast [i] <= mr_axis_tlast [i-1];
				mr_axis_tuser [i] <= mr_axis_tuser [i-1];
			end
		end
	end
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			mr_axis_tvalid[0] <= 0;
			mr_axis_tlast [0] <= 0;
			mr_axis_tuser [0][0] <= 0;
		end
		else if (out_ready) begin
			mr_axis_tvalid[0] <= input_valid;
			mr_axis_tlast [0] <= s0_axis_tlast;
			mr_axis_tuser [0][0] <= s0_axis_tuser[0];
		end
	end
	if (C_IN_NEED_WIDTH > 1) begin
		always @ (posedge clk) begin
			if (resetn == 1'b0)
				mr_axis_tuser[0][C_IN_NEED_WIDTH-1:1] <= 0;
			else if (out_ready)
				mr_axis_tuser[0][C_IN_NEED_WIDTH-1:1] = s0_axis_tuser[C_IN_NEED_WIDTH:2];
		end
	end

	/// split input
	wire [C_CHN_WIDTH-1:0]     s0_pure_data[C_S0_CHN_NUM-1:0];
	wire [C_CHN_WIDTH-1:0]     s1_pure_data[C_S1_CHN_NUM-1:0];
	wire [C_ALPHA_WIDTH-1:0]   alpha_data;
	assign alpha_data    = s1_axis_tdata[C_S1_WIDTH + C_ALPHA_WIDTH - 1 : C_S1_WIDTH];

	/// delay0
	reg[C_CHN_WIDTH-1:0]                   s0_data_d0     [C_S0_CHN_NUM-1:0];
	reg[C_ALPHA_WIDTH-1:0]                 nalpha_d0;
	reg[C_CHN_WIDTH + C_ALPHA_WIDTH -1:0]  s1_mul_alpha_d0[C_S1_CHN_NUM-1:0];

	always @ (posedge clk) begin
		if (out_ready) begin
			if (needs1)
				nalpha_d0       <= ~alpha_data;
			else
				nalpha_d0       <= {C_ALPHA_WIDTH{1'b1}};
		end
	end

	/// delay1
	reg[C_CHN_WIDTH + C_ALPHA_WIDTH - 1:0]  s0_mul_alpha_d1[C_S0_CHN_NUM-1:0];
	reg[C_CHN_WIDTH + C_ALPHA_WIDTH - 1:0]  s1_mul_alpha_d1[C_S1_CHN_NUM-1:0];

	for (i = 0; i < C_S0_CHN_NUM; i = i+1) begin
		assign s0_pure_data[i] = s0_axis_tdata[C_CHN_WIDTH*(i+1)-1:C_CHN_WIDTH*i];
		always @ (posedge clk) begin
			if (out_ready)
				s0_data_d0[i] <= s0_pure_data[i];
		end

		always @ (posedge clk) begin
			if (out_ready)
				s0_mul_alpha_d1[i] <= s0_data_d0[i] * nalpha_d0;
		end
	end
	for (i = 0; i < C_S1_CHN_NUM; i = i+1) begin
		assign s1_pure_data[i] = s1_axis_tdata[C_CHN_WIDTH*(i+1)-1:C_CHN_WIDTH*i];
		always @ (posedge clk) begin
			if (out_ready) begin
				if (needs1)
					s1_mul_alpha_d0[i] <= s1_pure_data[i] * alpha_data;
				else
					s1_mul_alpha_d0[i] <= 0;
			end
		end

		always @ (posedge clk) begin
			if (out_ready)
				s1_mul_alpha_d1[i] <= s1_mul_alpha_d0[i];
		end
	end

	/// output data
	wire [C_CHN_WIDTH + C_ALPHA_WIDTH-1:0] s0_mul_alpha_d1_regen[C_M_CHN_NUM-1:0];
	wire [C_CHN_WIDTH + C_ALPHA_WIDTH-1:0] s1_mul_alpha_d1_regen[C_M_CHN_NUM-1:0];
	reg [C_CHN_WIDTH-1:0]  mr_axis_tdata[C_M_CHN_NUM-1:0];
	for (i = 0; i < C_M_CHN_NUM; i = i+1) begin
		assign s0_mul_alpha_d1_regen[i] = s0_mul_alpha_d1[C_M_CHN_NUM == C_S0_CHN_NUM ? i : 0];
		assign s1_mul_alpha_d1_regen[i] = s1_mul_alpha_d1[C_M_CHN_NUM == C_S1_CHN_NUM ? i : 0];
		always @ (posedge clk) begin
			if (out_ready)
				mr_axis_tdata[i] <= ((s0_mul_alpha_d1_regen[i] + s1_mul_alpha_d1_regen[i]) >> C_ALPHA_WIDTH);
		end
		assign m_axis_tdata[C_CHN_WIDTH*(i+1)-1:C_CHN_WIDTH*i] = mr_axis_tdata[i];
	end
end
endgenerate

endmodule
