module scaler_core # (
	parameter integer C_S_WIDTH = 12,
	parameter integer C_M_WIDTH = 12,
	parameter integer C_S_BMP   = 0 ,
	parameter integer C_S_BID   = 0 ,
	parameter integer C_S_IDX   = 0 ,	/// C_S_WIDTH or 0
	parameter integer C_TEST    = 0
) (
	input wire clk,
	input wire resetn,

	input [C_S_WIDTH-1:0] s_nbr,
	input [C_M_WIDTH-1:0] m_nbr,

	input wire                                        enable        ,
	output wire                                       o_valid       ,

	output wire                                       s_advance     ,
	output wire                                       s_last        ,
	output wire [C_S_WIDTH + C_M_WIDTH        :0]     s_c           ,
	output wire [C_S_BMP + C_S_BID + C_S_IDX - 1 : 0] s_bmp_bid_idx0,
	output wire [C_S_BMP + C_S_BID + C_S_IDX - 1 : 0] s_bmp_bid_idx1,
	output wire [C_S_BMP + C_S_BID + C_S_IDX - 1 : 0] s_bmp_bid_idx2,

	output wire                                       m_advance     ,
	output wire                                       m_first       ,
	output wire                                       m_last        ,
	output wire [C_S_WIDTH + C_M_WIDTH        :0]     m_c           ,

	output wire                                       a_last        ,
	output wire                                       d_valid
);
	localparam integer C_A_WIDTH = C_S_WIDTH + C_M_WIDTH;

	reg [C_A_WIDTH  :0] s0_c;
	reg                 s0_last;
	reg [C_A_WIDTH  :0] s1_c;
	reg [C_S_WIDTH-1:0] s1_idx_evn;
	reg                 s1_last;
	reg                 su_c;

	reg [C_A_WIDTH  :0] m0_c;
	reg                 m0_first;
	reg                 m0_last;
	reg                 m1_valid;
	reg [C_A_WIDTH  :0] m1_c;
	reg                 m1_last;
	reg [C_A_WIDTH  :0] m2_c;
	reg [C_M_WIDTH-1:0] m2_idx_evn;
	reg                 m2_last;
	reg                 mu_c;

	reg                 s_v;	/// (s_c >= m_c)　or (s_last & ~m_last)
	reg                 s_vlast;	/// last valid
	reg                 sm_last;
	reg                 sm_valid;

	assign s_c       = s0_c;
	assign s_advance = su_c;
	assign s_last    = s0_last;
	assign m_c       = m0_c;
	assign m_advance = mu_c;
	assign m_first   = m0_first;
	assign m_last    = m0_last;
	assign d_valid   = s_v;
	assign a_last    = sm_last;
	assign o_valid   = sm_valid;

	wire aux_v01;  assign aux_v01  = (s0_c >= m1_c);
	wire aux_v10;  assign aux_v10  = (s1_c >= m0_c);
	wire aux_v11;  assign aux_v11  = (s1_c >= m1_c);
	wire aux_v12;  assign aux_v12  = (s1_c >= m2_c);
	wire aux_v02r; assign aux_v02r = (s0_c <  m2_c);
	wire aux_v11r; assign aux_v11r = (s1_c <  m1_c);
	wire aux_v12r; assign aux_v12r = (s1_c <  m2_c);
	wire aux_v10r; assign aux_v10r = (s1_c <  m0_c);
	wire aux_v01r; assign aux_v01r = (s0_c <  m1_c);

	wire [1:0] smu; assign smu = {su_c, mu_c};
	localparam integer UP_B = 2'b11;
	localparam integer UP_S = 2'b10;
	localparam integer UP_M = 2'b01;
	localparam integer UP_N = 2'b00;

	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			s0_c        <= 0;
			s0_last     <= 1;
		end
		else if (enable) begin
			if (su_c) begin
				s0_c        <= s1_c;
				s0_last     <= s1_last;
			end
		end
	end
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			s1_c        <= m_nbr;
			s1_idx_evn <= s_nbr;
			s1_last     <= (s_nbr == 1);
		end
		else if (enable) begin
			if (su_c) begin
				if (s1_last) begin
					s1_idx_evn <= s_nbr;
					s1_last    <= (s_nbr == 1);
					s1_c       <= m_nbr;
				end
				else begin
					s1_idx_evn <= s1_idx_evn - 1;
					s1_last    <= (s1_idx_evn == 2);
					s1_c       <= s1_c + m_nbr * 2;
				end
			end
		end
	end
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			m0_c        <= 0;
			m0_last     <= 0;
			m1_valid    <= 0;
			m1_c        <= 0;
			m1_last     <= 1;
		end
		else if (enable) begin
			if (mu_c) begin
				m0_c     <= m1_c;
				m0_last  <= m1_last;
				m0_first <= m0_last;
				m1_valid <= 1;
				m1_c     <= m2_c;
				m1_last  <= m2_last;
			end
		end
	end
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			m2_c        <= s_nbr;
			m2_idx_evn  <= m_nbr;
			m2_last     <= (m_nbr == 1);
		end
		else if (enable) begin
			if (mu_c) begin
				if (m2_last) begin
					m2_c        <= s_nbr;
					m2_idx_evn  <= m_nbr;
					m2_last     <= (m_nbr == 1);
				end
				else begin
					m2_c        <= m2_c + s_nbr * 2;
					m2_idx_evn  <= m2_idx_evn - 1;
					m2_last     <= (m2_idx_evn == 2);
				end
			end
		end
	end

	always @ (posedge clk) begin
		if (resetn == 1'b0)
			su_c <= 0;
		else if (enable) begin
			case (smu)
			UP_B: begin
				if (m1_last)      su_c <= 1;
				else if (s1_last) su_c <= 0;
				else              su_c <= aux_v12r;
			end
			UP_S: begin
				if (m0_last)      su_c <= 1;
				else if (s1_last) su_c <= 0;
				else              su_c <= aux_v11r;
			end
			UP_M: begin
				if (m1_last)      su_c <= 1;
				else if (s0_last) su_c <= 0;
				else              su_c <= aux_v02r;
			end
			default: begin
				su_c <= 0;
			end
			endcase
		end
	end
	always @ (posedge clk) begin
		if (resetn == 1'b0)
			mu_c <= 1;
		else if (enable) begin
			case (smu)
			UP_B: begin
				if (s1_last)      mu_c <= 1;
				else if (m1_last) mu_c <= 0;
				else              mu_c <= aux_v11;
			end
			UP_S: begin
				if (s1_last)      mu_c <= 1;
				else if (m0_last) mu_c <= 0;
				else              mu_c <= aux_v10;
			end
			UP_M: begin
				if (s0_last)      mu_c <= 1;
				else if (m1_last) mu_c <= 0;
				else              mu_c <= aux_v01;
			end
			default: begin
				mu_c <= 0;
			end
			endcase
		end
	end

	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			s_v     <= 0;
			s_vlast <= 0;
			sm_last <= 0;
		end
		else if (enable) begin
			case (smu)
			UP_B: begin
				if ((s1_last || aux_v11) && m1_last)
					s_vlast <= 1;
				else
					s_vlast <= 0;

				if (s1_last || aux_v11)
					s_v <= 1;
				else
					s_v <= 0;

				sm_last <= (s1_last && m1_last);
			end
			UP_S: begin
				if ((s1_last || aux_v10) && m0_last)
					s_vlast <= 1;

				if ((s1_last || aux_v10) && ~s_vlast)
					s_v <= 1;
				else
					s_v <= 0;

				sm_last <= (s1_last && m0_last);
			end
			UP_M: begin
				if ((s0_last || aux_v01) && m1_last)
					s_vlast <= 1;

				if (s0_last || aux_v01)
					s_v <= m1_valid;
				else
					s_v <= 0;

				sm_last <= (s0_last && m1_last);
			end
			default: begin
				s_vlast <= 0;
				s_v     <= 0;
				sm_last <= 0;
			end
			endcase
		end
	end

`define NEXT_SBMP(_r) \
	_r[C_S_BMP-1:0] <= {_r[C_S_BMP-2:0], _r[C_S_BMP-1]}
`define NEXT_SBID(_r) \
	_r[C_S_BID-1:0] <= (_r[C_S_BID-1:0] + 1)
`define NEXT_SIDX(_r) \
	_r <= (s1_last ? 0 : (_r+1))

generate
if (C_S_BMP > 0) begin
	reg [C_S_BMP-1:0] s_bmp[2:0];
	assign s_bmp_bid_idx0[C_S_BMP+C_S_BID+C_S_IDX-1:C_S_BID+C_S_IDX] = s_bmp[0];
	assign s_bmp_bid_idx1[C_S_BMP+C_S_BID+C_S_IDX-1:C_S_BID+C_S_IDX] = s_bmp[1];
	assign s_bmp_bid_idx2[C_S_BMP+C_S_BID+C_S_IDX-1:C_S_BID+C_S_IDX] = s_bmp[2];
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			s_bmp[0] <= 0;
			s_bmp[1] <= 0;
			s_bmp[2] <= 1;
		end
		else if (enable) begin
			case (smu)
			UP_B: begin
				if ((s1_last && aux_v11r) || sm_last)
					s_bmp[0] <= s_bmp[2];
				else
					s_bmp[0] <= s_bmp[1];

				s_bmp[1] <= s_bmp[2];
				`NEXT_SBMP(s_bmp[2]);
			end
			UP_S: begin
				if (s1_last && aux_v10r)
					s_bmp[0] <= s_bmp[2];
				else
					s_bmp[0] <= s_bmp[1];

				s_bmp[1] <= s_bmp[2];
				`NEXT_SBMP(s_bmp[2]);
			end
			UP_M: begin
				if (s0_last && aux_v01r)
					s_bmp[0] <= s_bmp[1];
			end
			default: begin
				s_bmp[0] <= 0;
				s_bmp[1] <= 0;
				s_bmp[2] <= 1;
			end
			endcase
		end
	end
end
if (C_S_BID > 0) begin
	reg [C_S_BID-1:0] s_bid[2:0];
	assign s_bmp_bid_idx0[C_S_BID+C_S_IDX-1:C_S_IDX] = s_bid[0];
	assign s_bmp_bid_idx1[C_S_BID+C_S_IDX-1:C_S_IDX] = s_bid[1];
	assign s_bmp_bid_idx2[C_S_BID+C_S_IDX-1:C_S_IDX] = s_bid[2];
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			s_bid[0] <= 0;
			s_bid[1] <= 0;
			s_bid[2] <= 0;	/// 0 is the first
		end
		else if (enable) begin
			case (smu)
			UP_B: begin
				if ((s1_last && aux_v11r) || sm_last)
					s_bid[0] <= s_bid[2];
				else
					s_bid[0] <= s_bid[1];

				s_bid[1] <= s_bid[2];
				`NEXT_SBID(s_bid[2]);
			end
			UP_S: begin
				if (s1_last && aux_v10r)
					s_bid[0] <= s_bid[2];
				else
					s_bid[0] <= s_bid[1];

				s_bid[1] <= s_bid[2];
				`NEXT_SBID(s_bid[2]);
			end
			UP_M: begin
				if (s0_last && aux_v01r)
					s_bid[0] <= s_bid[1];
			end
			default: begin
				s_bid[0] <= 0;
				s_bid[1] <= 0;
				s_bid[2] <= 0;
			end
			endcase
		end
	end
end
if (C_S_IDX > 0) begin
	reg [C_S_WIDTH-1:0] s_idx[2:0];
	assign s_bmp_bid_idx0[C_S_IDX-1:0] = s_idx[0];
	assign s_bmp_bid_idx1[C_S_IDX-1:0] = s_idx[1];
	assign s_bmp_bid_idx2[C_S_IDX-1:0] = s_idx[2];
	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			s_idx[0] <= 0;
			s_idx[1] <= 0;
			s_idx[2] <= 0;
		end
		else if (enable) begin
			case (smu)
			UP_B: begin
				if ((s1_last && aux_v11r) || sm_last)
					s_idx[0] <= s_idx[2];
				else
					s_idx[0] <= s_idx[1];

				s_idx[1] <= s_idx[2];
				`NEXT_SIDX(s_idx[2]);
			end
			UP_S: begin
				if (s1_last && aux_v10r)
					s_idx[0] <= s_idx[2];
				else
					s_idx[0] <= s_idx[1];

				s_idx[1] <= s_idx[2];
				`NEXT_SIDX(s_idx[2]);
			end
			UP_M: begin
				if (s0_last && aux_v01r)
					s_idx[0] <= s_idx[1];
			end
			default: begin
				s_idx[0] <= 0;
				s_idx[1] <= 0;
				s_idx[2] <= 0;
			end
			endcase
		end
	end
end
endgenerate

	always @ (posedge clk) begin
		if (resetn == 1'b0)
			sm_valid <= 0;
		else if (enable) begin
			if (su_c && mu_c)
				sm_valid <= 1;
		end
	end
endmodule
