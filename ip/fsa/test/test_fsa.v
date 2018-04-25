`include "../src/fsa.v"

module test_fsa # (
	parameter integer C_PIXEL_WIDTH = 8,
	parameter integer C_IMG_HW = 8,
	parameter integer C_IMG_WW = 8,
	parameter integer BR_DW    = 32
) (
);

	localparam integer height = 20;
	localparam integer width  = 40;
	localparam integer BR_AW = C_IMG_WW;

	reg [C_PIXEL_WIDTH-1:0] data[height-1:0][width-1:0];

	reg clk;
	reg resetn;

	reg                      r0_sof    ;
	reg                      r0_rd_en  ;
	reg  [BR_AW-1:0]         r0_rd_addr;
	wire [BR_DW-1:0]         r0_data   ;

	reg                      r1_sof    ;
	reg                      r1_rd_en  ;
	reg  [BR_AW-1:0]         r1_rd_addr;
	wire [BR_DW-1:0]         r1_data   ;

	reg  [C_PIXEL_WIDTH-1:0] ref_data ;
	wire [C_IMG_WW-1:0]      lft_v    ;
	wire [C_IMG_WW-1:0]      rt_v     ;
	reg                      s_axis_tvalid;
	reg  [C_PIXEL_WIDTH-1:0] s_axis_tdata ;
	reg                      s_axis_tuser ;
	reg                      s_axis_tlast ;
	wire                     s_axis_tready;

	fsa # (
		.C_PIXEL_WIDTH (C_PIXEL_WIDTH),
		.C_IMG_HW (C_IMG_HW),
		.C_IMG_WW (C_IMG_WW),
		.BR_NUM   (4),
		.BR_AW    (BR_AW),	/// same as C_IMG_WW
		.BR_DW    (BR_DW)
	) fsa_inst (
		.clk(clk),
		.resetn(resetn),

		.height(height),
		.width (width),

		.r0_sof    (r0_sof    ),
		.r0_rd_en  (r0_rd_en  ),
		.r0_rd_addr(r0_rd_addr),
		.r0_data   (r0_data   ),

		.r1_sof    (r1_sof    ),
		.r1_rd_en  (r1_rd_en  ),
		.r1_rd_addr(r1_rd_addr),
		.r1_data   (r1_data   ),

		.ref_data     (ref_data),
		.lft_v        (lft_v   ),
		.rt_v         (rt_v    ),
		.s_axis_tvalid(s_axis_tvalid),
		.s_axis_tdata (s_axis_tdata ),
		.s_axis_tuser (s_axis_tuser ),
		.s_axis_tlast (s_axis_tlast ),
		.s_axis_tready(s_axis_tready)
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

integer i, j;
initial begin
	for (i = 0; i < height; i=i+1) begin
		for (j=0; j < width; j=j+1) begin
			if ((i >= 5 && i <= 15)
				&& (j <= 17 || j >= 23))
				data[i][j] = 10;
			else
				data[i][j] = 128+j;
		end
	end
	assign ref_data = 128;
end

	reg[C_IMG_WW-1:0] col;
	reg[C_IMG_HW-1:0] row;
	wire snext;
	assign snext = (~s_axis_tvalid | s_axis_tready);
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			col <= 0;
			row <= 0;
		end
		else if (snext) begin
			if (col == width-1)
				col <= 0;
			else
				col <= col + 1;
			if (col == width-1) begin
				if (row == height - 1)
					row <= 0;
				else
					row <= row + 1;
			end
		end
	end
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			s_axis_tuser <= 0;
			s_axis_tlast <= 0;
			s_axis_tdata <= 0;
			s_axis_tvalid <= 0;
		end
		else if (snext) begin
			s_axis_tvalid <= 1;
			s_axis_tlast <= (col == width-1);
			s_axis_tuser <= (col == 0 && row == 0);
			s_axis_tdata <= data[row][col];
		end
		else if (s_axis_tready) begin
			s_axis_tvalid <= 0;
		end
	end


endmodule
