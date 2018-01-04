`timescale 1ns/1ps

module test_bd();
	reg [7:0]   S_REG_CTL_rd_addr;
	wire [31:0] S_REG_CTL_rd_data;
	reg         S_REG_CTL_rd_en;
	reg [7:0]   S_REG_CTL_wr_addr;
	reg [31:0]  S_REG_CTL_wr_data;
	reg         S_REG_CTL_wr_en;
	reg         clk;
	reg         resetn;
	reg         clk_reg;
	reg         resetn_reg;
	reg         clk_lcd;
	reg         resetn_lcd;
	reg         reset_lcd;
	wire        underflow;


	localparam integer C_PIXEL_WIDTH	= 32;
	localparam integer C_PRIORITY_WIDTH     = 3;
	localparam integer C_S_STREAM_NUM       = 2;
	localparam integer C_M_STREAM_NUM       = 8;
	localparam integer C_IMG_BITS		= 12;
	localparam integer C_ONE2MANY           = 0;
	localparam integer C_MAX_STREAM_NUM     = 2;

	reg [C_MAX_STREAM_NUM-1:0]                     s_random ;

	reg [C_IMG_BITS-1:0]     s_width  [C_MAX_STREAM_NUM-1:0];
	reg [C_IMG_BITS-1:0]     s_height [C_MAX_STREAM_NUM-1:0];

	reg                      s_valid       [C_MAX_STREAM_NUM-1:0];
	wire [C_PIXEL_WIDTH-1:0] s_data        [C_MAX_STREAM_NUM-1:0];
	wire                     s_user        [C_MAX_STREAM_NUM-1:0];
	wire                     s_last        [C_MAX_STREAM_NUM-1:0];
	wire                     s_ready       [C_MAX_STREAM_NUM-1:0];
	wire                     s_soft_resetn [ C_MAX_STREAM_NUM-1:0];

	wire                     o_fsync       ;

simbd_wrapper bdinst (
	.ST_AXIS_tdata      (s_data  [1]     ),
	.ST_AXIS_tlast      (s_last  [1]     ),
	.ST_AXIS_tready     (s_ready [1]     ),
	.ST_AXIS_tuser      (s_user  [1]     ),
	.ST_AXIS_tvalid     (s_valid [1]     ),
	.S_AXIS_tdata       (s_data  [0][7:0]),
	.S_AXIS_tlast       (s_last  [0]     ),
	.S_AXIS_tready      (s_ready [0]     ),
	.S_AXIS_tuser       (s_user  [0]     ),
	.S_AXIS_tvalid      (s_valid [0]     ),
	.o_fsync            (o_fsync         ),
	.s0_soft_resetn     (s_soft_resetn[0]),
	.st_soft_resetn     (s_soft_resetn[1]),
	.S_REG_CTL_rd_addr  (S_REG_CTL_rd_addr  ),
	.S_REG_CTL_rd_data  (S_REG_CTL_rd_data  ),
	.S_REG_CTL_rd_en    (S_REG_CTL_rd_en    ),
	.S_REG_CTL_wr_addr  (S_REG_CTL_wr_addr  ),
	.S_REG_CTL_wr_data  (S_REG_CTL_wr_data  ),
	.S_REG_CTL_wr_en    (S_REG_CTL_wr_en    ),
	.clk                (clk                ),
	.resetn             (resetn             ),
	.clk_reg            (clk_reg            ),
	.resetn_reg         (resetn_reg         ),
	.clk_lcd            (clk_lcd            ),
	.reset_lcd          (reset_lcd          ),
	.resetn_lcd         (resetn_lcd         ),
	.underflow          (underflow          )
);

initial begin
	clk <= 1'b1;
	forever #3.5 clk <= ~clk;
end

initial begin
	resetn <= 1'b0;
	repeat (8) #7 resetn <= 1'b0;
	forever #7 resetn <= 1'b1;
end


initial begin
	clk_reg <= 1'b1;
	forever #7.5 clk_reg <= ~clk_reg;
end

initial begin
	resetn_reg <= 1'b0;
	repeat (8) #13 resetn_reg <= 1'b0;
	forever #13 resetn_reg <= 1'b1;
end


initial begin
	clk_lcd <= 1'b1;
	forever #50 clk_lcd <= ~clk_lcd;
end

initial begin
	resetn_lcd <= 1'b0;
	repeat (8) #100 resetn_lcd <= 1'b0;
	forever #100 resetn_lcd <= 1'b1;
end

initial begin
	reset_lcd <= 1'b1;
	repeat (8) #100 reset_lcd <= 1'b1;
	forever #100 reset_lcd <= 1'b0;
end

initial begin
	S_REG_CTL_rd_addr <= 0;
	S_REG_CTL_rd_en   <= 0;
end

initial begin
	S_REG_CTL_wr_addr <= 0;
	S_REG_CTL_wr_data <= 0;
	S_REG_CTL_wr_en   <= 0;
end

initial begin
	s_random   <= 2'b00;
	s_width[0] <= 640; s_height[0] <= 400;
	s_width[1] <= 320; s_height[1] <= 240;
end

reg[63:0] time_ns;
reg[63:0] time_cnt;
always @ (posedge clk_reg) begin
	if (resetn_reg == 1'b0)
		time_ns <= 0;
	else
		time_ns <= time_ns + 15;
end
always @ (posedge clk_reg) begin
	if (resetn_reg == 1'b0)
		time_cnt <= 0;
	else
		time_cnt <= time_cnt + 1;
end

`define DEF_CHANGE_CFG(_starttime, _w, _h, _sl, _st, _sw, _sh, _dl, _dt, _dw, _dh) \
	else if (time_cnt == _starttime) begin \
		S_REG_CTL_wr_addr <= 0; \
		S_REG_CTL_wr_data <= 3; \
		S_REG_CTL_wr_en   <= 1; \
	end \
	else if (time_cnt == _starttime + 2) begin \
		S_REG_CTL_wr_addr <= 1; \
		S_REG_CTL_wr_data <= 1; \
		S_REG_CTL_wr_en   <= 1; \
	end \
	else if (time_cnt == _starttime + 4) begin \
		S_REG_CTL_wr_addr <= 5; \
		S_REG_CTL_wr_data <= (_w << 16) + _h; \
		S_REG_CTL_wr_en   <= 1; \
	end \
	else if (time_cnt == _starttime + 6) begin \
		S_REG_CTL_wr_addr <= 6; \
		S_REG_CTL_wr_data <= (_sl << 16) + _st; \
		S_REG_CTL_wr_en   <= 1; \
	end \
	else if (time_cnt == _starttime + 8) begin \
		S_REG_CTL_wr_addr <= 7; \
		S_REG_CTL_wr_data <= (_sw<<16) + _sh; \
		S_REG_CTL_wr_en   <= 1; \
	end \
	else if (time_cnt == _starttime + 10) begin \
		S_REG_CTL_wr_addr <= 8; \
		S_REG_CTL_wr_data <= (_dl << 16) + _dt; \
		S_REG_CTL_wr_en   <= 1; \
	end \
	else if (time_cnt == _starttime + 12) begin \
		S_REG_CTL_wr_addr <= 9; \
		S_REG_CTL_wr_data <= (_dw<<16) + _dh; \
		S_REG_CTL_wr_en   <= 1; \
	end \
	else if (time_cnt == _starttime + 14) begin \
		S_REG_CTL_wr_addr <= 0; \
		S_REG_CTL_wr_data <= 1; \
		S_REG_CTL_wr_en   <= 1; \
	end

