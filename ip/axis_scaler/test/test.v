`timescale 1ns / 1ps
`include "../src/axis_scaler.v"

module test();

	localparam RANDOMOUTPUT = 1;
	localparam RANDOMINPUT  = 1;

	localparam integer C_REALDATA = 1;

	localparam integer C_PIXEL_WIDTH = (C_REALDATA ? 8 : 16);
	localparam integer C_SH_WIDTH    = 12;
	localparam integer C_SW_WIDTH    = 12;
	localparam integer C_MH_WIDTH    = 12;
	localparam integer C_MW_WIDTH    = 12;
	localparam integer C_CH0_WIDTH   = 8;
	localparam integer C_CH1_WIDTH   = 0;
	localparam integer C_CH2_WIDTH   = 0;
	/// 10ms / 5ns
	localparam integer C_FSYNC_INTERVAL = 10 * 1000 * 1000 / 5;

wire[C_PIXEL_WIDTH-1:0] m_axis_tdata_tb ;
wire                    m_axis_tlast_tb ;
reg                     m_axis_tready_tb;
wire                    m_axis_tuser_tb ;
wire                    m_axis_tvalid_tb;

wire[C_PIXEL_WIDTH-1:0] s_axis_tdata_tb ;
wire                    s_axis_tlast_tb ;
wire                    s_axis_tready_tb;
wire                    s_axis_tuser_tb ;
reg                     s_axis_tvalid_tb;

reg[C_SH_WIDTH-1:0] s_height_tb = 10;
reg[C_SW_WIDTH-1:0] s_width_tb = 10;
reg resetn_tb;
reg[C_MH_WIDTH-1:0] m_height_tb = 240;
reg[C_MW_WIDTH-1:0] m_width_tb = 320;

integer fileR, picType, dataPosition, grayDepth;
reg[80*8:0] outputFileName;
reg[11:0] outputFileIdx = 0;
integer fileW = 0;
initial begin
	if (C_REALDATA) begin
		fileR=$fopen("a.pgm", "r");
		$fscanf(fileR, "P%d\n%d %d\n%d\n", picType, s_width_tb, s_height_tb, grayDepth);
		dataPosition=$ftell(fileR);
		$display("header: %dx%d, %d", s_width_tb, s_height_tb, grayDepth);
		m_height_tb = s_height_tb / 2;
		m_width_tb = s_width_tb / 2;
		$display("header: %dx%d, %d, %0dx%0d", s_width_tb, s_height_tb, grayDepth, m_width_tb, m_height_tb);
	end
	else begin
		s_width_tb = 10;
		s_height_tb = 10;
		m_height_tb = 60;
		m_width_tb = 60;
	end
end

reg clk;
reg fsync_tb = 0;

initial begin
	clk <= 1'b1;
	forever #2.5 clk <= ~clk;
end

initial begin
	m_axis_tready_tb <= 1'b0;
	#0.2 m_axis_tready_tb <= 1'b1;
	forever begin
		#5 m_axis_tready_tb <= (RANDOMOUTPUT ? {$random}%2 : 1);
	end
end

initial begin
	resetn_tb <= 1'b0;
	repeat (5) #5 resetn_tb <= 1'b0;
	forever #5 resetn_tb <= 1'b1;
end

initial begin
	fsync_tb <= 0;
	repeat (10) #5 fsync_tb <= 0;
	forever begin
		repeat (1) #5 fsync_tb <= 1;
		repeat (C_FSYNC_INTERVAL - 1) #5 fsync_tb <= 0;
	end
end

reg[23:0] outcnt = 0;
reg[11:0] outline = 0;


