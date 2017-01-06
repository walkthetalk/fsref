`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 11/18/2016 01:33:37 PM
// Design Name:
// Module Name: pcfa
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
//
//////////////////////////////////////////////////////////////////////////////////
module pcfa #
(
	C_PIXEL_WIDTH = 8,
	C_BAYER_PHASE = 0
) (
	input wire clk,
	input wire resetn,

	input wire	f0_full,
	output wire [C_PIXEL_WIDTH+1 : 0] f0_wr_data,
	output wire	f0_wr_en,

	input wire	f0_empty,
	input wire [C_PIXEL_WIDTH+1 : 0] f0_rd_data,
	output wire	f0_rd_en,

	input wire	f1_full,
	output wire [C_PIXEL_WIDTH+1 : 0] f1_wr_data,
	output wire	f1_wr_en,

	input wire	f1_empty,
	input wire [C_PIXEL_WIDTH+1 : 0] f1_rd_data,
	output wire	f1_rd_en,

	input wire	f2_full,
	output wire [C_PIXEL_WIDTH+1 : 0] f2_wr_data,
	output wire	f2_wr_en,

	input wire	f2_empty,
	input wire [C_PIXEL_WIDTH+1 : 0] f2_rd_data,
	output wire	f2_rd_en,

	input wire	f3_full,
	output wire [C_PIXEL_WIDTH+1 : 0] f3_wr_data,
	output wire	f3_wr_en,

	input wire	f3_empty,
	input wire [C_PIXEL_WIDTH+1 : 0] f3_rd_data,
	output wire	f3_rd_en,

	input wire s_axis_tvalid,
	input wire [C_PIXEL_WIDTH-1:0] s_axis_tdata,
	input wire s_axis_tuser,
	input wire s_axis_tlast,
	output wire s_axis_tready,

	output wire m_axis_tvalid,
	output wire [C_PIXEL_WIDTH*3-1:0] m_axis_tdata,
	output wire m_axis_tuser,
	output wire m_axis_tlast,
	input wire m_axis_tready
);

	wire snext;
	assign snext = s_axis_tvalid & s_axis_tready;

	reg [3:0] fifo_valid;
	reg [4:0] pixel_valid;
	reg [4:0] line_valid;

	reg [C_PIXEL_WIDTH+1 : 0] d00,d01,d02,d03;
	reg [C_PIXEL_WIDTH+1 : 0] d10,d11,d12,d13;
	reg [C_PIXEL_WIDTH+1 : 0] d20,d21,d22,d23;
	reg [C_PIXEL_WIDTH+1 : 0] d30,d31,d32,d33;
	reg [C_PIXEL_WIDTH+1 : 0] d40,d41,d42,d43;

	wire [C_PIXEL_WIDTH+1 : 0] d04;
	wire [C_PIXEL_WIDTH+1 : 0] d14;
	wire [C_PIXEL_WIDTH+1 : 0] d24;
	wire [C_PIXEL_WIDTH+1 : 0] d34;
	reg [C_PIXEL_WIDTH+1 : 0] d44;

	/// fifo write data
	assign f0_wr_data = f1_rd_data;
	assign f1_wr_data = f2_rd_data;
	assign f2_wr_data = f3_rd_data;
	assign f3_wr_data = d44;

	/// fifo write enable
	always @(posedge clk) begin
		if (resetn == 1'b0) begin
			f0_wr_en <= 1'b0;
			f1_wr_en <= 1'b0;
			f2_wr_en <= 1'b0;
			f3_wr_en <= 1'b0;
		end
		else begin
			f0_wr_en <= f1_rd_en;
			f1_wr_en <= f2_rd_en;
			f2_wr_en <= f3_rd_en;
			f3_wr_en <= snext;	/// @note: do not use pixel_valid[4]
		end
	end

	/// fifo read enable
	assign f0_rd_en = snext & fifo_valid[0];
	assign f1_rd_en = snext & fifo_valid[1];
	assign f2_rd_en = snext & fifo_valid[2];
	assign f3_rd_en = snext & fifo_valid[3];

	/// data x4
	assign d04 = f0_rd_data;
	assign d14 = f1_rd_data;
	assign d24 = f2_rd_data;
	assign d34 = f3_rd_data;
	always @(posedge clk) begin
		if (resetn == 1'b0)
			d44 <= 0;
		else if (snext)
			d44 <= {s_axis_tlast, s_axis_tuser, s_axis_tdata};
		else
			d44 <= d44;
	end

	always @(posedge clk) begin
		if (resetn == 1'b0) begin
			d00 <= 0;
			d01 <= 0;
			d02 <= 0;
			d03 <= 0;
		end
		else if (f0_rd_en) begin
			d00 <= d01;
			d01 <= d02;
			d02 <= d03;
			d03 <= d04;
		end
	end

	always @(posedge clk) begin
		if (resetn == 1'b0) begin
			d10 <= 0;
			d11 <= 0;
			d12 <= 0;
			d13 <= 0;
		end
		else if (f1_rd_en) begin
			d10 <= d11;
			d11 <= d12;
			d12 <= d13;
			d13 <= d14;
		end
	end

	always @(posedge clk) begin
		if (resetn == 1'b0) begin
			d20 <= 0;
			d21 <= 0;
			d22 <= 0;
			d23 <= 0;
		end
		else if (f2_rd_en) begin
			d20 <= d21;
			d21 <= d22;
			d22 <= d23;
			d23 <= d24;
		end
	end

	always @(posedge clk) begin
		if (resetn == 1'b0) begin
			d30 <= 0;
			d31 <= 0;
			d32 <= 0;
			d33 <= 0;
		end
		else if (f3_rd_en) begin
			d30 <= d31;
			d31 <= d32;
			d32 <= d33;
			d33 <= d34;
		end
	end

	/// pixel_valid
	always @(posedge clk) begin
		if (resetn == 1'b0)
			pixel_valid <= 0;
		else if (snext) begin
			if (s_axis_tuser | d44[C_PIXEL_WIDTH])	/// start of frame/line
				pixel_valid <= 5'b10000;
			else
				pixel_valid <= {1'b1, pixel_valid[4:1]};
		end
		else
			pixel_valid <= pixel_valid;
	end

	/// fifo_valid
	always @(posedge clk) begin
		if (resetn == 1'b0)
			fifo_valid <= 0;
		else if (snext && s_axis_tlast)
			fifo_valid <= {1'b1, fifo_valid[3:1]};
		else
			fifo_valid <= fifo_valid;
	end

	/// line_valid
	always @(posedge clk) begin
		if (resetn == 1'b0)
			line_valid <= 0;
		else if (snext) begin
			//@note: do not need, because one line must contain more than single one pixel.
			//if (s_axis_tuser && s_axis_tlast)
			//	line_valid <= 4'b1000;
			//else
			if (s_axis_tlast)
				line_valid <= {1'b1, line_valid[3:1]};
			else if (s_axis_tuser)
				line_valid <= 0;
			else
				line_valid <= line_valid;
		end
		else
			line_valid <= line_valid;
	end

	/// bayer phase
	localparam integer BAYER_PHASE_R = 2'b00;
	localparam integer BAYER_PHASE_Gr = 2'b01;
	localparam integer BAYER_PHASE_Gb = 2'b10;
	localparam integer BAYER_PHASE_B = 2'b11;

	reg line_phase;
	reg pixel_phase;
	wire[1:0] bayer_phase;
	assign bayer_phase = {line_phase, pixel_phase};

	always @(posedge clk) begin
		if (resetn == 1'b0)
			line_phase <= 1'b0;
		else if (snext) begin
			if (s_axis_tuser) begin	/// start of frame
				line_phase <= C_BAYER_PHASE[1];
			end
			else if (d44[C_PIXEL_WIDTH]) begin	/// start of line
				line_phase <= ~line_phase;
			end
			else begin
				line_phase <= line_phase;
			end
		end
		else
			line_phase <= line_phase;
	end

	always @(posedge clk) begin
		if (resetn == 1'b0)
			pixel_phase <= 1'b0;
		else if (snext) begin
			if (s_axis_tuser | d44[C_PIXEL_WIDTH]) begin	/// start of frame/line
				pixel_phase <= C_BAYER_PHASE[0];
			end
			else begin
				pixel_phase <= ~pixel_phase;
			end
		end
		else
			pixel_phase <= pixel_phase;
	end

	/// delay
	wire matrix_full;
	assign matrix_full = (pixel_valid == 5'b11111 && line_valid == 4'b1111);

	reg dvalid_d1; wire ready_d1;

	reg dvalid_d2; wire ready_d2;
	reg[1:0] bayer_phase_d2;
	reg sof_d2; reg eol_d2;
	reg[C_PIXEL_WIDTH-1:0] center;
	reg[C_PIXEL_WIDTH:0] sum_ud;
	reg[C_PIXEL_WIDTH:0] sum_lr;
	reg[C_PIXEL_WIDTH:0] sum_lft;
	reg[C_PIXEL_WIDTH:0] sum_rt;
	reg[C_PIXEL_WIDTH-1:0] diff_ud;
	reg[C_PIXEL_WIDTH-1:0] diff_lr;

	wire [C_PIXEL_WIDTH-1:0] half_ud;
	assign half_ud = sum_ud[C_PIXEL_WIDTH:1];
	wire [C_PIXEL_WIDTH-1:0] half_lr;
	assign half_lr = sum_lr[C_PIXEL_WIDTH:1];
	wire [C_PIXEL_WIDTH-1:0] quart_diamond;
	assign quart_diamond = (sum_ud + sum_lr) / 4;
	wire [C_PIXEL_WIDTH-1:0] quart_rectangle;
	assign quart_rectangle = (sum_lft + sum_rt) / 4;


	reg dvalid_d3; wire ready_d3;
	reg sof_d3; reg eol_d3;
	reg [C_PIXEL_WIDTH-1:0] R;
	reg [C_PIXEL_WIDTH-1:0] G;
	reg [C_PIXEL_WIDTH-1:0] B;

	assign m_axis_tdata = {R, G, B};
	assign m_axis_tuser = sof_d3;
	assign m_axis_tlast = eol_d3;
	assign m_axis_tvalid = dvalid_d3;

	/// ready
	assign ready_d1 = ~(dvalid_d1 & matrix_full) | ready_d2;
	assign ready_d2 = ~dvalid_d2 | ready_d3;
	assign s_axis_tready = ready_d1;

	/// dvalid
	always @(posedge clk) begin
		if (resetn == 1'b0)
			dvalid_d1 <= 1'b0;
		else if (snext)
			dvalid_d1 <= 1'b1;
		else if (ready_d2)
			dvalid_d1 <= 1'b0;
		else
			dvalid_d1 <= dvalid_d1;
	end

	always @(posedge clk) begin
		if (resetn == 1'b0)
			dvalid_d2 <= 1'b0;
		else if (ready_d2 & (dvalid_d1 & matrix_full))
			dvalid_d2 <= 1'b1;
		else if (ready_d3)
			dvalid_d2 <= 1'b0;
		else
			dvalid_d2 <= dvalid_d2;
	end

	always @(posedge clk) begin
		if (resetn == 1'b0)
			dvalid_d3 <= 1'b0;
		else if (ready_d3 & dvalid_d2)
			dvalid_d3 <= 1'b1;
		else if (m_axis_tready & dvalid_d3)
			dvalid_d3 <= 1'b0;
		else
			dvalid_d3 <= dvalid_d3;
	end

	always @(posedge clk) begin
		if (resetn == 1'b0) begin
			bayer_phase_d2 <= 2'b00;
			sof_d2 <= 1'b0;
			eol_d2 <= 1'b0;
		end
		else if (ready_d2 & (dvalid_d1 & matrix_full)) begin
			bayer_phase_d2 <= bayer_phase;
			sof_d2 <= d00[C_PIXEL_WIDTH];
			eol_d2 <= d44[C_PIXEL_WIDTH+1];
		end
		else begin
			bayer_phase_d2 <= bayer_phase_d2;
			sof_d2 <= sof_d2;
			eol_d2 <= eol_d2;
		end
	end

	always @(posedge clk) begin
		if (resetn == 1'b0) begin
			sum_ud	<= 0;
			sum_lr	<= 0;
			sum_lft	<= 0;
			sum_rt	<= 0;
			diff_ud	<= 0;
			diff_lr	<= 0;
			center	<= 0;
		end
		else if (ready_d2 & (dvalid_d1 & matrix_full)) begin
			sum_ud	<= d12 + d32;
			sum_lr	<= d21 + d23;
			sum_lft	<= d11 + d31;
			sum_rt	<= d31 + d33;
			diff_ud	<= (d02 > d42 ? d02 - d42 : d42 - d02);
			diff_lr	<= (d20 > d24 ? d20 - d24 : d24 - d20);
			center	<= d22;
		end
		else begin
			sum_ud	<= sum_ud;
			sum_lr	<= sum_lr;
			sum_lft	<= sum_lft;
			sum_rt	<= sum_rt;
			diff_ud	<= diff_ud;
			diff_lr	<= diff_lr;
			center	<= center;
		end
	end

	always @(posedge clk) begin
		if (resetn == 1'b0) begin
			R <= 0;
			G <= 0;
			B <= 0;
		end
		else if (ready_d3 & dvalid_d2) begin
		/*
			case (bayer_phase_d2)
			BAYER_PHASE_R: begin
				R	<= center;
				B	<= quart_rectangle;
				if (diff_ud < diff_lr)
					G <= half_ud;
				else if (diff_ud > diff_lr)
					G <= half_lr;
				else
					G <= quart_diamond;
			end
			BAYER_PHASE_Gr: begin
				R	<= half_lr;
				G	<= center;
				B	<= half_ud;
			end
			BAYER_PHASE_Gb: begin
				R	<= half_ud;
				G	<= center;
				B	<= half_lr;
			end
			BAYER_PHASE_B: begin
				R	<= quart_rectangle;
				B	<= center;
				if (diff_ud < diff_lr)
					G <= half_ud;
				else if (diff_ud > diff_lr)
					G <= half_lr;
				else
					G <= quart_diamond;
			end
			default: begin
				R <= 0;
				G <= 0;
				B <= 0;
			end
			endcase
		 */
			case (bayer_phase_d2)
			BAYER_PHASE_R: begin
				R	<= center;
				B	<= quart_rectangle;
			end
			BAYER_PHASE_Gr: begin
				R	<= half_lr;
				B	<= half_ud;
			end
			BAYER_PHASE_Gb: begin
				R	<= half_ud;
				B	<= half_lr;
			end
			BAYER_PHASE_B: begin
				R	<= quart_rectangle;
				B	<= center;
			end
			default: begin
				R <= 0;
				B <= 0;
			end
			endcase

			if (bayer_phase_d2[0] != bayer_phase_d2[1])	/// Gr or Gb
				G <= center;
			else if (diff_ud < diff_lr)
				G <= half_ud;
			else if (diff_ud > diff_lr)
				G <= half_lr;
			else
				G <= quart_diamond;
		end
		else begin
			R <= R;
			G <= G;
			B <= B;
		end
	end
	
	always @(posedge clk) begin
		if (resetn == 1'b0)
			dvalid_d3 <= 1'b0;
		else if (ready_d3 & dvalid_d2)
			dvalid_d3 <= 1'b1;
		else if (m_axis_tready)
			dvalid_d3 <= 1'b0;
		else
			dvalid_d3 <= dvalid_d3;
	end

	///@note: maybe result in long assign path
	assign ready_d3 = ~dvalid_d3 | m_axis_tready;

endmodule

