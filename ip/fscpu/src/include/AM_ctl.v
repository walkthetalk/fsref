`timescale 1ns / 1ps

module AM_ctl # (
	parameter integer C_IMG_WW = 12,
	parameter integer C_IMG_HW = 12,
	parameter integer C_STEP_NUMBER_WIDTH = 32,
	parameter integer C_SPEED_DATA_WIDTH = 32,
	parameter integer C_L2R = 1
) (
	input wire clk,
	input wire resetn,

	output reg          exe_done,

	input wire                req_ecf,
	input wire                req_abs,
	input wire                req_dep_img,
	input wire [C_IMG_HW-1:0] req_img_dst,
	input wire [C_IMG_HW-1:0] req_img_tol,
	input wire [C_SPEED_DATA_WIDTH-1:0]  req_speed,
	input wire signed [C_STEP_NUMBER_WIDTH-1:0] req_step,

	input wire                img_pulse,
	input wire                img_l_valid,
	input wire                img_r_valid,

	input wire                img_lo_valid,
	input wire [C_IMG_HW-1:0] img_lo_y    ,
	input wire                img_ro_valid,
	input wire [C_IMG_HW-1:0] img_ro_y    ,

	input wire                img_li_valid,
	input wire [C_IMG_HW-1:0] img_li_y    ,
	input wire                img_ri_valid,
	input wire [C_IMG_HW-1:0] img_ri_y    ,

	output wire                                  m_sel     ,
	input  wire                                  m_ntsign  ,
	input  wire                                  m_zpsign  ,
	input  wire                                  m_ptsign  ,
	input  wire                                  m_state   ,
	input  wire signed [C_STEP_NUMBER_WIDTH-1:0] m_position,
	output reg                                   m_start   ,
	output wire                                  m_stop    ,
	output reg  [C_SPEED_DATA_WIDTH-1:0]         m_speed   ,
	output reg  signed [C_STEP_NUMBER_WIDTH-1:0] m_step    ,
	output reg                                   m_abs     ,
	output wire                                  m_mod_remain,
	output wire signed [C_STEP_NUMBER_WIDTH-1:0] m_new_remain,

	input  wire                           m_dep_state,

	//output reg                 rd_en,
	output reg  [C_IMG_HW-1:0] rd_addr,
	input  wire [C_STEP_NUMBER_WIDTH-1:0] rd_data,

	output reg [31:0]          test1,
	output reg [31:0]          test2,
	output reg [31:0]          test3,
	output reg [31:0]          test4
);

//////////////////////////////// delay1 ////////////////////////////////////////
	//reg                img_o_valid_d1;
	reg [C_IMG_HW-1:0] img_o_diff_d1 ;
	reg                img_i_valid_d1;
	reg [C_IMG_HW-1:0] img_i_diff_d1 ;
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			//img_o_valid_d1 <= 1'b0;
			img_i_valid_d1 <= 1'b0;
			img_o_diff_d1  <= 0;
			img_i_diff_d1  <= 0;
		end
		else if (img_pulse) begin
			//img_o_valid_d1 <= (img_lo_valid & img_ro_valid);
			img_i_valid_d1 <= (img_li_valid & img_ri_valid);
			if (C_L2R) begin
				/// @note check sign
				img_o_diff_d1  <= ($signed(img_lo_y) - $signed(img_ro_y));
				img_i_diff_d1  <= ($signed(img_li_y) - $signed(img_ri_y));
			end
			else begin
				img_o_diff_d1  <= ($signed(img_ro_y) - $signed(img_lo_y));
				img_i_diff_d1  <= ($signed(img_ri_y) - $signed(img_li_y));
			end
		end
	end

	reg [1:0] m_self_running_hist;
	reg [1:0] m_dep_running_hist;
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			m_self_running_hist <= 0;
			m_dep_running_hist <= 0;
		end
		else if (img_pulse) begin
			m_self_running_hist <= {m_self_running_hist[0], m_state};
			m_dep_running_hist <= {m_dep_running_hist[0], m_dep_state};
		end
		else begin
			if (m_state)
				m_self_running_hist[0]  <= 1'b1;
			if (m_dep_state)
				m_dep_running_hist[0] <= 1'b1;
		end
	end

	/// @note cladding must valid
	reg pen_d1;
	always @ (posedge clk) begin
		if (resetn == 1'b0)
			pen_d1 <= 0;
		else if (pen_d1 == 1'b1)
			pen_d1 <= 0;
		else if (img_pulse) begin
			pen_d1 <= (req_dep_img
				&& img_l_valid
				&& img_r_valid
				&& img_lo_valid
				&& img_ro_valid);
		end
	end
//////////////////////////////// delay2 ////////////////////////////////////////
	/// calc eccentric
	reg [C_IMG_HW-1:0] img_ecf_d2   ;
	reg [C_IMG_HW-1:0] img_i_diff_d2;
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			img_ecf_d2    <= 0;
			img_i_diff_d2 <= 0;
		end
		else if (pen_d1) begin
			if (req_ecf)
				/// @note compensate 1/4
				img_ecf_d2 <= ($signed(img_o_diff_d1) - $signed(img_i_diff_d1)) >>> 2;
			else
				img_ecf_d2 <= 0;
			img_i_diff_d2 <= img_i_diff_d1;
		end
	end

	reg img_self_valid;
	reg img_real_valid;
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			img_self_valid <= 0;
			img_real_valid <= 0;
		end
		else if (pen_d1) begin
			img_self_valid <= (m_self_running_hist == 2'b00);
			img_real_valid <= (m_dep_running_hist == 2'b00);
		end
	end

	reg pen_d2;
	always @ (posedge clk) begin
		if (resetn == 1'b0)
			pen_d2 <= 0;
		else
			pen_d2 <= pen_d1;
	end
//////////////////////////////// delay3 ////////////////////////////////////////
	/// calc eccentric
	reg [C_IMG_HW-1:0] img_pos_d3   ;
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			img_pos_d3    <= 0;
		end
		else if (pen_d2) begin
			if (req_ecf && img_i_valid_d1) begin
				img_pos_d3 <= ($signed(img_i_diff_d2) - $signed(img_ecf_d2));
			end
			else begin
				img_pos_d3 <= img_o_diff_d1;
			end
		end
	end

	reg pen_d3;
	always @ (posedge clk) begin
		if (resetn == 1'b0)
			pen_d3 <= 0;
		else
			pen_d3 <= pen_d2;
	end
//////////////////////////////// delay4 ////////////////////////////////////////
	reg [C_IMG_HW-1:0] img_dst_d4   ;
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			img_dst_d4    <= 0;
		end
		else if (pen_d3) begin
			if ($signed(img_pos_d3) > 0)
				img_dst_d4 <= $signed(img_pos_d3) - $signed(req_img_dst);
			else
				img_dst_d4 <= $signed(img_pos_d3) + $signed(req_img_dst);
		end
	end

	reg pen_d4;
	always @ (posedge clk) begin
		if (resetn == 1'b0)
			pen_d4 <= 0;
		else
			pen_d4 <= pen_d3;
	end
//////////////////////////////// delay5 ////////////////////////////////////////
	/// calc eccentric
	reg [C_IMG_HW-1:0] img_needback_d5;
	reg [C_IMG_HW-1:0] img_dst_d5;

	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			img_needback_d5 <= 0;
			img_dst_d5      <= 0;
		end
		else if (pen_d4) begin
			if ($signed(img_dst_d4) > 0) begin
				img_needback_d5 <= 0;
				img_dst_d5      <= img_dst_d4;
			end
			else begin
				img_needback_d5 <= 1;
				img_dst_d5      <= ~img_dst_d4 + 1;
			end
		end
	end

	reg pen_d5;
	always @ (posedge clk) begin
		if (resetn == 1'b0)
			pen_d5 <= 0;
		else
			pen_d5 <= pen_d4;
	end

//////////////////////////////// delay6 ////////////////////////////////////////
	reg pos_needback;
	reg pos_ok;
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			//rd_en        <= 1'b0;
			pos_ok       <= 0;
			pos_needback <= 0;
			rd_addr      <= 0;
		end
		else if (pen_d5) begin
			pos_ok       <= (img_dst_d5 < req_img_tol);
			pos_needback <= img_needback_d5;
			//rd_en        <= 1'b1;
			rd_addr      <= img_dst_d5;
		end
		else begin
			//rd_en <= 1'b0;
		end
	end

	reg pen_d6;
	always @ (posedge clk) begin
		if (resetn == 1'b0)
			pen_d6 <= 0;
		else
			pen_d6 <= pen_d5;
	end

//////////////////////////////// delay7 ////////////////////////////////////////

	reg pen_d7;
	always @ (posedge clk) begin
		if (resetn == 1'b0)
			pen_d7 <= 0;
		else
			pen_d7 <= pen_d6;
	end
//////////////////////////////// delay8 ////////////////////////////////////////
	wire m_running;
	assign m_running = m_state;

	reg m_started;
	always @ (posedge clk) begin
		if (resetn == 1'b0)
			m_started <= 1'b0;
		else if (m_start)
			m_started <= 1'b1;
	end

	reg m_run_over;
	always @ (posedge clk) begin
		if (resetn == 1'b0)
			m_run_over <= 1'b0;
		else if (m_running)
			m_run_over <= 1'b1;
	end
	wire m_stopped;
	assign m_stopped = (m_run_over && ~m_running);

	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			exe_done <= 0;
		end
		else if (req_dep_img) begin
			if (pen_d7)
				exe_done <= (pos_ok && img_real_valid);
		end
		else begin
			if (m_stopped)
				exe_done <= 1;
		end
	end

	/// start
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			m_start  <= 1'b0;
		end
		else if (m_start == 1'b1) begin
			m_start  <= 1'b0;
		end
		else if (req_dep_img) begin
			if (pen_d7 && img_self_valid && ~pos_ok) begin
				m_start <= 1'b1;
				m_speed <= req_speed;
				m_step  <= (pos_needback ? (0-rd_data) : rd_data);
				m_abs   <= 1'b0;
			end
		end
		else begin
			if (m_started == 1'b0) begin
				m_start <= 1'b1;
				m_speed <= req_speed;
				m_step  <= req_step;
				m_abs   <= req_abs;
			end
		end
	end

	reg processed;
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			test1 <= 0;
			test2 <= 0;
			test3 <= 0;
			test4 <= 0;
			processed <= 0;
		end
		else if (~processed) begin
			if (pen_d7 && img_self_valid && ~pos_ok) begin
				processed <= 1;

				test1 <= req_speed;
				test2 <= rd_data;

				test3[15:0] <= img_pos_d3;
				test3[31:16] <= img_dst_d4;
				test4[15:0] <= img_dst_d5;
				test4[31:16] <= rd_addr;
			end
		end
	end

	assign m_mod_remain = 0;
	assign m_new_remain = 0;
	assign m_stop       = 0;

	assign m_sel = resetn;
endmodule
