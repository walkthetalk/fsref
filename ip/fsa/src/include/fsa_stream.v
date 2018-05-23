module fsa_stream #(
	parameter integer C_TEST = 0,
	parameter integer C_OUT_DW = 1,
	parameter integer C_OUT_DV = 1,
	parameter integer C_IMG_HW = 12,
	parameter integer C_IMG_WW = 12,
	parameter integer BR_DW    = 32,
	parameter integer BR_AW    = 12	/// same as C_IMG_WW
)(
	input	clk,
	input	resetn,

	input  wire [C_IMG_HW-1:0]      height  ,
	input  wire [C_IMG_WW-1:0]      width   ,

	output wire                     rd_sof  ,
	output reg                      rd_en   ,
	output wire [BR_AW-1:0]         rd_addr ,
	input  wire [BR_DW-1:0]         rd_data ,

	input  wire                     lft_valid  ,
	input  wire [C_IMG_WW-1:0]      lft_edge   ,
	input  wire                     rt_valid   ,
	input  wire [C_IMG_WW-1:0]      rt_edge    ,
	input  wire [C_IMG_WW-1:0]      lft_header_x    ,
	input  wire [C_IMG_WW-1:0]      lft_corner_top_x,
	input  wire [C_IMG_HW-1:0]      lft_corner_top_y,
	input  wire [C_IMG_WW-1:0]      lft_corner_bot_x,
	input  wire [C_IMG_HW-1:0]      lft_corner_bot_y,
	input  wire [C_IMG_WW-1:0]      rt_header_x    ,
	input  wire [C_IMG_WW-1:0]      rt_corner_top_x,
	input  wire [C_IMG_HW-1:0]      rt_corner_top_y,
	input  wire [C_IMG_WW-1:0]      rt_corner_bot_x,
	input  wire [C_IMG_HW-1:0]      rt_corner_bot_y,

	input  wire                     fsync,

	output wire                       m_axis_tvalid,
	output wire [C_TEST+C_OUT_DW-1:0] m_axis_tdata,
	output wire                       m_axis_tuser,
	output wire                       m_axis_tlast,
	input  wire                       m_axis_tready
);
	localparam integer FIFO_DW = 2 + C_OUT_DW + C_TEST;
	localparam integer FD_SOF  = 0;
	localparam integer FD_LAST = 1;
	localparam integer FD_DATA = 2;
	localparam integer FD_TEST = 2 + C_OUT_DW;

	localparam integer BBIT_B = 0;
	localparam integer BBIT_E = BBIT_B + C_IMG_HW;
	localparam integer TBIT_B = BBIT_E;
	localparam integer TBIT_E = TBIT_B + C_IMG_HW;
	localparam integer VBIT   = TBIT_E;

	wire               rd_val;
	assign rd_val = rd_data[VBIT];
	wire[C_IMG_HW-1:0] rd_top;
	assign rd_top = rd_data[TBIT_E-1:TBIT_B];
	wire[C_IMG_HW-1:0] rd_bot;
	assign rd_bot = rd_data[BBIT_E-1:BBIT_B];

	assign rd_sof = fsync;
	/// store fsa result
	reg                     r_lft_valid       ;
	reg [C_IMG_WW-1:0]      r_lft_edge        ;
	reg                     r_rt_valid        ;
	reg [C_IMG_WW-1:0]      r_rt_edge         ;
	reg [C_IMG_WW-1:0]      r_lft_header_x    ;
	reg [C_IMG_WW-1:0]      r_lft_corner_top_x;
	reg [C_IMG_HW-1:0]      r_lft_corner_top_y;
	reg [C_IMG_WW-1:0]      r_lft_corner_bot_x;
	reg [C_IMG_HW-1:0]      r_lft_corner_bot_y;
	reg [C_IMG_WW-1:0]      r_rt_header_x     ;
	reg [C_IMG_WW-1:0]      r_rt_corner_top_x ;
	reg [C_IMG_HW-1:0]      r_rt_corner_top_y ;
	reg [C_IMG_WW-1:0]      r_rt_corner_bot_x ;
	reg [C_IMG_HW-1:0]      r_rt_corner_bot_y ;
	always @ (posedge clk) begin
		if (fsync) begin
			r_lft_valid        <= lft_valid       ;
			r_lft_edge         <= lft_edge        ;
			r_rt_valid         <= rt_valid        ;
			r_rt_edge          <= rt_edge         ;
			r_lft_header_x     <= lft_header_x    ;
			r_lft_corner_top_x <= lft_corner_top_x;
			r_lft_corner_top_y <= lft_corner_top_y;
			r_lft_corner_bot_x <= lft_corner_bot_x;
			r_lft_corner_bot_y <= lft_corner_bot_y;
			r_rt_header_x      <= rt_header_x     ;
			r_rt_corner_top_x  <= rt_corner_top_x ;
			r_rt_corner_top_y  <= rt_corner_top_y ;
			r_rt_corner_bot_x  <= rt_corner_bot_x ;
			r_rt_corner_bot_y  <= rt_corner_bot_y ;
		end
	end

	reg fw_en;
	reg [FIFO_DW-1:0] fw_data;
	wire fw_af;
	wire fr_en;
	wire[FIFO_DW-1:0] fr_data;
	wire fr_empty;

	simple_fifo # (
		.DEPTH_WIDTH(3),
		.DATA_WIDTH(FIFO_DW),
		.ALMOST_FULL_TH(6),
		.ALMOST_EMPTY_TH(1)
	) fifo_inst (
		.clk(clk),
		.rst(~resetn),

		.wr_data(fw_data),
		.wr_en  (fw_en  ),

		.rd_data(fr_data),
		.rd_en  (fr_en  ),

		.full(),
		.empty(fr_empty),
		.almost_full(fw_af),
		.almost_empty()
	);

	reg               working;

	reg[C_IMG_WW-1:0] px;
	reg[C_IMG_HW-1:0] py;
	reg               pfirst;
	wire              plast;
	reg               xlast;
	reg               ylast;
	assign rd_addr = px;
	assign plast = (xlast && ylast);
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			px      <= 0;
			py      <= 0;
			pfirst  <= 1'b1;
			xlast   <= 0;
			ylast   <= 0;
		end
		else if (rd_en) begin
			if (xlast)
				px <= 0;
			else
				px <= px + 1;
			xlast <= (px == width - 2);

			if (xlast) begin
				if (ylast)
					py <= 0;
				else
					py <= py + 1;
				ylast <= (py == height - 2);
			end
			if (plast)
				pfirst <= 1;
			else
				pfirst <= 0;
		end
	end

	always @ (posedge clk) begin
		if (resetn == 1'b0)
			working <= 1'b0;
		else if (fsync)
			working <= 1'b1;
		else if (rd_en && plast)
			working <= 1'b0;
	end

	always @ (posedge clk) begin
		if (resetn == 1'b0)
			rd_en <= 0;
		else if ((working && ~fw_af)
			&& ~(plast && rd_en))
			rd_en <= 1;
		else
			rd_en <= 0;
	end

	reg rd_en_d1;
	reg pfirst_d1;
	reg xlast_d1;
	reg [C_IMG_HW-1:0] py_d1;
	reg [C_IMG_WW-1:0] px_d1;
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			rd_en_d1  <= 0;
			py_d1     <= 0;
			px_d1     <= 0;
			pfirst_d1 <= 0;
			xlast_d1  <= 0;
		end
		else begin
			rd_en_d1  <= rd_en;
			px_d1     <= px;
			py_d1     <= py;
			pfirst_d1 <= pfirst;
			xlast_d1  <= xlast;
		end
	end

	reg rd_en_d2;
	reg pfirst_d2;
	reg xlast_d2;
	reg [C_IMG_HW-1:0] py_d2;
	reg [C_IMG_WW-1:0] px_d2;
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			rd_en_d2  <= 0;
			py_d2     <= 0;
			px_d2     <= 0;
			pfirst_d2 <= 0;
			xlast_d2  <= 0;
		end
		else begin
			rd_en_d2  <= rd_en_d1;
			px_d2     <= px_d1;
			py_d2     <= py_d1;
			pfirst_d2 <= pfirst_d1;
			xlast_d2  <= xlast_d1;
		end
	end

	reg rd_en_d3;
	reg pfirst_d3;
	reg xlast_d3;
	reg [C_IMG_HW-1:0] py_d3;
	reg [C_IMG_WW-1:0] px_d3;
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			rd_en_d3  <= 0;
			py_d3     <= 0;
			px_d3     <= 0;
			pfirst_d3 <= 0;
			xlast_d3  <= 0;
		end
		else begin
			rd_en_d3  <= rd_en_d2;
			py_d3     <= py_d2;
			px_d3     <= px_d2;
			pfirst_d3 <= pfirst_d2;
			xlast_d3  <= xlast_d2;
		end
	end

	/// rd_data is valid
	reg rd_en_d4;
	reg pfirst_d4;
	reg xlast_d4;
	reg [C_IMG_HW-1:0] py_d4;
	/// corner
	reg lc_t;
	reg lc_b;
	reg rc_t;
	reg rc_b;
	/// body
	reg lb;
	reg lb_t;
	reg lb_b;
	reg rb;
	reg rb_t;
	reg rb_b;
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			rd_en_d4  <= 0;
			py_d4     <= 0;
			pfirst_d4 <= 0;
			xlast_d4  <= 0;
			lc_t <= 0;
			lc_b <= 0;
			rc_t <= 0;
			rc_b <= 0;
			lb   <= 0;
			lb_t <= 0;
			lb_b <= 0;
			rb   <= 0;
			rb_t <= 0;
			rb_b <= 0;
		end
		else begin
			rd_en_d4  <= rd_en_d3;
			py_d4     <= py_d3;
			pfirst_d4 <= pfirst_d3;
			xlast_d4  <= xlast_d3;
			lc_t      <= ((r_lft_corner_top_y <= py_d3 && py_d3 < rd_top)
					&& (r_lft_corner_top_x < px_d3 && px_d3 <= r_lft_edge));
			lc_b      <= ((r_lft_corner_bot_y >= py_d3 && py_d3 > rd_bot)
					&& (r_lft_corner_bot_x < px_d3 && px_d3 <= r_lft_edge));
			rc_t      <= ((r_rt_corner_top_y <= py_d3 && py_d3 < rd_top)
					&& (r_rt_edge <= px_d3 && px_d3 < r_rt_corner_top_x));
			rc_b      <= ((r_rt_corner_bot_y >= py_d3 && py_d3 > rd_bot)
					&& (r_rt_edge <= px_d3 && px_d3 < r_rt_corner_bot_x));
			lb        <= (px_d3 <= r_lft_header_x);
			rb        <= (px_d3 >= r_rt_header_x);
			lb_t      <= ((px_d3 <= r_lft_corner_top_x) && (py_d3 < rd_top));
			lb_b      <= ((px_d3 <= r_lft_corner_bot_x) && (py_d3 > rd_bot));
			rb_t      <= ((px_d3 >= r_rt_corner_top_x) && (py_d3 < rd_top));
			rb_b      <= ((px_d3 >= r_rt_corner_bot_x) && (py_d3 > rd_bot));
		end
	end

	/// @NOTE: delay 5, the almost_full for blockram must be 6
	/// if you add delay, don't forget to change blockram config.
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			fw_en <= 0;
			fw_data <= 0;
		end
		else if (rd_en_d4) begin
			fw_en <= 1'b1;
			fw_data[FD_SOF]  <= pfirst_d4;
			fw_data[FD_LAST] <= xlast_d4;
			if (1) begin
				if ((r_lft_valid && (lc_t | lc_b | lb))
				 	|| (r_rt_valid && (rc_t | rc_b | rb))) begin
					fw_data[FD_DATA+C_OUT_DW-1:FD_DATA] <= C_OUT_DV;
				end
				else begin
					fw_data[FD_DATA+C_OUT_DW-1:FD_DATA] <= 1'b0;
				end
			end
			else begin
				if (rd_val && py_d4 >= rd_top && py_d4 <= rd_bot)
					fw_data[FD_DATA+C_OUT_DW-1:FD_DATA] <= C_OUT_DV;
				else
					fw_data[FD_DATA+C_OUT_DW-1:FD_DATA] <= 1'b0;
			end
		end
		else begin
			fw_en <= 0;
		end
	end

generate
	if (C_TEST > 0) begin
		reg[C_TEST-1:0] test_d1;
		reg[C_TEST-1:0] test_d2;
		reg[C_TEST-1:0] test_d3;
		always @ (posedge clk) begin
			test_d1 <= px;
			test_d2 <= test_d1;
			test_d3 <= test_d2;
			fw_data[FIFO_DW-1:FD_TEST] <= test_d3;
		end
	end
endgenerate

	/////////////////////////////////// read side //////////////////////////
	reg   r_tvalid;
	wire [FIFO_DW-FD_DATA-1:0] r_tdata;
	wire  r_tuser;
	wire  r_tlast;
	wire  r_tready;
	assign fr_en = (~r_tvalid || r_tready) && ~fr_empty;
	always @ (posedge clk) begin
		if (resetn == 1'b0)
			r_tvalid <= 0;
		else if (fr_en)
			r_tvalid <= 1;
		else if (r_tready)
			r_tvalid <= 0;
	end
	assign r_tdata = fr_data[FIFO_DW-1:FD_DATA];
	assign r_tuser = fr_data[FD_SOF];
	assign r_tlast = fr_data[FD_LAST];

	axis_relay # (
		.C_PIXEL_WIDTH(C_OUT_DW + C_TEST)
	) relay_inst (
		.clk(clk),
		.resetn(resetn),

		.s_axis_tvalid(r_tvalid),
		.s_axis_tdata (r_tdata ),
		.s_axis_tuser (r_tuser ),
		.s_axis_tlast (r_tlast ),
		.s_axis_tready(r_tready),

		.m_axis_tvalid(m_axis_tvalid),
		.m_axis_tdata (m_axis_tdata ),
		.m_axis_tuser (m_axis_tuser ),
		.m_axis_tlast (m_axis_tlast ),
		.m_axis_tready(m_axis_tready)
	);
endmodule