always @ (posedge clk_reg) begin
	if (resetn_reg == 1'b0) begin
		S_REG_CTL_wr_addr <= 0;
		S_REG_CTL_wr_data <= 0;
		S_REG_CTL_wr_en   <= 0;
	end
	`DEF_CHANGE_CFG(22000000/15, 640, 400,   0,   0, 640, 400,   0,   0, 320, 200)
	`DEF_CHANGE_CFG(42000000/15, 640, 400,   0,   0, 640, 400,   0,   1, 320, 200)
	else begin
		S_REG_CTL_wr_en   <= 0;
	end
end

//////////////////////////////////// input ////////////////////////////////////
generate
	genvar i;
	genvar j;
	for (i = 0; i < C_S_STREAM_NUM; i = i + 1) begin: single_input
		reg [C_IMG_BITS-1:0]     s_ridx;
		reg [C_IMG_BITS-1:0]     s_cidx;
		reg en_input;
		reg in_frm;
		wire last_pixel;
		assign last_pixel = (s_cidx == (s_width[i] - 1) && s_ridx == (s_height[i] - 1));
		always @ (posedge clk) begin
			if (resetn == 1'b0) en_input <= 1'b0;
			else		en_input <= (s_random[i] ? {$random}%2 : 1);
		end
		always @ (posedge clk) begin
			if (resetn == 1'b0)
				s_valid[i] <= 1'b0;
			else if (~s_valid[i]) begin
				if (en_input && in_frm)
					s_valid[i] <= 1'b1;
			end
			else begin
				if (s_ready[i])
					s_valid[i] <= en_input && (in_frm && ~last_pixel);
			end
		end
		assign s_data[i] = (s_ridx * 16 + s_cidx) + i * 256;
		assign s_user[i] = (s_ridx == 0 && s_cidx == 0);
		assign s_last[i] = (s_cidx == s_width[i] - 1);

		always @ (posedge clk) begin
			if (resetn == 1'b0)
				in_frm <= 0;
			else if (o_fsync && s_soft_resetn[i])
				in_frm <= 1;
			else if (s_valid[i] && s_ready[i]
				&& last_pixel)
				in_frm <= 0;
		end

		always @ (posedge clk) begin
			if (resetn == 1'b0) begin
				s_ridx <= 0;
				s_cidx <= 0;
			end
			else if (s_valid[i] && s_ready[i]) begin
				if (s_cidx != s_width[i] - 1) begin
					s_cidx <= s_cidx + 1;
					s_ridx <= s_ridx;
				end
				else if (s_ridx != s_height[i] - 1) begin
					s_cidx <= 0;
					s_ridx <= s_ridx + 1;
				end
				else begin
					s_cidx <= 0;
					s_ridx <= 0;
				end
			end
		end
	end
endgenerate


endmodule
