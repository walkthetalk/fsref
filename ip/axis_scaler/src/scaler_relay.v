module scaler_relay # (
	parameter integer C_DATA_WIDTH = 12,
	parameter integer C_PASSTHROUGH   = 0
) (
	input wire clk,
	input wire resetn,

	input  wire                    s_valid,
	input  wire [C_DATA_WIDTH-1:0] s_data ,
	output wire                    s_ready,

	output wire                    m_valid,
	output wire [C_DATA_WIDTH-1:0] m_data ,
	input  wire                    m_ready
);
generate
if (C_PASSTHROUGH) begin
	assign m_valid = s_valid;
	assign m_data  = s_data;
	assign s_ready = m_ready;
end
else begin
	reg                    relay_valid[1:0];
	reg [C_DATA_WIDTH-1:0] relay_data [1:0];

	wire snext;
	assign snext = s_valid && s_ready;
	assign m_valid = relay_valid[0];
	assign m_data  = relay_data[0];
	wire mneed;
	assign mneed = ~relay_valid[0] || m_ready;

	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			relay_valid[1] <= 0;
		end
		else if (snext) begin
			if (relay_valid[1] || ~mneed) begin
				relay_valid[1] <= 1;
				relay_data[1]  <= s_data;
			end
		end
		else if (mneed) begin
			relay_valid[1] <= 0;
		end
	end

	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			relay_valid[0] <= 0;
			relay_data [0] <= 0;
		end
		else if (mneed) begin
			if (relay_valid[1]) begin
				relay_valid[0] <= 1;
				relay_data [0] <= relay_data[1];
			end
			else if (snext) begin
				relay_valid[0] <= 1;
				relay_data [0] <= s_data;
			end
			else begin
				relay_valid[0] <= 0;
			end
		end
	end

	reg r_sready;
	assign s_ready = r_sready;
	always @ (posedge clk) begin
		if (resetn == 1'b0)
			r_sready <= 0;
		else begin
			case ({relay_valid[1], relay_valid[0]})
			2'b00, 2'b10:
				r_sready <= 1;
			2'b01:
				r_sready <= (~r_sready || m_ready);
			2'b11:
				r_sready <= (~r_sready && m_ready);
			endcase
		end
	end
end
endgenerate

endmodule
