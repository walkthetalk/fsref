
`timescale 1 ns / 1 ps

module fsctl #
(
	parameter integer C_DATA_WIDTH	= 32,
	parameter integer C_ADDR_WIDTH	= 8,

	parameter integer C_IMG_WBITS = 12,
	parameter integer C_IMG_HBITS = 12,

	parameter integer C_IMG_WDEF = 320,
	parameter integer C_IMG_HDEF = 240
)
(
	input clk,
	input resetn,

	/// read/write interface
	input [C_ADDR_WIDTH-1:0] rd_addr,
	output reg [C_DATA_WIDTH-1:0] rd_data,

	input wr_en,
	input [C_ADDR_WIDTH-1:0] wr_addr,
	input [C_DATA_WIDTH-1:0] wr_data,

	//// controller
	output wire soft_resetn,

	output wire [C_IMG_WBITS-1:0] out_width,
	output wire [C_IMG_HBITS-1:0] out_height,

	output wire [C_IMG_WBITS-1:0] s0_win_left,
	output wire [C_IMG_WBITS-1:0] s0_win_width,
	output wire [C_IMG_HBITS-1:0] s0_win_top,
	output wire [C_IMG_HBITS-1:0] s0_win_height,

	output wire [C_IMG_WBITS-1:0] s0_scale_src_width,
	output wire [C_IMG_HBITS-1:0] s0_scale_src_height,
	output wire [C_IMG_WBITS-1:0] s0_scale_dst_width,
	output wire [C_IMG_HBITS-1:0] s0_scale_dst_height,

	output wire [C_IMG_WBITS-1:0] s0_dst_left,
	output wire [C_IMG_WBITS-1:0] s0_dst_width,
	output wire [C_IMG_HBITS-1:0] s0_dst_top,
	output wire [C_IMG_HBITS-1:0] s0_dst_height,

	output wire [C_IMG_WBITS-1:0] s1_win_left,
	output wire [C_IMG_WBITS-1:0] s1_win_width,
	output wire [C_IMG_HBITS-1:0] s1_win_top,
	output wire [C_IMG_HBITS-1:0] s1_win_height,

	output wire [C_IMG_WBITS-1:0] s1_scale_src_width,
	output wire [C_IMG_HBITS-1:0] s1_scale_src_height,
	output wire [C_IMG_WBITS-1:0] s1_scale_dst_width,
	output wire [C_IMG_HBITS-1:0] s1_scale_dst_height,

	output wire [C_IMG_WBITS-1:0] s1_dst_left,
	output wire [C_IMG_WBITS-1:0] s1_dst_width,
	output wire [C_IMG_HBITS-1:0] s1_dst_top,
	output wire [C_IMG_HBITS-1:0] s1_dst_height,

	output wire [C_IMG_WBITS-1:0] s2_win_left,
	output wire [C_IMG_WBITS-1:0] s2_win_width,
	output wire [C_IMG_HBITS-1:0] s2_win_top,
	output wire [C_IMG_HBITS-1:0] s2_win_height,

	output wire [C_IMG_WBITS-1:0] s2_scale_src_width,
	output wire [C_IMG_HBITS-1:0] s2_scale_src_height,
	output wire [C_IMG_WBITS-1:0] s2_scale_dst_width,
	output wire [C_IMG_HBITS-1:0] s2_scale_dst_height,

	output wire [C_IMG_WBITS-1:0] s2_dst_left,
	output wire [C_IMG_WBITS-1:0] s2_dst_width,
	output wire [C_IMG_HBITS-1:0] s2_dst_top,
	output wire [C_IMG_HBITS-1:0] s2_dst_height
);

	// Example-specific design signals
	// local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
	// ADDR_LSB is used for addressing 32/64 bit registers/memories
	// ADDR_LSB = 2 for 32 bits (n downto 2)
	// ADDR_LSB = 3 for 64 bits (n downto 3)
	localparam integer ADDR_LSB = (C_DATA_WIDTH/32) + 1;

	wire [C_ADDR_WIDTH-1-ADDR_LSB:0] rd_index;
	assign rd_index = rd_addr[C_ADDR_WIDTH-1:ADDR_LSB];
	wire [C_ADDR_WIDTH-1-ADDR_LSB:0] wr_index;
	assign wr_index = wr_addr[C_ADDR_WIDTH-1:ADDR_LSB];

	//----------------------------------------------
	//-- Signals for user logic register space example
	//------------------------------------------------
	//-- Number of Slave Registers 64
	reg [C_DATA_WIDTH-1:0]	slv_reg0;
	assign soft_resetn = slv_reg0[0];

	reg [C_DATA_WIDTH-1:0]	slv_reg1;
	reg [C_DATA_WIDTH-1:0]	slv_reg2;
	reg [C_DATA_WIDTH-1:0]	slv_reg3;
	reg [C_DATA_WIDTH-1:0]	slv_reg4;
	reg [C_DATA_WIDTH-1:0]	slv_reg5;
	reg [C_DATA_WIDTH-1:0]	slv_reg6;
	reg [C_DATA_WIDTH-1:0]	slv_reg7;
	reg [C_DATA_WIDTH-1:0]	slv_reg8;
	reg [C_DATA_WIDTH-1:0]	slv_reg9;
	reg [C_DATA_WIDTH-1:0]	slv_reg10;
	reg [C_DATA_WIDTH-1:0]	slv_reg11;
	reg [C_DATA_WIDTH-1:0]	slv_reg12;
	reg [C_DATA_WIDTH-1:0]	slv_reg13;
	reg [C_DATA_WIDTH-1:0]	slv_reg14;
	reg [C_DATA_WIDTH-1:0]	slv_reg15;
	reg [C_DATA_WIDTH-1:0]	slv_reg16;
	reg [C_DATA_WIDTH-1:0]	slv_reg17;
	reg [C_DATA_WIDTH-1:0]	slv_reg18;
	reg [C_DATA_WIDTH-1:0]	slv_reg19;
	reg [C_DATA_WIDTH-1:0]	slv_reg20;
	reg [C_DATA_WIDTH-1:0]	slv_reg21;
	reg [C_DATA_WIDTH-1:0]	slv_reg22;
	reg [C_DATA_WIDTH-1:0]	slv_reg23;
	reg [C_DATA_WIDTH-1:0]	slv_reg24;
	reg [C_DATA_WIDTH-1:0]	slv_reg25;
	reg [C_DATA_WIDTH-1:0]	slv_reg26;
	reg [C_DATA_WIDTH-1:0]	slv_reg27;
	reg [C_DATA_WIDTH-1:0]	slv_reg28;
	reg [C_DATA_WIDTH-1:0]	slv_reg29;
	reg [C_DATA_WIDTH-1:0]	slv_reg30;
	reg [C_DATA_WIDTH-1:0]	slv_reg31;
	reg [C_DATA_WIDTH-1:0]	slv_reg32;
	reg [C_DATA_WIDTH-1:0]	slv_reg33;
	reg [C_DATA_WIDTH-1:0]	slv_reg34;
	reg [C_DATA_WIDTH-1:0]	slv_reg35;
	reg [C_DATA_WIDTH-1:0]	slv_reg36;
	reg [C_DATA_WIDTH-1:0]	slv_reg37;
	reg [C_DATA_WIDTH-1:0]	slv_reg38;
	reg [C_DATA_WIDTH-1:0]	slv_reg39;
	reg [C_DATA_WIDTH-1:0]	slv_reg40;
	reg [C_DATA_WIDTH-1:0]	slv_reg41;
	reg [C_DATA_WIDTH-1:0]	slv_reg42;
	reg [C_DATA_WIDTH-1:0]	slv_reg43;
	reg [C_DATA_WIDTH-1:0]	slv_reg44;
	reg [C_DATA_WIDTH-1:0]	slv_reg45;
	reg [C_DATA_WIDTH-1:0]	slv_reg46;
	reg [C_DATA_WIDTH-1:0]	slv_reg47;
	reg [C_DATA_WIDTH-1:0]	slv_reg48;
	reg [C_DATA_WIDTH-1:0]	slv_reg49;
	reg [C_DATA_WIDTH-1:0]	slv_reg50;
	reg [C_DATA_WIDTH-1:0]	slv_reg51;
	reg [C_DATA_WIDTH-1:0]	slv_reg52;
	reg [C_DATA_WIDTH-1:0]	slv_reg53;
	reg [C_DATA_WIDTH-1:0]	slv_reg54;
	reg [C_DATA_WIDTH-1:0]	slv_reg55;
	reg [C_DATA_WIDTH-1:0]	slv_reg56;
	reg [C_DATA_WIDTH-1:0]	slv_reg57;
	reg [C_DATA_WIDTH-1:0]	slv_reg58;
	reg [C_DATA_WIDTH-1:0]	slv_reg59;
	reg [C_DATA_WIDTH-1:0]	slv_reg60;
	reg [C_DATA_WIDTH-1:0]	slv_reg61;
	reg [C_DATA_WIDTH-1:0]	slv_reg62;
	reg [C_DATA_WIDTH-1:0]	slv_reg63;

	/// read logic
	always @(*) begin
		// Address decoding for reading registers
		case (rd_index)
		6'h00   : rd_data <= slv_reg0;
		6'h01   : rd_data <= slv_reg1;
		6'h02   : rd_data <= slv_reg2;
		6'h03   : rd_data <= slv_reg3;
		6'h04   : rd_data <= slv_reg4;
		6'h05   : rd_data <= slv_reg5;
		6'h06   : rd_data <= slv_reg6;
		6'h07   : rd_data <= slv_reg7;
		6'h08   : rd_data <= slv_reg8;
		6'h09   : rd_data <= slv_reg9;
		6'h0A   : rd_data <= slv_reg10;
		6'h0B   : rd_data <= slv_reg11;
		6'h0C   : rd_data <= slv_reg12;
		6'h0D   : rd_data <= slv_reg13;
		6'h0E   : rd_data <= slv_reg14;
		6'h0F   : rd_data <= slv_reg15;
		6'h10   : rd_data <= slv_reg16;
		6'h11   : rd_data <= slv_reg17;
		6'h12   : rd_data <= slv_reg18;
		6'h13   : rd_data <= slv_reg19;
		6'h14   : rd_data <= slv_reg20;
		6'h15   : rd_data <= slv_reg21;
		6'h16   : rd_data <= slv_reg22;
		6'h17   : rd_data <= slv_reg23;
		6'h18   : rd_data <= slv_reg24;
		6'h19   : rd_data <= slv_reg25;
		6'h1A   : rd_data <= slv_reg26;
		6'h1B   : rd_data <= slv_reg27;
		6'h1C   : rd_data <= slv_reg28;
		6'h1D   : rd_data <= slv_reg29;
		6'h1E   : rd_data <= slv_reg30;
		6'h1F   : rd_data <= slv_reg31;
		6'h20   : rd_data <= slv_reg32;
		6'h21   : rd_data <= slv_reg33;
		6'h22   : rd_data <= slv_reg34;
		6'h23   : rd_data <= slv_reg35;
		6'h24   : rd_data <= slv_reg36;
		6'h25   : rd_data <= slv_reg37;
		6'h26   : rd_data <= slv_reg38;
		6'h27   : rd_data <= slv_reg39;
		6'h28   : rd_data <= slv_reg40;
		6'h29   : rd_data <= slv_reg41;
		6'h2A   : rd_data <= slv_reg42;
		6'h2B   : rd_data <= slv_reg43;
		6'h2C   : rd_data <= slv_reg44;
		6'h2D   : rd_data <= slv_reg45;
		6'h2E   : rd_data <= slv_reg46;
		6'h2F   : rd_data <= slv_reg47;
		6'h30   : rd_data <= slv_reg48;
		6'h31   : rd_data <= slv_reg49;
		6'h32   : rd_data <= slv_reg50;
		6'h33   : rd_data <= slv_reg51;
		6'h34   : rd_data <= slv_reg52;
		6'h35   : rd_data <= slv_reg53;
		6'h36   : rd_data <= slv_reg54;
		6'h37   : rd_data <= slv_reg55;
		6'h38   : rd_data <= slv_reg56;
		6'h39   : rd_data <= slv_reg57;
		6'h3A   : rd_data <= slv_reg58;
		6'h3B   : rd_data <= slv_reg59;
		6'h3C   : rd_data <= slv_reg60;
		6'h3D   : rd_data <= slv_reg61;
		6'h3E   : rd_data <= slv_reg62;
		6'h3F   : rd_data <= slv_reg63;
		default : rd_data <= 0;
		endcase
	end

	/// write logic
	always @(posedge clk) begin
		if (resetn == 1'b0) begin
			slv_reg0 <= 0;
			slv_reg1 <= 0;
			slv_reg2 <= 0;
			slv_reg3 <= 0;
			slv_reg4 <= 0;
			slv_reg5 <= 0;
			slv_reg6 <= 0;
			slv_reg7 <= 0;
			slv_reg8 <= 0;
			slv_reg9 <= 0;
			slv_reg10 <= 0;
			slv_reg11 <= 0;
			slv_reg12 <= 0;
			slv_reg13 <= 0;
			slv_reg14 <= 0;
			slv_reg15 <= 0;
			slv_reg16 <= 0;
			slv_reg17 <= 0;
			slv_reg18 <= 0;
			slv_reg19 <= 0;
			slv_reg20 <= 0;
			slv_reg21 <= 0;
			slv_reg22 <= 0;
			slv_reg23 <= 0;
			slv_reg24 <= 0;
			slv_reg25 <= 0;
			slv_reg26 <= 0;
			slv_reg27 <= 0;
			slv_reg28 <= 0;
			slv_reg29 <= 0;
			slv_reg30 <= 0;
			slv_reg31 <= 0;
			slv_reg32 <= 0;
			slv_reg33 <= 0;
			slv_reg34 <= 0;
			slv_reg35 <= 0;
			slv_reg36 <= 0;
			slv_reg37 <= 0;
			slv_reg38 <= 0;
			slv_reg39 <= 0;
			slv_reg40 <= 0;
			slv_reg41 <= 0;
			slv_reg42 <= 0;
			slv_reg43 <= 0;
			slv_reg44 <= 0;
			slv_reg45 <= 0;
			slv_reg46 <= 0;
			slv_reg47 <= 0;
			slv_reg48 <= 0;
			slv_reg49 <= 0;
			slv_reg50 <= 0;
			slv_reg51 <= 0;
			slv_reg52 <= 0;
			slv_reg53 <= 0;
			slv_reg54 <= 0;
			slv_reg55 <= 0;
			slv_reg56 <= 0;
			slv_reg57 <= 0;
			slv_reg58 <= 0;
			slv_reg59 <= 0;
			slv_reg60 <= 0;
			slv_reg61 <= 0;
			slv_reg62 <= 0;
			slv_reg63 <= 0;
		end
		else begin
			if (wr_en) begin
			case (wr_index)
				6'h00: slv_reg0 <= wr_data;
				6'h01: slv_reg1 <= wr_data;
				6'h02: slv_reg2 <= wr_data;
				6'h03: slv_reg3 <= wr_data;
				6'h04: slv_reg4 <= wr_data;
				6'h05: slv_reg5 <= wr_data;
				6'h06: slv_reg6 <= wr_data;
				6'h07: slv_reg7 <= wr_data;
				6'h08: slv_reg8 <= wr_data;
				6'h09: slv_reg9 <= wr_data;
				6'h0A: slv_reg10 <= wr_data;
				6'h0B: slv_reg11 <= wr_data;
				6'h0C: slv_reg12 <= wr_data;
				6'h0D: slv_reg13 <= wr_data;
				6'h0E: slv_reg14 <= wr_data;
				6'h0F: slv_reg15 <= wr_data;
				6'h10: slv_reg16 <= wr_data;
				6'h11: slv_reg17 <= wr_data;
				6'h12: slv_reg18 <= wr_data;
				6'h13: slv_reg19 <= wr_data;
				6'h14: slv_reg20 <= wr_data;
				6'h15: slv_reg21 <= wr_data;
				6'h16: slv_reg22 <= wr_data;
				6'h17: slv_reg23 <= wr_data;
				6'h18: slv_reg24 <= wr_data;
				6'h19: slv_reg25 <= wr_data;
				6'h1A: slv_reg26 <= wr_data;
				6'h1B: slv_reg27 <= wr_data;
				6'h1C: slv_reg28 <= wr_data;
				6'h1D: slv_reg29 <= wr_data;
				6'h1E: slv_reg30 <= wr_data;
				6'h1F: slv_reg31 <= wr_data;
				6'h20: slv_reg32 <= wr_data;
				6'h21: slv_reg33 <= wr_data;
				6'h22: slv_reg34 <= wr_data;
				6'h23: slv_reg35 <= wr_data;
				6'h24: slv_reg36 <= wr_data;
				6'h25: slv_reg37 <= wr_data;
				6'h26: slv_reg38 <= wr_data;
				6'h27: slv_reg39 <= wr_data;
				6'h28: slv_reg40 <= wr_data;
				6'h29: slv_reg41 <= wr_data;
				6'h2A: slv_reg42 <= wr_data;
				6'h2B: slv_reg43 <= wr_data;
				6'h2C: slv_reg44 <= wr_data;
				6'h2D: slv_reg45 <= wr_data;
				6'h2E: slv_reg46 <= wr_data;
				6'h2F: slv_reg47 <= wr_data;
				6'h30: slv_reg48 <= wr_data;
				6'h31: slv_reg49 <= wr_data;
				6'h32: slv_reg50 <= wr_data;
				6'h33: slv_reg51 <= wr_data;
				6'h34: slv_reg52 <= wr_data;
				6'h35: slv_reg53 <= wr_data;
				6'h36: slv_reg54 <= wr_data;
				6'h37: slv_reg55 <= wr_data;
				6'h38: slv_reg56 <= wr_data;
				6'h39: slv_reg57 <= wr_data;
				6'h3A: slv_reg58 <= wr_data;
				6'h3B: slv_reg59 <= wr_data;
				6'h3C: slv_reg60 <= wr_data;
				6'h3D: slv_reg61 <= wr_data;
				6'h3E: slv_reg62 <= wr_data;
				6'h3F: slv_reg63 <= wr_data;
				default : begin
					slv_reg0 <= slv_reg0;
					slv_reg1 <= slv_reg1;
					slv_reg2 <= slv_reg2;
					slv_reg3 <= slv_reg3;
					slv_reg4 <= slv_reg4;
					slv_reg5 <= slv_reg5;
					slv_reg6 <= slv_reg6;
					slv_reg7 <= slv_reg7;
					slv_reg8 <= slv_reg8;
					slv_reg9 <= slv_reg9;
					slv_reg10 <= slv_reg10;
					slv_reg11 <= slv_reg11;
					slv_reg12 <= slv_reg12;
					slv_reg13 <= slv_reg13;
					slv_reg14 <= slv_reg14;
					slv_reg15 <= slv_reg15;
					slv_reg16 <= slv_reg16;
					slv_reg17 <= slv_reg17;
					slv_reg18 <= slv_reg18;
					slv_reg19 <= slv_reg19;
					slv_reg20 <= slv_reg20;
					slv_reg21 <= slv_reg21;
					slv_reg22 <= slv_reg22;
					slv_reg23 <= slv_reg23;
					slv_reg24 <= slv_reg24;
					slv_reg25 <= slv_reg25;
					slv_reg26 <= slv_reg26;
					slv_reg27 <= slv_reg27;
					slv_reg28 <= slv_reg28;
					slv_reg29 <= slv_reg29;
					slv_reg30 <= slv_reg30;
					slv_reg31 <= slv_reg31;
					slv_reg32 <= slv_reg32;
					slv_reg33 <= slv_reg33;
					slv_reg34 <= slv_reg34;
					slv_reg35 <= slv_reg35;
					slv_reg36 <= slv_reg36;
					slv_reg37 <= slv_reg37;
					slv_reg38 <= slv_reg38;
					slv_reg39 <= slv_reg39;
					slv_reg40 <= slv_reg40;
					slv_reg41 <= slv_reg41;
					slv_reg42 <= slv_reg42;
					slv_reg43 <= slv_reg43;
					slv_reg44 <= slv_reg44;
					slv_reg45 <= slv_reg45;
					slv_reg46 <= slv_reg46;
					slv_reg47 <= slv_reg47;
					slv_reg48 <= slv_reg48;
					slv_reg49 <= slv_reg49;
					slv_reg50 <= slv_reg50;
					slv_reg51 <= slv_reg51;
					slv_reg52 <= slv_reg52;
					slv_reg53 <= slv_reg53;
					slv_reg54 <= slv_reg54;
					slv_reg55 <= slv_reg55;
					slv_reg56 <= slv_reg56;
					slv_reg57 <= slv_reg57;
					slv_reg58 <= slv_reg58;
					slv_reg59 <= slv_reg59;
					slv_reg60 <= slv_reg60;
					slv_reg61 <= slv_reg61;
					slv_reg62 <= slv_reg62;
					slv_reg63 <= slv_reg63;
				end
			endcase
			end
		end
	end
endmodule
