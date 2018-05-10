`timescale 1ns / 1ps
module axis_relay #
(
	parameter integer C_PIXEL_WIDTH = 8,
	parameter integer C_PASSTHROUGH = 0,
	parameter integer C_TEST = 0
) (
	input  wire clk,
	input  wire resetn,


	input  wire                     s_axis_tvalid,
	input  wire [C_PIXEL_WIDTH-1:0] s_axis_tdata ,
	input  wire                     s_axis_tuser ,
	input  wire                     s_axis_tlast ,
	output wire                     s_axis_tready,

	output wire                     m_axis_tvalid,
	output wire [C_PIXEL_WIDTH-1:0] m_axis_tdata ,
	output wire                     m_axis_tuser ,
	output wire                     m_axis_tlast ,
	input  wire                     m_axis_tready
);

generate
if (C_PASSTHROUGH) begin
	assign m_axis_tvalid = s_axis_tvalid;
	assign m_axis_tdata  = s_axis_tdata ;
	assign m_axis_tlast  = s_axis_tlast ;
	assign m_axis_tuser  = s_axis_tuser ;
	assign s_axis_tready = m_axis_tready;
end
else begin
	reg                     relay_tvalid[1:0];
	reg [C_PIXEL_WIDTH-1:0] relay_tdata[1:0];
	reg                     relay_tuser[1:0];
	reg                     relay_tlast[1:0];

	wire snext;
	assign snext = s_axis_tvalid && s_axis_tready;
	assign m_axis_tvalid = relay_tvalid[0];
	assign m_axis_tdata = relay_tdata[0];
	assign m_axis_tlast = relay_tlast[0];
	assign m_axis_tuser = relay_tuser[0];

	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			relay_tvalid[1] <= 0;
			relay_tdata[1] <= 0;
			relay_tuser[1] <= 0;
			relay_tlast[1] <= 0;
		end
		else if (snext) begin
			if (relay_tvalid[1]) begin
				relay_tvalid[1] <= 1;
				relay_tdata[1] <= s_axis_tdata;
				relay_tuser[1] <= s_axis_tuser;
				relay_tlast[1] <= s_axis_tlast;
			end
			else if (relay_tvalid[0] && ~m_axis_tready) begin
				relay_tvalid[1] <= 1;
				relay_tdata[1] <= s_axis_tdata;
				relay_tuser[1] <= s_axis_tuser;
				relay_tlast[1] <= s_axis_tlast;
			end
			else
				relay_tvalid[1] <= 0;
		end
		else if (~relay_tvalid[0] || m_axis_tready) begin
			relay_tvalid[1] <= 0;
		end
	end

	always @ (posedge clk) begin
		if (resetn == 1'b0) begin
			relay_tvalid[0] <= 0;
			relay_tdata[0] <= 0;
			relay_tuser[0] <= 0;
			relay_tlast[0] <= 0;
		end
		else if (~relay_tvalid[0] || m_axis_tready) begin
			if (relay_tvalid[1]) begin
				relay_tvalid[0] <= 1;
				relay_tdata[0] <= relay_tdata[1];
				relay_tuser[0] <= relay_tuser[1];
				relay_tlast[0] <= relay_tlast[1];
			end
			else if (snext) begin
				relay_tvalid[0] <= 1;
				relay_tdata[0] <= s_axis_tdata;
				relay_tuser[0] <= s_axis_tuser;
				relay_tlast[0] <= s_axis_tlast;
			end
			else begin
				relay_tvalid[0] <= 0;
			end
		end
	end

	reg r_s_axis_tready;
	assign s_axis_tready = r_s_axis_tready;
	always @ (posedge clk) begin
		if (resetn == 1'b0)
			r_s_axis_tready <= 0;
		else begin
			case ({relay_tvalid[1], relay_tvalid[0]})
			2'b00, 2'b10:
				r_s_axis_tready <= 1;
			2'b01:
				r_s_axis_tready <= (~r_s_axis_tready || m_axis_tready);
			2'b11:
				r_s_axis_tready <= (~r_s_axis_tready && m_axis_tready);
			endcase
		end
	end
end
endgenerate
endmodule
