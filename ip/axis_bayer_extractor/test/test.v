`timescale 1ns / 1ps
`include "../src/axis_bayer_extractor.v"
module test_bayer_extractor(
    );

    localparam RANDOMOUTPUT = 0;
    localparam RANDOMINPUT = 0;
    localparam  C_COL_ODD = 0;
    localparam  C_ROW_ODD = 0;

	wire[7:0] mdata;
	wire mlast;
	reg mready;
	wire muser;
	wire mvalid;

	wire[7:0] sdata;
	wire slast;
	wire sready;
	wire suser;
	reg svalid;

	reg[11:0] ori_height = 10;
	reg[11:0] ori_width = 10;

	reg resetn;
	reg clk;

axis_bayer_extractor #(
	.C_PIXEL_WIDTH(8),
	.C_COL_ODD(C_COL_ODD),
	.C_ROW_ODD(C_ROW_ODD)
)uut(
	.m_axis_tdata(mdata),
	.m_axis_tlast(mlast),
	.m_axis_tready(mready),
	.m_axis_tuser(muser),
	.m_axis_tvalid(mvalid),
	.s_axis_tdata(sdata),
	.s_axis_tlast(slast),
	.s_axis_tready(sready),
	.s_axis_tuser(suser),
	.s_axis_tvalid(svalid),
	.clk(clk),
	.resetn(resetn));

initial begin
	clk <= 1'b1;
	forever #1 clk <= ~clk;
end
initial begin
	resetn <= 1'b0;
	repeat (5) #2 resetn <= 1'b0;
	forever #2 resetn <= 1'b1;
end

reg[11:0] in_row;
reg[11:0] in_col;
assign sdata = (in_row * 16 + in_col);

reg[11:0] out_row;
reg[11:0] out_col;
reg[7:0]  out_data;
reg out_last;

assign suser = (in_row == 0 && in_col == 0);
assign slast = (in_col == ori_height - 1);

reg randominput;
reg randomoutput;
always @(posedge clk) begin
	if (resetn == 1'b0)
		randominput <= 1'b0;
	else
		randominput <= (RANDOMINPUT ? {$random}%2 : 1);

	if (resetn == 1'b0)
		randomoutput <= 1'b0;
	else
		randomoutput <= (RANDOMOUTPUT ? {$random}%2 : 1);

	if (resetn == 1'b0) begin
		in_row <= 0;
		in_col <= 0;
	end
	else if (svalid && sready) begin
		if (in_col != ori_width - 1) begin
			in_col <= in_col + 1;
			in_row <= in_row;
		end
		else if (in_row != ori_height - 1) begin
			in_col <= 0;
			in_row <= in_row + 1;
		end
		else begin
			in_row <= 0;
			in_col <= 0;
		end
	end

	if (resetn == 1'b0)
		svalid <= 1'b0;
	else if (~svalid) begin
		if (randominput) begin
			svalid <= 1'b1;
		end
	end
	else if (svalid && sready)  begin
		if (randominput) begin
			svalid <= 1'b1;
		end
		else begin
			svalid <= 1'b0;
		end
	end


	if (resetn == 1'b0)
		mready <= 1'b0;
	else if (randomoutput)
		mready <= 1'b1;
	else
		mready <= 1'b0;


	if (resetn == 1'b0) begin
		out_data <= 0;
		out_last <= 0;
	end
	else if (mready && mvalid) begin
		out_data <= mdata;
		out_last <= mlast;
	end


	if (resetn == 1'b0) begin
		out_col = 0;
		out_row = 0;
	end
	else if (mready && mvalid) begin
		if (muser) begin
			out_col = 0;
			out_row = 0;
		end
		else if (out_last) begin
			out_col = 0;
			out_row = out_row + 1;
		end
		else begin
			out_col = out_col + 1;
			out_row = out_row;
		end
		if (muser)
			$write("start new frame: \n");
		$write("%h ", mdata);
		if (mlast)
			$write("\n");
	end
end


endmodule
