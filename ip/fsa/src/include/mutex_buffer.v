
module mutex_buffer #
(
	parameter integer C_BUFF_NUM = 4
) (
	input wire clk,
	input wire resetn,

	output wire wr_done,

	input wire                        w_sof,
	output reg [C_BUFF_NUM-1:0]       w_bmp,

	input wire                        r0_sof,
	output reg [C_BUFF_NUM-1:0]       r0_bmp,

	input wire                        r1_sof,
	output reg [C_BUFF_NUM-1:0]       r1_bmp
);

	assign wr_done = w_sof;

	reg [C_BUFF_NUM-1:0]	last_bmp;

	/// reader 0
	always @(posedge clk) begin
		if (resetn == 0) begin
			r0_bmp  <= 0;
		end
		else if (r0_sof) begin
			if (w_sof) begin
				r0_bmp  <= w_bmp;
			end
			else begin
				r0_bmp  <= last_bmp;
			end
		end
	end

	/// reader 1 (same as reader 0)
	always @(posedge clk) begin
		if (resetn == 0) begin
			r1_bmp  <= 0;
		end
		else if (r1_sof) begin
			if (w_sof) begin
				r1_bmp  <= w_bmp;
			end
			else begin
				r1_bmp  <= last_bmp;
			end
		end
	end

	/// last done (ready for read)
	always @(posedge clk) begin
		if (resetn == 0) begin
			last_bmp  <= 4'b0001;
		end
		else if (w_sof) begin
			last_bmp  <= w_bmp;
		end
	end

	always @(posedge clk) begin
		if (resetn == 0) begin
			w_bmp  <= 4'b0010;
		end
		else if (w_sof) begin
			casez (w_bmp | r0_bmp | r1_bmp)
			4'b???0: begin
				w_bmp	<= 4'b0001;
			end
			4'b??01: begin
				w_bmp	<= 4'b0010;
			end
			4'b?011: begin
				w_bmp	<= 4'b0100;
			end
			4'b0111: begin
				w_bmp	<= 4'b1000;
			end
			default: begin
				w_bmp  <= 4'b0010;
			end
			endcase
		end
	end

endmodule
