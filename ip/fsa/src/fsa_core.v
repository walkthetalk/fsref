
module fsa_core #(
	parameter integer C_PIXEL_WIDTH = 8,
	parameter integer C_IMG_HW = 12,
	parameter integer C_IMG_WW = 12,
	parameter integer BR_DW    = 32,
	parameter integer BR_NUM   = 4,
	parameter integer BR_AW    = 12	/// same as C_IMG_WW
)(
	input	clk,
	input	resetn,

	input  wire [C_IMG_HW-1:0]      height  ,
	input  wire [C_IMG_WW-1:0]      width   ,

	output wire                     sof     ,
	input  wire [BR_NUM-1:0]        wr_bmp  ,

	output reg  [BR_NUM-1:0]        wr_en   ,
	output reg  [BR_AW-1:0]         wr_addr ,
	output wire [BR_DW-1:0]         wr_data ,

	output reg                      rd_en   ,
	output reg  [BR_AW-1:0]         rd_addr ,
	input  wire [BR_DW-1:0]         rd_data ,

	input  wire [C_PIXEL_WIDTH-1:0] ref_data,
	output reg  [C_IMG_WW-1:0]      lft_v   ,
	output reg  [C_IMG_WW-1:0]      rt_v    ,

	input  wire                     s_axis_tvalid,
	input  wire [C_PIXEL_WIDTH-1:0] s_axis_tdata,
	input  wire                     s_axis_tuser,
	input  wire                     s_axis_tlast,
	output wire                     s_axis_tready
);
	localparam integer BBIT_B = 0;
	localparam integer BBIT_E = BBIT_B + C_IMG_HW;
	localparam integer TBIT_B = BBIT_E;
	localparam integer TBIT_E = TBIT_B + C_IMG_HW;
	localparam integer VBIT   = TBIT_E;

	assign wr_data[BR_DW-1:VBIT+1] = 0;

	reg                wr_val;
	wire               rd_val;
	assign wr_data[VBIT] = wr_val;
	assign rd_val = rd_data[VBIT];

	reg [C_IMG_HW-1:0] wr_top;
	wire[C_IMG_HW-1:0] rd_top;
	assign wr_data[TBIT_E-1:TBIT_B] = wr_top;
	assign rd_top = rd_data[TBIT_E-1:TBIT_B];

	reg [C_IMG_HW-1:0] wr_bot;
	wire[C_IMG_HW-1:0] rd_bot;
	assign wr_data[BBIT_E-1:BBIT_B] = wr_bot;
	assign rd_bot = rd_data[BBIT_E-1:BBIT_B];

	assign s_axis_tready = 1'b1;
	wire snext;
	assign snext = s_axis_tvalid & s_axis_tready;

	reg [C_PIXEL_WIDTH-1:0] tdata_p0;
	reg wlast_p0;
	reg hfirst_p0;
	reg [C_IMG_HW-1:0] y_p0;
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			rd_en       <= 0;
			rd_addr     <= 0;
			tdata_p0    <= 0;
			wlast_p0    <= 0;
			hfirst_p0   <= 0;
			y_p0        <= 0;
		end
		else if (snext) begin
			rd_en       <= 1;
			if (s_axis_tuser || wlast_p0)
				rd_addr <= 0;
			else
				rd_addr <= rd_addr + 1;
			tdata_p0    <= s_axis_tdata;
			wlast_p0    <= s_axis_tlast;
			if (s_axis_tuser) begin
				y_p0 <= 0;
				hfirst_p0 <= 1;
			end
			else if (wlast_p0) begin
				y_p0 <= y_p0 + 1;
				hfirst_p0 <= 0;
			end
		end
		else begin
			rd_en <= 0;
		end
	end

	reg rd_en_d1;
	reg [BR_AW-1:0] x_d1;
	reg [C_PIXEL_WIDTH-1:0] tdata_p1;
	reg wlast_p1;
	reg hfirst_p1;
	reg hlast_p1;
	reg [C_IMG_HW-1:0] y_p1;
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			rd_en_d1    <= 0;
			x_d1        <= 0;
			tdata_p1    <= 0;
			wlast_p1    <= 0;
			hfirst_p1   <= 0;
			hlast_p1    <= 0;
			y_p1        <= 0;
		end
		else begin
			rd_en_d1    <= rd_en;
			x_d1        <= rd_addr;
			tdata_p1    <= tdata_p0;
			wlast_p1    <= wlast_p0;
			hfirst_p1   <= hfirst_p0;
			hlast_p1    <= (y_p0 == height-1);
			y_p1        <= y_p0;
		end
	end

	reg rd_en_d2;
	reg [BR_AW-1:0] x_d2;
	reg [C_PIXEL_WIDTH-1:0] tdata_p2;
	reg plast_p2;
	reg hfirst_p2;
	reg hlast_p2;
	reg [C_IMG_HW-1:0] y_p2;
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			rd_en_d2    <= 0;
			x_d2        <= 0;
			tdata_p2    <= 0;
			plast_p2    <= 0;
			hfirst_p2   <= 0;
			hlast_p2    <= 0;
			y_p2        <= 0;
		end
		else begin
			rd_en_d2    <= rd_en_d1;
			x_d2        <= x_d1;
			tdata_p2    <= tdata_p1;
			plast_p2    <= (wlast_p1 && hlast_p1);
			hfirst_p2   <= hfirst_p1;
			hlast_p2    <= hlast_p1;
			y_p2        <= y_p1;
		end
	end

	reg rd_en_d3;
	reg [BR_AW-1:0] x_d3;
	reg [C_PIXEL_WIDTH-1:0] tdata_p3;
	reg plast_p3;
	reg hfirst_p3;
	reg hlast_p3;
	reg [C_IMG_HW-1:0] y_p3;
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			rd_en_d3    <= 0;
			x_d3        <= 0;
			tdata_p3    <= 0;
			plast_p3    <= 0;
			hfirst_p3   <= 0;
			hlast_p3    <= 0;
			y_p3        <= 0;
		end
		else begin
			rd_en_d3    <= rd_en_d2;
			x_d3        <= x_d2;
			tdata_p3    <= tdata_p2;
			plast_p3    <= plast_p2 ;
			hfirst_p3   <= hfirst_p2;
			hlast_p3    <= hlast_p2;
			y_p3        <= y_p2;
		end
	end
	assign sof = plast_p3;

	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			wr_en   <= 0;
			wr_addr <= 0;
			wr_val  <= 0;
			wr_top  <= 0;
			wr_bot  <= 0;
		end
		else if (rd_en_d3) begin
			wr_en   <= wr_bmp;
			wr_addr <= x_d3;

			if (tdata_p3 < ref_data)
				wr_val <= 1;
			else if (hfirst_p3)
				wr_val <= 0;
			else
				wr_val <= rd_val;

			if (hfirst_p3)
				wr_top <= 0;
			else if (tdata_p3 < ref_data && ~rd_val)
				wr_top <= y_p3;
			else
				wr_top <= rd_top;

			if (tdata_p3 < ref_data)
				wr_bot <= y_p3;
			else if (hfirst_p3)
				wr_bot <= 0;
			else
				wr_bot <= rd_bot;
		end
		else begin
			wr_en   <= 0;
		end
	end

	/// detect edge
	reg lft_val;
	reg[C_IMG_WW-1:0] lft_edge;
	reg rt_val;
	reg[C_IMG_WW-1:0] rt_edge;
	always @ (posedge clk) begin
		if (resetn == 1'b0 || ~hlast_p3) begin
			lft_val  <= 0;
			lft_edge <= 0;
		end
		else if (rd_en_d3) begin
			if (~lft_val && rd_val)
				lft_edge <= x_d3;
			if (~rd_val)
				lft_val <= 1;
		end
	end
	always @ (posedge clk) begin
		if (resetn == 1'b0 || ~hlast_p3) begin
			rt_val  <= 0;
			rt_edge <= 0;
		end
		else if (rd_en_d3) begin
			rt_val <= rd_val;
			if (~rt_val || ~rd_val)
				rt_edge <= x_d3;
		end
	end

	reg update_edge_p4;
	always @ (posedge clk) begin
		if (resetn == 1'b0)
			update_edge_p4 <= 0;
		else
			update_edge_p4 <= (plast_p3 && rd_en_d3);
	end

	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			lft_v <= 0;
			rt_v  <= 0;
		end
		else if (update_edge_p4) begin
			lft_v <= lft_edge;
			rt_v  <= rt_edge ;
		end
	end
endmodule
