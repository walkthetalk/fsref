`timescale 1ns / 1ps

`include "../src/linebuffer.v"
`include "../src/yscaler.v"

module test();

	localparam  integer C_PIXEL_WIDTH = 16;
	localparam  integer C_RESO_WIDTH  = 12;
	localparam integer C_CH0_WIDTH = 8;
	localparam integer C_CH1_WIDTH = 8;
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

reg[C_RESO_WIDTH-1:0] s_height_tb = 30;
reg[C_RESO_WIDTH-1:0] s_width_tb = 10;
reg resetn_tb;
reg[C_RESO_WIDTH-1:0] m_height_tb = 10;
reg[C_RESO_WIDTH-1:0] m_width_tb = 10;

reg clk;
reg fsync_tb = 0;

localparam RANDOMOUTPUT = 1;
localparam RANDOMINPUT = 1;

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
	.fsync(0),
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

reg randominput;
always @(posedge clk) begin
	if (resetn_tb == 1'b0)
		randominput <= 1'b0;
	else
		randominput <= (RANDOMINPUT ? {$random}%2 : 1);

	if (resetn_tb == 1'b0 || (cnt > s_width_tb * s_height_tb)) begin
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
			s_axis_tdata_tb <= 0;
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
			s_axis_tdata_tb <= (cnt / s_width_tb * 256 + cnt % s_width_tb);
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
			s_axis_tdata_tb <= (cnt / s_width_tb * 256 + cnt % s_width_tb);
			s_axis_tlast_tb <= ((cnt+1) % s_width_tb == 0);
			s_axis_tuser_tb <= 1'b0;
			cnt <= cnt + 1;
		end
	end


	if (resetn_tb == 1'b0 || (outcnt >= m_height_tb * m_width_tb && m_axis_tready_tb)) begin
		if (outcnt > 0) $display ("new output!");
		outcnt <= 0;
		outline <= 0;
	end
	else if (m_axis_tready_tb && m_axis_tvalid_tb) begin
		if (m_axis_tuser_tb != (outcnt == 0)) begin
			$display("error sof");
		end
		if (m_axis_tlast_tb != ((outcnt+1) % s_width_tb == 0)) begin
			$display("error eol");
		end
		$write("%h   ", m_axis_tdata_tb);
		if (m_axis_tlast_tb) begin
			$write(outline+1, "\n");
			outline <= outline + 1;
		end
		outcnt <= outcnt + 1;
	end
end

endmodule
