`timescale 1ns / 1ps
`include "../src/include/axis_shifter_v2.v"
`include "../src/axis_window.v"
module testwindow(
    );

    localparam RANDOMOUTPUT = 1;
    localparam RANDOMINPUT = 1;

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

	reg[11:0] ori_height = 16;
	reg[11:0] ori_width = 16;

	reg[11:0] w_left = 3;
	reg[11:0] w_top = 3;
	reg[11:0] w_width = 5;
	reg[11:0] w_height = 6;

	reg resetn;
	reg clk;

axis_window #(
	.C_PIXEL_WIDTH(8),
	.C_IMG_WBITS(12),
	.C_IMG_HBITS(12)
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
	.win_height(w_height),
	.win_left(w_left),
	.win_top(w_top),
	.win_width(w_width),
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

assign suser = (in_row == 0 && in_col == 0);
assign slast = (in_col == ori_height - 1);

reg randominput;
reg randomoutput;
reg input_done;
reg output_done;
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
		input_done <= 0;
	else if (svalid && sready && in_col == ori_width-1 && in_row == ori_height-1)
		input_done <= 1;
	else if (input_done && output_done)
		input_done <= 0;

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
		out_col = 0;
		out_row = 0;
	end
	else if (mready && mvalid) begin
		if (muser) begin
			out_col <= 0;
			out_row <= 0;
		end
		else if (mlast) begin
			out_col <= 0;
			out_row <= out_row + 1;
		end
		else begin
			out_col <= out_col + 1;
			out_row <= out_row;
		end
		if (muser)
			$write("start new frame: \n");
		$write("%h ", mdata);
		if (mlast)
			$write("\n");
	end

	if (resetn == 1'b0)
		output_done <= 0;
	else if (output_done && input_done)
		output_done <= 0;
	else if (~output_done
		&& (mready && mvalid
		&& out_col == w_width-1
		&& out_row == w_height-1) || (w_width == 0 || w_height == 0))
		output_done <= 1;
/*
	if (resetn == 1'b0) begin
	end
	else if (out_row == w_height) begin
		w_left <= 0;
		w_top <= 0;
		w_height <= 0;
		w_width <= 0;
	end
*/
	if (input_done && output_done) begin
		if (w_left != 0) begin
			w_left <= 0;
			w_top <= 0;
			w_height <= 0;
			w_width <= 0;
		end
		else begin
			w_left <= 3;
			w_top <= 3;
			w_width <= 5;
			w_height <= 6;
		end
	end

end


endmodule
