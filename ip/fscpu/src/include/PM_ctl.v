`timescale 1ns / 1ps

module PM_ctl # (
	parameter integer C_IMG_WW = 12,
	parameter integer C_IMG_HW = 12,
	parameter integer C_FRMN_WIDTH = 2,
	parameter integer C_STEP_NUMBER_WIDTH = 32,
	parameter integer C_SPEED_DATA_WIDTH = 32,
	parameter integer C_L2R = 1
) (
	input wire clk,
	input wire resetn,

	output reg          exe_done,

	input wire [31:0]                img_delay_cnt,
	input wire [C_FRMN_WIDTH-1:0]    img_delay_frm,

	input wire                req_single_dir,
	input wire                req_dir_back,
	input wire                req_dep_img,
	input wire [C_IMG_WW-1:0] req_img_dst,
	input wire [C_IMG_WW-1:0] req_img_tol,
	input wire [C_SPEED_DATA_WIDTH-1:0]  req_speed,
	input wire [C_STEP_NUMBER_WIDTH-1:0] req_step,

	input wire                img_pulse,
	input wire                img_valid,	/// image position valid
	input wire [C_IMG_WW-1:0] img_pos,	/// sync as pen[0]

	output wire                           m_sel     ,
	input  wire                           m_zpsign  ,
	input  wire                           m_tpsign  ,
	input  wire                           m_state   ,
	input  wire [C_STEP_NUMBER_WIDTH-1:0] m_position,
	output reg                            m_start   ,
	output reg                            m_stop    ,
	output reg  [C_SPEED_DATA_WIDTH-1:0]  m_speed   ,
	output reg  [C_STEP_NUMBER_WIDTH-1:0] m_step    ,
	output reg                            m_dir     ,
	output reg                            m_mod_remain,
	output reg  [C_STEP_NUMBER_WIDTH-1:0] m_new_remain,

	output reg                 rd_en,
	output reg  [C_IMG_WW-1:0] rd_addr,
	input  wire [C_STEP_NUMBER_WIDTH-1:0] rd_data,

	output wire [31:0]         test1,
	output wire [31:0]         test2,
	output wire [31:0]         test3,
	output wire [31:0]         test4
);

/////////////////// motor_pos ///////////////////////////////////////////
	wire [C_STEP_NUMBER_WIDTH-1:0] movie_pos;
	img_delay_ctl # (
		.C_STEP_NUMBER_WIDTH(C_STEP_NUMBER_WIDTH),
		.C_FRMN_WIDTH(C_FRMN_WIDTH),
		.C_TEST(0)
	) delay_ctl_inst (
		.clk(clk),
		.eof(img_pulse),
		.delay0_cnt  (img_delay_cnt),
		.delay0_frm  (img_delay_frm),
		.delay0_pulse(),
		.cur_pos(m_position),
		.movie_pos(movie_pos)
	);

//////////////////////////////// delay1 ////////////////////////////////////////
	reg [C_IMG_WW-1:0] pos_l;	/// left
	reg [C_IMG_WW-1:0] pos_d;	/// dst
	reg [C_IMG_WW-1:0] pos_r;	/// right
	reg [C_IMG_WW-1:0] pos_c;	/// cur
	always @ (posedge clk) begin
		if (img_pulse) begin
			pos_l <= req_img_dst - req_img_tol;
			pos_d <= req_img_dst;
			pos_r <= req_img_dst + req_img_tol;
			pos_c <= img_pos;
		end
	end

	reg pen_d1;
	always @ (posedge clk) begin
		if (resetn == 1'b0)
			pen_d1 <= 0;
		else
			pen_d1 <= (img_pulse && req_dep_img);
	end
//////////////////////////////// delay2 ////////////////////////////////////////
	reg pos_lofl;
	reg pos_rofr;
	reg pos_lofd;
	reg[C_IMG_WW-1:0] pos_dmc;
	reg[C_IMG_WW-1:0] pos_cmd;
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			pos_lofl <= 0;
			pos_rofr <= 0;
			pos_dmc  <= 0;
			pos_cmd  <= 0;
		end
		else if (pen_d1) begin
			if (pos_c < pos_l)
				pos_lofl <= 1;
			else
				pos_lofl <= 0;

			if (pos_c > pos_r)
				pos_rofr <= 1;
			else
				pos_rofr <= 0;

			if (pos_c < pos_d)
				pos_lofd <= 1;
			else
				pos_lofd <= 0;

			pos_dmc <= (pos_d - pos_c);
			pos_cmd <= (pos_c - pos_d);
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
	reg pos_needback;
	reg pos_ok;
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			rd_en        <= 1'b0;
			pos_ok       <= 0;
			pos_needback <= 0;
			rd_addr      <= 0;
		end
		else if (pen_d2) begin
			if (pos_rofr == 1'b0 && pos_lofl == 1'b0)
				pos_ok <= 1'b1;
			pos_needback <= (pos_lofd != C_L2R);
			rd_en <= 1'b1;
			if (pos_rofr)
				rd_addr <= pos_cmd;
			else if (pos_lofl)
				rd_addr <= pos_dmc;
			else
				rd_addr <= 0;
		end
		else begin
			rd_en <= 1'b0;
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

	//reg pos_needback_d4;
	reg pos_ok_d4;
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			pos_ok_d4 <= 0;
			//pos_needback_d4 <= 0;
		end
		else if (pen_d3) begin
			pos_ok_d4 <= pos_ok;
			//pos_needback_d4 <= pos_needback;
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
	reg [C_STEP_NUMBER_WIDTH-1:0] dst_pos;
	reg pos_over;
	reg pos_ok_d5;
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			dst_pos  <= 0;
			pos_over <= 0;
			pos_ok_d5 <= 0;
		end
		else if (pen_d4) begin
			pos_ok_d5 <= pos_ok_d4;

			if (pos_ok_d4)
				pos_over <= 0;
			else
				pos_over <= (pos_needback != req_dir_back);

			if (pos_needback)
				dst_pos <= movie_pos - rd_data;
			else
				dst_pos <= movie_pos + rd_data;
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
	reg m_started;
	wire m_running;
	assign m_running = m_state;
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

	/// stop
	always @ (posedge clk) begin
		if (resetn == 1'b0)
			m_stop <= 1'b0;
		else if (m_stop == 1'b1)
			m_stop <= 1'b0;
		else if (pen_d5) begin
			if (req_single_dir) begin
				/*
				if (m_running) begin
					if (req_dir_back) begin
						if (m_position <= dst_pos)
							m_stop <= 1'b1;
					end
					else begin
						if (m_position >= dst_pos)
							m_stop <= 1'b1;
					end
				end
				*/
			end
		end
	end

	/// start
	reg need_dyn_adjust;
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			m_start  <= 1'b0;
			need_dyn_adjust <= 1'b0;
		end
		else if (m_start == 1'b1) begin
			m_start  <= 1'b0;
		end
		else if (req_dep_img) begin
			if (pen_d5) begin
				if (req_single_dir) begin
					if (pos_ok_d5 == 1'b0 && pos_over == 1'b0 && m_started == 1'b0) begin
						m_start <= 1'b1;
						m_speed <= req_speed;
						if (img_valid)
							m_step <= rd_data;
						else begin
							m_step <= 0;
						end
						m_dir <= req_dir_back;
					end

					need_dyn_adjust <= ~img_valid;
				end
			end
		end
		else begin
			if (m_started == 1'b0) begin
				m_start <= 1'b1;
				m_speed <= req_speed;
				m_step  <= req_step;
				m_dir   <= req_dir_back;
			end
		end
	end

	/// change remain step
	reg [31:0] r_test1;	assign test1 = r_test1;
	reg [31:0] r_test2;	assign test2 = r_test2;
	reg [31:0] r_test3;	assign test3 = r_test3;
	reg [31:0] r_test4;	assign test4 = r_test4;
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			m_mod_remain  <= 1'b0;
		end
		else if (m_mod_remain == 1'b1) begin
			m_mod_remain  <= 1'b0;
		end
		else if (pen_d5) begin
			if (req_single_dir) begin
				if (m_running && need_dyn_adjust && img_valid) begin
					r_test1 <= dst_pos;
					r_test2 <= m_position;
					r_test3 <= movie_pos;
					r_test4 <= rd_data;
					if (req_dir_back) begin
						if (m_position > dst_pos) begin
							m_mod_remain <= 1'b1;
							m_new_remain <= m_position - dst_pos;
						end
					end
					else begin
						if (m_position < dst_pos) begin
							m_mod_remain <= 1'b1;
							m_new_remain <= dst_pos - m_position;
						end
					end
				end
			end
		end
	end

	//////////////// exe_done
	always @ (posedge clk) begin
		if (resetn == 1'b0)
			exe_done <= 1'b0;
		else if (req_single_dir) begin
			if (m_stopped)
				exe_done <= 1'b1;
		end
	end

	assign m_sel = resetn;
endmodule
