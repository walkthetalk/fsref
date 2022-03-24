`include "../src/include/block_ram.v"
`include "../src/include/block_ram_container.v"
`include "../src/include/img_delay_ctl.v"
`include "../src/include/PM_ctl.v"
`include "../src/include/AM_ctl.v"
`include "../src/include/DISCHARGE_ctl.v"
`include "../src/fscpu.v"

module test_fscpu # (
	parameter integer C_IMG_HW = 8,
	parameter integer C_IMG_WW = 8,
	parameter integer C_SPEED_DATA_WIDTH = 32,
	parameter integer C_STEP_NUMBER_WIDTH = 8
) (
);

	reg clk;
	reg resetn;

	reg bpm_init;
	reg bpm_wr_en;
	reg [C_STEP_NUMBER_WIDTH-1:0] bpm_data;
	wire [C_IMG_WW:0] bpm_size;

	reg req_en;
	reg[31:0] req_cmd;
	reg[127:0] req_param;
	wire req_done;
	wire[31:0] req_err;

	reg ana_done;
	reg lft_valid;
	reg[C_IMG_WW-1:0] lft_edge;
	reg rt_valid;
	reg[C_IMG_WW-1:0] rt_edge;

	reg                     x_ana_done              ;
	reg                     x_lft_valid             ;
	reg [C_IMG_WW-1:0]      x_lft_edge              ;
	reg                     x_lft_header_outer_valid;
	reg [C_IMG_WW-1:0]      x_lft_header_outer_y    ;
	reg                     x_lft_header_inner_valid;
	reg [C_IMG_WW-1:0]      x_lft_header_inner_y    ;
	reg                     x_rt_valid              ;
	reg [C_IMG_WW-1:0]      x_rt_edge               ;
	reg                     x_rt_header_outer_valid ;
	reg [C_IMG_WW-1:0]      x_rt_header_outer_y     ;
	reg                     x_rt_header_inner_valid ;
	reg [C_IMG_WW-1:0]      x_rt_header_inner_y     ;

	wire                           ml_sel       ;
	reg                            ml_zpsign    ;
	reg                            ml_tpsign    ;
	reg                            ml_state     ;
	reg  [C_STEP_NUMBER_WIDTH-1:0] ml_position  ;
	wire                           ml_start     ;
	wire                           ml_stop      ;
	wire [C_SPEED_DATA_WIDTH-1:0]  ml_speed     ;
	wire [C_STEP_NUMBER_WIDTH-1:0] ml_step      ;
	wire                           ml_dir       ;
	wire                           ml_mod_remain;
	wire [C_STEP_NUMBER_WIDTH-1:0] ml_new_remain;

	wire                           mr_sel       ;
	reg                            mr_zpsign    ;
	reg                            mr_tpsign    ;
	reg                            mr_state     ;
	reg  [C_STEP_NUMBER_WIDTH-1:0] mr_position  ;
	wire                           mr_start     ;
	wire                           mr_stop      ;
	wire [C_SPEED_DATA_WIDTH-1:0]  mr_speed     ;
	wire [C_STEP_NUMBER_WIDTH-1:0] mr_step      ;
	wire                           mr_dir       ;
	wire                           mr_mod_remain;
	wire [C_STEP_NUMBER_WIDTH-1:0] mr_new_remain;

	wire                           mx_sel       ;
	reg                            mx_zpsign    ;
	reg                            mx_tpsign    ;
	reg                            mx_state     ;
	reg  [C_STEP_NUMBER_WIDTH-1:0] mx_position  ;
	wire                           mx_start     ;
	wire                           mx_stop      ;
	wire [C_SPEED_DATA_WIDTH-1:0]  mx_speed     ;
	wire [C_STEP_NUMBER_WIDTH-1:0] mx_step      ;
	wire                           mx_dir       ;
	wire                           mx_mod_remain;
	wire [C_STEP_NUMBER_WIDTH-1:0] mx_new_remain;

	wire                           my_sel       ;
	reg                            my_zpsign    ;
	reg                            my_tpsign    ;
	reg                            my_state     ;
	reg  [C_STEP_NUMBER_WIDTH-1:0] my_position  ;
	wire                           my_start     ;
	wire                           my_stop      ;
	wire [C_SPEED_DATA_WIDTH-1:0]  my_speed     ;
	wire [C_STEP_NUMBER_WIDTH-1:0] my_step      ;
	wire                           my_dir       ;
	wire                           my_mod_remain;
	wire [C_STEP_NUMBER_WIDTH-1:0] my_new_remain;

	wire                           discharge_drive;

	fscpu # (
		.C_IMG_HW(C_IMG_HW),
		.C_IMG_WW(C_IMG_WW),
		.C_SPEED_DATA_WIDTH(C_SPEED_DATA_WIDTH),
		.C_STEP_NUMBER_WIDTH(C_STEP_NUMBER_WIDTH)
	) fscpu_inst (
		.clk(clk),
		.resetn(resetn),

		.bpm_init (bpm_init ),
		.bpm_wr_en(bpm_wr_en),
		.bpm_data (bpm_data ),
		.bpm_size (bpm_size ),

		.req_en   (req_en   ),
		.req_cmd  (req_cmd  ),
		.req_param(req_param),
		.req_done (req_done ),
		.req_err  (req_err  ),

		.x_ana_done              (x_ana_done              ),
		.x_lft_valid             (x_lft_valid             ),
		.x_lft_edge              (x_lft_edge              ),
		.x_lft_header_outer_valid(x_lft_header_outer_valid),
		.x_lft_header_outer_y    (x_lft_header_outer_y    ),
		.x_lft_header_inner_valid(x_lft_header_inner_valid),
		.x_lft_header_inner_y    (x_lft_header_inner_y    ),
		.x_rt_valid              (x_rt_valid              ),
		.x_rt_edge               (x_rt_edge               ),
		.x_rt_header_outer_valid (x_rt_header_outer_valid ),
		.x_rt_header_outer_y     (x_rt_header_outer_y     ),
		.x_rt_header_inner_valid (x_rt_header_inner_valid ),
		.x_rt_header_inner_y     (x_rt_header_inner_y     ),

		.ml_sel       (ml_sel       ),
		.ml_zpsign    (ml_zpsign    ),
		.ml_tpsign    (ml_tpsign    ),
		.ml_state     (ml_state     ),
		.ml_position  (ml_position  ),
		.ml_start     (ml_start     ),
		.ml_stop      (ml_stop      ),
		.ml_speed     (ml_speed     ),
		.ml_step      (ml_step      ),
		.ml_dir       (ml_dir       ),
		.ml_mod_remain(ml_mod_remain),
		.ml_new_remain(ml_new_remain),

		.mr_sel       (mr_sel       ),
		.mr_zpsign    (mr_zpsign    ),
		.mr_tpsign    (mr_tpsign    ),
		.mr_state     (mr_state     ),
		.mr_position  (mr_position  ),
		.mr_start     (mr_start     ),
		.mr_stop      (mr_stop      ),
		.mr_speed     (mr_speed     ),
		.mr_step      (mr_step      ),
		.mr_dir       (mr_dir       ),
		.mr_mod_remain(mr_mod_remain),
		.mr_new_remain(mr_new_remain),

		.mx_sel       (mx_sel       ),
		.mx_zpsign    (mx_zpsign    ),
		.mx_tpsign    (mx_tpsign    ),
		.mx_state     (mx_state     ),
		.mx_position  (mx_position  ),
		.mx_start     (mx_start     ),
		.mx_stop      (mx_stop      ),
		.mx_speed     (mx_speed     ),
		.mx_step      (mx_step      ),
		.mx_dir       (mx_dir       ),
		.mx_mod_remain(mx_mod_remain),
		.mx_new_remain(mx_new_remain),

		.my_sel       (my_sel       ),
		.my_zpsign    (my_zpsign    ),
		.my_tpsign    (my_tpsign    ),
		.my_state     (my_state     ),
		.my_position  (my_position  ),
		.my_start     (my_start     ),
		.my_stop      (my_stop      ),
		.my_speed     (my_speed     ),
		.my_step      (my_step      ),
		.my_dir       (my_dir       ),
		.my_mod_remain(my_mod_remain),
		.my_new_remain(my_new_remain),

		.discharge_drive(discharge_drive)
	);

initial begin
	clk <= 1'b1;
	forever #2.5 clk <= ~clk;
end

initial begin
	resetn <= 1'b0;
	repeat (5) #5 resetn <= 1'b0;
	forever #5 resetn <= 1'b1;
end

reg[63:0] time_cnt;
always @ (posedge clk) begin
	if (resetn == 1'b0)
		time_cnt <= 0;
	else
		time_cnt <= time_cnt + 1;
end

always @ (posedge clk) begin
	if (resetn == 1'b0) begin
		bpm_init  <= 0;
		bpm_wr_en <= 0;
		bpm_data  <= 0;
	end
	else if (time_cnt > 100 && time_cnt < 1100) begin
		bpm_init <= 1;
		bpm_wr_en <= 1;
		bpm_data  <= (time_cnt - 100) * 2;
	end
	else begin
		bpm_init <= 0;
		bpm_wr_en <= 0;
	end
end

wire[31:0] img_dly_frm;
assign img_dly_frm = 0;
wire[31:0] img_dly_cnt;
assign img_dly_cnt = 1200000;

wire[15:0] discharge_denominator;
assign discharge_denominator = 19;

wire[15:0] dis_numerator0;
wire[15:0] dis_numerator1;
wire[31:0] dis_number0;
wire[31:0] dis_number1;
wire[31:0] dis_inc;
assign dis_numerator0 = 17;
assign dis_numerator1 = 17;//5;
assign dis_number0 = 3;
assign dis_number1 = 0;//5;
assign dis_inc = 0;//(17 - 5) * 65536 / 14;
always @ (posedge clk) begin
	if (resetn == 1'b0) begin
		req_en <= 0;
	end
	else if (time_cnt == 1195) begin
		req_en <= 1;
		/// config
		req_cmd <= 29;
		req_param <= {32'h0, {16'h00, discharge_denominator}, img_dly_cnt, img_dly_frm};
	end
	else if (time_cnt == 1200) begin
		req_en <= 1;
		/// push left
		req_cmd <= 0;
		req_param <= {32'h0, 32'h0, 32'h1000, 32'h3};
	end
	else if (time_cnt == 1203 || time_cnt == 1655) begin
		req_en <= 1;
		/// discharge
		//req_cmd <= 8;
		//req_param <= {dis_inc, dis_number1, dis_number0, {dis_numerator1, dis_numerator0}};
		req_cmd <= 2;
		req_param <= {32'h0, 32'h0, 32'h57, 32'h15};
	end
	else if (time_cnt == 1205 || time_cnt == 1656) begin
		req_en <= 1;
		/// exe
		req_cmd <= 30;
		req_param <= {32'h0, 32'h0, 32'h1000, 32'h0};
	end
	else begin
		req_en <= 0;
	end
end

always @ (posedge clk) begin
	if (resetn == 1'b0) begin
		x_ana_done  <= 0;
		x_lft_valid <= 0;
		x_lft_edge  <= 0;
		x_rt_valid  <= 0;
		x_rt_edge   <= 0;
		x_lft_header_outer_valid <= 1;
		x_lft_header_outer_y     <= 'h9b;
		x_lft_header_inner_valid <= 0;
		x_lft_header_inner_y     <= 0;
		x_rt_header_outer_valid  <= 1;
		x_rt_header_outer_y      <= 'h77;
		x_rt_header_inner_valid  <= 0;
		x_rt_header_inner_y      <= 0;
	end
	else if (time_cnt[7:0] == 0) begin
		x_ana_done <= 1;
	end
	else begin
		x_ana_done <= 0;
	end
end

always @ (posedge clk) begin
	if (resetn == 1'b0) begin
		ml_state    <= 0;
		ml_position <= 0;
		mr_state    <= 0;
		mr_position <= 0;
		mx_state    <= 0;
		mx_position <= 0;
		my_state    <= 0;
		my_position <= 0;
	end
	else if (time_cnt == 1220) begin
		ml_state    <= 1;
	end
	else if (time_cnt == 1230) begin
		ml_state    <= 0;
	end
end

endmodule
