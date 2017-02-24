module bilinear_scaler # (
	C_RESO_WIDTH  = 10
) (
	input wire clk,
	input wire resetn,

	input wire [C_RESO_WIDTH-1 : 0] ori_size,
	input wire [C_RESO_WIDTH-1 : 0] scale_size,

	input wire update_mul,

	output wire m_repeat_line,
	output reg [C_RESO_WIDTH-1 : 0] m_inv_cnt,
	output reg [C_RESO_WIDTH-1 : 0] o_inv_cnt,

	output wire m_ovalid
);
	localparam C_CMP_WIDTH = C_RESO_WIDTH * 2 + 1 + 1;

	reg [C_CMP_WIDTH-1:0] m_mul_p;
	reg [C_CMP_WIDTH-1:0] m_mul;
	reg [C_CMP_WIDTH-1:0] o_mul;

	reg [C_CMP_WIDTH-1:0] m_mul_next;
	reg [C_CMP_WIDTH-1:0] o_mul_next;

	reg [C_RESO_WIDTH-1:0] m_inv_cnt;	/// [h,1] @note: keep last 1
	reg [C_RESO_WIDTH-1:0] o_inv_cnt;	/// [h, 1][0]

	assign m_repeat_line = m_mul >= o_mul_next;
	assign m_ovalid = m_mul >= o_mul;

	/// @note: update even repeat, (for last input line, iow, extenting)
	wire update_mmul;
	assign update_mmul = update_mul && (~m_repeat_line || m_inv_cnt == 1);
	wire update_omul;
	assign update_omul = update_mul && (m_mul >= o_mul);

	/// compare counter for checking if ready
	/// @note: max value is ori_size * scale_size * 2 + (ori_size or scale_size)/2

	always @(posedge clk) begin
		if (resetn == 1'b0)
			m_mul_next <= (ori_size == 1 ? scale_size * 2 : scale_size * 3);
		else if (update_mmul) begin
			case (m_inv_cnt)
			1:	m_mul_next <= m_mul_next;
			2:	m_mul_next <= m_mul_next + scale_size;
			default:m_mul_next <= m_mul_next + scale_size * 2;
			endcase
		end
		else
			m_mul_next <= m_mul_next;
	end
	always @(posedge clk) begin
		if (resetn == 1'b0)	m_mul <= scale_size;
		else if (update_mmul)	m_mul <= m_mul_next;
		else			m_mul <= m_mul;
	end
	always @(posedge clk) begin
		if (resetn == 1'b0)	m_mul_p <= 0;
		else if (update_mmul)	m_mul_p <= m_mul;
		else			m_mul_p <= m_mul_p;
	end

	always @(posedge clk) begin
		if (resetn == 1'b0)	o_mul <= ori_size;
		else if (update_omul)	o_mul <= o_mul_next;
		else			o_mul <= o_mul;
	end

	always @(posedge clk) begin
		if (resetn == 1'b0)
			o_mul_next <= ori_size*3;
		else if (update_omul) begin
			o_mul_next <= o_mul_next + ori_size * 2;
		end
		else
			o_mul_next <= o_mul_next;
	end

	always @(posedge clk) begin
		if (resetn == 1'b0)	o_inv_cnt <= scale_size;
		else if (update_omul)	o_inv_cnt <= o_inv_cnt - 1;
		else			o_inv_cnt <= o_inv_cnt;
	end

	always @(posedge clk) begin
		if (resetn == 1'b0)	m_inv_cnt <= ori_size;
		/// @note: don't modify counter when repeating last line
		else if (update_mmul && m_inv_cnt != 1)	m_inv_cnt <= m_inv_cnt - 1;
		else			m_inv_cnt <= m_inv_cnt;
	end
endmodule
