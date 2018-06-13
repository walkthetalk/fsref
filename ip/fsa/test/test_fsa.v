`include "../src/include/block_ram.v"
`include "../src/include/mutex_buffer.v"
`include "../src/include/simple_dpram_sclk.v"
`include "../src/include/simple_fifo.v"
`include "../src/include/fsa_core.v"
`include "../src/include/fsa_detect_edge.v"
`include "../src/include/axis_relay.v"
`include "../src/include/fsa_stream.v"
`include "../src/fsa.v"
`include "../../axis_blender/src/axis_blender.v"

module test_fsa # (
	parameter integer C_PIXEL_WIDTH = 8,
	parameter integer C_IMG_HW = 8,
	parameter integer C_IMG_WW = 8,
	parameter integer BR_DW    = 32
) (
);

	localparam RANDOMINPUT = 1;
	localparam RANDOMOUTPUT = 1;
	localparam integer height = 20;
	localparam integer width  = 40;
	localparam integer BR_AW = C_IMG_WW;
	localparam integer TEST_BW = 12;
	localparam integer GEN_BW = 32;
	localparam integer GEN_BV = 32'hFFFF0000;

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

	reg                      fsync;
	reg                      en_axis;
	wire                     m_axis_tvalid;
	wire [TEST_BW+GEN_BW-1:0]         m_axis_tdata ;
	wire                     m_axis_tuser ;
	wire                     m_axis_tlast ;
	wire                     m_axis_tready;

	fsa # (
		.C_TEST(TEST_BW),
		.C_OUT_DW(GEN_BW),
		.C_OUT_DV(GEN_BV),
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

		.r_sof ({r1_sof,    r0_sof    }),
		.r_en  ({r1_rd_en,  r0_rd_en  }),
		.r_addr({r1_rd_addr,r0_rd_addr}),
		.r_data({r1_data,   r0_data   }),

		.ref_data     (ref_data),
		.lft_edge     (lft_v   ),
		.rt_edge      (rt_v    ),
		.s_axis_tvalid(s_axis_tvalid),
		.s_axis_tdata (s_axis_tdata ),
		.s_axis_tuser (s_axis_tuser ),
		.s_axis_tlast (s_axis_tlast ),
		.s_axis_tready(s_axis_tready),

		.m_axis_fsync(fsync),
		.m_axis_resetn(en_axis),
		.m_axis_tvalid(m_axis_tvalid),
		.m_axis_tdata (m_axis_tdata ),
		.m_axis_tuser (m_axis_tuser ),
		.m_axis_tlast (m_axis_tlast ),
		.m_axis_tready(m_axis_tready)
	);

	reg       s0_valid;
	reg [7:0] s0_data;
	reg       s0_user;
	reg       s0_last;
	wire      s0_ready;

	wire            m_valid  ;
	wire [23:0]     m_data   ;
	wire            m_user   ;
	wire            m_last   ;
	reg             m_ready  ;
	axis_blender # (
		.C_CHN_WIDTH          (8     ),
		.C_S0_CHN_NUM         (1    ),
		.C_S1_CHN_NUM         (3    ),
		.C_ALPHA_WIDTH        (8   ),
		.C_S1_ENABLE          (1     ),
		.C_IN_NEED_WIDTH      (0 ),
		.C_OUT_NEED_WIDTH     (0),
		.C_M_WIDTH            (24       ),
		.C_TEST               (1        )
	) blender_inst (
		.clk(clk),
		.resetn(resetn),

		.s0_axis_tvalid(s0_valid),
		.s0_axis_tdata (s0_data),
		.s0_axis_tuser (s0_user),
		.s0_axis_tlast (s0_last),
		.s0_axis_tready(s0_ready),

		.s1_enable     (en_axis),
		.s1_axis_tvalid(m_axis_tvalid),
		.s1_axis_tdata (m_axis_tdata ),
		.s1_axis_tuser (m_axis_tuser ),
		.s1_axis_tlast (m_axis_tlast ),
		.s1_axis_tready(m_axis_tready),

		.m_axis_tvalid(m_valid   ),
		.m_axis_tdata (m_data    ),
		.m_axis_tuser (m_user    ),
		.m_axis_tlast (m_last    ),
		.m_axis_tready(m_ready   )
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
			if (j <= 17 || j >= 23) begin
				if (j <= 14 || j >= 27) begin
					if ((i >= 5 && i <= 7) || (i >= 10 && i <= 15)) begin
						data[i][j] = 10;
					end
					else begin
						data[i][j] = 128+j;
					end
				end
				else begin
					if ((i >= 6 && i <= 7) || (i >= 10 && i <= 13)) begin
						data[i][j] = 10;
					end
					else begin
						data[i][j] = 128+j;
					end
				end
			end
			else
				data[i][j] = 128+j;
		end
	end
	assign ref_data = 128;
end

	reg[63:0] clk_cnt;
	always @ (posedge clk) begin
		if (resetn == 1'b0 || clk_cnt == 2500)
			clk_cnt <= 0;
		else
			clk_cnt <= clk_cnt + 1;
	end

	reg randominput;
	always @ (posedge clk) begin
		if (resetn == 1'b0)
			randominput <= 1'b0;
		else
			randominput <= (RANDOMINPUT ? {$random}%2 : 1);
	end

	always @ (posedge clk) begin
		if (resetn == 1'b0)
			m_ready <= 1'b0;
		else
			m_ready <= (RANDOMOUTPUT ? {$random}%2 : 1);
	end

/////////////////////////////////////// fs img /////////////////////////////////
	reg[C_IMG_WW-1:0] col;
	reg[C_IMG_HW-1:0] row;
	wire snext;
	assign snext = (~s_axis_tvalid | s_axis_tready) && randominput;
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

/////////////////////////////////////// ext img /////////////////////////////////

	reg randoms0;
	always @ (posedge clk) begin
		if (resetn == 1'b0)
			randoms0 <= 1'b0;
		else
			randoms0 <= (RANDOMINPUT ? {$random}%2 : 1);
	end

	reg[C_IMG_WW-1:0] s0_col;
	reg[C_IMG_HW-1:0] s0_row;
	wire s0next;
	assign s0next = (~s0_valid | s0_ready) && randoms0 && en_axis;
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			s0_col <= 0;
			s0_row <= 0;
		end
		else if (s0next) begin
			if (s0_col == width-1)
				s0_col <= 0;
			else
				s0_col <= s0_col + 1;
			if (s0_col == width-1) begin
				if (s0_row == height - 1)
					s0_row <= 0;
				else
					s0_row <= s0_row + 1;
			end
		end
	end
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			s0_user <= 0;
			s0_last <= 0;
			s0_data <= 0;
			s0_valid <= 0;
		end
		else if (s0next) begin
			s0_valid <= 1;
			s0_last <= (s0_col == width-1);
			s0_user <= (s0_col == 0 && s0_row == 0);
			s0_data <= 0;
		end
		else if (s0_ready) begin
			s0_valid <= 0;
		end
	end

//////////////////////////////////////////////////////////////////////////////

	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			fsync <= 0;
			en_axis <= 0;
		end
		else if (clk_cnt[11:0] == 1000) begin
			fsync <= 1;
			en_axis <= 1;
		end
		else begin
			fsync <= 0;
		end
	end
generate
if (1) begin
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
		end
		else if (m_valid && m_ready) begin
			if (m_user)
				$write("\nstart new frame:\n");
			/*
			if (m_data[GEN_BW-1:0] == GEN_BV)
				$write("1");
			else
				$write("0");
			*/
			$write("%x ", m_data[23:16]);
			//$write("%d ", (m_data/2));
			if (m_last)
				$write("\n");
		end
	end
end
else begin
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
		end
		else if (fsync)
			$write("\nfsync\n");
		else if (m_axis_tvalid && m_axis_tready) begin
			if (m_axis_tuser)
				$write("\nstart new frame:\n");
			/*
			if (m_data[GEN_BW-1:0] == GEN_BV)
				$write("1");
			else
				$write("0");
			*/
			$write("%x ", m_axis_tdata[23:16]);
			//$write("%d ", (m_data/2));
			if (m_axis_tlast)
				$write("\n");
		end
	end
end
endgenerate

endmodule
