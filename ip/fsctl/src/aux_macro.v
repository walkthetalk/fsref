
/// aux macro
`define WR_EN_POSEDGE(_ridx, _name) \
	reg s_wr_en_d1_``_name; \
	always @ (posedge o_clk) begin \
		if (o_resetn == 1'b0) \
			s_wr_en_d1_``_name <= 0; \
		else \
			s_wr_en_d1_``_name <= s_wr_en[_ridx]; \
	end \
	wire _name; \
	assign _name = (s_wr_en[_ridx] & s_wr_en_d1_``_name);

`define DEFREG(_ridx, _bstart, _bwidth, _name, _defv, _autoclr) \
	reg [_bwidth-1 : 0] r_``_name; \
	assign slv_reg[_ridx][_bstart + _bwidth - 1 : _bstart] = r_``_name; \
	always @ (posedge clk) begin \
		if (resetn == 1'b0) \
			r_``_name <= _defv; \
		else if (s_wr_en[_ridx]) \
			r_``_name <= wr_data[_bstart + _bwidth - 1 : _bstart]; \
		else \
			r_``_name <= (_autoclr ? 0 : r_``_name); \
	end

`define DEFREG_FIXED(_ridx, _bstart, _bwidth, _name, _defv) \
	wire [_bwidth-1 : 0] r_``_name; \
	assign slv_reg[_ridx][_bstart + _bwidth - 1 : _bstart] = r_``_name; \
	assign r_``_name = _defv;

`define DEFREG_DIRECT_OUT(_ridx, _bstart, _bwidth, _name, _defv, _autoclr) \
        `DEFREG(_ridx, _bstart, _bwidth, _name, _defv, _autoclr) \
	assign _name = r_``_name;

`define DEFREG_DIRECT_IN(_ridx, _bstart, _bwidth, _name) \
        assign slv_reg[_ridx][_bstart + _bwidth - 1 : _bstart] = _name;

`define DEFREG_EXTERNAL(_ridx, _bstart, _bwidth, _name, _defv) \
	`DEFREG(_ridx, _bstart, _bwidth, _name, _defv, 0) \
	always @ (posedge o_clk) begin \
		if (o_resetn == 1'b0) \
			_name <= _defv; \
		else \
			_name <= r_``_name; \
	end

`define DEFREG_INTERNAL(_ridx, _bstart, _bwidth, _name, _defv) \
	`DEFREG(_ridx, _bstart, _bwidth, _name, _defv, 0) \
	wire _name; \
	assign _name = r_``_name; \

`define COND(_en, _val) \
        generate \
        if (_en) begin \
                _val \
        end \
        endgenerate

/// imagesize aux macro
`define DEFREG_DISP(_ridx, _bstart, _bwidth, _name, _defv) \
	`DEFREG(_ridx, _bstart, _bwidth, _name, _defv, 0) \
	always @ (posedge o_clk) begin \
		if (o_resetn == 1'b0) \
			_name <= _defv; \
		else if (update_display_cfg) \
			_name <= r_``_name; \
		else \
			_name <= _name; \
	end

`define DEFREG_IMGSIZE(_ridx, _name1, _defv1, _name0, _defv0) \
	`DEFREG_DISP(_ridx, 16, C_IMG_WBITS, _name1, _defv1) \
	`DEFREG_DISP(_ridx,  0, C_IMG_HBITS, _name0, _defv0)
