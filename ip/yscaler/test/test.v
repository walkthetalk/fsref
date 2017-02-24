`timescale 1ns / 1ps

/// 2. first line output : if f0 valid
/// 3. sof for reset

module test();

wire[7:0] M_AXIS_tdata_tb;
wire M_AXIS_tlast_tb;
reg M_AXIS_tready_tb;
wire M_AXIS_tuser_tb;
wire M_AXIS_tvalid_tb;

reg[7:0] S_AXIS_tdata_tb;
reg S_AXIS_tlast_tb;
wire S_AXIS_tready_tb;
reg S_AXIS_tuser_tb;
reg S_AXIS_tvalid_tb;

reg[11:0] ori_height_tb = 10;
reg[11:0] ori_width_tb = 10;
reg resetn_tb;
reg[11:0] scale_height_tb = 2;
reg[11:0] scale_width_tb = 10;

reg clk;

test_yscaler_wrapper uut(
	.M_AXIS_tdata(M_AXIS_tdata_tb),
	.M_AXIS_tlast(M_AXIS_tlast_tb),
	.M_AXIS_tready(M_AXIS_tready_tb),
	.M_AXIS_tuser(M_AXIS_tuser_tb),
	.M_AXIS_tvalid(M_AXIS_tvalid_tb),
	.S_AXIS_tdata(S_AXIS_tdata_tb),
	.S_AXIS_tlast(S_AXIS_tlast_tb),
	.S_AXIS_tready(S_AXIS_tready_tb),
	.S_AXIS_tuser(S_AXIS_tuser_tb),
	.S_AXIS_tvalid(S_AXIS_tvalid_tb),
	.clk(clk),
	.ori_height(ori_height_tb),
	.ori_width(ori_width_tb),
	.resetn(resetn_tb),
	.scale_height(scale_height_tb),
	.scale_width(scale_width_tb));

initial begin
    clk <= 1'b1;
	forever #1 clk <= ~clk;
end

initial begin
	M_AXIS_tready_tb <= 1'b0;
	#0.2 M_AXIS_tready_tb <= 1'b1;
	forever begin
		//#2 M_AXIS_tready_tb <= 1'b1;
		#2 M_AXIS_tready_tb <= {$random}%2;
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

always @(posedge clk) begin
	if (resetn_tb == 1'b0 || (cnt > ori_width_tb * ori_height_tb)) begin
		cnt <= 0;
		S_AXIS_tvalid_tb <= 1'b0;
		S_AXIS_tdata_tb <= 0;
		S_AXIS_tlast_tb <= 1'b0;
		S_AXIS_tuser_tb <= 1'b0;
	end
	else if (cnt == 0 && ~S_AXIS_tvalid_tb) begin
		if ({$random}%2) begin
			S_AXIS_tvalid_tb <= 1'b1;
			S_AXIS_tuser_tb <= 1'b1;
			S_AXIS_tdata_tb <= 0;
			S_AXIS_tlast_tb <= (ori_width_tb == 1);
			cnt <= 1;
		end
	end
	else if (S_AXIS_tvalid_tb && S_AXIS_tready_tb)  begin
		if (cnt == ori_width_tb * ori_height_tb) begin
			cnt <= 0;
			S_AXIS_tvalid_tb <= 1'b0;
			S_AXIS_tdata_tb <= 0;
			S_AXIS_tlast_tb <= 1'b0;
			S_AXIS_tuser_tb <= 1'b0;
		end
		else if ({$random}%2) begin
			S_AXIS_tvalid_tb <= 1'b1;
			S_AXIS_tdata_tb <= (cnt / ori_width_tb * 10 + cnt % ori_width_tb);
			S_AXIS_tlast_tb <= ((cnt+1) % ori_width_tb == 0);
			S_AXIS_tuser_tb <= 1'b0;
			cnt <= cnt + 1;
		end
		else begin
			S_AXIS_tvalid_tb <= 1'b0;
		end
	end
	else if (~S_AXIS_tvalid_tb) begin
		if ({$random}%2) begin
			S_AXIS_tvalid_tb <= 1'b1;
			S_AXIS_tdata_tb <= (cnt / ori_width_tb * 10 + cnt % ori_width_tb);
			S_AXIS_tlast_tb <= ((cnt+1) % ori_width_tb == 0);
			S_AXIS_tuser_tb <= 1'b0;
			cnt <= cnt + 1;
		end
	end


	if (resetn_tb == 1'b0 || (outcnt >= scale_height_tb * scale_width_tb && M_AXIS_tready_tb)) begin
		if (outcnt > 0) $display ("new output!");
		outcnt <= 0;
		outline <= 0;
	end
	else if (M_AXIS_tready_tb && M_AXIS_tvalid_tb) begin
		if (M_AXIS_tuser_tb != (outcnt == 0)) begin
			$display("error sof");
		end
		if (M_AXIS_tlast_tb != ((outcnt+1) % ori_width_tb == 0)) begin
			$display("error eol");
		end
		$write(M_AXIS_tdata_tb, "  ");
		if (M_AXIS_tlast_tb) begin
			$write(outline+1, "\n");
			outline <= outline + 1;
		end
		outcnt <= outcnt + 1;
	end
end

endmodule