////////////////////////////////////////////////////////////////////////// input
	reg [C_SH_WIDTH-1:0]     s_ridx;
	reg [C_SW_WIDTH-1:0]     s_cidx;
	wire s_rlast;
	wire s_clast;
	assign s_rlast = (s_ridx == s_height_tb - 1);
	assign s_clast = (s_cidx == s_width_tb - 1);
	assign s_axis_tuser_tb = (s_ridx == 0 && s_cidx == 0);
	assign s_axis_tlast_tb = (s_cidx == s_width_tb - 1);

	always @ (posedge clk) begin
		if (resetn_tb == 1'b0) begin
			s_ridx <= 0;
			s_cidx <= 0;
		end
		else if (s_axis_tvalid_tb && s_axis_tready_tb) begin
			if (~s_clast) begin
				s_cidx <= s_cidx + 1;
				s_ridx <= s_ridx;
			end
			else if (~s_rlast) begin
				s_cidx <= 0;
				s_ridx <= s_ridx + 1;
			end
			else begin
				s_cidx <= 0;
				s_ridx <= 0;
			end
		end
	end
////////////////////////// enable input ////////////////////////////////////////
	reg frm_done;
	wire en_input;
	wire trans_frm_last;
	assign trans_frm_last = (s_ridx == (s_height_tb - 1)
		&& s_cidx == s_width_tb - 1
		&& s_axis_tvalid_tb);
	always @ (posedge clk) begin
		if (resetn_tb == 0)
			frm_done <= 1;
		else if (trans_frm_last)
			frm_done <= 1;
		else if (fsync_tb)
			frm_done <= 0;
	end

	reg randomresult;
	always @ (posedge clk) begin
		randomresult <= (RANDOMINPUT ? {$random}%2 : 1);
	end

	assign en_input = (~trans_frm_last && ~frm_done && randomresult);
	always @ (posedge clk) begin
		if (resetn_tb == 1'b0)
			s_axis_tvalid_tb <= 1'b0;
		else if (~s_axis_tvalid_tb || s_axis_tready_tb) begin
			s_axis_tvalid_tb <= en_input;
		end
	end
generate
if (C_REALDATA) begin
	reg [C_PIXEL_WIDTH-1:0] s_axis_tdata_tb_r ;
	assign s_axis_tdata_tb = s_axis_tdata_tb_r;
	always @ (posedge clk) begin
		if (fsync_tb)
			$fseek(fileR, dataPosition, 0);
	end
	always @ (posedge clk) begin
		if (resetn_tb == 1'b0) begin
			s_axis_tdata_tb_r <= 0;
		end
		else if ((~s_axis_tvalid_tb || s_axis_tready_tb)
			&& en_input)  begin
			s_axis_tdata_tb_r <= $fgetc(fileR);
		end
	end
end
else begin
	assign s_axis_tdata_tb = (s_ridx * 256 + s_cidx);
end
endgenerate

///////////////////////////////////////////////////// output
always @(posedge clk) begin
	if (resetn_tb == 1'b0 || (outcnt >= m_height_tb * m_width_tb && m_axis_tready_tb)) begin
		if (fileW == 0) begin
			outputFileIdx <= outputFileIdx + 1;
			$sformat(outputFileName, "output%0d.pgm", outputFileIdx);
			fileW=$fopen(outputFileName, "w");
			$display("outputFileName: %s - %0d", outputFileName, fileW);
			$fwrite(fileW, "P%0d\n%0d %0d\n%0d\n", picType, m_width_tb, m_height_tb, grayDepth);
		end

		if (outcnt > 0) $display ("new output!");
		outcnt <= 0;
		outline <= 0;
	end
	else if (m_axis_tready_tb && m_axis_tvalid_tb) begin
		//$display("output data to %s", outputFileName);
		$fwrite(fileW, "%c", m_axis_tdata_tb);
		if (m_axis_tuser_tb != (outcnt == 0)) begin
			$display("error sof %t", $time);
		end
		if (m_axis_tlast_tb != ((outcnt+1) % m_width_tb == 0)) begin
			$display("error eol %t", $time);
		end
		$write("%h ", m_axis_tdata_tb);
		if (m_axis_tlast_tb) begin
			$write(outline+1, "   time: %t\n", $time);
			outline <= outline + 1;
		end
		outcnt <= outcnt + 1;

		if (outcnt == m_height_tb * m_width_tb - 1) begin
			$fclose(fileW);
			fileW = 0;
		end
	end
end


axis_scaler # (
	.C_PIXEL_WIDTH(C_PIXEL_WIDTH),
	.C_SH_WIDTH   (C_SH_WIDTH   ),
	.C_SW_WIDTH   (C_SW_WIDTH   ),
	.C_MH_WIDTH   (C_MH_WIDTH   ),
	.C_MW_WIDTH   (C_MW_WIDTH   ),
	.C_CH0_WIDTH  (C_CH0_WIDTH  ),
	.C_CH1_WIDTH  (C_CH1_WIDTH  ),
	.C_CH2_WIDTH  (C_CH2_WIDTH  )
) uut (
	.m_axis_tdata(m_axis_tdata_tb),
	.m_axis_tlast(m_axis_tlast_tb),
	.m_axis_tready(m_axis_tready_tb),
	.m_axis_tuser(m_axis_tuser_tb),
	.m_axis_tvalid(m_axis_tvalid_tb),
	.s_axis_tdata(s_axis_tdata_tb),
	.s_axis_tlast(s_axis_tlast_tb),
	.s_axis_tready(s_axis_tready_tb),
	.s_axis_tuser(s_axis_tuser_tb),
	.s_axis_tvalid(s_axis_tvalid_tb),
	.clk(clk),
	.resetn(resetn_tb),
	.fsync(fsync_tb),
	.s_height(s_height_tb),
	.s_width(s_width_tb),
	.m_height(m_height_tb),
	.m_width(m_width_tb)
);

endmodule
