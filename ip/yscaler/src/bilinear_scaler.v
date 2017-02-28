module bilinear_scaler # (
	C_RESO_WIDTH  = 10
) (
	input wire clk,
	input wire resetn,

	input wire [C_RESO_WIDTH-1 : 0] ori_size,
	input wire [C_RESO_WIDTH-1 : 0] scale_size,

	input wire update_mul,

	output wire m_repeat_line,
	output reg [C_RESO_WIDTH-1 : 0] m_inv_cnt, 	/// [h,1] @note: keep last 1
	output reg [C_RESO_WIDTH-1 : 0] o_inv_cnt,	/// [h, 1][0]

	output wire m_ovalid,

	output wire [2:0] ratio
);
	localparam C_CMP_WIDTH = C_RESO_WIDTH * 2 + 1 + 1;

	reg [C_CMP_WIDTH-1:0] m_mul;
	reg [C_CMP_WIDTH-1:0] o_mul;

	reg [C_CMP_WIDTH-1:0] m_spliter[3:0];

	reg [C_CMP_WIDTH-1:0] o_mul_next;

	assign m_repeat_line = m_mul >= o_mul_next;
	assign m_ovalid = m_mul >= o_mul;
	assign ratio = (o_mul >= m_spliter[2]
			? (o_mul >= m_spliter[3] ? 4 : 3)
			: (o_mul >= m_spliter[1] ? 2 : (o_mul >= m_spliter[0] ? 1 : 0))
		);

	/// @note: update even repeat, (for last input line, iow, extenting)
	wire update_mmul;
	assign update_mmul = update_mul && ~m_repeat_line;
	wire update_omul;
	assign update_omul = update_mul && (m_mul >= o_mul);

	/// compare counter for checking if ready
	/// @note: max value is ori_size * scale_size * 2 + (ori_size or scale_size)/2

	always @(posedge clk) begin
		if (resetn == 1'b0)
			m_mul <= (ori_size == 1 ? scale_size * 2 : scale_size);
		else if (update_mmul) begin
			case (m_inv_cnt)
			1:	m_mul <= m_mul;
			2:	m_mul <= m_mul + scale_size * 2 + scale_size;
			default:m_mul <= m_mul + scale_size * 2;
			endcase
		end
		else
			m_mul <= m_mul;
	end

	always @(posedge clk) begin
		if (resetn == 1'b0) begin
			m_spliter[0] <= scale_size;
			m_spliter[1] <= scale_size;
			m_spliter[2] <= scale_size;
			m_spliter[3] <= scale_size;
		end
		else if (update_mmul) begin
			case (m_inv_cnt)
			1: begin
				m_spliter[0] <= m_mul;
				m_spliter[1] <= m_mul;
				m_spliter[2] <= m_mul;
				m_spliter[3] <= m_mul;
			end
			default: begin
				m_spliter[0] <= m_mul + scale_size/4;
				m_spliter[1] <= m_mul + scale_size - scale_size/4;
				m_spliter[2] <= m_mul + scale_size + scale_size/4;
				m_spliter[3] <= m_mul + scale_size;
			end
			endcase
		end
		else begin
			m_spliter[0] <= m_spliter[0];
			m_spliter[1] <= m_spliter[1];
			m_spliter[2] <= m_spliter[2];
			m_spliter[3] <= m_spliter[3];
		end
	end

	always @(posedge clk) begin
		if (resetn == 1'b0)
			o_mul <= ori_size;
		else if (update_omul)
			o_mul <= o_mul_next;
		else
			o_mul <= o_mul;
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
		if (resetn == 1'b0)
			m_inv_cnt <= ori_size;
		/// @note: don't modify counter when repeating last line
		else if (update_mmul && m_inv_cnt != 1)
			m_inv_cnt <= m_inv_cnt - 1;
		else
			m_inv_cnt <= m_inv_cnt;
	end
endmodule
