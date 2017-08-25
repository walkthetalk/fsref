`timescale 1ns / 1ps
module testwindow(
    );

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

	reg[11:0] w_left = 0;
	reg[11:0] w_top = 0;
	reg[11:0] w_width = 10;
	reg[11:0] w_height = 10;

	reg resetn;
	reg clk;

hehe23_wrapper uut(
	.M_AXIS_tdata(mdata),
	.M_AXIS_tlast(mlast),
	.M_AXIS_tready(mready),
	.M_AXIS_tuser(muser),
	.M_AXIS_tvalid(mvalid),
	.S_AXIS_tdata(sdata),
	.S_AXIS_tlast(slast),
	.S_AXIS_tready(sready),
	.S_AXIS_tuser(suser),
	.S_AXIS_tvalid(svalid),
	.S_WIN_CTL_height(w_height),
	.S_WIN_CTL_left(w_left),
	.S_WIN_CTL_top(w_top),
	.S_WIN_CTL_width(w_width),
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


localparam RANDOMOUTPUT = 0;
localparam RANDOMINPUT = 0;

reg[11:0] in_row;
reg[11:0] in_col;
assign sdata = (in_row * 10 + in_col);

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
		$write("%d ", mdata);
		if (mlast)
			$write("\n");
	end
end


endmodule
