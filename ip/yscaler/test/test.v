`timescale 1ns / 1ps

`include "../src/linebuffer.v"
`include "../src/yscaler.v"

module test();

	localparam RANDOMOUTPUT = 1;
	localparam RANDOMINPUT = 1;

	localparam  integer C_PIXEL_WIDTH = 8;
	localparam  integer C_RESO_WIDTH  = 12;
	localparam integer C_CH0_WIDTH = 8;
	localparam integer C_CH1_WIDTH = 0;
	localparam integer C_CH2_WIDTH = 0;

wire[C_PIXEL_WIDTH-1:0] m_axis_tdata_tb;
wire m_axis_tlast_tb;
reg m_axis_tready_tb;
wire m_axis_tuser_tb;
wire m_axis_tvalid_tb;

reg[C_PIXEL_WIDTH-1:0] s_axis_tdata_tb;
reg s_axis_tlast_tb;
wire s_axis_tready_tb;
reg s_axis_tuser_tb;
reg s_axis_tvalid_tb;

reg[C_RESO_WIDTH-1:0] s_height_tb = 10;
reg[C_RESO_WIDTH-1:0] s_width_tb = 10;
reg resetn_tb;
reg[C_RESO_WIDTH-1:0] m_height_tb = 240;
reg[C_RESO_WIDTH-1:0] m_width_tb = 320;

integer fileR, picType, dataPosition, grayDepth;
reg[80*8:0] outputFileName;
reg[11:0] outputFileIdx = 0;
integer fileW = 0;
initial begin
    fileR=$fopen("a.pgm", "r");
    $fscanf(fileR, "P%d\n%d %d\n%d\n", picType, s_width_tb, s_height_tb, grayDepth);
    dataPosition=$ftell(fileR);
    $display("header: %dx%d, %d", s_width_tb, s_height_tb, grayDepth);
    m_height_tb = s_height_tb*2;
    m_width_tb = s_width_tb*2;
    $display("header: %dx%d, %d, %0dx%0d", s_width_tb, s_height_tb, grayDepth, m_width_tb, m_height_tb);
end

reg clk;
reg fsync_tb = 0;

yscaler # (
	.C_PIXEL_WIDTH(C_PIXEL_WIDTH),
	.C_RESO_WIDTH(C_RESO_WIDTH),
	.C_CH0_WIDTH(C_CH0_WIDTH),
	.C_CH1_WIDTH(C_CH1_WIDTH),
	.C_CH2_WIDTH(C_CH2_WIDTH)
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
	.fsync(1'b0),
	.s_height(s_height_tb),
	.s_width(s_width_tb),
	.m_height(m_height_tb),
	.m_width(m_width_tb));

initial begin
    clk <= 1'b1;
	forever #1 clk <= ~clk;
end

initial begin
	m_axis_tready_tb <= 1'b0;
	#0.2 m_axis_tready_tb <= 1'b1;
	forever begin
		#2 m_axis_tready_tb <= (RANDOMOUTPUT ? {$random}%2 : 1);
	end
end

initial begin
	resetn_tb <= 1'b0;
	repeat (5) #2 resetn_tb <= 1'b0;
	forever #2 resetn_tb <= 1'b1;
end

reg[23:0] cnt = 0;

reg[23:0] outcnt = 0;
reg[11:0] outline = 0;
/*
reg output_done;
reg input_done;
always @ (posedge clk) begin
	if (resetn_tb == 1'b0)
		output_done <= 0;
	else if (~output_done && m_axis_tready_tb && m_axis_tvalid_tb)
end
*/
reg randominput;
always @(posedge clk) begin
	if (resetn_tb == 1'b0)
		randominput <= 1'b0;
	else
		randominput <= (RANDOMINPUT ? {$random}%2 : 1);

	if (resetn_tb == 1'b0 || (cnt > s_width_tb * s_height_tb)) begin
		$fseek(fileR, dataPosition, 0);
		cnt <= 0;
		s_axis_tvalid_tb <= 1'b0;
		s_axis_tdata_tb <= 0;
		s_axis_tlast_tb <= 1'b0;
		s_axis_tuser_tb <= 1'b0;
	end
	else if (cnt == 0 && ~s_axis_tvalid_tb) begin
		if (randominput) begin
			s_axis_tvalid_tb <= 1'b1;
			s_axis_tuser_tb <= 1'b1;
			s_axis_tdata_tb <= $fgetc(fileR);
			s_axis_tlast_tb <= (s_width_tb == 1);
			cnt <= 1;
		end
	end
	else if (s_axis_tvalid_tb && s_axis_tready_tb)  begin
		if (cnt == s_width_tb * s_height_tb) begin
			cnt <= 0;
			s_axis_tvalid_tb <= 1'b0;
			s_axis_tdata_tb <= 0;
			s_axis_tlast_tb <= 1'b0;
			s_axis_tuser_tb <= 1'b0;
		end
		else if (randominput) begin
			s_axis_tvalid_tb <= 1'b1;
			s_axis_tdata_tb <= $fgetc(fileR);
			s_axis_tlast_tb <= ((cnt+1) % s_width_tb == 0);
			s_axis_tuser_tb <= 1'b0;
			cnt <= cnt + 1;
		end
		else begin
			s_axis_tvalid_tb <= 1'b0;
		end
	end
	else if (~s_axis_tvalid_tb) begin
		if (randominput) begin
			s_axis_tvalid_tb <= 1'b1;
			s_axis_tdata_tb <= $fgetc(fileR);
			s_axis_tlast_tb <= ((cnt+1) % s_width_tb == 0);
			s_axis_tuser_tb <= 1'b0;
			cnt <= cnt + 1;
		end
	end


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
			$display("error sof");
		end
		if (m_axis_tlast_tb != ((outcnt+1) % m_width_tb == 0)) begin
			$display("error eol");
		end
		$write("%h ", m_axis_tdata_tb);
		if (m_axis_tlast_tb) begin
			$write(outline+1, "\n");
			outline <= outline + 1;
		end
		outcnt <= outcnt + 1;

		if (outcnt == m_height_tb * m_width_tb - 1) begin
			$fclose(fileW);
			fileW = 0;
		end
	end
end

endmodule
