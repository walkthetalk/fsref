
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

`define WR_TRIG(_ridx, _name, _defv, _autoclr) \
	always @ (posedge o_clk) begin \
		if (resetn == 1'b0) \
			_name <= _defv; \
		else if (wr_sync_reg[_ridx]) \
			_name <= ~_defv; \
		else \
			_name <= (_autoclr ? _defv : ~_defv); \
	end

`define WR_SYNC_WIRE(_ridx, _bstart, _bwidth, _name, _defv, _autoclr) \
	reg[_bwidth - 1 : 0] r_``_name; \
	always @ (posedge o_clk) begin \
		if (resetn == 1'b0) \
			r_``_name <= _defv; \
		else if (wr_sync_reg[_ridx]) \
			r_``_name <= wr_data_d1[_bstart + _bwidth - 1 : _bstart]; \
		else \
			r_``_name <= (_autoclr ? 0 : r_``_name); \
	end \
	assign _name = r_``_name;

`define DRC_REG(_bwidth, _name) \
	reg [_bwidth-1 : 0] _name;

`define DRC_WIRE(_bwidth, _name) \
	wire [_bwidth-1 : 0] _name;

`define DRC_WL(_ridx, _bstart, _bwidth, _name, _defv, _autoclr, _dep) \
	always @ (posedge clk) begin \
		if (resetn == 1'b0) \
			_name <= _defv; \
		else if (s_wr_en[_ridx] && (_dep)) \
			_name <= wr_data[_bstart + _bwidth - 1 : _bstart]; \
		else \
			_name <= (_autoclr ? 0 : _name); \
	end

`define DRC_RL(_ridx, _bstart, _bwidth, _name) \
	if (_bwidth == 1) begin \
		assign slv_reg[_ridx][_bstart] = _name; \
	end \
	else begin \
		assign slv_reg[_ridx][_bstart + _bwidth - 1 : _bstart] = _name; \
	end

`define DRC_RW(_ridx, _bstart, _bwidth, _name, _defv, _autoclr, _dep) \
	`DRC_REG(_bwidth, _name) \
	`DRC_WL(_ridx, _bstart, _bwidth, _name, _defv, _autoclr, _dep) \
	`DRC_RL(_ridx, _bstart, _bwidth, _name)

`define DRC_SYNC_TO_OCLK(_dst, _src, _defv) \
	always @ (posedge o_clk) begin \
		if (o_resetn == 1'b0) \
			_dst <= _defv; \
		else \
			_dst <= _src; \
	end

`define DEFREG_FIXED(_ridx, _bstart, _bwidth, _name, _defv) \
	`DRC_WIRE(_bwidth, _name) \
	`DRC_RL(_ridx, _bstart, _bwidth, _name) \
	assign _name = _defv;

`define DEFREG_DIRECT_OUT(_ridx, _bstart, _bwidth, _name, _defv, _autoclr) \
	`DRC_RW(_ridx, _bstart, _bwidth, r_``_name, _defv, _autoclr, 1) \
	assign _name = r_``_name;

`define DEFREG_DIRECT_IN(_ridx, _bstart, _bwidth, _name) \
	`DRC_RL(_ridx, _bstart, _bwidth, _name)

`define DEFREG_EXTERNAL(_ridx, _bstart, _bwidth, _name, _defv) \
	`DRC_RW(_ridx, _bstart, _bwidth, r_sw_``_name, _defv, 0, 1) \
	`DRC_REG(_bwidth, r_``_name) \
	`DRC_SYNC_TO_OCLK(r_``_name, r_sw_``_name, _defv) \
	assign _name = r_``_name;

`define DEFREG_INTERNAL(_ridx, _bstart, _bwidth, _name, _defv, _autoclr, _dep) \
	`DRC_RW(_ridx, _bstart, _bwidth, _name, _defv, _autoclr, _dep) \

`define DEFREG_INT_EN(_ridx, _bitIdx, _name) \
	`DRC_RW(_ridx, _bitIdx, 1, int_en_``_name, 0, 0, 1)

/// write '1' for clear
`define DEFREG_INT_STATE(_ridx, _bitIdx, _name, _trigV) \
	`DRC_REG(1, _name``_d1) \
	`DRC_SYNC_TO_OCLK(_name``_d1, _name, 0) \
	`DRC_REG(1, int_state_``_name) \
	`DRC_RL(_ridx, _bitIdx, 1, int_state_``_name) \
	always @ (posedge o_clk) begin \
		if (o_resetn == 1'b0) \
			int_state_``_name <= 0; \
		else if (_name``_d1 != _name && _name == _trigV) \
			int_state_``_name <= 1; \
		else if (wr_sync_reg[_ridx] && wr_data_d1[_bitIdx]) \
			int_state_``_name <= 0; \
	end

`define COND(_en, _val) \
	if (_en) begin \
		_val \
	end

/// imagesize aux macro
`define DEFREG_STREAM_DIRECT(_ridx, _bstart, _bwidth, _name, _defv) \
	`DRC_RW(_ridx, _bstart, _bwidth, r_sw_``_name, _defv, 0, 1) \
	`DRC_REG(_bwidth, r_``_name) \
	always @ (posedge o_clk) begin \
		if (o_resetn == 1'b0) \
			r_``_name <= _defv; \
		else if (update_display_cfg) \
			r_``_name <= r_sw_``_name; \
	end \
	assign _name = r_``_name;

`define DEFREG_STREAM_INDIRECT(_ridx, _bstart, _bwidth, _name, _dep, _defv) \
	`DRC_REG(_bwidth, r_``_name``_indirect) \
	`DRC_WL(_ridx, _bstart, _bwidth, r_``_name``_indirect, _defv, 0, _dep) \
	`DRC_REG(_bwidth, r_``_name) \
	always @ (posedge o_clk) begin \
		if (o_resetn == 1'b0) \
			r_``_name <= _defv; \
		else if (update_display_cfg) \
			r_``_name <= r_``_name``_indirect; \
	end \
	assign _name = r_``_name;
