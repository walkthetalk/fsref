module fsa_stream_v2 #(
	parameter integer C_OUT_DW = 24,	/// C_CHANNEL_WIDTH * 3
	parameter integer C_OUT_DV = 1,
	parameter integer C_IMG_HW = 12,
	parameter integer C_IMG_WW = 12,
	parameter integer BR_AW    = 12,	/// same as C_IMG_WW
	parameter integer C_CHANNEL_WIDTH   = 8,
	parameter integer C_S_CHANNEL = 1
)(
	input	clk,
	input	resetn,

	input  wire [C_IMG_HW-1:0]      height  ,
	input  wire [C_IMG_WW-1:0]      width   ,

	input  wire                     fsync   ,

	output wire                     rd_sof  ,
	output wire                     rd_en   ,
	output wire [BR_AW-1:0]         rd_addr ,
	input  wire                     rd_black,
	input  wire                     rd_val_outer,
	input  wire [C_IMG_HW-1:0]      rd_top_outer,
	input  wire [C_IMG_HW-1:0]      rd_bot_outer,
	input  wire                     rd_val_inner,
	input  wire [C_IMG_HW-1:0]      rd_top_inner,
	input  wire [C_IMG_HW-1:0]      rd_bot_inner,

	input  wire                     lft_valid  ,
	input  wire [C_IMG_WW-1:0]      lft_edge   ,
	input  wire                     rt_valid   ,
	input  wire [C_IMG_WW-1:0]      rt_edge    ,
	input  wire                     lft_header_outer_valid,
	input  wire [C_IMG_WW-1:0]      lft_header_outer_x    ,
	input  wire                     lft_corner_valid,
	input  wire [C_IMG_WW-1:0]      lft_corner_top_x,
	input  wire [C_IMG_HW-1:0]      lft_corner_top_y,
	input  wire [C_IMG_WW-1:0]      lft_corner_bot_x,
	input  wire [C_IMG_HW-1:0]      lft_corner_bot_y,
	input  wire                     rt_header_outer_valid,
	input  wire [C_IMG_WW-1:0]      rt_header_outer_x    ,
	input  wire                     rt_corner_valid,
	input  wire [C_IMG_WW-1:0]      rt_corner_top_x,
	input  wire [C_IMG_HW-1:0]      rt_corner_top_y,
	input  wire [C_IMG_WW-1:0]      rt_corner_bot_x,
	input  wire [C_IMG_HW-1:0]      rt_corner_bot_y,

	input  wire                       s_axis_tvalid,
	input  wire [C_CHANNEL_WIDTH*C_S_CHANNEL-1:0] s_axis_tdata,
	input  wire                       s_axis_tuser,
	input  wire                       s_axis_tlast,
	output wire                       s_axis_tready,
	input  wire [C_IMG_WW-1:0]        s_axis_source_x,
	input  wire [C_IMG_HW-1:0]        s_axis_source_y,

	output wire                       m_axis_tvalid,
	output wire [C_CHANNEL_WIDTH*3-1:0]        m_axis_tdata,
	output wire                       m_axis_tuser,
	output wire                       m_axis_tlast,
	input  wire                       m_axis_tready
);
	localparam integer C_STAGE_WIDTH = 2 + C_CHANNEL_WIDTH*C_S_CHANNEL;
	localparam integer FIFO_DW = 2 + C_OUT_DW;
	localparam integer FD_SOF  = 0;
	localparam integer FD_LAST = 1;
	localparam integer FD_DATA = 2;

	assign rd_sof = fsync;
	assign rd_en = s_axis_tvalid && s_axis_tready;
	assign rd_addr = s_axis_source_x;

	reg rd_en_d1;
	reg [C_IMG_HW-1:0] py_d1;
	reg [C_IMG_WW-1:0] px_d1;
	reg [C_STAGE_WIDTH-1:0]  data_d1;
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			rd_en_d1  <= 0;
			py_d1     <= 0;
			px_d1     <= 0;
			data_d1   <= 0;
		end
		else begin
			rd_en_d1  <= rd_en;
			px_d1     <= s_axis_source_x;
			py_d1     <= s_axis_source_y;
			data_d1   <= {s_axis_tdata, s_axis_tlast, s_axis_tuser};
		end
	end

	reg rd_en_d2;
	reg [C_IMG_HW-1:0] py_d2;
	reg [C_IMG_WW-1:0] px_d2;
	reg [C_STAGE_WIDTH-1:0]  data_d2;
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			rd_en_d2  <= 0;
			py_d2     <= 0;
			px_d2     <= 0;
			data_d2   <= 0;
		end
		else begin
			rd_en_d2  <= rd_en_d1;
			px_d2     <= px_d1;
			py_d2     <= py_d1;
			data_d2   <= data_d1;
		end
	end

	reg rd_en_d3;
	reg [C_IMG_HW-1:0] py_d3;
	reg [C_IMG_WW-1:0] px_d3;
	reg [C_STAGE_WIDTH-1:0]  data_d3;
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			rd_en_d3  <= 0;
			py_d3     <= 0;
			px_d3     <= 0;
			data_d3   <= 0;
		end
		else begin
			rd_en_d3  <= rd_en_d2;
			py_d3     <= py_d2;
			px_d3     <= px_d2;
			data_d3   <= data_d2;
		end
	end

	/// rd_data is valid
	reg rd_en_d4;
	reg [C_IMG_HW-1:0] py_d4;
	reg [C_STAGE_WIDTH-1:0]  data_d4;
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
			data_d4   <= 0;
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
			data_d4   <= data_d3;
			lc_t      <= lft_corner_valid && ((lft_corner_top_y <= py_d3 && py_d3 < rd_top_outer)
					&& (lft_corner_top_x < px_d3 && px_d3 <= lft_edge));
			lc_b      <= lft_corner_valid && ((lft_corner_bot_y >= py_d3 && py_d3 > rd_bot_outer)
					&& (lft_corner_bot_x < px_d3 && px_d3 <= lft_edge));
			rc_t      <= rt_corner_valid && ((rt_corner_top_y <= py_d3 && py_d3 < rd_top_outer)
					&& (rt_edge <= px_d3 && px_d3 < rt_corner_top_x));
			rc_b      <= rt_corner_valid && ((rt_corner_bot_y >= py_d3 && py_d3 > rd_bot_outer)
					&& (rt_edge <= px_d3 && px_d3 < rt_corner_bot_x));
			lb        <= lft_header_outer_valid && (px_d3 <= lft_header_outer_x);
			rb        <= rt_header_outer_valid && (px_d3 >= rt_header_outer_x);
			lb_t      <= lft_corner_valid && ((px_d3 <= lft_corner_top_x) && (py_d3 < rd_top_outer));
			lb_b      <= lft_corner_valid && ((px_d3 <= lft_corner_bot_x) && (py_d3 > rd_bot_outer));
			rb_t      <= rt_corner_valid && ((px_d3 >= rt_corner_top_x) && (py_d3 < rd_top_outer));
			rb_b      <= rt_corner_valid && ((px_d3 >= rt_corner_bot_x) && (py_d3 > rd_bot_outer));
		end
	end

	/// @NOTE: delay 5, the almost_full for blockram must be 6
	/// if you add delay, don't forget to change blockram config.
	reg rd_en_d5;
	reg [FIFO_DW-1 : 0] out_data_d5;
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			rd_en_d5 <= 0;
			out_data_d5 <= 0;
		end
		else begin
			rd_en_d5 <= rd_en_d4;
			out_data_d5[FIFO_SOF] <= data_d4[FIFO_SOF];
			out_data_d5[FD_LAST]  <= data_d4[FIFO_LAST];
			if ((lft_valid && (lc_t | lc_b))
				|| (rt_valid && (rc_t | rc_b))) begin
				out_data_d5[FD_DATA+C_OUT_DW-1:FD_DATA] <= C_OUT_DV;
			end
			else begin
				if (C_S_CHANNEL == 1) begin
					out_data_d5[FD_DATA+C_OUT_DW-1:FD_DATA] <= {
						data_d4[C_STAGE_WIDTH-1:FD_DATA],
						data_d4[C_STAGE_WIDTH-1:FD_DATA],
						data_d4[C_STAGE_WIDTH-1:FD_DATA]};
				end
				else if (C_S_CHANNEL == 3) begin
					out_data_d5[FD_DATA+C_OUT_DW-1:FD_DATA] <= data_d4[C_STAGE_WIDTH-1:FD_DATA];
				end
				else begin
					/// @ERROR
					out_data_d5[FD_DATA+C_OUT_DW-1:FD_DATA] <= 0;
				end
			end
		end
	end

	//////////////////////////////////////////////////// FIFO ////////////////////////////////////////
	wire fw_en;
	wire [FIFO_DW-1:0] fw_data;
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

	assign fw_en = rd_en_d5;
	assign fw_data = out_data_d5;
	assign fr_en = (~m_axis_tvalid || m_axis_tready) && ~fr_empty;

	assign s_axis_tready = ~fw_af;

	reg axis_tvalid;
	assign m_axis_tvalid = axis_tvalid;
	always @(posedge clk) begin
		if (resetn == 0)
			axis_tvalid <= 0;
		else if (fr_en)
			axis_tvalid <= 1;
		else if (m_axis_tready)
			axis_tvalid <= 0;
	end
	assign m_axis_tdata = fr_data[FIFO_DW-1:FD_DATA];
	assign m_axis_tuser = fr_data[FD_SOF];
	assign m_axis_tlast = fr_data[FD_LAST];
endmodule
