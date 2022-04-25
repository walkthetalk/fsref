`timescale 1ns / 1ps
`include "../src/axis_reshaper_v2.v"
module testreshaper(
    );
	localparam RANDOMOUTPUT = 1;
	localparam RANDOMINPUT = 1;
	localparam DATA_WIDTH = 12;

	wire[DATA_WIDTH-1:0] mdata;
	wire mlast;
	reg mready;
	wire muser;
	wire mvalid;

	wire[DATA_WIDTH-1:0] sdata;
	wire slast;
	wire sready;
	wire suser;
	reg svalid;

	reg[11:0] ori_height = 10;
	reg[11:0] ori_width = 10;

	reg resetn;
	reg clk;
	
	wire soft_resetn;

axis_reshaper_v2 #(
	.C_PIXEL_WIDTH(DATA_WIDTH),
	.C_LOCK_FRAMES(2),
	.C_WIDTH_BITS(12),
	.C_HEIGHT_BITS(12)
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
	.resetn(resetn),
	
	.m_width(ori_width),
	.m_height(ori_height),
	.soft_resetn(soft_resetn)
);

initial begin
	clk <= 1'b1;
	forever #1 clk <= ~clk;
end
initial begin
	resetn <= 1'b0;
	repeat (5) #2 resetn <= 1'b0;
	forever #2 resetn <= 1'b1;
end

reg[11:0] in_frm;
reg[11:0] in_row;
reg[11:0] in_col;
assign sdata = (in_frm * 256 + in_row * 16 + in_col);

reg[11:0] out_row;
reg[11:0] out_col;
reg[7:0]  out_data;
reg out_last;

assign suser = (in_row == 0 && in_col == 0);
assign slast = (change_last ? (in_col != ori_height - 1) : (in_col == ori_height - 1));

reg last_invert_last;
reg[11:0] last_reset_col;
reg[11:0] last_reset_row;
reg invert_last;
reg[11:0] reset_col;
reg[11:0] reset_row;
always @ (posedge clk) begin
	if (resetn == 1'b0) begin
		last_invert_last <= 0;
		invert_last <= 0;
		last_reset_col <= ori_width-1;
		last_reset_row <= ori_height-1;
		reset_col <= ori_width;
		reset_row <= ori_height;
	end
	else if (svalid && sready) begin
		if (reset_frm || (in_col == ori_width - 1
			&& in_row == ori_height -1)) begin
			last_invert_last <= invert_last;
			invert_last <= ({$random} % 2);
			last_reset_col <= reset_col;
			last_reset_row <= reset_row;
			reset_col <= ({$random} % (10 + 1));
			reset_row <= ({$random} % (10 + 1));
			//$write("\nreset_col is %h", reset_col);
			//$write("\nreset_row is %h\n", reset_row);
		end
	end
end

wire change_last;
assign change_last = (invert_last && (in_col == reset_col && in_row == reset_row));
wire reset_frm;
assign reset_frm = (~invert_last && (in_col == reset_col && in_row == reset_row));

reg randominput;
reg randomoutput;
reg[DATA_WIDTH-1:0] last_mdata;
always @ (posedge clk) begin
	if (resetn == 1'b0)
		last_mdata <= 0;
	else if (mready && mvalid) begin
		if (muser) begin
			if (last_invert_last)
				$write("\ninvert last -- ");
			else
				$write("\nrestart frame -- ");
			if (last_mdata%256 == (last_reset_row * 16 + last_reset_col)) begin
				$write("frame ok %h %hx%h\n", last_mdata, last_reset_row, last_reset_col);
			end
			else begin
				$write("frame err! %h %hx%h\n", last_mdata, last_reset_row, last_reset_col);
			end
		end
		last_mdata <= mdata;
	end
end

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
		in_frm <= 0;
		in_row <= 0;
		in_col <= 0;
	end
	else if (svalid && sready) begin
		if (reset_frm) begin
			in_frm <= in_frm + 1;
			in_row <= 0;
			in_col <= 0;
		end
		else if (in_col != ori_width - 1) begin
			in_col <= in_col + 1;
			in_row <= in_row;
		end
		else if (in_row != ori_height - 1) begin
			in_col <= 0;
			in_row <= in_row + 1;
		end
		else begin
			in_frm <= in_frm + 1;
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
			$write("\nstart new frame: \n");
		$write("%h ", mdata);
		if (mdata[7:0] != (out_row * 16 + out_col))
			$write("err!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n");
		if (mlast)
			$write("\n");
	end
end


endmodule
