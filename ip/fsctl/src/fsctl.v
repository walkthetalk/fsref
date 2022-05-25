module fsctl # (
	/**********************************************************************
	 *                          section: params                           *
	 **********************************************************************/
	parameter integer C_CORE_VERSION      = 32'hFF00FF00,
	parameter integer C_TS_WIDTH          = 64          ,
	parameter integer C_DATA_WIDTH        = 32          ,
	parameter integer C_REG_IDX_WIDTH     = 8           ,
	parameter integer C_IMG_PBITS         = 8           ,
	parameter integer C_IMG_WBITS         = 12          ,
	parameter integer C_IMG_HBITS         = 12          ,
	parameter integer C_IMG_WDEF          = 320         ,
	parameter integer C_IMG_HDEF          = 240         ,
	parameter integer C_STREAM_NBR        = 2           ,
	parameter integer C_BUF_ADDR_WIDTH    = 32          ,
	parameter integer C_BUF_IDX_WIDTH     = 2           ,
	parameter integer C_ST_ADDR           = 32'h3D000000,
	parameter integer C_S0_ADDR           = 32'h3E000000,
	parameter integer C_S0_SIZE           = 32'h00100000,
	parameter integer C_S1_ADDR           = 32'h3E400000,
	parameter integer C_S1_SIZE           = 32'h00100000,
	parameter integer C_S2_ADDR           = 32'h3E800000,
	parameter integer C_S2_SIZE           = 32'h00100000,
	parameter integer C_S3_ADDR           = 32'h3EB00000,
	parameter integer C_S3_SIZE           = 32'h00100000,
	parameter integer C_S4_ADDR           = 32'h3F000000,
	parameter integer C_S4_SIZE           = 32'h00100000,
	parameter integer C_S5_ADDR           = 32'h3F400000,
	parameter integer C_S5_SIZE           = 32'h00100000,
	parameter integer C_S6_ADDR           = 32'h3F800000,
	parameter integer C_S6_SIZE           = 32'h00100000,
	parameter integer C_S7_ADDR           = 32'h3FC00000,
	parameter integer C_S7_SIZE           = 32'h00100000,
	/// block ram number, must be <= 8
	parameter integer C_BR_INITOR_NBR     = 2           ,
	parameter integer C_BR_ADDR_WIDTH     = 9           ,
	/// motor number, must be <= 8
	parameter integer C_MOTOR_NBR         = 4           ,
	parameter integer C_ZPD_SEQ           = 8'b00000011 ,
	parameter integer C_SPEED_DATA_WIDTH  = 16          ,
	parameter integer C_STEP_NUMBER_WIDTH = 16          ,
	parameter integer C_MICROSTEP_WIDTH   = 3           ,
	parameter integer C_PWM_NBR           = 8           ,
	parameter integer C_PWM_CNT_WIDTH     = 16          ,
	parameter integer C_EXT_INT_WIDTH     = 8           ,
	parameter integer C_HEAT_VALUE_WIDTH  = 12          ,
	parameter integer C_HEAT_TIME_WIDTH   = 32          ,
	parameter integer C_TEST              = 0
) (
	/**********************************************************************
	 *                           section: ports                           *
	 **********************************************************************/
	input  wire                        clk          ,
	input  wire                        resetn       ,
	input  wire                        rd_en        ,
	input  wire [C_REG_IDX_WIDTH-1 :0] rd_addr      ,
	output wire [C_DATA_WIDTH-1    :0] rd_data      ,
	input  wire                        wr_en        ,
	input  wire [C_REG_IDX_WIDTH-1 :0] wr_addr      ,
	input  wire [C_DATA_WIDTH-1    :0] wr_data      ,
	input  wire                        o_clk        ,
	input  wire                        o_resetn     ,
	input  wire                        fsync        ,
	output wire                        o_fsync      ,
	output wire                        intr         ,
	output wire                        out_ce       ,
	output wire [C_IMG_WBITS-1     :0] out_width    ,
	output wire [C_IMG_HBITS-1     :0] out_height   ,
	output wire                        st_out_resetn,
	output wire [C_BUF_ADDR_WIDTH-1:0] st_addr      ,
	output wire [C_IMG_WBITS-1     :0] st_width     ,
	output wire [C_IMG_HBITS-1     :0] st_height    ,
	/// stream interface ports
	/// s0
	output wire                        s0_in_resetn       ,
	output wire                        s0_out_resetn      ,
	output wire                        s0_fsa_disp_resetn ,
	output wire [C_STREAM_NBR-1    :0] s0_dst_bmp         ,
	output wire [C_IMG_WBITS-1     :0] s0_width           ,
	output wire [C_IMG_HBITS-1     :0] s0_height          ,
	output wire [C_BUF_ADDR_WIDTH-1:0] s0_buf0_addr       ,
	output wire [C_BUF_ADDR_WIDTH-1:0] s0_buf1_addr       ,
	output wire [C_BUF_ADDR_WIDTH-1:0] s0_buf2_addr       ,
	output wire [C_BUF_ADDR_WIDTH-1:0] s0_buf3_addr       ,
	output wire [C_IMG_WBITS-1     :0] s0_win_left        ,
	output wire [C_IMG_WBITS-1     :0] s0_win_width       ,
	output wire [C_IMG_HBITS-1     :0] s0_win_top         ,
	output wire [C_IMG_HBITS-1     :0] s0_win_height      ,
	output wire [C_IMG_WBITS-1     :0] s0_scale_src_width ,
	output wire [C_IMG_HBITS-1     :0] s0_scale_src_height,
	output wire [C_IMG_WBITS-1     :0] s0_scale_dst_width ,
	output wire [C_IMG_HBITS-1     :0] s0_scale_dst_height,
	output wire [C_IMG_WBITS-1     :0] s0_dst_left        ,
	output wire [C_IMG_WBITS-1     :0] s0_dst_width       ,
	output wire [C_IMG_HBITS-1     :0] s0_dst_top         ,
	output wire [C_IMG_HBITS-1     :0] s0_dst_height      ,
	input  wire                        s0_wr_done         ,
	output wire                        s0_rd_en           ,
	input  wire [C_BUF_IDX_WIDTH-1 :0] s0_rd_buf_idx      ,
	input  wire [C_TS_WIDTH-1      :0] s0_rd_buf_ts       ,
	input  wire [C_IMG_WBITS-1     :0] s0_lft_v           ,
	input  wire [C_IMG_WBITS-1     :0] s0_rt_v            ,
	output wire [C_IMG_PBITS-1     :0] s0_ref_data        ,
	/// s1
	output wire                        s1_in_resetn       ,
	output wire                        s1_out_resetn      ,
	output wire                        s1_fsa_disp_resetn ,
	output wire [C_STREAM_NBR-1    :0] s1_dst_bmp         ,
	output wire [C_IMG_WBITS-1     :0] s1_width           ,
	output wire [C_IMG_HBITS-1     :0] s1_height          ,
	output wire [C_BUF_ADDR_WIDTH-1:0] s1_buf0_addr       ,
	output wire [C_BUF_ADDR_WIDTH-1:0] s1_buf1_addr       ,
	output wire [C_BUF_ADDR_WIDTH-1:0] s1_buf2_addr       ,
	output wire [C_BUF_ADDR_WIDTH-1:0] s1_buf3_addr       ,
	output wire [C_IMG_WBITS-1     :0] s1_win_left        ,
	output wire [C_IMG_WBITS-1     :0] s1_win_width       ,
	output wire [C_IMG_HBITS-1     :0] s1_win_top         ,
	output wire [C_IMG_HBITS-1     :0] s1_win_height      ,
	output wire [C_IMG_WBITS-1     :0] s1_scale_src_width ,
	output wire [C_IMG_HBITS-1     :0] s1_scale_src_height,
	output wire [C_IMG_WBITS-1     :0] s1_scale_dst_width ,
	output wire [C_IMG_HBITS-1     :0] s1_scale_dst_height,
	output wire [C_IMG_WBITS-1     :0] s1_dst_left        ,
	output wire [C_IMG_WBITS-1     :0] s1_dst_width       ,
	output wire [C_IMG_HBITS-1     :0] s1_dst_top         ,
	output wire [C_IMG_HBITS-1     :0] s1_dst_height      ,
	input  wire                        s1_wr_done         ,
	output wire                        s1_rd_en           ,
	input  wire [C_BUF_IDX_WIDTH-1 :0] s1_rd_buf_idx      ,
	input  wire [C_TS_WIDTH-1      :0] s1_rd_buf_ts       ,
	input  wire [C_IMG_WBITS-1     :0] s1_lft_v           ,
	input  wire [C_IMG_WBITS-1     :0] s1_rt_v            ,
	output wire [C_IMG_PBITS-1     :0] s1_ref_data        ,
	/// s2
	output wire                        s2_in_resetn       ,
	output wire                        s2_out_resetn      ,
	output wire                        s2_fsa_disp_resetn ,
	output wire [C_STREAM_NBR-1    :0] s2_dst_bmp         ,
	output wire [C_IMG_WBITS-1     :0] s2_width           ,
	output wire [C_IMG_HBITS-1     :0] s2_height          ,
	output wire [C_BUF_ADDR_WIDTH-1:0] s2_buf0_addr       ,
	output wire [C_BUF_ADDR_WIDTH-1:0] s2_buf1_addr       ,
	output wire [C_BUF_ADDR_WIDTH-1:0] s2_buf2_addr       ,
	output wire [C_BUF_ADDR_WIDTH-1:0] s2_buf3_addr       ,
	output wire [C_IMG_WBITS-1     :0] s2_win_left        ,
	output wire [C_IMG_WBITS-1     :0] s2_win_width       ,
	output wire [C_IMG_HBITS-1     :0] s2_win_top         ,
	output wire [C_IMG_HBITS-1     :0] s2_win_height      ,
	output wire [C_IMG_WBITS-1     :0] s2_scale_src_width ,
	output wire [C_IMG_HBITS-1     :0] s2_scale_src_height,
	output wire [C_IMG_WBITS-1     :0] s2_scale_dst_width ,
	output wire [C_IMG_HBITS-1     :0] s2_scale_dst_height,
	output wire [C_IMG_WBITS-1     :0] s2_dst_left        ,
	output wire [C_IMG_WBITS-1     :0] s2_dst_width       ,
	output wire [C_IMG_HBITS-1     :0] s2_dst_top         ,
	output wire [C_IMG_HBITS-1     :0] s2_dst_height      ,
	input  wire                        s2_wr_done         ,
	output wire                        s2_rd_en           ,
	input  wire [C_BUF_IDX_WIDTH-1 :0] s2_rd_buf_idx      ,
	input  wire [C_TS_WIDTH-1      :0] s2_rd_buf_ts       ,
	input  wire [C_IMG_WBITS-1     :0] s2_lft_v           ,
	input  wire [C_IMG_WBITS-1     :0] s2_rt_v            ,
	output wire [C_IMG_PBITS-1     :0] s2_ref_data        ,
	/// s3
	output wire                        s3_in_resetn       ,
	output wire                        s3_out_resetn      ,
	output wire                        s3_fsa_disp_resetn ,
	output wire [C_STREAM_NBR-1    :0] s3_dst_bmp         ,
	output wire [C_IMG_WBITS-1     :0] s3_width           ,
	output wire [C_IMG_HBITS-1     :0] s3_height          ,
	output wire [C_BUF_ADDR_WIDTH-1:0] s3_buf0_addr       ,
	output wire [C_BUF_ADDR_WIDTH-1:0] s3_buf1_addr       ,
	output wire [C_BUF_ADDR_WIDTH-1:0] s3_buf2_addr       ,
	output wire [C_BUF_ADDR_WIDTH-1:0] s3_buf3_addr       ,
	output wire [C_IMG_WBITS-1     :0] s3_win_left        ,
	output wire [C_IMG_WBITS-1     :0] s3_win_width       ,
	output wire [C_IMG_HBITS-1     :0] s3_win_top         ,
	output wire [C_IMG_HBITS-1     :0] s3_win_height      ,
	output wire [C_IMG_WBITS-1     :0] s3_scale_src_width ,
	output wire [C_IMG_HBITS-1     :0] s3_scale_src_height,
	output wire [C_IMG_WBITS-1     :0] s3_scale_dst_width ,
	output wire [C_IMG_HBITS-1     :0] s3_scale_dst_height,
	output wire [C_IMG_WBITS-1     :0] s3_dst_left        ,
	output wire [C_IMG_WBITS-1     :0] s3_dst_width       ,
	output wire [C_IMG_HBITS-1     :0] s3_dst_top         ,
	output wire [C_IMG_HBITS-1     :0] s3_dst_height      ,
	input  wire                        s3_wr_done         ,
	output wire                        s3_rd_en           ,
	input  wire [C_BUF_IDX_WIDTH-1 :0] s3_rd_buf_idx      ,
	input  wire [C_TS_WIDTH-1      :0] s3_rd_buf_ts       ,
	input  wire [C_IMG_WBITS-1     :0] s3_lft_v           ,
	input  wire [C_IMG_WBITS-1     :0] s3_rt_v            ,
	output wire [C_IMG_PBITS-1     :0] s3_ref_data        ,
	/// s4
	output wire                        s4_in_resetn       ,
	output wire                        s4_out_resetn      ,
	output wire                        s4_fsa_disp_resetn ,
	output wire [C_STREAM_NBR-1    :0] s4_dst_bmp         ,
	output wire [C_IMG_WBITS-1     :0] s4_width           ,
	output wire [C_IMG_HBITS-1     :0] s4_height          ,
	output wire [C_BUF_ADDR_WIDTH-1:0] s4_buf0_addr       ,
	output wire [C_BUF_ADDR_WIDTH-1:0] s4_buf1_addr       ,
	output wire [C_BUF_ADDR_WIDTH-1:0] s4_buf2_addr       ,
	output wire [C_BUF_ADDR_WIDTH-1:0] s4_buf3_addr       ,
	output wire [C_IMG_WBITS-1     :0] s4_win_left        ,
	output wire [C_IMG_WBITS-1     :0] s4_win_width       ,
	output wire [C_IMG_HBITS-1     :0] s4_win_top         ,
	output wire [C_IMG_HBITS-1     :0] s4_win_height      ,
	output wire [C_IMG_WBITS-1     :0] s4_scale_src_width ,
	output wire [C_IMG_HBITS-1     :0] s4_scale_src_height,
	output wire [C_IMG_WBITS-1     :0] s4_scale_dst_width ,
	output wire [C_IMG_HBITS-1     :0] s4_scale_dst_height,
	output wire [C_IMG_WBITS-1     :0] s4_dst_left        ,
	output wire [C_IMG_WBITS-1     :0] s4_dst_width       ,
	output wire [C_IMG_HBITS-1     :0] s4_dst_top         ,
	output wire [C_IMG_HBITS-1     :0] s4_dst_height      ,
	input  wire                        s4_wr_done         ,
	output wire                        s4_rd_en           ,
	input  wire [C_BUF_IDX_WIDTH-1 :0] s4_rd_buf_idx      ,
	input  wire [C_TS_WIDTH-1      :0] s4_rd_buf_ts       ,
	input  wire [C_IMG_WBITS-1     :0] s4_lft_v           ,
	input  wire [C_IMG_WBITS-1     :0] s4_rt_v            ,
	output wire [C_IMG_PBITS-1     :0] s4_ref_data        ,
	/// s5
	output wire                        s5_in_resetn       ,
	output wire                        s5_out_resetn      ,
	output wire                        s5_fsa_disp_resetn ,
	output wire [C_STREAM_NBR-1    :0] s5_dst_bmp         ,
	output wire [C_IMG_WBITS-1     :0] s5_width           ,
	output wire [C_IMG_HBITS-1     :0] s5_height          ,
	output wire [C_BUF_ADDR_WIDTH-1:0] s5_buf0_addr       ,
	output wire [C_BUF_ADDR_WIDTH-1:0] s5_buf1_addr       ,
	output wire [C_BUF_ADDR_WIDTH-1:0] s5_buf2_addr       ,
	output wire [C_BUF_ADDR_WIDTH-1:0] s5_buf3_addr       ,
	output wire [C_IMG_WBITS-1     :0] s5_win_left        ,
	output wire [C_IMG_WBITS-1     :0] s5_win_width       ,
	output wire [C_IMG_HBITS-1     :0] s5_win_top         ,
	output wire [C_IMG_HBITS-1     :0] s5_win_height      ,
	output wire [C_IMG_WBITS-1     :0] s5_scale_src_width ,
	output wire [C_IMG_HBITS-1     :0] s5_scale_src_height,
	output wire [C_IMG_WBITS-1     :0] s5_scale_dst_width ,
	output wire [C_IMG_HBITS-1     :0] s5_scale_dst_height,
	output wire [C_IMG_WBITS-1     :0] s5_dst_left        ,
	output wire [C_IMG_WBITS-1     :0] s5_dst_width       ,
	output wire [C_IMG_HBITS-1     :0] s5_dst_top         ,
	output wire [C_IMG_HBITS-1     :0] s5_dst_height      ,
	input  wire                        s5_wr_done         ,
	output wire                        s5_rd_en           ,
	input  wire [C_BUF_IDX_WIDTH-1 :0] s5_rd_buf_idx      ,
	input  wire [C_TS_WIDTH-1      :0] s5_rd_buf_ts       ,
	input  wire [C_IMG_WBITS-1     :0] s5_lft_v           ,
	input  wire [C_IMG_WBITS-1     :0] s5_rt_v            ,
	output wire [C_IMG_PBITS-1     :0] s5_ref_data        ,
	/// s6
	output wire                        s6_in_resetn       ,
	output wire                        s6_out_resetn      ,
	output wire                        s6_fsa_disp_resetn ,
	output wire [C_STREAM_NBR-1    :0] s6_dst_bmp         ,
	output wire [C_IMG_WBITS-1     :0] s6_width           ,
	output wire [C_IMG_HBITS-1     :0] s6_height          ,
	output wire [C_BUF_ADDR_WIDTH-1:0] s6_buf0_addr       ,
	output wire [C_BUF_ADDR_WIDTH-1:0] s6_buf1_addr       ,
	output wire [C_BUF_ADDR_WIDTH-1:0] s6_buf2_addr       ,
	output wire [C_BUF_ADDR_WIDTH-1:0] s6_buf3_addr       ,
	output wire [C_IMG_WBITS-1     :0] s6_win_left        ,
	output wire [C_IMG_WBITS-1     :0] s6_win_width       ,
	output wire [C_IMG_HBITS-1     :0] s6_win_top         ,
	output wire [C_IMG_HBITS-1     :0] s6_win_height      ,
	output wire [C_IMG_WBITS-1     :0] s6_scale_src_width ,
	output wire [C_IMG_HBITS-1     :0] s6_scale_src_height,
	output wire [C_IMG_WBITS-1     :0] s6_scale_dst_width ,
	output wire [C_IMG_HBITS-1     :0] s6_scale_dst_height,
	output wire [C_IMG_WBITS-1     :0] s6_dst_left        ,
	output wire [C_IMG_WBITS-1     :0] s6_dst_width       ,
	output wire [C_IMG_HBITS-1     :0] s6_dst_top         ,
	output wire [C_IMG_HBITS-1     :0] s6_dst_height      ,
	input  wire                        s6_wr_done         ,
	output wire                        s6_rd_en           ,
	input  wire [C_BUF_IDX_WIDTH-1 :0] s6_rd_buf_idx      ,
	input  wire [C_TS_WIDTH-1      :0] s6_rd_buf_ts       ,
	input  wire [C_IMG_WBITS-1     :0] s6_lft_v           ,
	input  wire [C_IMG_WBITS-1     :0] s6_rt_v            ,
	output wire [C_IMG_PBITS-1     :0] s6_ref_data        ,
	/// s7
	output wire                        s7_in_resetn       ,
	output wire                        s7_out_resetn      ,
	output wire                        s7_fsa_disp_resetn ,
	output wire [C_STREAM_NBR-1    :0] s7_dst_bmp         ,
	output wire [C_IMG_WBITS-1     :0] s7_width           ,
	output wire [C_IMG_HBITS-1     :0] s7_height          ,
	output wire [C_BUF_ADDR_WIDTH-1:0] s7_buf0_addr       ,
	output wire [C_BUF_ADDR_WIDTH-1:0] s7_buf1_addr       ,
	output wire [C_BUF_ADDR_WIDTH-1:0] s7_buf2_addr       ,
	output wire [C_BUF_ADDR_WIDTH-1:0] s7_buf3_addr       ,
	output wire [C_IMG_WBITS-1     :0] s7_win_left        ,
	output wire [C_IMG_WBITS-1     :0] s7_win_width       ,
	output wire [C_IMG_HBITS-1     :0] s7_win_top         ,
	output wire [C_IMG_HBITS-1     :0] s7_win_height      ,
	output wire [C_IMG_WBITS-1     :0] s7_scale_src_width ,
	output wire [C_IMG_HBITS-1     :0] s7_scale_src_height,
	output wire [C_IMG_WBITS-1     :0] s7_scale_dst_width ,
	output wire [C_IMG_HBITS-1     :0] s7_scale_dst_height,
	output wire [C_IMG_WBITS-1     :0] s7_dst_left        ,
	output wire [C_IMG_WBITS-1     :0] s7_dst_width       ,
	output wire [C_IMG_HBITS-1     :0] s7_dst_top         ,
	output wire [C_IMG_HBITS-1     :0] s7_dst_height      ,
	input  wire                        s7_wr_done         ,
	output wire                        s7_rd_en           ,
	input  wire [C_BUF_IDX_WIDTH-1 :0] s7_rd_buf_idx      ,
	input  wire [C_TS_WIDTH-1      :0] s7_rd_buf_ts       ,
	input  wire [C_IMG_WBITS-1     :0] s7_lft_v           ,
	input  wire [C_IMG_WBITS-1     :0] s7_rt_v            ,
	output wire [C_IMG_PBITS-1     :0] s7_ref_data        ,
	/// blockram interface ports
	/// br0
	output wire                          br0_init ,
	output wire                          br0_wr_en,
	output wire [C_SPEED_DATA_WIDTH-1:0] br0_data ,
	input  wire [C_BR_ADDR_WIDTH     :0] br0_size ,
	/// br1
	output wire                          br1_init ,
	output wire                          br1_wr_en,
	output wire [C_SPEED_DATA_WIDTH-1:0] br1_data ,
	input  wire [C_BR_ADDR_WIDTH     :0] br1_size ,
	/// br2
	output wire                          br2_init ,
	output wire                          br2_wr_en,
	output wire [C_SPEED_DATA_WIDTH-1:0] br2_data ,
	input  wire [C_BR_ADDR_WIDTH     :0] br2_size ,
	/// br3
	output wire                          br3_init ,
	output wire                          br3_wr_en,
	output wire [C_SPEED_DATA_WIDTH-1:0] br3_data ,
	input  wire [C_BR_ADDR_WIDTH     :0] br3_size ,
	/// br4
	output wire                          br4_init ,
	output wire                          br4_wr_en,
	output wire [C_SPEED_DATA_WIDTH-1:0] br4_data ,
	input  wire [C_BR_ADDR_WIDTH     :0] br4_size ,
	/// br5
	output wire                          br5_init ,
	output wire                          br5_wr_en,
	output wire [C_SPEED_DATA_WIDTH-1:0] br5_data ,
	input  wire [C_BR_ADDR_WIDTH     :0] br5_size ,
	/// br6
	output wire                          br6_init ,
	output wire                          br6_wr_en,
	output wire [C_SPEED_DATA_WIDTH-1:0] br6_data ,
	input  wire [C_BR_ADDR_WIDTH     :0] br6_size ,
	/// br7
	output wire                          br7_init ,
	output wire                          br7_wr_en,
	output wire [C_SPEED_DATA_WIDTH-1:0] br7_data ,
	input  wire [C_BR_ADDR_WIDTH     :0] br7_size ,
	/// motor interface ports
	/// motor0
	output wire                           motor0_xen     ,
	output wire                           motor0_xrst    ,
	output wire [C_STEP_NUMBER_WIDTH-1:0] motor0_min_pos ,
	output wire [C_STEP_NUMBER_WIDTH-1:0] motor0_max_pos ,
	output wire [C_MICROSTEP_WIDTH-1  :0] motor0_ms      ,
	input  wire                           motor0_ntsign  ,
	input  wire                           motor0_zpsign  ,
	input  wire                           motor0_ptsign  ,
	input  wire                           motor0_state   ,
	input  wire [C_SPEED_DATA_WIDTH-1 :0] motor0_rt_speed,
	input  wire [C_STEP_NUMBER_WIDTH-1:0] motor0_position,
	output wire                           motor0_start   ,
	output wire                           motor0_stop    ,
	output wire [C_SPEED_DATA_WIDTH-1 :0] motor0_speed   ,
	output wire [C_STEP_NUMBER_WIDTH-1:0] motor0_step    ,
	output wire                           motor0_abs     ,
	/// motor1
	output wire                           motor1_xen     ,
	output wire                           motor1_xrst    ,
	output wire [C_STEP_NUMBER_WIDTH-1:0] motor1_min_pos ,
	output wire [C_STEP_NUMBER_WIDTH-1:0] motor1_max_pos ,
	output wire [C_MICROSTEP_WIDTH-1  :0] motor1_ms      ,
	input  wire                           motor1_ntsign  ,
	input  wire                           motor1_zpsign  ,
	input  wire                           motor1_ptsign  ,
	input  wire                           motor1_state   ,
	input  wire [C_SPEED_DATA_WIDTH-1 :0] motor1_rt_speed,
	input  wire [C_STEP_NUMBER_WIDTH-1:0] motor1_position,
	output wire                           motor1_start   ,
	output wire                           motor1_stop    ,
	output wire [C_SPEED_DATA_WIDTH-1 :0] motor1_speed   ,
	output wire [C_STEP_NUMBER_WIDTH-1:0] motor1_step    ,
	output wire                           motor1_abs     ,
	/// motor2
	output wire                           motor2_xen     ,
	output wire                           motor2_xrst    ,
	output wire [C_STEP_NUMBER_WIDTH-1:0] motor2_min_pos ,
	output wire [C_STEP_NUMBER_WIDTH-1:0] motor2_max_pos ,
	output wire [C_MICROSTEP_WIDTH-1  :0] motor2_ms      ,
	input  wire                           motor2_ntsign  ,
	input  wire                           motor2_zpsign  ,
	input  wire                           motor2_ptsign  ,
	input  wire                           motor2_state   ,
	input  wire [C_SPEED_DATA_WIDTH-1 :0] motor2_rt_speed,
	input  wire [C_STEP_NUMBER_WIDTH-1:0] motor2_position,
	output wire                           motor2_start   ,
	output wire                           motor2_stop    ,
	output wire [C_SPEED_DATA_WIDTH-1 :0] motor2_speed   ,
	output wire [C_STEP_NUMBER_WIDTH-1:0] motor2_step    ,
	output wire                           motor2_abs     ,
	/// motor3
	output wire                           motor3_xen     ,
	output wire                           motor3_xrst    ,
	output wire [C_STEP_NUMBER_WIDTH-1:0] motor3_min_pos ,
	output wire [C_STEP_NUMBER_WIDTH-1:0] motor3_max_pos ,
	output wire [C_MICROSTEP_WIDTH-1  :0] motor3_ms      ,
	input  wire                           motor3_ntsign  ,
	input  wire                           motor3_zpsign  ,
	input  wire                           motor3_ptsign  ,
	input  wire                           motor3_state   ,
	input  wire [C_SPEED_DATA_WIDTH-1 :0] motor3_rt_speed,
	input  wire [C_STEP_NUMBER_WIDTH-1:0] motor3_position,
	output wire                           motor3_start   ,
	output wire                           motor3_stop    ,
	output wire [C_SPEED_DATA_WIDTH-1 :0] motor3_speed   ,
	output wire [C_STEP_NUMBER_WIDTH-1:0] motor3_step    ,
	output wire                           motor3_abs     ,
	/// motor4
	output wire                           motor4_xen     ,
	output wire                           motor4_xrst    ,
	output wire [C_STEP_NUMBER_WIDTH-1:0] motor4_min_pos ,
	output wire [C_STEP_NUMBER_WIDTH-1:0] motor4_max_pos ,
	output wire [C_MICROSTEP_WIDTH-1  :0] motor4_ms      ,
	input  wire                           motor4_ntsign  ,
	input  wire                           motor4_zpsign  ,
	input  wire                           motor4_ptsign  ,
	input  wire                           motor4_state   ,
	input  wire [C_SPEED_DATA_WIDTH-1 :0] motor4_rt_speed,
	input  wire [C_STEP_NUMBER_WIDTH-1:0] motor4_position,
	output wire                           motor4_start   ,
	output wire                           motor4_stop    ,
	output wire [C_SPEED_DATA_WIDTH-1 :0] motor4_speed   ,
	output wire [C_STEP_NUMBER_WIDTH-1:0] motor4_step    ,
	output wire                           motor4_abs     ,
	/// motor5
	output wire                           motor5_xen     ,
	output wire                           motor5_xrst    ,
	output wire [C_STEP_NUMBER_WIDTH-1:0] motor5_min_pos ,
	output wire [C_STEP_NUMBER_WIDTH-1:0] motor5_max_pos ,
	output wire [C_MICROSTEP_WIDTH-1  :0] motor5_ms      ,
	input  wire                           motor5_ntsign  ,
	input  wire                           motor5_zpsign  ,
	input  wire                           motor5_ptsign  ,
	input  wire                           motor5_state   ,
	input  wire [C_SPEED_DATA_WIDTH-1 :0] motor5_rt_speed,
	input  wire [C_STEP_NUMBER_WIDTH-1:0] motor5_position,
	output wire                           motor5_start   ,
	output wire                           motor5_stop    ,
	output wire [C_SPEED_DATA_WIDTH-1 :0] motor5_speed   ,
	output wire [C_STEP_NUMBER_WIDTH-1:0] motor5_step    ,
	output wire                           motor5_abs     ,
	/// motor6
	output wire                           motor6_xen     ,
	output wire                           motor6_xrst    ,
	output wire [C_STEP_NUMBER_WIDTH-1:0] motor6_min_pos ,
	output wire [C_STEP_NUMBER_WIDTH-1:0] motor6_max_pos ,
	output wire [C_MICROSTEP_WIDTH-1  :0] motor6_ms      ,
	input  wire                           motor6_ntsign  ,
	input  wire                           motor6_zpsign  ,
	input  wire                           motor6_ptsign  ,
	input  wire                           motor6_state   ,
	input  wire [C_SPEED_DATA_WIDTH-1 :0] motor6_rt_speed,
	input  wire [C_STEP_NUMBER_WIDTH-1:0] motor6_position,
	output wire                           motor6_start   ,
	output wire                           motor6_stop    ,
	output wire [C_SPEED_DATA_WIDTH-1 :0] motor6_speed   ,
	output wire [C_STEP_NUMBER_WIDTH-1:0] motor6_step    ,
	output wire                           motor6_abs     ,
	/// motor7
	output wire                           motor7_xen     ,
	output wire                           motor7_xrst    ,
	output wire [C_STEP_NUMBER_WIDTH-1:0] motor7_min_pos ,
	output wire [C_STEP_NUMBER_WIDTH-1:0] motor7_max_pos ,
	output wire [C_MICROSTEP_WIDTH-1  :0] motor7_ms      ,
	input  wire                           motor7_ntsign  ,
	input  wire                           motor7_zpsign  ,
	input  wire                           motor7_ptsign  ,
	input  wire                           motor7_state   ,
	input  wire [C_SPEED_DATA_WIDTH-1 :0] motor7_rt_speed,
	input  wire [C_STEP_NUMBER_WIDTH-1:0] motor7_position,
	output wire                           motor7_start   ,
	output wire                           motor7_stop    ,
	output wire [C_SPEED_DATA_WIDTH-1 :0] motor7_speed   ,
	output wire [C_STEP_NUMBER_WIDTH-1:0] motor7_step    ,
	output wire                           motor7_abs     ,
	/// pwm interface ports
	/// pwm0
	input  wire                       pwm0_def        ,
	output wire                       pwm0_en         ,
	output wire [C_PWM_CNT_WIDTH-1:0] pwm0_numerator  ,
	output wire [C_PWM_CNT_WIDTH-1:0] pwm0_denominator,
	/// pwm1
	input  wire                       pwm1_def        ,
	output wire                       pwm1_en         ,
	output wire [C_PWM_CNT_WIDTH-1:0] pwm1_numerator  ,
	output wire [C_PWM_CNT_WIDTH-1:0] pwm1_denominator,
	/// pwm2
	input  wire                       pwm2_def        ,
	output wire                       pwm2_en         ,
	output wire [C_PWM_CNT_WIDTH-1:0] pwm2_numerator  ,
	output wire [C_PWM_CNT_WIDTH-1:0] pwm2_denominator,
	/// pwm3
	input  wire                       pwm3_def        ,
	output wire                       pwm3_en         ,
	output wire [C_PWM_CNT_WIDTH-1:0] pwm3_numerator  ,
	output wire [C_PWM_CNT_WIDTH-1:0] pwm3_denominator,
	/// pwm4
	input  wire                       pwm4_def        ,
	output wire                       pwm4_en         ,
	output wire [C_PWM_CNT_WIDTH-1:0] pwm4_numerator  ,
	output wire [C_PWM_CNT_WIDTH-1:0] pwm4_denominator,
	/// pwm5
	input  wire                       pwm5_def        ,
	output wire                       pwm5_en         ,
	output wire [C_PWM_CNT_WIDTH-1:0] pwm5_numerator  ,
	output wire [C_PWM_CNT_WIDTH-1:0] pwm5_denominator,
	/// pwm6
	input  wire                       pwm6_def        ,
	output wire                       pwm6_en         ,
	output wire [C_PWM_CNT_WIDTH-1:0] pwm6_numerator  ,
	output wire [C_PWM_CNT_WIDTH-1:0] pwm6_denominator,
	/// pwm7
	input  wire                       pwm7_def        ,
	output wire                       pwm7_en         ,
	output wire [C_PWM_CNT_WIDTH-1:0] pwm7_numerator  ,
	output wire [C_PWM_CNT_WIDTH-1:0] pwm7_denominator,
	/// pwm8
	input  wire                       pwm8_def        ,
	output wire                       pwm8_en         ,
	output wire [C_PWM_CNT_WIDTH-1:0] pwm8_numerator  ,
	output wire [C_PWM_CNT_WIDTH-1:0] pwm8_denominator,
	/// pwm9
	input  wire                       pwm9_def        ,
	output wire                       pwm9_en         ,
	output wire [C_PWM_CNT_WIDTH-1:0] pwm9_numerator  ,
	output wire [C_PWM_CNT_WIDTH-1:0] pwm9_denominator,
	/// pwm10
	input  wire                       pwm10_def        ,
	output wire                       pwm10_en         ,
	output wire [C_PWM_CNT_WIDTH-1:0] pwm10_numerator  ,
	output wire [C_PWM_CNT_WIDTH-1:0] pwm10_denominator,
	/// pwm11
	input  wire                       pwm11_def        ,
	output wire                       pwm11_en         ,
	output wire [C_PWM_CNT_WIDTH-1:0] pwm11_numerator  ,
	output wire [C_PWM_CNT_WIDTH-1:0] pwm11_denominator,
	/// pwm12
	input  wire                       pwm12_def        ,
	output wire                       pwm12_en         ,
	output wire [C_PWM_CNT_WIDTH-1:0] pwm12_numerator  ,
	output wire [C_PWM_CNT_WIDTH-1:0] pwm12_denominator,
	/// pwm13
	input  wire                       pwm13_def        ,
	output wire                       pwm13_en         ,
	output wire [C_PWM_CNT_WIDTH-1:0] pwm13_numerator  ,
	output wire [C_PWM_CNT_WIDTH-1:0] pwm13_denominator,
	/// pwm14
	input  wire                       pwm14_def        ,
	output wire                       pwm14_en         ,
	output wire [C_PWM_CNT_WIDTH-1:0] pwm14_numerator  ,
	output wire [C_PWM_CNT_WIDTH-1:0] pwm14_denominator,
	/// pwm15
	input  wire                       pwm15_def        ,
	output wire                       pwm15_en         ,
	output wire [C_PWM_CNT_WIDTH-1:0] pwm15_numerator  ,
	output wire [C_PWM_CNT_WIDTH-1:0] pwm15_denominator,
	/// request to fscpu ports
	/// reqctl0
	output wire           reqctl0_resetn,
	output wire           reqctl0_en    ,
	output wire [32-1 :0] reqctl0_cmd   ,
	output wire [160-1:0] reqctl0_param ,
	input  wire           reqctl0_done  ,
	input  wire [32-1 :0] reqctl0_err   ,
	/// heater0
	output wire                          heater0_resetn    ,
	output wire                          heater0_auto_start,
	output wire                          heater0_auto_hold ,
	output wire [C_HEAT_VALUE_WIDTH-1:0] heater0_holdv     ,
	output wire [C_HEAT_VALUE_WIDTH-1:0] heater0_keepv     ,
	output wire [C_HEAT_TIME_WIDTH-1 :0] heater0_keept     ,
	output wire [C_HEAT_VALUE_WIDTH-1:0] heater0_finishv   ,
	output wire                          heater0_start     ,
	output wire                          heater0_stop      ,
	input  wire [2-1                 :0] heater0_state     ,
	input  wire [C_HEAT_VALUE_WIDTH-1:0] heater0_value     ,
	/// external interrupt source ports
	/// extint0
	input wire extint0_src,
	/// extint1
	input wire extint1_src,
	/// extint2
	input wire extint2_src,
	/// extint3
	input wire extint3_src,
	/// extint4
	input wire extint4_src,
	/// extint5
	input wire extint5_src,
	/// extint6
	input wire extint6_src,
	/// extint7
	input wire extint7_src,
	input  wire [32-1              :0] test0        ,
	input  wire [32-1              :0] test1        ,
	input  wire [32-1              :0] test2        ,
	input  wire [32-1              :0] test3        ,
	input  wire [32-1              :0] test4        ,
	input  wire [32-1              :0] test5        ,
	input  wire [32-1              :0] test6        ,
	input  wire [32-1              :0] test7        ,
	input  wire [32-1              :0] test8        ,
	input  wire [32-1              :0] test9        ,
	input  wire [32-1              :0] test10       ,
	input  wire [32-1              :0] test11       ,
	input  wire [32-1              :0] test12       ,
	input  wire [32-1              :0] test13       ,
	input  wire [32-1              :0] test14       ,
	input  wire [32-1              :0] test15
);
	/**********************************************************************
	 *                        section: localparams                        *
	 **********************************************************************/
	/// register number
	localparam integer C_REG_NUM = 2**C_REG_IDX_WIDTH;
	/**********************************************************************
	 *                       section: internal sigs                       *
	 **********************************************************************/
	/// reg container signals
	wire [C_DATA_WIDTH-1      :0] slv_reg           [C_REG_NUM-1:0];
	/// write reg enable
	reg  [C_REG_NUM-1         :0] wre_sync                         ;
	/// write reg data
	reg  [C_DATA_WIDTH-1      :0] wrd_sync                         ;
	/// stream interrupt
	reg                           stream_int                       ;
	/// request interrupt
	reg                           reqctl_int                       ;
	/// request interrupt
	reg                           heater_int                       ;
	/// external interrupt
	reg                           ext_int                          ;
	/// enable update stream configuration
	reg                           update_stream_cfg                ;
	/// configuring stream
	reg                           stream_cfging                    ;
	/// select stream for configure
	reg                           stream_cfgsel     [C_REG_NUM-1:0];
	/// blockram write enable
	reg  [C_BR_INITOR_NBR-1   :0] br_sel                           ;
	/// blockram write enable
	reg                           br_wre                           ;
	/// blockram write enable
	reg  [C_SPEED_DATA_WIDTH-1:0] br_wrd                           ;
	/// motor interrupt
	reg                           motor_int                        ;
	/// select motor for configure
	reg  [C_MOTOR_NBR-1       :0] motor_sel                        ;
	/// select pwm for configure
	reg  [C_PWM_NBR-1         :0] pwm_sel                          ;
	/**********************************************************************
	 *                          section: ifsigs                           *
	 **********************************************************************/
	/// stream interface array
	/// stream interface array for input
	/*input*/ wire                       s_wr_done    [C_STREAM_NBR-1:0];
	/*input*/ wire [C_BUF_IDX_WIDTH-1:0] s_rd_buf_idx [C_STREAM_NBR-1:0];
	/*input*/ wire [C_TS_WIDTH-1     :0] s_rd_buf_ts  [C_STREAM_NBR-1:0];
	/*input*/ wire [C_IMG_WBITS-1    :0] s_lft_v      [C_STREAM_NBR-1:0];
	/*input*/ wire [C_IMG_WBITS-1    :0] s_rt_v       [C_STREAM_NBR-1:0];
	/// stream interface array for interrupt
	/*input*/ reg  int_dly_s_wr_done [C_STREAM_NBR-1:0];
	/*input*/ reg  int_ena_s_wr_done [C_STREAM_NBR-1:0];
	/*input*/ reg  int_sta_s_wr_done [C_STREAM_NBR-1:0];
	/*input*/ wire int_clr_s_wr_done [C_STREAM_NBR-1:0];
	/// stream interface array for config
	/*output*/ reg                     s_in_resetn       [C_STREAM_NBR-1:0];
	/*output*/ reg                     s_out_resetn      [C_STREAM_NBR-1:0];
	/*output*/ reg                     s_fsa_disp_resetn [C_STREAM_NBR-1:0];
	/*output*/ reg  [C_STREAM_NBR-1:0] s_dst_bmp         [C_STREAM_NBR-1:0];
	/*output*/ reg  [C_IMG_WBITS-1 :0] s_width           [C_STREAM_NBR-1:0];
	/*output*/ reg  [C_IMG_HBITS-1 :0] s_height          [C_STREAM_NBR-1:0];
	/*output*/ reg  [C_IMG_WBITS-1 :0] s_win_left        [C_STREAM_NBR-1:0];
	/*output*/ reg  [C_IMG_WBITS-1 :0] s_win_width       [C_STREAM_NBR-1:0];
	/*output*/ reg  [C_IMG_HBITS-1 :0] s_win_top         [C_STREAM_NBR-1:0];
	/*output*/ reg  [C_IMG_HBITS-1 :0] s_win_height      [C_STREAM_NBR-1:0];
	/*output*/ reg  [C_IMG_WBITS-1 :0] s_dst_left        [C_STREAM_NBR-1:0];
	/*output*/ reg  [C_IMG_WBITS-1 :0] s_dst_width       [C_STREAM_NBR-1:0];
	/*output*/ reg  [C_IMG_HBITS-1 :0] s_dst_top         [C_STREAM_NBR-1:0];
	/*output*/ reg  [C_IMG_HBITS-1 :0] s_dst_height      [C_STREAM_NBR-1:0];
	/*output*/ reg  [C_IMG_PBITS-1 :0] s_ref_data        [C_STREAM_NBR-1:0];
	/// stream interface array for fixed
	/*output*/ wire [C_BUF_ADDR_WIDTH-1:0] s_buf0_addr [C_STREAM_NBR-1:0];
	/*output*/ wire [C_BUF_ADDR_WIDTH-1:0] s_buf1_addr [C_STREAM_NBR-1:0];
	/*output*/ wire [C_BUF_ADDR_WIDTH-1:0] s_buf2_addr [C_STREAM_NBR-1:0];
	/*output*/ wire [C_BUF_ADDR_WIDTH-1:0] s_buf3_addr [C_STREAM_NBR-1:0];
	/// stream interface array for trigbyclrint
	/*output*/ reg  s_rd_en [C_STREAM_NBR-1:0];
	/// stream interface array for config (sync source)
	/// s_in_resetn
	/// s_out_resetn
	/*output*/ reg                     r_s_fsa_disp_resetn [C_STREAM_NBR-1:0];
	/*output*/ reg  [C_STREAM_NBR-1:0] r_s_dst_bmp         [C_STREAM_NBR-1:0];
	/*output*/ reg  [C_IMG_WBITS-1 :0] r_s_width           [C_STREAM_NBR-1:0];
	/*output*/ reg  [C_IMG_HBITS-1 :0] r_s_height          [C_STREAM_NBR-1:0];
	/*output*/ reg  [C_IMG_WBITS-1 :0] r_s_win_left        [C_STREAM_NBR-1:0];
	/*output*/ reg  [C_IMG_WBITS-1 :0] r_s_win_width       [C_STREAM_NBR-1:0];
	/*output*/ reg  [C_IMG_HBITS-1 :0] r_s_win_top         [C_STREAM_NBR-1:0];
	/*output*/ reg  [C_IMG_HBITS-1 :0] r_s_win_height      [C_STREAM_NBR-1:0];
	/*output*/ reg  [C_IMG_WBITS-1 :0] r_s_dst_left        [C_STREAM_NBR-1:0];
	/*output*/ reg  [C_IMG_WBITS-1 :0] r_s_dst_width       [C_STREAM_NBR-1:0];
	/*output*/ reg  [C_IMG_HBITS-1 :0] r_s_dst_top         [C_STREAM_NBR-1:0];
	/*output*/ reg  [C_IMG_HBITS-1 :0] r_s_dst_height      [C_STREAM_NBR-1:0];
	/*output*/ reg  [C_IMG_PBITS-1 :0] r_s_ref_data        [C_STREAM_NBR-1:0];
	/// blockram interface array
	/// blockram interface array for input
	/*input*/ wire [C_BR_ADDR_WIDTH:0] br_size [C_BR_INITOR_NBR-1:0];
	/// blockram interface array for interrupt
	/// blockram interface array for config
	/// blockram interface array for fixed
	/*output*/ wire                          br_init  [C_BR_INITOR_NBR-1:0];
	/*output*/ wire                          br_wr_en [C_BR_INITOR_NBR-1:0];
	/*output*/ wire [C_SPEED_DATA_WIDTH-1:0] br_data  [C_BR_INITOR_NBR-1:0];
	/// blockram interface array for trigbyclrint
	/// motor interface array
	/// motor interface array for input
	/*input*/ wire                           motor_ntsign   [C_MOTOR_NBR-1:0];
	/*input*/ wire                           motor_zpsign   [C_MOTOR_NBR-1:0];
	/*input*/ wire                           motor_ptsign   [C_MOTOR_NBR-1:0];
	/*input*/ wire                           motor_state    [C_MOTOR_NBR-1:0];
	/*input*/ wire [C_SPEED_DATA_WIDTH-1 :0] motor_rt_speed [C_MOTOR_NBR-1:0];
	/*input*/ wire [C_STEP_NUMBER_WIDTH-1:0] motor_position [C_MOTOR_NBR-1:0];
	/// motor interface array for interrupt
	/*input*/ reg  int_dly_motor_ntsign [C_MOTOR_NBR-1:0];
	/*input*/ reg  int_ena_motor_ntsign [C_MOTOR_NBR-1:0];
	/*input*/ reg  int_sta_motor_ntsign [C_MOTOR_NBR-1:0];
	/*input*/ wire int_clr_motor_ntsign [C_MOTOR_NBR-1:0];
	/*input*/ reg  int_dly_motor_zpsign [C_MOTOR_NBR-1:0];
	/*input*/ reg  int_ena_motor_zpsign [C_MOTOR_NBR-1:0];
	/*input*/ reg  int_sta_motor_zpsign [C_MOTOR_NBR-1:0];
	/*input*/ wire int_clr_motor_zpsign [C_MOTOR_NBR-1:0];
	/*input*/ reg  int_dly_motor_ptsign [C_MOTOR_NBR-1:0];
	/*input*/ reg  int_ena_motor_ptsign [C_MOTOR_NBR-1:0];
	/*input*/ reg  int_sta_motor_ptsign [C_MOTOR_NBR-1:0];
	/*input*/ wire int_clr_motor_ptsign [C_MOTOR_NBR-1:0];
	/*input*/ reg  int_dly_motor_state  [C_MOTOR_NBR-1:0];
	/*input*/ reg  int_ena_motor_state  [C_MOTOR_NBR-1:0];
	/*input*/ reg  int_sta_motor_state  [C_MOTOR_NBR-1:0];
	/*input*/ wire int_clr_motor_state  [C_MOTOR_NBR-1:0];
	/// motor interface array for config
	/*output*/ reg                            motor_xen     [C_MOTOR_NBR-1:0];
	/*output*/ reg                            motor_xrst    [C_MOTOR_NBR-1:0];
	/*output*/ reg  [C_STEP_NUMBER_WIDTH-1:0] motor_min_pos [C_MOTOR_NBR-1:0];
	/*output*/ reg  [C_STEP_NUMBER_WIDTH-1:0] motor_max_pos [C_MOTOR_NBR-1:0];
	/*output*/ reg  [C_MICROSTEP_WIDTH-1  :0] motor_ms      [C_MOTOR_NBR-1:0];
	/*output*/ reg                            motor_start   [C_MOTOR_NBR-1:0];
	/*output*/ reg                            motor_stop    [C_MOTOR_NBR-1:0];
	/*output*/ reg  [C_SPEED_DATA_WIDTH-1 :0] motor_speed   [C_MOTOR_NBR-1:0];
	/*output*/ reg  [C_STEP_NUMBER_WIDTH-1:0] motor_step    [C_MOTOR_NBR-1:0];
	/*output*/ reg                            motor_abs     [C_MOTOR_NBR-1:0];
	/// motor interface array for fixed
	/// motor interface array for trigbyclrint
	/// pwm interface array
	/// pwm interface array for input
	/*input*/ wire pwm_def [C_PWM_NBR-1:0];
	/// pwm interface array for interrupt
	/// pwm interface array for config
	/*output*/ reg                        pwm_en          [C_PWM_NBR-1:0];
	/*output*/ reg  [C_PWM_CNT_WIDTH-1:0] pwm_numerator   [C_PWM_NBR-1:0];
	/*output*/ reg  [C_PWM_CNT_WIDTH-1:0] pwm_denominator [C_PWM_NBR-1:0];
	/// pwm interface array for fixed
	/// pwm interface array for trigbyclrint
	/// request to fscpu array
	/// request to fscpu array for input
	/*input*/ wire          reqctl_done [0:0];
	/*input*/ wire [32-1:0] reqctl_err  [0:0];
	/// request to fscpu array for interrupt
	/*input*/ reg  int_dly_reqctl_done [0:0];
	/*input*/ reg  int_ena_reqctl_done [0:0];
	/*input*/ reg  int_sta_reqctl_done [0:0];
	/*input*/ wire int_clr_reqctl_done [0:0];
	/// request to fscpu array for config
	/*output*/ reg            reqctl_resetn [0:0];
	/*output*/ reg            reqctl_en     [0:0];
	/*output*/ reg  [32-1 :0] reqctl_cmd    [0:0];
	/*output*/ reg  [160-1:0] reqctl_param  [0:0];
	/// request to fscpu array for fixed
	/// request to fscpu array for trigbyclrint
	/*input*/ wire [2-1                 :0] heater_state [0:0];
	/*input*/ wire [C_HEAT_VALUE_WIDTH-1:0] heater_value [0:0];
	/*input*/ reg[2 - 1 : 0]         int_dly_heater_state [0:0];
	/*input*/ reg          int_ena_heater_state [0:0];
	/*input*/ reg          int_sta_heater_state [0:0];
	/*input*/ wire         int_clr_heater_state [0:0];
	/*output*/ reg                           heater_resetn     [0:0];
	/*output*/ reg                           heater_auto_start [0:0];
	/*output*/ reg                           heater_auto_hold  [0:0];
	/*output*/ reg  [C_HEAT_VALUE_WIDTH-1:0] heater_holdv      [0:0];
	/*output*/ reg  [C_HEAT_VALUE_WIDTH-1:0] heater_keepv      [0:0];
	/*output*/ reg  [C_HEAT_TIME_WIDTH-1 :0] heater_keept      [0:0];
	/*output*/ reg  [C_HEAT_VALUE_WIDTH-1:0] heater_finishv    [0:0];
	/*output*/ reg                           heater_start      [0:0];
	/*output*/ reg                           heater_stop       [0:0];
	/// external interrupt source array
	/// external interrupt source array for input
	/*input*/ wire extint_src [C_EXT_INT_WIDTH-1:0];
	/// external interrupt source array for interrupt
	/*input*/ reg  int_dly_extint_src [C_EXT_INT_WIDTH-1:0];
	/*input*/ reg  int_ena_extint_src [C_EXT_INT_WIDTH-1:0];
	/*input*/ reg  int_sta_extint_src [C_EXT_INT_WIDTH-1:0];
	/*input*/ wire int_clr_extint_src [C_EXT_INT_WIDTH-1:0];
	/// external interrupt source array for config
	/// external interrupt source array for fixed
	/// external interrupt source array for trigbyclrint
	genvar i;
	integer j;
	generate
	/**********************************************************************
	 *                          section: ifcvts                           *
	 **********************************************************************/
	/// convert interface s0 to s[0]
	if (C_STREAM_NBR > 0) begin: s0_to_array
		assign s_wr_done   [0] = /*input*/ s0_wr_done   ;
		assign s_rd_buf_idx[0] = /*input*/ s0_rd_buf_idx;
		assign s_rd_buf_ts [0] = /*input*/ s0_rd_buf_ts ;
		assign s_lft_v     [0] = /*input*/ s0_lft_v     ;
		assign s_rt_v      [0] = /*input*/ s0_rt_v      ;
		assign /*mirror*/ s0_scale_src_width  = /*output*/ s0_win_width ;
		assign /*mirror*/ s0_scale_src_height = /*output*/ s0_win_height;
		assign /*mirror*/ s0_scale_dst_width  = /*output*/ s0_dst_width ;
		assign /*mirror*/ s0_scale_dst_height = /*output*/ s0_dst_height;
		assign /*fixed */ s0_buf0_addr = s_buf0_addr[0];
		assign /*fixed */ s0_buf1_addr = s_buf1_addr[0];
		assign /*fixed */ s0_buf2_addr = s_buf2_addr[0];
		assign /*fixed */ s0_buf3_addr = s_buf3_addr[0];
		assign /*fixed */ s_buf0_addr[0] = C_S0_ADDR;
		assign /*fixed */ s_buf1_addr[0] = C_S0_ADDR + C_S0_SIZE;
		assign /*fixed */ s_buf2_addr[0] = C_S0_ADDR + C_S0_SIZE * 2;
		assign /*fixed */ s_buf3_addr[0] = C_S0_ADDR + C_S0_SIZE * 3;
		assign /*config*/ s0_in_resetn       = s_in_resetn      [0];
		assign /*config*/ s0_out_resetn      = s_out_resetn     [0];
		assign /*config*/ s0_fsa_disp_resetn = s_fsa_disp_resetn[0];
		assign /*config*/ s0_dst_bmp         = s_dst_bmp        [0];
		assign /*config*/ s0_width           = s_width          [0];
		assign /*config*/ s0_height          = s_height         [0];
		assign /*config*/ s0_win_left        = s_win_left       [0];
		assign /*config*/ s0_win_width       = s_win_width      [0];
		assign /*config*/ s0_win_top         = s_win_top        [0];
		assign /*config*/ s0_win_height      = s_win_height     [0];
		assign /*config*/ s0_dst_left        = s_dst_left       [0];
		assign /*config*/ s0_dst_width       = s_dst_width      [0];
		assign /*config*/ s0_dst_top         = s_dst_top        [0];
		assign /*config*/ s0_dst_height      = s_dst_height     [0];
		assign /*config*/ s0_ref_data        = s_ref_data       [0];
		assign /*trigbyclrint*/ s0_rd_en = s_rd_en[0];
	end
	else begin
		assign /*output*/ s0_in_resetn        = 0;
		assign /*output*/ s0_out_resetn       = 0;
		assign /*output*/ s0_fsa_disp_resetn  = 0;
		assign /*output*/ s0_dst_bmp          = 0;
		assign /*output*/ s0_width            = 0;
		assign /*output*/ s0_height           = 0;
		assign /*output*/ s0_buf0_addr        = 0;
		assign /*output*/ s0_buf1_addr        = 0;
		assign /*output*/ s0_buf2_addr        = 0;
		assign /*output*/ s0_buf3_addr        = 0;
		assign /*output*/ s0_win_left         = 0;
		assign /*output*/ s0_win_width        = 0;
		assign /*output*/ s0_win_top          = 0;
		assign /*output*/ s0_win_height       = 0;
		assign /*output*/ s0_scale_src_width  = 0;
		assign /*output*/ s0_scale_src_height = 0;
		assign /*output*/ s0_scale_dst_width  = 0;
		assign /*output*/ s0_scale_dst_height = 0;
		assign /*output*/ s0_dst_left         = 0;
		assign /*output*/ s0_dst_width        = 0;
		assign /*output*/ s0_dst_top          = 0;
		assign /*output*/ s0_dst_height       = 0;
		assign /*output*/ s0_rd_en            = 0;
		assign /*output*/ s0_ref_data         = 0;
	end
	/// convert interface s1 to s[1]
	if (C_STREAM_NBR > 1) begin: s1_to_array
		assign s_wr_done   [1] = /*input*/ s1_wr_done   ;
		assign s_rd_buf_idx[1] = /*input*/ s1_rd_buf_idx;
		assign s_rd_buf_ts [1] = /*input*/ s1_rd_buf_ts ;
		assign s_lft_v     [1] = /*input*/ s1_lft_v     ;
		assign s_rt_v      [1] = /*input*/ s1_rt_v      ;
		assign /*mirror*/ s1_scale_src_width  = /*output*/ s1_win_width ;
		assign /*mirror*/ s1_scale_src_height = /*output*/ s1_win_height;
		assign /*mirror*/ s1_scale_dst_width  = /*output*/ s1_dst_width ;
		assign /*mirror*/ s1_scale_dst_height = /*output*/ s1_dst_height;
		assign /*fixed */ s1_buf0_addr = s_buf0_addr[1];
		assign /*fixed */ s1_buf1_addr = s_buf1_addr[1];
		assign /*fixed */ s1_buf2_addr = s_buf2_addr[1];
		assign /*fixed */ s1_buf3_addr = s_buf3_addr[1];
		assign /*fixed */ s_buf0_addr[1] = C_S1_ADDR;
		assign /*fixed */ s_buf1_addr[1] = C_S1_ADDR + C_S1_SIZE;
		assign /*fixed */ s_buf2_addr[1] = C_S1_ADDR + C_S1_SIZE * 2;
		assign /*fixed */ s_buf3_addr[1] = C_S1_ADDR + C_S1_SIZE * 3;
		assign /*config*/ s1_in_resetn       = s_in_resetn      [1];
		assign /*config*/ s1_out_resetn      = s_out_resetn     [1];
		assign /*config*/ s1_fsa_disp_resetn = s_fsa_disp_resetn[1];
		assign /*config*/ s1_dst_bmp         = s_dst_bmp        [1];
		assign /*config*/ s1_width           = s_width          [1];
		assign /*config*/ s1_height          = s_height         [1];
		assign /*config*/ s1_win_left        = s_win_left       [1];
		assign /*config*/ s1_win_width       = s_win_width      [1];
		assign /*config*/ s1_win_top         = s_win_top        [1];
		assign /*config*/ s1_win_height      = s_win_height     [1];
		assign /*config*/ s1_dst_left        = s_dst_left       [1];
		assign /*config*/ s1_dst_width       = s_dst_width      [1];
		assign /*config*/ s1_dst_top         = s_dst_top        [1];
		assign /*config*/ s1_dst_height      = s_dst_height     [1];
		assign /*config*/ s1_ref_data        = s_ref_data       [1];
		assign /*trigbyclrint*/ s1_rd_en = s_rd_en[1];
	end
	else begin
		assign /*output*/ s1_in_resetn        = 0;
		assign /*output*/ s1_out_resetn       = 0;
		assign /*output*/ s1_fsa_disp_resetn  = 0;
		assign /*output*/ s1_dst_bmp          = 0;
		assign /*output*/ s1_width            = 0;
		assign /*output*/ s1_height           = 0;
		assign /*output*/ s1_buf0_addr        = 0;
		assign /*output*/ s1_buf1_addr        = 0;
		assign /*output*/ s1_buf2_addr        = 0;
		assign /*output*/ s1_buf3_addr        = 0;
		assign /*output*/ s1_win_left         = 0;
		assign /*output*/ s1_win_width        = 0;
		assign /*output*/ s1_win_top          = 0;
		assign /*output*/ s1_win_height       = 0;
		assign /*output*/ s1_scale_src_width  = 0;
		assign /*output*/ s1_scale_src_height = 0;
		assign /*output*/ s1_scale_dst_width  = 0;
		assign /*output*/ s1_scale_dst_height = 0;
		assign /*output*/ s1_dst_left         = 0;
		assign /*output*/ s1_dst_width        = 0;
		assign /*output*/ s1_dst_top          = 0;
		assign /*output*/ s1_dst_height       = 0;
		assign /*output*/ s1_rd_en            = 0;
		assign /*output*/ s1_ref_data         = 0;
	end
	/// convert interface s2 to s[2]
	if (C_STREAM_NBR > 2) begin: s2_to_array
		assign s_wr_done   [2] = /*input*/ s2_wr_done   ;
		assign s_rd_buf_idx[2] = /*input*/ s2_rd_buf_idx;
		assign s_rd_buf_ts [2] = /*input*/ s2_rd_buf_ts ;
		assign s_lft_v     [2] = /*input*/ s2_lft_v     ;
		assign s_rt_v      [2] = /*input*/ s2_rt_v      ;
		assign /*mirror*/ s2_scale_src_width  = /*output*/ s2_win_width ;
		assign /*mirror*/ s2_scale_src_height = /*output*/ s2_win_height;
		assign /*mirror*/ s2_scale_dst_width  = /*output*/ s2_dst_width ;
		assign /*mirror*/ s2_scale_dst_height = /*output*/ s2_dst_height;
		assign /*fixed */ s2_buf0_addr = s_buf0_addr[2];
		assign /*fixed */ s2_buf1_addr = s_buf1_addr[2];
		assign /*fixed */ s2_buf2_addr = s_buf2_addr[2];
		assign /*fixed */ s2_buf3_addr = s_buf3_addr[2];
		assign /*fixed */ s_buf0_addr[2] = C_S2_ADDR;
		assign /*fixed */ s_buf1_addr[2] = C_S2_ADDR + C_S2_SIZE;
		assign /*fixed */ s_buf2_addr[2] = C_S2_ADDR + C_S2_SIZE * 2;
		assign /*fixed */ s_buf3_addr[2] = C_S2_ADDR + C_S2_SIZE * 3;
		assign /*config*/ s2_in_resetn       = s_in_resetn      [2];
		assign /*config*/ s2_out_resetn      = s_out_resetn     [2];
		assign /*config*/ s2_fsa_disp_resetn = s_fsa_disp_resetn[2];
		assign /*config*/ s2_dst_bmp         = s_dst_bmp        [2];
		assign /*config*/ s2_width           = s_width          [2];
		assign /*config*/ s2_height          = s_height         [2];
		assign /*config*/ s2_win_left        = s_win_left       [2];
		assign /*config*/ s2_win_width       = s_win_width      [2];
		assign /*config*/ s2_win_top         = s_win_top        [2];
		assign /*config*/ s2_win_height      = s_win_height     [2];
		assign /*config*/ s2_dst_left        = s_dst_left       [2];
		assign /*config*/ s2_dst_width       = s_dst_width      [2];
		assign /*config*/ s2_dst_top         = s_dst_top        [2];
		assign /*config*/ s2_dst_height      = s_dst_height     [2];
		assign /*config*/ s2_ref_data        = s_ref_data       [2];
		assign /*trigbyclrint*/ s2_rd_en = s_rd_en[2];
	end
	else begin
		assign /*output*/ s2_in_resetn        = 0;
		assign /*output*/ s2_out_resetn       = 0;
		assign /*output*/ s2_fsa_disp_resetn  = 0;
		assign /*output*/ s2_dst_bmp          = 0;
		assign /*output*/ s2_width            = 0;
		assign /*output*/ s2_height           = 0;
		assign /*output*/ s2_buf0_addr        = 0;
		assign /*output*/ s2_buf1_addr        = 0;
		assign /*output*/ s2_buf2_addr        = 0;
		assign /*output*/ s2_buf3_addr        = 0;
		assign /*output*/ s2_win_left         = 0;
		assign /*output*/ s2_win_width        = 0;
		assign /*output*/ s2_win_top          = 0;
		assign /*output*/ s2_win_height       = 0;
		assign /*output*/ s2_scale_src_width  = 0;
		assign /*output*/ s2_scale_src_height = 0;
		assign /*output*/ s2_scale_dst_width  = 0;
		assign /*output*/ s2_scale_dst_height = 0;
		assign /*output*/ s2_dst_left         = 0;
		assign /*output*/ s2_dst_width        = 0;
		assign /*output*/ s2_dst_top          = 0;
		assign /*output*/ s2_dst_height       = 0;
		assign /*output*/ s2_rd_en            = 0;
		assign /*output*/ s2_ref_data         = 0;
	end
	/// convert interface s3 to s[3]
	if (C_STREAM_NBR > 3) begin: s3_to_array
		assign s_wr_done   [3] = /*input*/ s3_wr_done   ;
		assign s_rd_buf_idx[3] = /*input*/ s3_rd_buf_idx;
		assign s_rd_buf_ts [3] = /*input*/ s3_rd_buf_ts ;
		assign s_lft_v     [3] = /*input*/ s3_lft_v     ;
		assign s_rt_v      [3] = /*input*/ s3_rt_v      ;
		assign /*mirror*/ s3_scale_src_width  = /*output*/ s3_win_width ;
		assign /*mirror*/ s3_scale_src_height = /*output*/ s3_win_height;
		assign /*mirror*/ s3_scale_dst_width  = /*output*/ s3_dst_width ;
		assign /*mirror*/ s3_scale_dst_height = /*output*/ s3_dst_height;
		assign /*fixed */ s3_buf0_addr = s_buf0_addr[3];
		assign /*fixed */ s3_buf1_addr = s_buf1_addr[3];
		assign /*fixed */ s3_buf2_addr = s_buf2_addr[3];
		assign /*fixed */ s3_buf3_addr = s_buf3_addr[3];
		assign /*fixed */ s_buf0_addr[3] = C_S3_ADDR;
		assign /*fixed */ s_buf1_addr[3] = C_S3_ADDR + C_S3_SIZE;
		assign /*fixed */ s_buf2_addr[3] = C_S3_ADDR + C_S3_SIZE * 2;
		assign /*fixed */ s_buf3_addr[3] = C_S3_ADDR + C_S3_SIZE * 3;
		assign /*config*/ s3_in_resetn       = s_in_resetn      [3];
		assign /*config*/ s3_out_resetn      = s_out_resetn     [3];
		assign /*config*/ s3_fsa_disp_resetn = s_fsa_disp_resetn[3];
		assign /*config*/ s3_dst_bmp         = s_dst_bmp        [3];
		assign /*config*/ s3_width           = s_width          [3];
		assign /*config*/ s3_height          = s_height         [3];
		assign /*config*/ s3_win_left        = s_win_left       [3];
		assign /*config*/ s3_win_width       = s_win_width      [3];
		assign /*config*/ s3_win_top         = s_win_top        [3];
		assign /*config*/ s3_win_height      = s_win_height     [3];
		assign /*config*/ s3_dst_left        = s_dst_left       [3];
		assign /*config*/ s3_dst_width       = s_dst_width      [3];
		assign /*config*/ s3_dst_top         = s_dst_top        [3];
		assign /*config*/ s3_dst_height      = s_dst_height     [3];
		assign /*config*/ s3_ref_data        = s_ref_data       [3];
		assign /*trigbyclrint*/ s3_rd_en = s_rd_en[3];
	end
	else begin
		assign /*output*/ s3_in_resetn        = 0;
		assign /*output*/ s3_out_resetn       = 0;
		assign /*output*/ s3_fsa_disp_resetn  = 0;
		assign /*output*/ s3_dst_bmp          = 0;
		assign /*output*/ s3_width            = 0;
		assign /*output*/ s3_height           = 0;
		assign /*output*/ s3_buf0_addr        = 0;
		assign /*output*/ s3_buf1_addr        = 0;
		assign /*output*/ s3_buf2_addr        = 0;
		assign /*output*/ s3_buf3_addr        = 0;
		assign /*output*/ s3_win_left         = 0;
		assign /*output*/ s3_win_width        = 0;
		assign /*output*/ s3_win_top          = 0;
		assign /*output*/ s3_win_height       = 0;
		assign /*output*/ s3_scale_src_width  = 0;
		assign /*output*/ s3_scale_src_height = 0;
		assign /*output*/ s3_scale_dst_width  = 0;
		assign /*output*/ s3_scale_dst_height = 0;
		assign /*output*/ s3_dst_left         = 0;
		assign /*output*/ s3_dst_width        = 0;
		assign /*output*/ s3_dst_top          = 0;
		assign /*output*/ s3_dst_height       = 0;
		assign /*output*/ s3_rd_en            = 0;
		assign /*output*/ s3_ref_data         = 0;
	end
	/// convert interface s4 to s[4]
	if (C_STREAM_NBR > 4) begin: s4_to_array
		assign s_wr_done   [4] = /*input*/ s4_wr_done   ;
		assign s_rd_buf_idx[4] = /*input*/ s4_rd_buf_idx;
		assign s_rd_buf_ts [4] = /*input*/ s4_rd_buf_ts ;
		assign s_lft_v     [4] = /*input*/ s4_lft_v     ;
		assign s_rt_v      [4] = /*input*/ s4_rt_v      ;
		assign /*mirror*/ s4_scale_src_width  = /*output*/ s4_win_width ;
		assign /*mirror*/ s4_scale_src_height = /*output*/ s4_win_height;
		assign /*mirror*/ s4_scale_dst_width  = /*output*/ s4_dst_width ;
		assign /*mirror*/ s4_scale_dst_height = /*output*/ s4_dst_height;
		assign /*fixed */ s4_buf0_addr = s_buf0_addr[4];
		assign /*fixed */ s4_buf1_addr = s_buf1_addr[4];
		assign /*fixed */ s4_buf2_addr = s_buf2_addr[4];
		assign /*fixed */ s4_buf3_addr = s_buf3_addr[4];
		assign /*fixed */ s_buf0_addr[4] = C_S4_ADDR;
		assign /*fixed */ s_buf1_addr[4] = C_S4_ADDR + C_S4_SIZE;
		assign /*fixed */ s_buf2_addr[4] = C_S4_ADDR + C_S4_SIZE * 2;
		assign /*fixed */ s_buf3_addr[4] = C_S4_ADDR + C_S4_SIZE * 3;
		assign /*config*/ s4_in_resetn       = s_in_resetn      [4];
		assign /*config*/ s4_out_resetn      = s_out_resetn     [4];
		assign /*config*/ s4_fsa_disp_resetn = s_fsa_disp_resetn[4];
		assign /*config*/ s4_dst_bmp         = s_dst_bmp        [4];
		assign /*config*/ s4_width           = s_width          [4];
		assign /*config*/ s4_height          = s_height         [4];
		assign /*config*/ s4_win_left        = s_win_left       [4];
		assign /*config*/ s4_win_width       = s_win_width      [4];
		assign /*config*/ s4_win_top         = s_win_top        [4];
		assign /*config*/ s4_win_height      = s_win_height     [4];
		assign /*config*/ s4_dst_left        = s_dst_left       [4];
		assign /*config*/ s4_dst_width       = s_dst_width      [4];
		assign /*config*/ s4_dst_top         = s_dst_top        [4];
		assign /*config*/ s4_dst_height      = s_dst_height     [4];
		assign /*config*/ s4_ref_data        = s_ref_data       [4];
		assign /*trigbyclrint*/ s4_rd_en = s_rd_en[4];
	end
	else begin
		assign /*output*/ s4_in_resetn        = 0;
		assign /*output*/ s4_out_resetn       = 0;
		assign /*output*/ s4_fsa_disp_resetn  = 0;
		assign /*output*/ s4_dst_bmp          = 0;
		assign /*output*/ s4_width            = 0;
		assign /*output*/ s4_height           = 0;
		assign /*output*/ s4_buf0_addr        = 0;
		assign /*output*/ s4_buf1_addr        = 0;
		assign /*output*/ s4_buf2_addr        = 0;
		assign /*output*/ s4_buf3_addr        = 0;
		assign /*output*/ s4_win_left         = 0;
		assign /*output*/ s4_win_width        = 0;
		assign /*output*/ s4_win_top          = 0;
		assign /*output*/ s4_win_height       = 0;
		assign /*output*/ s4_scale_src_width  = 0;
		assign /*output*/ s4_scale_src_height = 0;
		assign /*output*/ s4_scale_dst_width  = 0;
		assign /*output*/ s4_scale_dst_height = 0;
		assign /*output*/ s4_dst_left         = 0;
		assign /*output*/ s4_dst_width        = 0;
		assign /*output*/ s4_dst_top          = 0;
		assign /*output*/ s4_dst_height       = 0;
		assign /*output*/ s4_rd_en            = 0;
		assign /*output*/ s4_ref_data         = 0;
	end
	/// convert interface s5 to s[5]
	if (C_STREAM_NBR > 5) begin: s5_to_array
		assign s_wr_done   [5] = /*input*/ s5_wr_done   ;
		assign s_rd_buf_idx[5] = /*input*/ s5_rd_buf_idx;
		assign s_rd_buf_ts [5] = /*input*/ s5_rd_buf_ts ;
		assign s_lft_v     [5] = /*input*/ s5_lft_v     ;
		assign s_rt_v      [5] = /*input*/ s5_rt_v      ;
		assign /*mirror*/ s5_scale_src_width  = /*output*/ s5_win_width ;
		assign /*mirror*/ s5_scale_src_height = /*output*/ s5_win_height;
		assign /*mirror*/ s5_scale_dst_width  = /*output*/ s5_dst_width ;
		assign /*mirror*/ s5_scale_dst_height = /*output*/ s5_dst_height;
		assign /*fixed */ s5_buf0_addr = s_buf0_addr[5];
		assign /*fixed */ s5_buf1_addr = s_buf1_addr[5];
		assign /*fixed */ s5_buf2_addr = s_buf2_addr[5];
		assign /*fixed */ s5_buf3_addr = s_buf3_addr[5];
		assign /*fixed */ s_buf0_addr[5] = C_S5_ADDR;
		assign /*fixed */ s_buf1_addr[5] = C_S5_ADDR + C_S5_SIZE;
		assign /*fixed */ s_buf2_addr[5] = C_S5_ADDR + C_S5_SIZE * 2;
		assign /*fixed */ s_buf3_addr[5] = C_S5_ADDR + C_S5_SIZE * 3;
		assign /*config*/ s5_in_resetn       = s_in_resetn      [5];
		assign /*config*/ s5_out_resetn      = s_out_resetn     [5];
		assign /*config*/ s5_fsa_disp_resetn = s_fsa_disp_resetn[5];
		assign /*config*/ s5_dst_bmp         = s_dst_bmp        [5];
		assign /*config*/ s5_width           = s_width          [5];
		assign /*config*/ s5_height          = s_height         [5];
		assign /*config*/ s5_win_left        = s_win_left       [5];
		assign /*config*/ s5_win_width       = s_win_width      [5];
		assign /*config*/ s5_win_top         = s_win_top        [5];
		assign /*config*/ s5_win_height      = s_win_height     [5];
		assign /*config*/ s5_dst_left        = s_dst_left       [5];
		assign /*config*/ s5_dst_width       = s_dst_width      [5];
		assign /*config*/ s5_dst_top         = s_dst_top        [5];
		assign /*config*/ s5_dst_height      = s_dst_height     [5];
		assign /*config*/ s5_ref_data        = s_ref_data       [5];
		assign /*trigbyclrint*/ s5_rd_en = s_rd_en[5];
	end
	else begin
		assign /*output*/ s5_in_resetn        = 0;
		assign /*output*/ s5_out_resetn       = 0;
		assign /*output*/ s5_fsa_disp_resetn  = 0;
		assign /*output*/ s5_dst_bmp          = 0;
		assign /*output*/ s5_width            = 0;
		assign /*output*/ s5_height           = 0;
		assign /*output*/ s5_buf0_addr        = 0;
		assign /*output*/ s5_buf1_addr        = 0;
		assign /*output*/ s5_buf2_addr        = 0;
		assign /*output*/ s5_buf3_addr        = 0;
		assign /*output*/ s5_win_left         = 0;
		assign /*output*/ s5_win_width        = 0;
		assign /*output*/ s5_win_top          = 0;
		assign /*output*/ s5_win_height       = 0;
		assign /*output*/ s5_scale_src_width  = 0;
		assign /*output*/ s5_scale_src_height = 0;
		assign /*output*/ s5_scale_dst_width  = 0;
		assign /*output*/ s5_scale_dst_height = 0;
		assign /*output*/ s5_dst_left         = 0;
		assign /*output*/ s5_dst_width        = 0;
		assign /*output*/ s5_dst_top          = 0;
		assign /*output*/ s5_dst_height       = 0;
		assign /*output*/ s5_rd_en            = 0;
		assign /*output*/ s5_ref_data         = 0;
	end
	/// convert interface s6 to s[6]
	if (C_STREAM_NBR > 6) begin: s6_to_array
		assign s_wr_done   [6] = /*input*/ s6_wr_done   ;
		assign s_rd_buf_idx[6] = /*input*/ s6_rd_buf_idx;
		assign s_rd_buf_ts [6] = /*input*/ s6_rd_buf_ts ;
		assign s_lft_v     [6] = /*input*/ s6_lft_v     ;
		assign s_rt_v      [6] = /*input*/ s6_rt_v      ;
		assign /*mirror*/ s6_scale_src_width  = /*output*/ s6_win_width ;
		assign /*mirror*/ s6_scale_src_height = /*output*/ s6_win_height;
		assign /*mirror*/ s6_scale_dst_width  = /*output*/ s6_dst_width ;
		assign /*mirror*/ s6_scale_dst_height = /*output*/ s6_dst_height;
		assign /*fixed */ s6_buf0_addr = s_buf0_addr[6];
		assign /*fixed */ s6_buf1_addr = s_buf1_addr[6];
		assign /*fixed */ s6_buf2_addr = s_buf2_addr[6];
		assign /*fixed */ s6_buf3_addr = s_buf3_addr[6];
		assign /*fixed */ s_buf0_addr[6] = C_S6_ADDR;
		assign /*fixed */ s_buf1_addr[6] = C_S6_ADDR + C_S6_SIZE;
		assign /*fixed */ s_buf2_addr[6] = C_S6_ADDR + C_S6_SIZE * 2;
		assign /*fixed */ s_buf3_addr[6] = C_S6_ADDR + C_S6_SIZE * 3;
		assign /*config*/ s6_in_resetn       = s_in_resetn      [6];
		assign /*config*/ s6_out_resetn      = s_out_resetn     [6];
		assign /*config*/ s6_fsa_disp_resetn = s_fsa_disp_resetn[6];
		assign /*config*/ s6_dst_bmp         = s_dst_bmp        [6];
		assign /*config*/ s6_width           = s_width          [6];
		assign /*config*/ s6_height          = s_height         [6];
		assign /*config*/ s6_win_left        = s_win_left       [6];
		assign /*config*/ s6_win_width       = s_win_width      [6];
		assign /*config*/ s6_win_top         = s_win_top        [6];
		assign /*config*/ s6_win_height      = s_win_height     [6];
		assign /*config*/ s6_dst_left        = s_dst_left       [6];
		assign /*config*/ s6_dst_width       = s_dst_width      [6];
		assign /*config*/ s6_dst_top         = s_dst_top        [6];
		assign /*config*/ s6_dst_height      = s_dst_height     [6];
		assign /*config*/ s6_ref_data        = s_ref_data       [6];
		assign /*trigbyclrint*/ s6_rd_en = s_rd_en[6];
	end
	else begin
		assign /*output*/ s6_in_resetn        = 0;
		assign /*output*/ s6_out_resetn       = 0;
		assign /*output*/ s6_fsa_disp_resetn  = 0;
		assign /*output*/ s6_dst_bmp          = 0;
		assign /*output*/ s6_width            = 0;
		assign /*output*/ s6_height           = 0;
		assign /*output*/ s6_buf0_addr        = 0;
		assign /*output*/ s6_buf1_addr        = 0;
		assign /*output*/ s6_buf2_addr        = 0;
		assign /*output*/ s6_buf3_addr        = 0;
		assign /*output*/ s6_win_left         = 0;
		assign /*output*/ s6_win_width        = 0;
		assign /*output*/ s6_win_top          = 0;
		assign /*output*/ s6_win_height       = 0;
		assign /*output*/ s6_scale_src_width  = 0;
		assign /*output*/ s6_scale_src_height = 0;
		assign /*output*/ s6_scale_dst_width  = 0;
		assign /*output*/ s6_scale_dst_height = 0;
		assign /*output*/ s6_dst_left         = 0;
		assign /*output*/ s6_dst_width        = 0;
		assign /*output*/ s6_dst_top          = 0;
		assign /*output*/ s6_dst_height       = 0;
		assign /*output*/ s6_rd_en            = 0;
		assign /*output*/ s6_ref_data         = 0;
	end
	/// convert interface s7 to s[7]
	if (C_STREAM_NBR > 7) begin: s7_to_array
		assign s_wr_done   [7] = /*input*/ s7_wr_done   ;
		assign s_rd_buf_idx[7] = /*input*/ s7_rd_buf_idx;
		assign s_rd_buf_ts [7] = /*input*/ s7_rd_buf_ts ;
		assign s_lft_v     [7] = /*input*/ s7_lft_v     ;
		assign s_rt_v      [7] = /*input*/ s7_rt_v      ;
		assign /*mirror*/ s7_scale_src_width  = /*output*/ s7_win_width ;
		assign /*mirror*/ s7_scale_src_height = /*output*/ s7_win_height;
		assign /*mirror*/ s7_scale_dst_width  = /*output*/ s7_dst_width ;
		assign /*mirror*/ s7_scale_dst_height = /*output*/ s7_dst_height;
		assign /*fixed */ s7_buf0_addr = s_buf0_addr[7];
		assign /*fixed */ s7_buf1_addr = s_buf1_addr[7];
		assign /*fixed */ s7_buf2_addr = s_buf2_addr[7];
		assign /*fixed */ s7_buf3_addr = s_buf3_addr[7];
		assign /*fixed */ s_buf0_addr[7] = C_S7_ADDR;
		assign /*fixed */ s_buf1_addr[7] = C_S7_ADDR + C_S7_SIZE;
		assign /*fixed */ s_buf2_addr[7] = C_S7_ADDR + C_S7_SIZE * 2;
		assign /*fixed */ s_buf3_addr[7] = C_S7_ADDR + C_S7_SIZE * 3;
		assign /*config*/ s7_in_resetn       = s_in_resetn      [7];
		assign /*config*/ s7_out_resetn      = s_out_resetn     [7];
		assign /*config*/ s7_fsa_disp_resetn = s_fsa_disp_resetn[7];
		assign /*config*/ s7_dst_bmp         = s_dst_bmp        [7];
		assign /*config*/ s7_width           = s_width          [7];
		assign /*config*/ s7_height          = s_height         [7];
		assign /*config*/ s7_win_left        = s_win_left       [7];
		assign /*config*/ s7_win_width       = s_win_width      [7];
		assign /*config*/ s7_win_top         = s_win_top        [7];
		assign /*config*/ s7_win_height      = s_win_height     [7];
		assign /*config*/ s7_dst_left        = s_dst_left       [7];
		assign /*config*/ s7_dst_width       = s_dst_width      [7];
		assign /*config*/ s7_dst_top         = s_dst_top        [7];
		assign /*config*/ s7_dst_height      = s_dst_height     [7];
		assign /*config*/ s7_ref_data        = s_ref_data       [7];
		assign /*trigbyclrint*/ s7_rd_en = s_rd_en[7];
	end
	else begin
		assign /*output*/ s7_in_resetn        = 0;
		assign /*output*/ s7_out_resetn       = 0;
		assign /*output*/ s7_fsa_disp_resetn  = 0;
		assign /*output*/ s7_dst_bmp          = 0;
		assign /*output*/ s7_width            = 0;
		assign /*output*/ s7_height           = 0;
		assign /*output*/ s7_buf0_addr        = 0;
		assign /*output*/ s7_buf1_addr        = 0;
		assign /*output*/ s7_buf2_addr        = 0;
		assign /*output*/ s7_buf3_addr        = 0;
		assign /*output*/ s7_win_left         = 0;
		assign /*output*/ s7_win_width        = 0;
		assign /*output*/ s7_win_top          = 0;
		assign /*output*/ s7_win_height       = 0;
		assign /*output*/ s7_scale_src_width  = 0;
		assign /*output*/ s7_scale_src_height = 0;
		assign /*output*/ s7_scale_dst_width  = 0;
		assign /*output*/ s7_scale_dst_height = 0;
		assign /*output*/ s7_dst_left         = 0;
		assign /*output*/ s7_dst_width        = 0;
		assign /*output*/ s7_dst_top          = 0;
		assign /*output*/ s7_dst_height       = 0;
		assign /*output*/ s7_rd_en            = 0;
		assign /*output*/ s7_ref_data         = 0;
	end
	for (i = 0; i < C_STREAM_NBR; i=i+1) begin: sync_cfg_for_s
		always @ (posedge o_clk) begin
			if (o_resetn == 1'b0) begin
				s_out_resetn     [i] <= 0;
				s_fsa_disp_resetn[i] <= 0;
				s_dst_bmp        [i] <= 0;
				s_width          [i] <= 0;
				s_height         [i] <= 0;
				s_win_left       [i] <= 0;
				s_win_width      [i] <= 0;
				s_win_top        [i] <= 0;
				s_win_height     [i] <= 0;
				s_dst_left       [i] <= 0;
				s_dst_width      [i] <= 0;
				s_dst_top        [i] <= 0;
				s_dst_height     [i] <= 0;
				s_ref_data       [i] <= 0;
			end
			else if (update_stream_cfg) begin
				s_out_resetn     [i] <= (r_s_dst_bmp[i] != 0);
				s_fsa_disp_resetn[i] <= r_s_fsa_disp_resetn[i];
				s_dst_bmp        [i] <= r_s_dst_bmp        [i];
				s_width          [i] <= r_s_width          [i];
				s_height         [i] <= r_s_height         [i];
				s_win_left       [i] <= r_s_win_left       [i];
				s_win_width      [i] <= r_s_win_width      [i];
				s_win_top        [i] <= r_s_win_top        [i];
				s_win_height     [i] <= r_s_win_height     [i];
				s_dst_left       [i] <= r_s_dst_left       [i];
				s_dst_width      [i] <= r_s_dst_width      [i];
				s_dst_top        [i] <= r_s_dst_top        [i];
				s_dst_height     [i] <= r_s_dst_height     [i];
				s_ref_data       [i] <= r_s_ref_data       [i];
			end
		end
		always @ (posedge o_clk) begin
			if (o_resetn == 1'b0)
				int_dly_s_wr_done[i] <= 0;
			else
				int_dly_s_wr_done[i] <= s_wr_done[i];
		end
		always @ (posedge o_clk) begin
			if (o_resetn == 1'b0)
				int_sta_s_wr_done[i] <= 0;
			else if (int_clr_s_wr_done[i])
				int_sta_s_wr_done[i] <= 0;
			else if (int_dly_s_wr_done[i] == 0 && s_wr_done[i] == 1)
				int_sta_s_wr_done[i] <= 1;
		end
		always @ (posedge o_clk) begin
			if (o_resetn == 1'b0)
				s_rd_en[i] <= 0;
			else if (int_clr_s_wr_done[i])
				s_rd_en[i] <= 1;
			else
				s_rd_en[i] <= 0;
		end
	end
	/// convert interface br0 to br[0]
	if (C_BR_INITOR_NBR > 0) begin: br0_to_array
		assign br_size[0] = /*input*/ br0_size;
		assign /*fixed */ br0_init  = br_init [0];
		assign /*fixed */ br0_wr_en = br_wr_en[0];
		assign /*fixed */ br0_data  = br_data [0];
		assign /*fixed */ br_init [0] = br_sel[0];
		assign /*fixed */ br_wr_en[0] = br_wre;
		assign /*fixed */ br_data [0] = br_wrd;
	end
	else begin
		assign /*output*/ br0_init  = 0;
		assign /*output*/ br0_wr_en = 0;
		assign /*output*/ br0_data  = 0;
	end
	/// convert interface br1 to br[1]
	if (C_BR_INITOR_NBR > 1) begin: br1_to_array
		assign br_size[1] = /*input*/ br1_size;
		assign /*fixed */ br1_init  = br_init [1];
		assign /*fixed */ br1_wr_en = br_wr_en[1];
		assign /*fixed */ br1_data  = br_data [1];
		assign /*fixed */ br_init [1] = br_sel[1];
		assign /*fixed */ br_wr_en[1] = br_wre;
		assign /*fixed */ br_data [1] = br_wrd;
	end
	else begin
		assign /*output*/ br1_init  = 0;
		assign /*output*/ br1_wr_en = 0;
		assign /*output*/ br1_data  = 0;
	end
	/// convert interface br2 to br[2]
	if (C_BR_INITOR_NBR > 2) begin: br2_to_array
		assign br_size[2] = /*input*/ br2_size;
		assign /*fixed */ br2_init  = br_init [2];
		assign /*fixed */ br2_wr_en = br_wr_en[2];
		assign /*fixed */ br2_data  = br_data [2];
		assign /*fixed */ br_init [2] = br_sel[2];
		assign /*fixed */ br_wr_en[2] = br_wre;
		assign /*fixed */ br_data [2] = br_wrd;
	end
	else begin
		assign /*output*/ br2_init  = 0;
		assign /*output*/ br2_wr_en = 0;
		assign /*output*/ br2_data  = 0;
	end
	/// convert interface br3 to br[3]
	if (C_BR_INITOR_NBR > 3) begin: br3_to_array
		assign br_size[3] = /*input*/ br3_size;
		assign /*fixed */ br3_init  = br_init [3];
		assign /*fixed */ br3_wr_en = br_wr_en[3];
		assign /*fixed */ br3_data  = br_data [3];
		assign /*fixed */ br_init [3] = br_sel[3];
		assign /*fixed */ br_wr_en[3] = br_wre;
		assign /*fixed */ br_data [3] = br_wrd;
	end
	else begin
		assign /*output*/ br3_init  = 0;
		assign /*output*/ br3_wr_en = 0;
		assign /*output*/ br3_data  = 0;
	end
	/// convert interface br4 to br[4]
	if (C_BR_INITOR_NBR > 4) begin: br4_to_array
		assign br_size[4] = /*input*/ br4_size;
		assign /*fixed */ br4_init  = br_init [4];
		assign /*fixed */ br4_wr_en = br_wr_en[4];
		assign /*fixed */ br4_data  = br_data [4];
		assign /*fixed */ br_init [4] = br_sel[4];
		assign /*fixed */ br_wr_en[4] = br_wre;
		assign /*fixed */ br_data [4] = br_wrd;
	end
	else begin
		assign /*output*/ br4_init  = 0;
		assign /*output*/ br4_wr_en = 0;
		assign /*output*/ br4_data  = 0;
	end
	/// convert interface br5 to br[5]
	if (C_BR_INITOR_NBR > 5) begin: br5_to_array
		assign br_size[5] = /*input*/ br5_size;
		assign /*fixed */ br5_init  = br_init [5];
		assign /*fixed */ br5_wr_en = br_wr_en[5];
		assign /*fixed */ br5_data  = br_data [5];
		assign /*fixed */ br_init [5] = br_sel[5];
		assign /*fixed */ br_wr_en[5] = br_wre;
		assign /*fixed */ br_data [5] = br_wrd;
	end
	else begin
		assign /*output*/ br5_init  = 0;
		assign /*output*/ br5_wr_en = 0;
		assign /*output*/ br5_data  = 0;
	end
	/// convert interface br6 to br[6]
	if (C_BR_INITOR_NBR > 6) begin: br6_to_array
		assign br_size[6] = /*input*/ br6_size;
		assign /*fixed */ br6_init  = br_init [6];
		assign /*fixed */ br6_wr_en = br_wr_en[6];
		assign /*fixed */ br6_data  = br_data [6];
		assign /*fixed */ br_init [6] = br_sel[6];
		assign /*fixed */ br_wr_en[6] = br_wre;
		assign /*fixed */ br_data [6] = br_wrd;
	end
	else begin
		assign /*output*/ br6_init  = 0;
		assign /*output*/ br6_wr_en = 0;
		assign /*output*/ br6_data  = 0;
	end
	/// convert interface br7 to br[7]
	if (C_BR_INITOR_NBR > 7) begin: br7_to_array
		assign br_size[7] = /*input*/ br7_size;
		assign /*fixed */ br7_init  = br_init [7];
		assign /*fixed */ br7_wr_en = br_wr_en[7];
		assign /*fixed */ br7_data  = br_data [7];
		assign /*fixed */ br_init [7] = br_sel[7];
		assign /*fixed */ br_wr_en[7] = br_wre;
		assign /*fixed */ br_data [7] = br_wrd;
	end
	else begin
		assign /*output*/ br7_init  = 0;
		assign /*output*/ br7_wr_en = 0;
		assign /*output*/ br7_data  = 0;
	end
	for (i = 0; i < C_BR_INITOR_NBR; i=i+1) begin: sync_cfg_for_br
	end
	/// convert interface motor0 to motor[0]
	if (C_MOTOR_NBR > 0) begin: motor0_to_array
		assign motor_ntsign  [0] = /*input*/ motor0_ntsign  ;
		assign motor_zpsign  [0] = /*input*/ motor0_zpsign  ;
		assign motor_ptsign  [0] = /*input*/ motor0_ptsign  ;
		assign motor_state   [0] = /*input*/ motor0_state   ;
		assign motor_rt_speed[0] = /*input*/ motor0_rt_speed;
		assign motor_position[0] = /*input*/ motor0_position;
		assign /*config*/ motor0_xen     = motor_xen    [0];
		assign /*config*/ motor0_xrst    = motor_xrst   [0];
		assign /*config*/ motor0_min_pos = motor_min_pos[0];
		assign /*config*/ motor0_max_pos = motor_max_pos[0];
		assign /*config*/ motor0_ms      = motor_ms     [0];
		assign /*config*/ motor0_start   = motor_start  [0];
		assign /*config*/ motor0_stop    = motor_stop   [0];
		assign /*config*/ motor0_speed   = motor_speed  [0];
		assign /*config*/ motor0_step    = motor_step   [0];
		assign /*config*/ motor0_abs     = motor_abs    [0];
	end
	else begin
		assign /*output*/ motor0_xen     = 0;
		assign /*output*/ motor0_xrst    = 0;
		assign /*output*/ motor0_min_pos = 0;
		assign /*output*/ motor0_max_pos = 0;
		assign /*output*/ motor0_ms      = 0;
		assign /*output*/ motor0_start   = 0;
		assign /*output*/ motor0_stop    = 0;
		assign /*output*/ motor0_speed   = 0;
		assign /*output*/ motor0_step    = 0;
		assign /*output*/ motor0_abs     = 0;
	end
	/// convert interface motor1 to motor[1]
	if (C_MOTOR_NBR > 1) begin: motor1_to_array
		assign motor_ntsign  [1] = /*input*/ motor1_ntsign  ;
		assign motor_zpsign  [1] = /*input*/ motor1_zpsign  ;
		assign motor_ptsign  [1] = /*input*/ motor1_ptsign  ;
		assign motor_state   [1] = /*input*/ motor1_state   ;
		assign motor_rt_speed[1] = /*input*/ motor1_rt_speed;
		assign motor_position[1] = /*input*/ motor1_position;
		assign /*config*/ motor1_xen     = motor_xen    [1];
		assign /*config*/ motor1_xrst    = motor_xrst   [1];
		assign /*config*/ motor1_min_pos = motor_min_pos[1];
		assign /*config*/ motor1_max_pos = motor_max_pos[1];
		assign /*config*/ motor1_ms      = motor_ms     [1];
		assign /*config*/ motor1_start   = motor_start  [1];
		assign /*config*/ motor1_stop    = motor_stop   [1];
		assign /*config*/ motor1_speed   = motor_speed  [1];
		assign /*config*/ motor1_step    = motor_step   [1];
		assign /*config*/ motor1_abs     = motor_abs    [1];
	end
	else begin
		assign /*output*/ motor1_xen     = 0;
		assign /*output*/ motor1_xrst    = 0;
		assign /*output*/ motor1_min_pos = 0;
		assign /*output*/ motor1_max_pos = 0;
		assign /*output*/ motor1_ms      = 0;
		assign /*output*/ motor1_start   = 0;
		assign /*output*/ motor1_stop    = 0;
		assign /*output*/ motor1_speed   = 0;
		assign /*output*/ motor1_step    = 0;
		assign /*output*/ motor1_abs     = 0;
	end
	/// convert interface motor2 to motor[2]
	if (C_MOTOR_NBR > 2) begin: motor2_to_array
		assign motor_ntsign  [2] = /*input*/ motor2_ntsign  ;
		assign motor_zpsign  [2] = /*input*/ motor2_zpsign  ;
		assign motor_ptsign  [2] = /*input*/ motor2_ptsign  ;
		assign motor_state   [2] = /*input*/ motor2_state   ;
		assign motor_rt_speed[2] = /*input*/ motor2_rt_speed;
		assign motor_position[2] = /*input*/ motor2_position;
		assign /*config*/ motor2_xen     = motor_xen    [2];
		assign /*config*/ motor2_xrst    = motor_xrst   [2];
		assign /*config*/ motor2_min_pos = motor_min_pos[2];
		assign /*config*/ motor2_max_pos = motor_max_pos[2];
		assign /*config*/ motor2_ms      = motor_ms     [2];
		assign /*config*/ motor2_start   = motor_start  [2];
		assign /*config*/ motor2_stop    = motor_stop   [2];
		assign /*config*/ motor2_speed   = motor_speed  [2];
		assign /*config*/ motor2_step    = motor_step   [2];
		assign /*config*/ motor2_abs     = motor_abs    [2];
	end
	else begin
		assign /*output*/ motor2_xen     = 0;
		assign /*output*/ motor2_xrst    = 0;
		assign /*output*/ motor2_min_pos = 0;
		assign /*output*/ motor2_max_pos = 0;
		assign /*output*/ motor2_ms      = 0;
		assign /*output*/ motor2_start   = 0;
		assign /*output*/ motor2_stop    = 0;
		assign /*output*/ motor2_speed   = 0;
		assign /*output*/ motor2_step    = 0;
		assign /*output*/ motor2_abs     = 0;
	end
	/// convert interface motor3 to motor[3]
	if (C_MOTOR_NBR > 3) begin: motor3_to_array
		assign motor_ntsign  [3] = /*input*/ motor3_ntsign  ;
		assign motor_zpsign  [3] = /*input*/ motor3_zpsign  ;
		assign motor_ptsign  [3] = /*input*/ motor3_ptsign  ;
		assign motor_state   [3] = /*input*/ motor3_state   ;
		assign motor_rt_speed[3] = /*input*/ motor3_rt_speed;
		assign motor_position[3] = /*input*/ motor3_position;
		assign /*config*/ motor3_xen     = motor_xen    [3];
		assign /*config*/ motor3_xrst    = motor_xrst   [3];
		assign /*config*/ motor3_min_pos = motor_min_pos[3];
		assign /*config*/ motor3_max_pos = motor_max_pos[3];
		assign /*config*/ motor3_ms      = motor_ms     [3];
		assign /*config*/ motor3_start   = motor_start  [3];
		assign /*config*/ motor3_stop    = motor_stop   [3];
		assign /*config*/ motor3_speed   = motor_speed  [3];
		assign /*config*/ motor3_step    = motor_step   [3];
		assign /*config*/ motor3_abs     = motor_abs    [3];
	end
	else begin
		assign /*output*/ motor3_xen     = 0;
		assign /*output*/ motor3_xrst    = 0;
		assign /*output*/ motor3_min_pos = 0;
		assign /*output*/ motor3_max_pos = 0;
		assign /*output*/ motor3_ms      = 0;
		assign /*output*/ motor3_start   = 0;
		assign /*output*/ motor3_stop    = 0;
		assign /*output*/ motor3_speed   = 0;
		assign /*output*/ motor3_step    = 0;
		assign /*output*/ motor3_abs     = 0;
	end
	/// convert interface motor4 to motor[4]
	if (C_MOTOR_NBR > 4) begin: motor4_to_array
		assign motor_ntsign  [4] = /*input*/ motor4_ntsign  ;
		assign motor_zpsign  [4] = /*input*/ motor4_zpsign  ;
		assign motor_ptsign  [4] = /*input*/ motor4_ptsign  ;
		assign motor_state   [4] = /*input*/ motor4_state   ;
		assign motor_rt_speed[4] = /*input*/ motor4_rt_speed;
		assign motor_position[4] = /*input*/ motor4_position;
		assign /*config*/ motor4_xen     = motor_xen    [4];
		assign /*config*/ motor4_xrst    = motor_xrst   [4];
		assign /*config*/ motor4_min_pos = motor_min_pos[4];
		assign /*config*/ motor4_max_pos = motor_max_pos[4];
		assign /*config*/ motor4_ms      = motor_ms     [4];
		assign /*config*/ motor4_start   = motor_start  [4];
		assign /*config*/ motor4_stop    = motor_stop   [4];
		assign /*config*/ motor4_speed   = motor_speed  [4];
		assign /*config*/ motor4_step    = motor_step   [4];
		assign /*config*/ motor4_abs     = motor_abs    [4];
	end
	else begin
		assign /*output*/ motor4_xen     = 0;
		assign /*output*/ motor4_xrst    = 0;
		assign /*output*/ motor4_min_pos = 0;
		assign /*output*/ motor4_max_pos = 0;
		assign /*output*/ motor4_ms      = 0;
		assign /*output*/ motor4_start   = 0;
		assign /*output*/ motor4_stop    = 0;
		assign /*output*/ motor4_speed   = 0;
		assign /*output*/ motor4_step    = 0;
		assign /*output*/ motor4_abs     = 0;
	end
	/// convert interface motor5 to motor[5]
	if (C_MOTOR_NBR > 5) begin: motor5_to_array
		assign motor_ntsign  [5] = /*input*/ motor5_ntsign  ;
		assign motor_zpsign  [5] = /*input*/ motor5_zpsign  ;
		assign motor_ptsign  [5] = /*input*/ motor5_ptsign  ;
		assign motor_state   [5] = /*input*/ motor5_state   ;
		assign motor_rt_speed[5] = /*input*/ motor5_rt_speed;
		assign motor_position[5] = /*input*/ motor5_position;
		assign /*config*/ motor5_xen     = motor_xen    [5];
		assign /*config*/ motor5_xrst    = motor_xrst   [5];
		assign /*config*/ motor5_min_pos = motor_min_pos[5];
		assign /*config*/ motor5_max_pos = motor_max_pos[5];
		assign /*config*/ motor5_ms      = motor_ms     [5];
		assign /*config*/ motor5_start   = motor_start  [5];
		assign /*config*/ motor5_stop    = motor_stop   [5];
		assign /*config*/ motor5_speed   = motor_speed  [5];
		assign /*config*/ motor5_step    = motor_step   [5];
		assign /*config*/ motor5_abs     = motor_abs    [5];
	end
	else begin
		assign /*output*/ motor5_xen     = 0;
		assign /*output*/ motor5_xrst    = 0;
		assign /*output*/ motor5_min_pos = 0;
		assign /*output*/ motor5_max_pos = 0;
		assign /*output*/ motor5_ms      = 0;
		assign /*output*/ motor5_start   = 0;
		assign /*output*/ motor5_stop    = 0;
		assign /*output*/ motor5_speed   = 0;
		assign /*output*/ motor5_step    = 0;
		assign /*output*/ motor5_abs     = 0;
	end
	/// convert interface motor6 to motor[6]
	if (C_MOTOR_NBR > 6) begin: motor6_to_array
		assign motor_ntsign  [6] = /*input*/ motor6_ntsign  ;
		assign motor_zpsign  [6] = /*input*/ motor6_zpsign  ;
		assign motor_ptsign  [6] = /*input*/ motor6_ptsign  ;
		assign motor_state   [6] = /*input*/ motor6_state   ;
		assign motor_rt_speed[6] = /*input*/ motor6_rt_speed;
		assign motor_position[6] = /*input*/ motor6_position;
		assign /*config*/ motor6_xen     = motor_xen    [6];
		assign /*config*/ motor6_xrst    = motor_xrst   [6];
		assign /*config*/ motor6_min_pos = motor_min_pos[6];
		assign /*config*/ motor6_max_pos = motor_max_pos[6];
		assign /*config*/ motor6_ms      = motor_ms     [6];
		assign /*config*/ motor6_start   = motor_start  [6];
		assign /*config*/ motor6_stop    = motor_stop   [6];
		assign /*config*/ motor6_speed   = motor_speed  [6];
		assign /*config*/ motor6_step    = motor_step   [6];
		assign /*config*/ motor6_abs     = motor_abs    [6];
	end
	else begin
		assign /*output*/ motor6_xen     = 0;
		assign /*output*/ motor6_xrst    = 0;
		assign /*output*/ motor6_min_pos = 0;
		assign /*output*/ motor6_max_pos = 0;
		assign /*output*/ motor6_ms      = 0;
		assign /*output*/ motor6_start   = 0;
		assign /*output*/ motor6_stop    = 0;
		assign /*output*/ motor6_speed   = 0;
		assign /*output*/ motor6_step    = 0;
		assign /*output*/ motor6_abs     = 0;
	end
	/// convert interface motor7 to motor[7]
	if (C_MOTOR_NBR > 7) begin: motor7_to_array
		assign motor_ntsign  [7] = /*input*/ motor7_ntsign  ;
		assign motor_zpsign  [7] = /*input*/ motor7_zpsign  ;
		assign motor_ptsign  [7] = /*input*/ motor7_ptsign  ;
		assign motor_state   [7] = /*input*/ motor7_state   ;
		assign motor_rt_speed[7] = /*input*/ motor7_rt_speed;
		assign motor_position[7] = /*input*/ motor7_position;
		assign /*config*/ motor7_xen     = motor_xen    [7];
		assign /*config*/ motor7_xrst    = motor_xrst   [7];
		assign /*config*/ motor7_min_pos = motor_min_pos[7];
		assign /*config*/ motor7_max_pos = motor_max_pos[7];
		assign /*config*/ motor7_ms      = motor_ms     [7];
		assign /*config*/ motor7_start   = motor_start  [7];
		assign /*config*/ motor7_stop    = motor_stop   [7];
		assign /*config*/ motor7_speed   = motor_speed  [7];
		assign /*config*/ motor7_step    = motor_step   [7];
		assign /*config*/ motor7_abs     = motor_abs    [7];
	end
	else begin
		assign /*output*/ motor7_xen     = 0;
		assign /*output*/ motor7_xrst    = 0;
		assign /*output*/ motor7_min_pos = 0;
		assign /*output*/ motor7_max_pos = 0;
		assign /*output*/ motor7_ms      = 0;
		assign /*output*/ motor7_start   = 0;
		assign /*output*/ motor7_stop    = 0;
		assign /*output*/ motor7_speed   = 0;
		assign /*output*/ motor7_step    = 0;
		assign /*output*/ motor7_abs     = 0;
	end
	for (i = 0; i < C_MOTOR_NBR; i=i+1) begin: sync_cfg_for_motor
		always @ (posedge o_clk) begin
			if (o_resetn == 1'b0)
				int_dly_motor_ntsign[i] <= 0;
			else
				int_dly_motor_ntsign[i] <= motor_ntsign[i];
		end
		always @ (posedge o_clk) begin
			if (o_resetn == 1'b0)
				int_sta_motor_ntsign[i] <= 0;
			else if (int_clr_motor_ntsign[i])
				int_sta_motor_ntsign[i] <= 0;
			else if (int_dly_motor_ntsign[i] == 0 && motor_ntsign[i] == 1)
				int_sta_motor_ntsign[i] <= 1;
		end
		always @ (posedge o_clk) begin
			if (o_resetn == 1'b0)
				int_dly_motor_zpsign[i] <= 0;
			else
				int_dly_motor_zpsign[i] <= motor_zpsign[i];
		end
		always @ (posedge o_clk) begin
			if (o_resetn == 1'b0)
				int_sta_motor_zpsign[i] <= 0;
			else if (int_clr_motor_zpsign[i])
				int_sta_motor_zpsign[i] <= 0;
			else if (int_dly_motor_zpsign[i] == 0 && motor_zpsign[i] == 1)
				int_sta_motor_zpsign[i] <= 1;
		end
		always @ (posedge o_clk) begin
			if (o_resetn == 1'b0)
				int_dly_motor_ptsign[i] <= 0;
			else
				int_dly_motor_ptsign[i] <= motor_ptsign[i];
		end
		always @ (posedge o_clk) begin
			if (o_resetn == 1'b0)
				int_sta_motor_ptsign[i] <= 0;
			else if (int_clr_motor_ptsign[i])
				int_sta_motor_ptsign[i] <= 0;
			else if (int_dly_motor_ptsign[i] == 0 && motor_ptsign[i] == 1)
				int_sta_motor_ptsign[i] <= 1;
		end
		always @ (posedge o_clk) begin
			if (o_resetn == 1'b0)
				int_dly_motor_state [i] <= 0;
			else
				int_dly_motor_state [i] <= motor_state [i];
		end
		always @ (posedge o_clk) begin
			if (o_resetn == 1'b0)
				int_sta_motor_state[i] <= 0;
			else if (int_clr_motor_state[i])
				int_sta_motor_state[i] <= 0;
			else if (int_dly_motor_state[i] == 1 && motor_state[i] == 0)
				int_sta_motor_state[i] <= 1;
		end
	end
	/// convert interface pwm0 to pwm[0]
	if (C_PWM_NBR > 0) begin: pwm0_to_array
		assign pwm_def[0] = /*input*/ pwm0_def;
		assign /*config*/ pwm0_en          = pwm_en         [0];
		assign /*config*/ pwm0_numerator   = pwm_numerator  [0];
		assign /*config*/ pwm0_denominator = pwm_denominator[0];
	end
	else begin
		assign /*output*/ pwm0_en          = 0;
		assign /*output*/ pwm0_numerator   = 0;
		assign /*output*/ pwm0_denominator = 0;
	end
	/// convert interface pwm1 to pwm[1]
	if (C_PWM_NBR > 1) begin: pwm1_to_array
		assign pwm_def[1] = /*input*/ pwm1_def;
		assign /*config*/ pwm1_en          = pwm_en         [1];
		assign /*config*/ pwm1_numerator   = pwm_numerator  [1];
		assign /*config*/ pwm1_denominator = pwm_denominator[1];
	end
	else begin
		assign /*output*/ pwm1_en          = 0;
		assign /*output*/ pwm1_numerator   = 0;
		assign /*output*/ pwm1_denominator = 0;
	end
	/// convert interface pwm2 to pwm[2]
	if (C_PWM_NBR > 2) begin: pwm2_to_array
		assign pwm_def[2] = /*input*/ pwm2_def;
		assign /*config*/ pwm2_en          = pwm_en         [2];
		assign /*config*/ pwm2_numerator   = pwm_numerator  [2];
		assign /*config*/ pwm2_denominator = pwm_denominator[2];
	end
	else begin
		assign /*output*/ pwm2_en          = 0;
		assign /*output*/ pwm2_numerator   = 0;
		assign /*output*/ pwm2_denominator = 0;
	end
	/// convert interface pwm3 to pwm[3]
	if (C_PWM_NBR > 3) begin: pwm3_to_array
		assign pwm_def[3] = /*input*/ pwm3_def;
		assign /*config*/ pwm3_en          = pwm_en         [3];
		assign /*config*/ pwm3_numerator   = pwm_numerator  [3];
		assign /*config*/ pwm3_denominator = pwm_denominator[3];
	end
	else begin
		assign /*output*/ pwm3_en          = 0;
		assign /*output*/ pwm3_numerator   = 0;
		assign /*output*/ pwm3_denominator = 0;
	end
	/// convert interface pwm4 to pwm[4]
	if (C_PWM_NBR > 4) begin: pwm4_to_array
		assign pwm_def[4] = /*input*/ pwm4_def;
		assign /*config*/ pwm4_en          = pwm_en         [4];
		assign /*config*/ pwm4_numerator   = pwm_numerator  [4];
		assign /*config*/ pwm4_denominator = pwm_denominator[4];
	end
	else begin
		assign /*output*/ pwm4_en          = 0;
		assign /*output*/ pwm4_numerator   = 0;
		assign /*output*/ pwm4_denominator = 0;
	end
	/// convert interface pwm5 to pwm[5]
	if (C_PWM_NBR > 5) begin: pwm5_to_array
		assign pwm_def[5] = /*input*/ pwm5_def;
		assign /*config*/ pwm5_en          = pwm_en         [5];
		assign /*config*/ pwm5_numerator   = pwm_numerator  [5];
		assign /*config*/ pwm5_denominator = pwm_denominator[5];
	end
	else begin
		assign /*output*/ pwm5_en          = 0;
		assign /*output*/ pwm5_numerator   = 0;
		assign /*output*/ pwm5_denominator = 0;
	end
	/// convert interface pwm6 to pwm[6]
	if (C_PWM_NBR > 6) begin: pwm6_to_array
		assign pwm_def[6] = /*input*/ pwm6_def;
		assign /*config*/ pwm6_en          = pwm_en         [6];
		assign /*config*/ pwm6_numerator   = pwm_numerator  [6];
		assign /*config*/ pwm6_denominator = pwm_denominator[6];
	end
	else begin
		assign /*output*/ pwm6_en          = 0;
		assign /*output*/ pwm6_numerator   = 0;
		assign /*output*/ pwm6_denominator = 0;
	end
	/// convert interface pwm7 to pwm[7]
	if (C_PWM_NBR > 7) begin: pwm7_to_array
		assign pwm_def[7] = /*input*/ pwm7_def;
		assign /*config*/ pwm7_en          = pwm_en         [7];
		assign /*config*/ pwm7_numerator   = pwm_numerator  [7];
		assign /*config*/ pwm7_denominator = pwm_denominator[7];
	end
	else begin
		assign /*output*/ pwm7_en          = 0;
		assign /*output*/ pwm7_numerator   = 0;
		assign /*output*/ pwm7_denominator = 0;
	end
	/// convert interface pwm8 to pwm[8]
	if (C_PWM_NBR > 8) begin: pwm8_to_array
		assign pwm_def[8] = /*input*/ pwm8_def;
		assign /*config*/ pwm8_en          = pwm_en         [8];
		assign /*config*/ pwm8_numerator   = pwm_numerator  [8];
		assign /*config*/ pwm8_denominator = pwm_denominator[8];
	end
	else begin
		assign /*output*/ pwm8_en          = 0;
		assign /*output*/ pwm8_numerator   = 0;
		assign /*output*/ pwm8_denominator = 0;
	end
	/// convert interface pwm9 to pwm[9]
	if (C_PWM_NBR > 9) begin: pwm9_to_array
		assign pwm_def[9] = /*input*/ pwm9_def;
		assign /*config*/ pwm9_en          = pwm_en         [9];
		assign /*config*/ pwm9_numerator   = pwm_numerator  [9];
		assign /*config*/ pwm9_denominator = pwm_denominator[9];
	end
	else begin
		assign /*output*/ pwm9_en          = 0;
		assign /*output*/ pwm9_numerator   = 0;
		assign /*output*/ pwm9_denominator = 0;
	end
	/// convert interface pwm10 to pwm[10]
	if (C_PWM_NBR > 10) begin: pwm10_to_array
		assign pwm_def[10] = /*input*/ pwm10_def;
		assign /*config*/ pwm10_en          = pwm_en         [10];
		assign /*config*/ pwm10_numerator   = pwm_numerator  [10];
		assign /*config*/ pwm10_denominator = pwm_denominator[10];
	end
	else begin
		assign /*output*/ pwm10_en          = 0;
		assign /*output*/ pwm10_numerator   = 0;
		assign /*output*/ pwm10_denominator = 0;
	end
	/// convert interface pwm11 to pwm[11]
	if (C_PWM_NBR > 11) begin: pwm11_to_array
		assign pwm_def[11] = /*input*/ pwm11_def;
		assign /*config*/ pwm11_en          = pwm_en         [11];
		assign /*config*/ pwm11_numerator   = pwm_numerator  [11];
		assign /*config*/ pwm11_denominator = pwm_denominator[11];
	end
	else begin
		assign /*output*/ pwm11_en          = 0;
		assign /*output*/ pwm11_numerator   = 0;
		assign /*output*/ pwm11_denominator = 0;
	end
	/// convert interface pwm12 to pwm[12]
	if (C_PWM_NBR > 12) begin: pwm12_to_array
		assign pwm_def[12] = /*input*/ pwm12_def;
		assign /*config*/ pwm12_en          = pwm_en         [12];
		assign /*config*/ pwm12_numerator   = pwm_numerator  [12];
		assign /*config*/ pwm12_denominator = pwm_denominator[12];
	end
	else begin
		assign /*output*/ pwm12_en          = 0;
		assign /*output*/ pwm12_numerator   = 0;
		assign /*output*/ pwm12_denominator = 0;
	end
	/// convert interface pwm13 to pwm[13]
	if (C_PWM_NBR > 13) begin: pwm13_to_array
		assign pwm_def[13] = /*input*/ pwm13_def;
		assign /*config*/ pwm13_en          = pwm_en         [13];
		assign /*config*/ pwm13_numerator   = pwm_numerator  [13];
		assign /*config*/ pwm13_denominator = pwm_denominator[13];
	end
	else begin
		assign /*output*/ pwm13_en          = 0;
		assign /*output*/ pwm13_numerator   = 0;
		assign /*output*/ pwm13_denominator = 0;
	end
	/// convert interface pwm14 to pwm[14]
	if (C_PWM_NBR > 14) begin: pwm14_to_array
		assign pwm_def[14] = /*input*/ pwm14_def;
		assign /*config*/ pwm14_en          = pwm_en         [14];
		assign /*config*/ pwm14_numerator   = pwm_numerator  [14];
		assign /*config*/ pwm14_denominator = pwm_denominator[14];
	end
	else begin
		assign /*output*/ pwm14_en          = 0;
		assign /*output*/ pwm14_numerator   = 0;
		assign /*output*/ pwm14_denominator = 0;
	end
	/// convert interface pwm15 to pwm[15]
	if (C_PWM_NBR > 15) begin: pwm15_to_array
		assign pwm_def[15] = /*input*/ pwm15_def;
		assign /*config*/ pwm15_en          = pwm_en         [15];
		assign /*config*/ pwm15_numerator   = pwm_numerator  [15];
		assign /*config*/ pwm15_denominator = pwm_denominator[15];
	end
	else begin
		assign /*output*/ pwm15_en          = 0;
		assign /*output*/ pwm15_numerator   = 0;
		assign /*output*/ pwm15_denominator = 0;
	end
	for (i = 0; i < C_PWM_NBR; i=i+1) begin: sync_cfg_for_pwm
	end
	/// convert interface reqctl0 to reqctl[0]
	if (1 > 0) begin: reqctl0_to_array
		assign reqctl_done[0] = /*input*/ reqctl0_done;
		assign reqctl_err [0] = /*input*/ reqctl0_err ;
		assign /*config*/ reqctl0_resetn = reqctl_resetn[0];
		assign /*config*/ reqctl0_en     = reqctl_en    [0];
		assign /*config*/ reqctl0_cmd    = reqctl_cmd   [0];
		assign /*config*/ reqctl0_param  = reqctl_param [0];
	end
	else begin
		assign /*output*/ reqctl0_resetn = 0;
		assign /*output*/ reqctl0_en     = 0;
		assign /*output*/ reqctl0_cmd    = 0;
		assign /*output*/ reqctl0_param  = 0;
	end
	for (i = 0; i < 1; i=i+1) begin: sync_cfg_for_reqctl
		always @ (posedge o_clk) begin
			if (o_resetn == 1'b0)
				int_dly_reqctl_done[i] <= 0;
			else
				int_dly_reqctl_done[i] <= reqctl_done[i];
		end
		always @ (posedge o_clk) begin
			if (o_resetn == 1'b0)
				int_sta_reqctl_done[i] <= 0;
			else if (int_clr_reqctl_done[i])
				int_sta_reqctl_done[i] <= 0;
			else if (int_dly_reqctl_done[i] == 0 && reqctl_done[i] == 1)
				int_sta_reqctl_done[i] <= 1;
		end
	end
	/// convert interface heater0 to heater[0]
	if (1 > 0) begin: heater0_to_array
		assign heater_state[0] = /*input*/ heater0_state;
		assign heater_value[0] = /*input*/ heater0_value;
		assign /*config*/ heater0_resetn     = heater_resetn    [0];
		assign /*config*/ heater0_auto_start = heater_auto_start[0];
		assign /*config*/ heater0_auto_hold  = heater_auto_hold [0];
		assign /*config*/ heater0_holdv      = heater_holdv     [0];
		assign /*config*/ heater0_keepv      = heater_keepv     [0];
		assign /*config*/ heater0_keept      = heater_keept     [0];
		assign /*config*/ heater0_finishv    = heater_finishv   [0];
		assign /*config*/ heater0_start      = heater_start     [0];
		assign /*config*/ heater0_stop       = heater_stop      [0];
	end
	else begin
		assign /*output*/ heater0_resetn     = 0;
		assign /*output*/ heater0_auto_start = 0;
		assign /*output*/ heater0_auto_hold  = 0;
		assign /*output*/ heater0_holdv      = 0;
		assign /*output*/ heater0_keepv      = 0;
		assign /*output*/ heater0_keept      = 0;
		assign /*output*/ heater0_finishv    = 0;
		assign /*output*/ heater0_start      = 0;
		assign /*output*/ heater0_stop       = 0;
	end
	for (i = 0; i < 1; i=i+1) begin: sync_cfg_for_heater
		always @ (posedge o_clk) begin
			if (o_resetn == 1'b0)
				int_dly_heater_state[i] <= 0;
			else
				int_dly_heater_state[i] <= heater_state[i];
		end
		always @ (posedge o_clk) begin
			if (o_resetn == 1'b0)
				int_sta_heater_state[i] <= 0;
			else if (int_clr_heater_state[i])
				int_sta_heater_state[i] <= 0;
			else if (int_dly_heater_state[i] != heater_state[i])
				int_sta_heater_state[i] <= 1;
		end
	end
	/// convert interface extint0 to extint[0]
	if (C_EXT_INT_WIDTH > 0) begin: extint0_to_array
		assign extint_src[0] = /*input*/ extint0_src;
	end
	else begin
	end
	/// convert interface extint1 to extint[1]
	if (C_EXT_INT_WIDTH > 1) begin: extint1_to_array
		assign extint_src[1] = /*input*/ extint1_src;
	end
	else begin
	end
	/// convert interface extint2 to extint[2]
	if (C_EXT_INT_WIDTH > 2) begin: extint2_to_array
		assign extint_src[2] = /*input*/ extint2_src;
	end
	else begin
	end
	/// convert interface extint3 to extint[3]
	if (C_EXT_INT_WIDTH > 3) begin: extint3_to_array
		assign extint_src[3] = /*input*/ extint3_src;
	end
	else begin
	end
	/// convert interface extint4 to extint[4]
	if (C_EXT_INT_WIDTH > 4) begin: extint4_to_array
		assign extint_src[4] = /*input*/ extint4_src;
	end
	else begin
	end
	/// convert interface extint5 to extint[5]
	if (C_EXT_INT_WIDTH > 5) begin: extint5_to_array
		assign extint_src[5] = /*input*/ extint5_src;
	end
	else begin
	end
	/// convert interface extint6 to extint[6]
	if (C_EXT_INT_WIDTH > 6) begin: extint6_to_array
		assign extint_src[6] = /*input*/ extint6_src;
	end
	else begin
	end
	/// convert interface extint7 to extint[7]
	if (C_EXT_INT_WIDTH > 7) begin: extint7_to_array
		assign extint_src[7] = /*input*/ extint7_src;
	end
	else begin
	end
	for (i = 0; i < C_EXT_INT_WIDTH; i=i+1) begin: sync_cfg_for_extint
		always @ (posedge o_clk) begin
			if (o_resetn == 1'b0)
				int_dly_extint_src[i] <= 0;
			else
				int_dly_extint_src[i] <= extint_src[i];
		end
		always @ (posedge o_clk) begin
			if (o_resetn == 1'b0)
				int_sta_extint_src[i] <= 0;
			else if (int_clr_extint_src[i])
				int_sta_extint_src[i] <= 0;
			else if (int_dly_extint_src[i] != extint_src[i])
				int_sta_extint_src[i] <= 1;
		end
	end
	/**********************************************************************
	 *                        section: misc logic                         *
	 **********************************************************************/
	/// register read logic
	reg[C_DATA_WIDTH-1:0] r_rd_data;
	assign rd_data = r_rd_data;
	always @ (posedge o_clk)
		if (rd_en)
			r_rd_data <= slv_reg[rd_addr];
	/// out width/height
	assign out_width  = C_IMG_WDEF;
	assign out_height = C_IMG_HDEF;
	/// st_out_resetn
	assign st_out_resetn = 1;
	/// st_addr
	assign st_addr = C_ST_ADDR;
	/// st width/height
	assign st_width  = out_width;
	assign st_height = out_height;
	/// out_ce
	reg r_stream_en;
	always @ (posedge o_clk) begin
		if (o_resetn == 1'b0)
			r_stream_en <= 0;
		else if (o_fsync)
			r_stream_en <= 1;
	end
	assign out_ce = r_stream_en;
	/// sync register write enable signals
	/// @NOTE: freq_oclk > 4 freq_clk
	reg clk_toggle;
	always @ (posedge clk) begin
		if (resetn == 0)
			clk_toggle <= 0;
		else
			clk_toggle <= ~clk_toggle;
	end
	reg clk_d1;
	reg wr_en_d1;
	reg[C_DATA_WIDTH-1:0]    wr_data_d1;
	reg[C_REG_IDX_WIDTH-1:0] wr_addr_d1;
	always @ (posedge o_clk) begin
		clk_d1     <= clk_toggle;
		wr_en_d1   <= wr_en;
		wr_data_d1 <= wr_data;
		wr_addr_d1 <= wr_addr;
	end
	reg clk_d2;
	reg wr_en_d2;
	reg[C_DATA_WIDTH-1:0]    wr_data_d2;
	reg[C_REG_NUM-1:0]       wr_addr_d2;
	always @ (posedge o_clk) begin
		clk_d2     <= clk_d1;
		wr_en_d2   <= wr_en_d1;
		wr_data_d2 <= wr_data_d1;
		wr_addr_d2 <= wr_addr_d1;
	end
	always @ (posedge o_clk)
		wrd_sync <= wr_data_d2;
	for (i = 0; i < C_REG_NUM; i = i + 1)
		always @ (posedge o_clk)
			wre_sync[i]     <= ((clk_d2 != clk_d1) && (wr_en_d2 && o_resetn) && (wr_addr_d2 == i));
	/// fsync delay
	reg[1:0] fsync_dly;
	always @ (posedge o_clk) begin
		if (o_resetn == 1'b0)
			fsync_dly <= 2'b00;
		else
			fsync_dly[1:0] <= {fsync_dly[0], fsync};
	end
	/// fsync_posedge and update_stream_cfg
	reg fsync_posedge;
	always @ (posedge o_clk) begin
		if (o_resetn == 1'b0) begin
			fsync_posedge     <= 1'b0;
			update_stream_cfg <= 1'b0;
		end
		else if (fsync_dly == 2'b01) begin
			fsync_posedge     <= 1'b1;
			update_stream_cfg <= ~stream_cfging;
		end
		else begin
			fsync_posedge     <= 1'b0;
			update_stream_cfg <= 1'b0;
		end
	end
	/// o_fsync
	/// @NOTE: o_fsync is delay 1 clock comparing with fsync_posedge,
	///        i.e. moving config is appeared same time as assigning o_fsync.
	reg r_o_fsync;
	assign o_fsync = r_o_fsync;
	always @ (posedge o_clk) begin
		if (o_resetn == 1'b0)
			r_o_fsync <= 1'b0;
		else
			r_o_fsync <= fsync_posedge;
	end
	/**********************************************************************
	 *                    section: register definition                    *
	 **********************************************************************/
	/// reg 0 - 0000_0000
	for (i = 0; i < C_STREAM_NBR; i=i+1) begin: reg0define
		always @ (posedge o_clk) begin
			if (o_resetn == 1'b0)
				int_ena_s_wr_done[i] <= 0;
			else if (wre_sync[0])
				int_ena_s_wr_done[i] <= wrd_sync[4*i];
		end
		assign slv_reg[0][4*i] = int_ena_s_wr_done[i];
	end
	/// reg 1 - 0000_0001
	for (i = 0; i < C_STREAM_NBR; i=i+1) begin: reg1define
		assign slv_reg[1][4*i] = int_sta_s_wr_done[i];
	end
	for (i = 0; i < C_STREAM_NBR; i=i+1) begin: loop4int_clr_s_wr_done
		assign int_clr_s_wr_done[i] = wre_sync[1] && wrd_sync[i*4];
	end
	always @ (posedge o_clk) begin
		stream_int <= ((slv_reg[0] & slv_reg[1]) != 0);
	end
	/// reg 2 - 0000_0010
	for (i = 0; i < C_STREAM_NBR; i=i+1) begin: loop4r_s_in_resetn
		always @ (posedge o_clk) begin
			if (o_resetn == 1'b0)
				s_in_resetn[i] <= 0;
			else if (wre_sync[2])
				s_in_resetn[i] <= wrd_sync[i];
		end
		assign slv_reg[2][i] = s_in_resetn[i];
	end
	/// reg 3 - 0000_0011
	for (i = 0; i < C_STREAM_NBR; i=i+1) begin: loop4r_s_fsa_disp_resetn
		always @ (posedge o_clk) begin
			if (o_resetn == 1'b0)
				r_s_fsa_disp_resetn[i] <= 0;
			else if (wre_sync[3])
				r_s_fsa_disp_resetn[i] <= wrd_sync[i];
		end
		assign slv_reg[3][i] = r_s_fsa_disp_resetn[i];
	end
	/// reg 4 - 0000_0100
	always @ (posedge o_clk) begin
		if (o_resetn == 1'b0)
			stream_cfging <= 0;
		else if (wre_sync[4])
			stream_cfging <= wrd_sync[0];
	end
	assign slv_reg[4][0] = stream_cfging;
	/// reg 5 - 0000_0101
	for (i = 0; i < C_STREAM_NBR; i=i+1) begin: reg5define
		always @ (posedge o_clk) begin
			if (o_resetn == 1'b0)
				stream_cfgsel[i] <= 0;
			else if (wre_sync[5])
				stream_cfgsel[i] <= wrd_sync[i];
		end
		assign slv_reg[5][i] = stream_cfgsel[i];
	end
	/// reg 6 - 0000_0110
	reg [C_STREAM_NBR - 1:0] ind_r_s_dst_bmp;
	for (i = 0; i < C_STREAM_NBR; i=i+1) begin: loop4write_ind_r_s_dst_bmp
		always @ (posedge o_clk) begin
			if (o_resetn == 1'b0)
				r_s_dst_bmp[i] <= 0;
			else if (wre_sync[6] && stream_cfgsel[i])
				r_s_dst_bmp[i] <= wrd_sync[C_STREAM_NBR - 1:0];
		end
	end
	/// load to ind reg continuously
	always @ (posedge o_clk) begin
		for (j = 0; j < C_STREAM_NBR; j=j+1) begin: loop4read_ind_r_s_dst_bmp
			if (stream_cfgsel[j])
				ind_r_s_dst_bmp <= r_s_dst_bmp[j];
		end
	end
	assign slv_reg[6][C_STREAM_NBR - 1:0] = ind_r_s_dst_bmp;
	if (C_STREAM_NBR < 32) begin: idle6_0
		assign slv_reg[6][31:C_STREAM_NBR] = 0;
	end
	/// reg 7 - 0000_0111
	reg [C_IMG_HBITS - 1:0] ind_r_s_height;
	for (i = 0; i < C_STREAM_NBR; i=i+1) begin: loop4write_ind_r_s_height
		always @ (posedge o_clk) begin
			if (o_resetn == 1'b0)
				r_s_height[i] <= 0;
			else if (wre_sync[7] && stream_cfgsel[i])
				r_s_height[i] <= wrd_sync[C_IMG_HBITS - 1:0];
		end
	end
	/// load to ind reg continuously
	always @ (posedge o_clk) begin
		for (j = 0; j < C_STREAM_NBR; j=j+1) begin: loop4read_ind_r_s_height
			if (stream_cfgsel[j])
				ind_r_s_height <= r_s_height[j];
		end
	end
	assign slv_reg[7][C_IMG_HBITS - 1:0] = ind_r_s_height;
	if (C_IMG_HBITS < 16) begin: idle7_0
		assign slv_reg[7][15:C_IMG_HBITS] = 0;
	end
	reg [C_IMG_WBITS - 1:0] ind_r_s_width;
	for (i = 0; i < C_STREAM_NBR; i=i+1) begin: loop4write_ind_r_s_width
		always @ (posedge o_clk) begin
			if (o_resetn == 1'b0)
				r_s_width[i] <= 0;
			else if (wre_sync[7] && stream_cfgsel[i])
				r_s_width[i] <= wrd_sync[C_IMG_WBITS + 15:16];
		end
	end
	/// load to ind reg continuously
	always @ (posedge o_clk) begin
		for (j = 0; j < C_STREAM_NBR; j=j+1) begin: loop4read_ind_r_s_width
			if (stream_cfgsel[j])
				ind_r_s_width <= r_s_width[j];
		end
	end
	assign slv_reg[7][C_IMG_WBITS + 15:16] = ind_r_s_width;
	if (C_IMG_WBITS < 16) begin: idle7_16
		assign slv_reg[7][31:C_IMG_WBITS + 16] = 0;
	end
	/// reg 8 - 0000_1000
	reg [C_IMG_HBITS - 1:0] ind_r_s_win_top;
	for (i = 0; i < C_STREAM_NBR; i=i+1) begin: loop4write_ind_r_s_win_top
		always @ (posedge o_clk) begin
			if (o_resetn == 1'b0)
				r_s_win_top[i] <= 0;
			else if (wre_sync[8] && stream_cfgsel[i])
				r_s_win_top[i] <= wrd_sync[C_IMG_HBITS - 1:0];
		end
	end
	/// load to ind reg continuously
	always @ (posedge o_clk) begin
		for (j = 0; j < C_STREAM_NBR; j=j+1) begin: loop4read_ind_r_s_win_top
			if (stream_cfgsel[j])
				ind_r_s_win_top <= r_s_win_top[j];
		end
	end
	assign slv_reg[8][C_IMG_HBITS - 1:0] = ind_r_s_win_top;
	if (C_IMG_HBITS < 16) begin: idle8_0
		assign slv_reg[8][15:C_IMG_HBITS] = 0;
	end
	reg [C_IMG_WBITS - 1:0] ind_r_s_win_left;
	for (i = 0; i < C_STREAM_NBR; i=i+1) begin: loop4write_ind_r_s_win_left
		always @ (posedge o_clk) begin
			if (o_resetn == 1'b0)
				r_s_win_left[i] <= 0;
			else if (wre_sync[8] && stream_cfgsel[i])
				r_s_win_left[i] <= wrd_sync[C_IMG_WBITS + 15:16];
		end
	end
	/// load to ind reg continuously
	always @ (posedge o_clk) begin
		for (j = 0; j < C_STREAM_NBR; j=j+1) begin: loop4read_ind_r_s_win_left
			if (stream_cfgsel[j])
				ind_r_s_win_left <= r_s_win_left[j];
		end
	end
	assign slv_reg[8][C_IMG_WBITS + 15:16] = ind_r_s_win_left;
	if (C_IMG_WBITS < 16) begin: idle8_16
		assign slv_reg[8][31:C_IMG_WBITS + 16] = 0;
	end
	/// reg 9 - 0000_1001
	reg [C_IMG_HBITS - 1:0] ind_r_s_win_height;
	for (i = 0; i < C_STREAM_NBR; i=i+1) begin: loop4write_ind_r_s_win_height
		always @ (posedge o_clk) begin
			if (o_resetn == 1'b0)
				r_s_win_height[i] <= 0;
			else if (wre_sync[9] && stream_cfgsel[i])
				r_s_win_height[i] <= wrd_sync[C_IMG_HBITS - 1:0];
		end
	end
	/// load to ind reg continuously
	always @ (posedge o_clk) begin
		for (j = 0; j < C_STREAM_NBR; j=j+1) begin: loop4read_ind_r_s_win_height
			if (stream_cfgsel[j])
				ind_r_s_win_height <= r_s_win_height[j];
		end
	end
	assign slv_reg[9][C_IMG_HBITS - 1:0] = ind_r_s_win_height;
	if (C_IMG_HBITS < 16) begin: idle9_0
		assign slv_reg[9][15:C_IMG_HBITS] = 0;
	end
	reg [C_IMG_WBITS - 1:0] ind_r_s_win_width;
	for (i = 0; i < C_STREAM_NBR; i=i+1) begin: loop4write_ind_r_s_win_width
		always @ (posedge o_clk) begin
			if (o_resetn == 1'b0)
				r_s_win_width[i] <= 0;
			else if (wre_sync[9] && stream_cfgsel[i])
				r_s_win_width[i] <= wrd_sync[C_IMG_WBITS + 15:16];
		end
	end
	/// load to ind reg continuously
	always @ (posedge o_clk) begin
		for (j = 0; j < C_STREAM_NBR; j=j+1) begin: loop4read_ind_r_s_win_width
			if (stream_cfgsel[j])
				ind_r_s_win_width <= r_s_win_width[j];
		end
	end
	assign slv_reg[9][C_IMG_WBITS + 15:16] = ind_r_s_win_width;
	if (C_IMG_WBITS < 16) begin: idle9_16
		assign slv_reg[9][31:C_IMG_WBITS + 16] = 0;
	end
	/// reg 10 - 0000_1010
	reg [C_IMG_HBITS - 1:0] ind_r_s_dst_top;
	for (i = 0; i < C_STREAM_NBR; i=i+1) begin: loop4write_ind_r_s_dst_top
		always @ (posedge o_clk) begin
			if (o_resetn == 1'b0)
				r_s_dst_top[i] <= 0;
			else if (wre_sync[10] && stream_cfgsel[i])
				r_s_dst_top[i] <= wrd_sync[C_IMG_HBITS - 1:0];
		end
	end
	/// load to ind reg continuously
	always @ (posedge o_clk) begin
		for (j = 0; j < C_STREAM_NBR; j=j+1) begin: loop4read_ind_r_s_dst_top
			if (stream_cfgsel[j])
				ind_r_s_dst_top <= r_s_dst_top[j];
		end
	end
	assign slv_reg[10][C_IMG_HBITS - 1:0] = ind_r_s_dst_top;
	if (C_IMG_HBITS < 16) begin: idle10_0
		assign slv_reg[10][15:C_IMG_HBITS] = 0;
	end
	reg [C_IMG_WBITS - 1:0] ind_r_s_dst_left;
	for (i = 0; i < C_STREAM_NBR; i=i+1) begin: loop4write_ind_r_s_dst_left
		always @ (posedge o_clk) begin
			if (o_resetn == 1'b0)
				r_s_dst_left[i] <= 0;
			else if (wre_sync[10] && stream_cfgsel[i])
				r_s_dst_left[i] <= wrd_sync[C_IMG_WBITS + 15:16];
		end
	end
	/// load to ind reg continuously
	always @ (posedge o_clk) begin
		for (j = 0; j < C_STREAM_NBR; j=j+1) begin: loop4read_ind_r_s_dst_left
			if (stream_cfgsel[j])
				ind_r_s_dst_left <= r_s_dst_left[j];
		end
	end
	assign slv_reg[10][C_IMG_WBITS + 15:16] = ind_r_s_dst_left;
	if (C_IMG_WBITS < 16) begin: idle10_16
		assign slv_reg[10][31:C_IMG_WBITS + 16] = 0;
	end
	/// reg 11 - 0000_1011
	reg [C_IMG_HBITS - 1:0] ind_r_s_dst_height;
	for (i = 0; i < C_STREAM_NBR; i=i+1) begin: loop4write_ind_r_s_dst_height
		always @ (posedge o_clk) begin
			if (o_resetn == 1'b0)
				r_s_dst_height[i] <= 0;
			else if (wre_sync[11] && stream_cfgsel[i])
				r_s_dst_height[i] <= wrd_sync[C_IMG_HBITS - 1:0];
		end
	end
	/// load to ind reg continuously
	always @ (posedge o_clk) begin
		for (j = 0; j < C_STREAM_NBR; j=j+1) begin: loop4read_ind_r_s_dst_height
			if (stream_cfgsel[j])
				ind_r_s_dst_height <= r_s_dst_height[j];
		end
	end
	assign slv_reg[11][C_IMG_HBITS - 1:0] = ind_r_s_dst_height;
	if (C_IMG_HBITS < 16) begin: idle11_0
		assign slv_reg[11][15:C_IMG_HBITS] = 0;
	end
	reg [C_IMG_WBITS - 1:0] ind_r_s_dst_width;
	for (i = 0; i < C_STREAM_NBR; i=i+1) begin: loop4write_ind_r_s_dst_width
		always @ (posedge o_clk) begin
			if (o_resetn == 1'b0)
				r_s_dst_width[i] <= 0;
			else if (wre_sync[11] && stream_cfgsel[i])
				r_s_dst_width[i] <= wrd_sync[C_IMG_WBITS + 15:16];
		end
	end
	/// load to ind reg continuously
	always @ (posedge o_clk) begin
		for (j = 0; j < C_STREAM_NBR; j=j+1) begin: loop4read_ind_r_s_dst_width
			if (stream_cfgsel[j])
				ind_r_s_dst_width <= r_s_dst_width[j];
		end
	end
	assign slv_reg[11][C_IMG_WBITS + 15:16] = ind_r_s_dst_width;
	if (C_IMG_WBITS < 16) begin: idle11_16
		assign slv_reg[11][31:C_IMG_WBITS + 16] = 0;
	end
	/// reg 12 - 0000_1100
	reg [C_BUF_IDX_WIDTH - 1:0] ind_s_rd_buf_idx;
	/// load to ind reg continuously
	always @ (posedge o_clk) begin
		for (j = 0; j < C_STREAM_NBR; j=j+1) begin: loop4read_ind_s_rd_buf_idx
			if (stream_cfgsel[j])
				ind_s_rd_buf_idx <= s_rd_buf_idx[j];
		end
	end
	assign slv_reg[12][C_BUF_IDX_WIDTH - 1:0] = ind_s_rd_buf_idx;
	if (C_BUF_IDX_WIDTH < 32) begin: idle12_0
		assign slv_reg[12][31:C_BUF_IDX_WIDTH] = 0;
	end
	/// reg 13 - 0000_1101
	reg [31:0] ind_s_rd_buf_ts_0;
	/// load to ind reg continuously
	always @ (posedge o_clk) begin
		for (j = 0; j < C_STREAM_NBR; j=j+1) begin: loop4read_ind_s_rd_buf_ts_0
			if (stream_cfgsel[j])
				ind_s_rd_buf_ts_0 <= s_rd_buf_ts[j][31:0];
		end
	end
	assign slv_reg[13][31:0] = ind_s_rd_buf_ts_0;
	/// reg 14 - 0000_1110
	reg [31:0] ind_s_rd_buf_ts_32;
	/// load to ind reg continuously
	always @ (posedge o_clk) begin
		for (j = 0; j < C_STREAM_NBR; j=j+1) begin: loop4read_ind_s_rd_buf_ts_32
			if (stream_cfgsel[j])
				ind_s_rd_buf_ts_32 <= s_rd_buf_ts[j][63:32];
		end
	end
	assign slv_reg[14][31:0] = ind_s_rd_buf_ts_32;
	/// reg 15 - 0000_1111
	reg [C_IMG_WBITS - 1:0] ind_s_lft_v;
	/// load to ind reg continuously
	always @ (posedge o_clk) begin
		for (j = 0; j < C_STREAM_NBR; j=j+1) begin: loop4read_ind_s_lft_v
			if (stream_cfgsel[j])
				ind_s_lft_v <= s_lft_v[j];
		end
	end
	assign slv_reg[15][C_IMG_WBITS - 1:0] = ind_s_lft_v;
	if (C_IMG_WBITS < 16) begin: idle15_0
		assign slv_reg[15][15:C_IMG_WBITS] = 0;
	end
	reg [C_IMG_WBITS - 1:0] ind_s_rt_v;
	/// load to ind reg continuously
	always @ (posedge o_clk) begin
		for (j = 0; j < C_STREAM_NBR; j=j+1) begin: loop4read_ind_s_rt_v
			if (stream_cfgsel[j])
				ind_s_rt_v <= s_rt_v[j];
		end
	end
	assign slv_reg[15][C_IMG_WBITS + 15:16] = ind_s_rt_v;
	if (C_IMG_WBITS < 16) begin: idle15_16
		assign slv_reg[15][31:C_IMG_WBITS + 16] = 0;
	end
	/// reg 16 - 0001_0000
	reg [C_IMG_PBITS - 1:0] ind_r_s_ref_data;
	for (i = 0; i < C_STREAM_NBR; i=i+1) begin: loop4write_ind_r_s_ref_data
		always @ (posedge o_clk) begin
			if (o_resetn == 1'b0)
				r_s_ref_data[i] <= 0;
			else if (wre_sync[16] && stream_cfgsel[i])
				r_s_ref_data[i] <= wrd_sync[C_IMG_PBITS - 1:0];
		end
	end
	/// load to ind reg continuously
	always @ (posedge o_clk) begin
		for (j = 0; j < C_STREAM_NBR; j=j+1) begin: loop4read_ind_r_s_ref_data
			if (stream_cfgsel[j])
				ind_r_s_ref_data <= r_s_ref_data[j];
		end
	end
	assign slv_reg[16][C_IMG_PBITS - 1:0] = ind_r_s_ref_data;
	if (C_IMG_PBITS < 32) begin: idle16_0
		assign slv_reg[16][31:C_IMG_PBITS] = 0;
	end
	/// reg 17 - 0001_0001
	assign slv_reg[17] = 0;
	/// reg 18 - 0001_0010
	assign slv_reg[18] = 0;
	/// reg 19 - 0001_0011
	assign slv_reg[19] = 0;
	/// reg 20 - 0001_0100
	assign slv_reg[20] = 0;
	/// reg 21 - 0001_0101
	assign slv_reg[21] = 0;
	/// reg 22 - 0001_0110
	assign slv_reg[22] = 0;
	/// reg 23 - 0001_0111
	assign slv_reg[23] = 0;
	/// reg 24 - 0001_1000
	assign slv_reg[24] = 0;
	/// reg 25 - 0001_1001
	assign slv_reg[25] = 0;
	/// reg 26 - 0001_1010
	assign slv_reg[26] = 0;
	/// reg 27 - 0001_1011
	assign slv_reg[27] = 0;
	/// reg 28 - 0001_1100
	for (i = 0; i < C_BR_INITOR_NBR; i=i+1) begin: reg28define
		always @ (posedge o_clk) begin
			if (o_resetn == 1'b0)
				br_sel[i] <= 0;
			else if (wre_sync[28])
				br_sel[i] <= wrd_sync[i];
		end
		assign slv_reg[28][i] = br_sel[i];
	end
	/// reg 29 - 0001_1101
	always @ (posedge o_clk) begin
		if (o_resetn == 1'b0)
			br_wrd <= 0;
		else if (wre_sync[29])
			br_wrd <= wrd_sync[C_SPEED_DATA_WIDTH - 1:0];
	end
	always @ (posedge o_clk) begin
		if (o_resetn == 1'b0)
			br_wre <= 0;
		else if (wre_sync[29])
			br_wre <= 1;
		else
			br_wre <= 0;
	end
	assign slv_reg[29] = 0;
	/// reg 30 - 0001_1110
	reg [C_BR_ADDR_WIDTH:0] ind_br_size;
	/// load to ind reg continuously
	always @ (posedge o_clk) begin
		for (j = 0; j < C_BR_INITOR_NBR; j=j+1) begin: loop4read_ind_br_size
			if (br_sel[j])
				ind_br_size <= br_size[j];
		end
	end
	assign slv_reg[30][C_BR_ADDR_WIDTH:0] = ind_br_size;
	/// reg 31 - 0001_1111
	assign slv_reg[31] = 0;
	/// reg 32 - 0010_0000
	for (i = 0; i < C_MOTOR_NBR; i=i+1) begin: reg32define
		always @ (posedge o_clk) begin
			if (o_resetn == 1'b0)
				motor_xen[i] <= 0;
			else if (wre_sync[32])
				motor_xen[i] <= wrd_sync[4*i];
		end
		assign slv_reg[32][4*i] = motor_xen[i];
		always @ (posedge o_clk) begin
			if (o_resetn == 1'b0)
				motor_xrst[i] <= 0;
			else if (wre_sync[32])
				motor_xrst[i] <= wrd_sync[4*i + 1];
		end
		assign slv_reg[32][4*i + 1] = motor_xrst[i];
	end
	/// reg 33 - 0010_0001
	for (i = 0; i < C_MOTOR_NBR; i=i+1) begin: reg33define
		always @ (posedge o_clk) begin
			if (o_resetn == 1'b0)
				int_ena_motor_ntsign[i] <= 0;
			else if (wre_sync[33])
				int_ena_motor_ntsign[i] <= wrd_sync[4*i];
		end
		assign slv_reg[33][4*i] = int_ena_motor_ntsign[i];
		always @ (posedge o_clk) begin
			if (o_resetn == 1'b0)
				int_ena_motor_zpsign[i] <= 0;
			else if (wre_sync[33])
				int_ena_motor_zpsign[i] <= wrd_sync[4*i + 1];
		end
		assign slv_reg[33][4*i + 1] = int_ena_motor_zpsign[i];
		always @ (posedge o_clk) begin
			if (o_resetn == 1'b0)
				int_ena_motor_ptsign[i] <= 0;
			else if (wre_sync[33])
				int_ena_motor_ptsign[i] <= wrd_sync[4*i + 2];
		end
		assign slv_reg[33][4*i + 2] = int_ena_motor_ptsign[i];
		always @ (posedge o_clk) begin
			if (o_resetn == 1'b0)
				int_ena_motor_state[i] <= 0;
			else if (wre_sync[33])
				int_ena_motor_state[i] <= wrd_sync[4*i + 3];
		end
		assign slv_reg[33][4*i + 3] = int_ena_motor_state[i];
	end
	/// reg 34 - 0010_0010
	for (i = 0; i < C_MOTOR_NBR; i=i+1) begin: reg34define
		assign slv_reg[34][4*i] = int_sta_motor_ntsign[i];
		assign slv_reg[34][4*i + 1] = int_sta_motor_zpsign[i];
		assign slv_reg[34][4*i + 2] = int_sta_motor_ptsign[i];
		assign slv_reg[34][4*i + 3] = int_sta_motor_state[i];
	end
	for (i = 0; i < C_MOTOR_NBR; i=i+1) begin: loop4int_clr_motor_motor
		assign int_clr_motor_ntsign[i] = wre_sync[34] && wrd_sync[i*4+0];
		assign int_clr_motor_zpsign[i] = wre_sync[34] && wrd_sync[i*4+1];
		assign int_clr_motor_ptsign[i] = wre_sync[34] && wrd_sync[i*4+2];
		assign int_clr_motor_state[i] = wre_sync[34] && wrd_sync[i*4+3];
	end
	always @ (posedge o_clk) begin
		motor_int <= ((slv_reg[33] & slv_reg[34]) != 0);
	end
	/// reg 35 - 0010_0011
	for (i = 0; i < C_MOTOR_NBR; i=i+1) begin: reg35define
		assign slv_reg[35][4*i] = motor_ntsign[i];
		assign slv_reg[35][4*i + 1] = motor_zpsign[i];
		assign slv_reg[35][4*i + 2] = motor_ptsign[i];
		assign slv_reg[35][4*i + 3] = motor_state[i];
	end
	/// reg 36 - 0010_0100
	for (i = 0; i < C_MOTOR_NBR; i=i+1) begin: reg36define
		always @ (posedge o_clk) begin
			if (o_resetn == 1'b0)
				motor_start[i] <= 0;
			else if (wre_sync[36])
				motor_start[i] <= wrd_sync[4*i];
			else
				motor_start[i] <= 0;
		end
		always @ (posedge o_clk) begin
			if (o_resetn == 1'b0)
				motor_stop[i] <= 0;
			else if (wre_sync[36])
				motor_stop[i] <= wrd_sync[4*i + 1];
			else
				motor_stop[i] <= 0;
		end
	end
	assign slv_reg[36] = 0;
	/// reg 37 - 0010_0101
	for (i = 0; i < C_MOTOR_NBR; i=i+1) begin: reg37define
		always @ (posedge o_clk) begin
			if (o_resetn == 1'b0)
				motor_sel[i] <= 0;
			else if (wre_sync[37])
				motor_sel[i] <= wrd_sync[i];
		end
		assign slv_reg[37][i] = motor_sel[i];
	end
	/// reg 38 - 0010_0110
	reg [C_MICROSTEP_WIDTH - 1:0] ind_motor_ms;
	for (i = 0; i < C_MOTOR_NBR; i=i+1) begin: loop4write_ind_motor_ms
		always @ (posedge o_clk) begin
			if (o_resetn == 1'b0)
				motor_ms[i] <= 0;
			else if (wre_sync[38] && motor_sel[i])
				motor_ms[i] <= wrd_sync[C_MICROSTEP_WIDTH - 1:0];
		end
	end
	/// load to ind reg continuously
	always @ (posedge o_clk) begin
		for (j = 0; j < C_MOTOR_NBR; j=j+1) begin: loop4read_ind_motor_ms
			if (motor_sel[j])
				ind_motor_ms <= motor_ms[j];
		end
	end
	assign slv_reg[38][C_MICROSTEP_WIDTH - 1:0] = ind_motor_ms;
	if (C_MICROSTEP_WIDTH < 32) begin: idle38_0
		assign slv_reg[38][31:C_MICROSTEP_WIDTH] = 0;
	end
	/// reg 39 - 0010_0111
	reg [C_STEP_NUMBER_WIDTH - 1:0] ind_motor_min_pos;
	for (i = 0; i < C_MOTOR_NBR; i=i+1) begin: loop4write_ind_motor_min_pos
		always @ (posedge o_clk) begin
			if (o_resetn == 1'b0)
				motor_min_pos[i] <= 0;
			else if (wre_sync[39] && motor_sel[i])
				motor_min_pos[i] <= wrd_sync[C_STEP_NUMBER_WIDTH - 1:0];
		end
	end
	/// load to ind reg continuously
	always @ (posedge o_clk) begin
		for (j = 0; j < C_MOTOR_NBR; j=j+1) begin: loop4read_ind_motor_min_pos
			if (motor_sel[j])
				ind_motor_min_pos <= motor_min_pos[j];
		end
	end
	assign slv_reg[39][C_STEP_NUMBER_WIDTH - 1:0] = ind_motor_min_pos;
	if (C_STEP_NUMBER_WIDTH < 32) begin: idle39_0
		assign slv_reg[39][31:C_STEP_NUMBER_WIDTH] = 0;
	end
	/// reg 40 - 0010_1000
	reg [C_STEP_NUMBER_WIDTH - 1:0] ind_motor_max_pos;
	for (i = 0; i < C_MOTOR_NBR; i=i+1) begin: loop4write_ind_motor_max_pos
		always @ (posedge o_clk) begin
			if (o_resetn == 1'b0)
				motor_max_pos[i] <= 0;
			else if (wre_sync[40] && motor_sel[i])
				motor_max_pos[i] <= wrd_sync[C_STEP_NUMBER_WIDTH - 1:0];
		end
	end
	/// load to ind reg continuously
	always @ (posedge o_clk) begin
		for (j = 0; j < C_MOTOR_NBR; j=j+1) begin: loop4read_ind_motor_max_pos
			if (motor_sel[j])
				ind_motor_max_pos <= motor_max_pos[j];
		end
	end
	assign slv_reg[40][C_STEP_NUMBER_WIDTH - 1:0] = ind_motor_max_pos;
	if (C_STEP_NUMBER_WIDTH < 32) begin: idle40_0
		assign slv_reg[40][31:C_STEP_NUMBER_WIDTH] = 0;
	end
	/// reg 41 - 0010_1001
	reg ind_motor_abs;
	for (i = 0; i < C_MOTOR_NBR; i=i+1) begin: loop4write_ind_motor_abs
		always @ (posedge o_clk) begin
			if (o_resetn == 1'b0)
				motor_abs[i] <= 0;
			else if (wre_sync[41] && motor_sel[i])
				motor_abs[i] <= wrd_sync[0];
		end
	end
	/// load to ind reg continuously
	always @ (posedge o_clk) begin
		for (j = 0; j < C_MOTOR_NBR; j=j+1) begin: loop4read_ind_motor_abs
			if (motor_sel[j])
				ind_motor_abs <= motor_abs[j];
		end
	end
	assign slv_reg[41][0] = ind_motor_abs;
	if (1 < 32) begin: idle41_0
		assign slv_reg[41][31:1] = 0;
	end
	/// reg 42 - 0010_1010
	reg [C_STEP_NUMBER_WIDTH - 1:0] ind_motor_step;
	for (i = 0; i < C_MOTOR_NBR; i=i+1) begin: loop4write_ind_motor_step
		always @ (posedge o_clk) begin
			if (o_resetn == 1'b0)
				motor_step[i] <= 0;
			else if (wre_sync[42] && motor_sel[i])
				motor_step[i] <= wrd_sync[C_STEP_NUMBER_WIDTH - 1:0];
		end
	end
	/// load to ind reg continuously
	always @ (posedge o_clk) begin
		for (j = 0; j < C_MOTOR_NBR; j=j+1) begin: loop4read_ind_motor_step
			if (motor_sel[j])
				ind_motor_step <= motor_step[j];
		end
	end
	assign slv_reg[42][C_STEP_NUMBER_WIDTH - 1:0] = ind_motor_step;
	if (C_STEP_NUMBER_WIDTH < 32) begin: idle42_0
		assign slv_reg[42][31:C_STEP_NUMBER_WIDTH] = 0;
	end
	/// reg 43 - 0010_1011
	reg [C_SPEED_DATA_WIDTH - 1:0] ind_motor_speed;
	for (i = 0; i < C_MOTOR_NBR; i=i+1) begin: loop4write_ind_motor_speed
		always @ (posedge o_clk) begin
			if (o_resetn == 1'b0)
				motor_speed[i] <= 0;
			else if (wre_sync[43] && motor_sel[i])
				motor_speed[i] <= wrd_sync[C_SPEED_DATA_WIDTH - 1:0];
		end
	end
	/// load to ind reg continuously
	always @ (posedge o_clk) begin
		for (j = 0; j < C_MOTOR_NBR; j=j+1) begin: loop4read_ind_motor_speed
			if (motor_sel[j])
				ind_motor_speed <= motor_speed[j];
		end
	end
	assign slv_reg[43][C_SPEED_DATA_WIDTH - 1:0] = ind_motor_speed;
	if (C_SPEED_DATA_WIDTH < 32) begin: idle43_0
		assign slv_reg[43][31:C_SPEED_DATA_WIDTH] = 0;
	end
	/// reg 44 - 0010_1100
	assign slv_reg[44] = 0;
	/// reg 45 - 0010_1101
	assign slv_reg[45] = 0;
	/// reg 46 - 0010_1110
	assign slv_reg[46] = 0;
	/// reg 47 - 0010_1111
	assign slv_reg[47] = 0;
	/// reg 48 - 0011_0000
	for (i = 0; i < C_PWM_NBR; i=i+1) begin: reg48define
		assign slv_reg[48][i] = pwm_def[i];
	end
	/// reg 49 - 0011_0001
	for (i = 0; i < C_PWM_NBR; i=i+1) begin: reg49define
		always @ (posedge o_clk) begin
			if (o_resetn == 1'b0)
				pwm_en[i] <= 0;
			else if (wre_sync[49])
				pwm_en[i] <= wrd_sync[i];
		end
		assign slv_reg[49][i] = pwm_en[i];
	end
	/// reg 50 - 0011_0010
	for (i = 0; i < C_PWM_NBR; i=i+1) begin: reg50define
		always @ (posedge o_clk) begin
			if (o_resetn == 1'b0)
				pwm_sel[i] <= 0;
			else if (wre_sync[50])
				pwm_sel[i] <= wrd_sync[i];
		end
		assign slv_reg[50][i] = pwm_sel[i];
	end
	/// reg 51 - 0011_0011
	reg [C_PWM_CNT_WIDTH - 1:0] ind_pwm_denominator;
	for (i = 0; i < C_PWM_NBR; i=i+1) begin: loop4write_ind_pwm_denominator
		always @ (posedge o_clk) begin
			if (o_resetn == 1'b0)
				pwm_denominator[i] <= 0;
			else if (wre_sync[51] && pwm_sel[i])
				pwm_denominator[i] <= wrd_sync[C_PWM_CNT_WIDTH - 1:0];
		end
	end
	/// load to ind reg continuously
	always @ (posedge o_clk) begin
		for (j = 0; j < C_PWM_NBR; j=j+1) begin: loop4read_ind_pwm_denominator
			if (pwm_sel[j])
				ind_pwm_denominator <= pwm_denominator[j];
		end
	end
	assign slv_reg[51][C_PWM_CNT_WIDTH - 1:0] = ind_pwm_denominator;
	if (C_PWM_CNT_WIDTH < 32) begin: idle51_0
		assign slv_reg[51][31:C_PWM_CNT_WIDTH] = 0;
	end
	/// reg 52 - 0011_0100
	reg [C_PWM_CNT_WIDTH - 1:0] ind_pwm_numerator;
	for (i = 0; i < C_PWM_NBR; i=i+1) begin: loop4write_ind_pwm_numerator
		always @ (posedge o_clk) begin
			if (o_resetn == 1'b0)
				pwm_numerator[i] <= 0;
			else if (wre_sync[52] && pwm_sel[i])
				pwm_numerator[i] <= wrd_sync[C_PWM_CNT_WIDTH - 1:0];
		end
	end
	/// load to ind reg continuously
	always @ (posedge o_clk) begin
		for (j = 0; j < C_PWM_NBR; j=j+1) begin: loop4read_ind_pwm_numerator
			if (pwm_sel[j])
				ind_pwm_numerator <= pwm_numerator[j];
		end
	end
	assign slv_reg[52][C_PWM_CNT_WIDTH - 1:0] = ind_pwm_numerator;
	if (C_PWM_CNT_WIDTH < 32) begin: idle52_0
		assign slv_reg[52][31:C_PWM_CNT_WIDTH] = 0;
	end
	/// reg 53 - 0011_0101
	assign slv_reg[53] = 0;
	/// reg 54 - 0011_0110
	assign slv_reg[54] = 0;
	/// reg 55 - 0011_0111
	assign slv_reg[55] = 0;
	/// reg 56 - 0011_1000
	assign slv_reg[56][0] = stream_int;
	assign slv_reg[56][1] = motor_int;
	assign slv_reg[56][2] = reqctl_int;
	assign slv_reg[56][3] = heater_int;
	assign slv_reg[56][4] = ext_int;
	assign intr = (slv_reg[56] != 0);
	/// reg 57 - 0011_1001
	assign slv_reg[57] = 0;
	/// reg 58 - 0011_1010
	assign slv_reg[58] = 0;
	/// reg 59 - 0011_1011
	assign slv_reg[59] = 0;
	/// reg 60 - 0011_1100
	assign slv_reg[60] = 0;
	/// reg 61 - 0011_1101
	assign slv_reg[61] = 0;
	/// reg 62 - 0011_1110
	assign slv_reg[62] = 0;
	/// reg 63 - 0011_1111
	assign slv_reg[63] = 0;
	/// reg 64 - 0100_0000
	always @ (posedge o_clk) begin
		if (o_resetn == 1'b0)
			reqctl_resetn[0] <= 0;
		else if (wre_sync[64])
			reqctl_resetn[0] <= wrd_sync[0];
	end
	assign slv_reg[64][0] = reqctl_resetn[0];
	/// reg 65 - 0100_0001
	for (i = 0; i < 1; i=i+1) begin: reg65define
		always @ (posedge o_clk) begin
			if (o_resetn == 1'b0)
				int_ena_reqctl_done[i] <= 0;
			else if (wre_sync[65])
				int_ena_reqctl_done[i] <= wrd_sync[i];
		end
		assign slv_reg[65][i] = int_ena_reqctl_done[i];
	end
	/// reg 66 - 0100_0010
	for (i = 0; i < 1; i=i+1) begin: reg66define
		assign slv_reg[66][i] = int_sta_reqctl_done[i];
	end
	for (i = 0; i < 1; i=i+1) begin: loop4int_clr_reqctl_done
		assign int_clr_reqctl_done[i] = wre_sync[66] && wrd_sync[i];
	end
	always @ (posedge o_clk) begin
		reqctl_int <= ((slv_reg[65] & slv_reg[66]) != 0);
	end
	/// reg 67 - 0100_0011
	assign slv_reg[67][31:0] = reqctl_err[0];
	/// reg 68 - 0100_0100
	always @ (posedge o_clk) begin
		if (o_resetn == 1'b0)
			reqctl_cmd[0] <= 0;
		else if (wre_sync[68])
			reqctl_cmd[0] <= wrd_sync[31:0];
	end
	assign slv_reg[68][31:0] = reqctl_cmd[0];
	/// note: issue command just when write command
	always @ (posedge o_clk) begin
		if (o_resetn == 1'b0)
			reqctl_en[0] <= 0;
		else if (wre_sync[68])
			reqctl_en[0] <= 1;
		else
			reqctl_en[0] <= 0;
	end
	/// reg 69 - 0100_0101
	always @ (posedge o_clk) begin
		if (o_resetn == 1'b0)
			reqctl_param[0][31:0] <= 0;
		else if (wre_sync[69])
			reqctl_param[0][31:0] <= wrd_sync[31:0];
	end
	assign slv_reg[69][31:0] = reqctl_param[0][31:0];
	/// reg 70 - 0100_0110
	always @ (posedge o_clk) begin
		if (o_resetn == 1'b0)
			reqctl_param[0][63:32] <= 0;
		else if (wre_sync[70])
			reqctl_param[0][63:32] <= wrd_sync[31:0];
	end
	assign slv_reg[70][31:0] = reqctl_param[0][63:32];
	/// reg 71 - 0100_0111
	always @ (posedge o_clk) begin
		if (o_resetn == 1'b0)
			reqctl_param[0][95:64] <= 0;
		else if (wre_sync[71])
			reqctl_param[0][95:64] <= wrd_sync[31:0];
	end
	assign slv_reg[71][31:0] = reqctl_param[0][95:64];
	/// reg 72 - 0100_1000
	always @ (posedge o_clk) begin
		if (o_resetn == 1'b0)
			reqctl_param[0][127:96] <= 0;
		else if (wre_sync[72])
			reqctl_param[0][127:96] <= wrd_sync[31:0];
	end
	assign slv_reg[72][31:0] = reqctl_param[0][127:96];
	/// reg 73 - 0100_1001
	always @ (posedge o_clk) begin
		if (o_resetn == 1'b0)
			reqctl_param[0][159:128] <= 0;
		else if (wre_sync[73])
			reqctl_param[0][159:128] <= wrd_sync[31:0];
	end
	assign slv_reg[73][31:0] = reqctl_param[0][159:128];
	assign slv_reg[74] = 0;
	assign slv_reg[75] = 0;
	/// reg 76 - 0100_1100
	for (i = 0; i < C_EXT_INT_WIDTH; i=i+1) begin: reg76define
		always @ (posedge o_clk) begin
			if (o_resetn == 1'b0)
				int_ena_extint_src[i] <= 0;
			else if (wre_sync[76])
				int_ena_extint_src[i] <= wrd_sync[i];
		end
		assign slv_reg[76][i] = int_ena_extint_src[i];
	end
	/// reg 77 - 0100_1101
	for (i = 0; i < C_EXT_INT_WIDTH; i=i+1) begin: reg77define
		assign slv_reg[77][i] = int_sta_extint_src[i];
	end
	for (i = 0; i < C_EXT_INT_WIDTH; i=i+1) begin: loop4int_clr_extint_src
		assign int_clr_extint_src[i] = wre_sync[77] && wrd_sync[i];
	end
	always @ (posedge o_clk) begin
		ext_int <= ((slv_reg[76] & slv_reg[77]) != 0);
	end
	/// reg 78 - 0100_1110
	for (i = 0; i < C_EXT_INT_WIDTH; i=i+1) begin: reg78define
		assign slv_reg[78][i] = extint_src[i];
	end
	/// reg 79 - 0100_1111
	assign slv_reg[79] = 0;
	/// reg 80 - 0101_0000
	always @ (posedge o_clk) begin
		if (o_resetn == 1'b0)
			heater_resetn[0] <= 0;
		else if (wre_sync[80])
			heater_resetn[0] <= wrd_sync[0];
	end
	assign slv_reg[80][0] = heater_resetn[0];
	/// reg 81 - 0101_0001
	for (i = 0; i < 1; i=i+1) begin: reg81define
		always @ (posedge o_clk) begin
			if (o_resetn == 1'b0)
				int_ena_heater_state[i] <= 0;
			else if (wre_sync[81])
				int_ena_heater_state[i] <= wrd_sync[i];
		end
		assign slv_reg[81][i] = int_ena_heater_state[i];
	end
	/// reg 82 - 0101_0010
	for (i = 0; i < 1; i=i+1) begin: reg82define
		assign slv_reg[82][i] = int_sta_heater_state[i];
	end
	for (i = 0; i < 1; i=i+1) begin: loop4int_clr_heater_state
		assign int_clr_heater_state[i] = wre_sync[82] && wrd_sync[i];
	end
	always @ (posedge o_clk) begin
		heater_int <= ((slv_reg[81] & slv_reg[82]) != 0);
	end
	/// reg 83 - 0101_0011
	assign slv_reg[83][1:0] = heater_state[0];
	/// reg 84 - 0101_0100
	assign slv_reg[84][31:0] = heater_value[0];
	/// reg 85 - 0101_0101
	always @ (posedge o_clk) begin
		if (o_resetn == 1'b0)
			heater_auto_start[0] <= 0;
		else if (wre_sync[85])
			heater_auto_start[0] <= wrd_sync[0];
	end
	assign slv_reg[85][0] = heater_auto_start[0];
	always @ (posedge o_clk) begin
		if (o_resetn == 1'b0)
			heater_auto_hold[0] <= 0;
		else if (wre_sync[85])
			heater_auto_hold[0] <= wrd_sync[1];
	end
	assign slv_reg[85][1] = heater_auto_hold[0];
	assign slv_reg[85][31:2] = 0;
	/// reg 86 - 0101_0110
	always @ (posedge o_clk) begin
		if (o_resetn == 1'b0)
			heater_holdv[0] <= 0;
		else if (wre_sync[86])
			heater_holdv[0] <= wrd_sync[C_HEAT_VALUE_WIDTH - 1:0];
	end
	assign slv_reg[86][C_HEAT_VALUE_WIDTH - 1:0] = heater_holdv[0];
	assign slv_reg[86][31:C_HEAT_VALUE_WIDTH] = 0;
	/// reg 87 - 0101_0111
	always @ (posedge o_clk) begin
		if (o_resetn == 1'b0)
			heater_keepv[0] <= 0;
		else if (wre_sync[87])
			heater_keepv[0] <= wrd_sync[C_HEAT_VALUE_WIDTH - 1:0];
	end
	assign slv_reg[87][C_HEAT_VALUE_WIDTH - 1:0] = heater_keepv[0];
	assign slv_reg[87][31:C_HEAT_VALUE_WIDTH] = 0;
	/// reg 88 - 0101_1000
	if (C_HEAT_TIME_WIDTH < 32) begin: reg88_l32
		always @ (posedge o_clk) begin
			if (o_resetn == 1'b0)
				heater_keept[0] <= 0;
			else if (wre_sync[88])
				heater_keept[0] <= wrd_sync[C_HEAT_TIME_WIDTH - 1:0];
		end
		assign slv_reg[88][C_HEAT_TIME_WIDTH - 1:0] = heater_keept[0];
		assign slv_reg[88][31:C_HEAT_TIME_WIDTH] = 0;
	end
	else begin
		always @ (posedge o_clk) begin
			if (o_resetn == 1'b0)
				heater_keept[0][31:0] <= 0;
			else if (wre_sync[88])
				heater_keept[0][31:0] <= wrd_sync[31:0];
		end
		assign slv_reg[88][31:0] = heater_keept[0][31:0];
	end
	/// reg 89 - 0101_1001
	if (C_HEAT_TIME_WIDTH <= 32) begin: reg89_le32
	assign slv_reg[89] = 0;
	end
	else if (C_HEAT_TIME_WIDTH < 64) begin: reg89_l64
		always @ (posedge o_clk) begin
			if (o_resetn == 1'b0)
				heater_keept[0][C_HEAT_TIME_WIDTH-1:32] <= 0;
			else if (wre_sync[89])
				heater_keept[0][C_HEAT_TIME_WIDTH-1:32] <= wrd_sync[C_HEAT_TIME_WIDTH - 33:0];
		end
		assign slv_reg[89][C_HEAT_TIME_WIDTH - 33:0] = heater_keept[0][C_HEAT_TIME_WIDTH-1:32];
		assign slv_reg[89][31:C_HEAT_TIME_WIDTH-32] = 0;
	end
	else begin
		always @ (posedge o_clk) begin
			if (o_resetn == 1'b0)
				heater_keept[0][63:32] <= 0;
			else if (wre_sync[89])
				heater_keept[0][63:32] <= wrd_sync[31:0];
		end
		assign slv_reg[89][31:0] = heater_keept[0][63:32];
	end
	/// reg 90 - 0101_1010
	always @ (posedge o_clk) begin
		if (o_resetn == 1'b0)
			heater_finishv[0] <= 0;
		else if (wre_sync[90])
			heater_finishv[0] <= wrd_sync[C_HEAT_VALUE_WIDTH - 1:0];
	end
	assign slv_reg[90][C_HEAT_VALUE_WIDTH - 1:0] = heater_finishv[0];
	assign slv_reg[90][31:C_HEAT_VALUE_WIDTH] = 0;
	/// reg 91 - 0101_1011
	always @ (posedge o_clk) begin
		if (o_resetn == 1'b0)
			heater_start[0] <= 0;
		else if (wre_sync[91])
			heater_start[0] <= wrd_sync[0];
		else
			heater_start[0] <= 0;
	end
	always @ (posedge o_clk) begin
		if (o_resetn == 1'b0)
			heater_stop[0] <= 0;
		else if (wre_sync[91])
			heater_stop[0] <= wrd_sync[1];
		else
			heater_stop[0] <= 0;
	end
	assign slv_reg[91] = 0;
	assign slv_reg[92] = 0;
	assign slv_reg[93] = 0;
	assign slv_reg[94] = 0;
	assign slv_reg[95] = 0;
	assign slv_reg[96] = 0;
	assign slv_reg[97] = 0;
	/// reg 98 - 0110_0010
	assign slv_reg[98][31:0] = test0;
	/// reg 99 - 0110_0011
	assign slv_reg[99][31:0] = test1;
	/// reg 100 - 0110_0100
	assign slv_reg[100][31:0] = test2;
	/// reg 101 - 0110_0101
	assign slv_reg[101][31:0] = test3;
	/// reg 102 - 0110_0110
	assign slv_reg[102][31:0] = test4;
	/// reg 103 - 0110_0111
	assign slv_reg[103][31:0] = test5;
	/// reg 104 - 0110_1000
	assign slv_reg[104][31:0] = test6;
	/// reg 105 - 0110_1001
	assign slv_reg[105][31:0] = test7;
	/// remain regs from 106-C_REG_NUM
	for (i = 106; i < C_REG_NUM; i=i+1) begin: remain_regs
		assign slv_reg[i] = 0;
	end
	endgenerate
endmodule
