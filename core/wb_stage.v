// =============================================================================
// @File         :  wb_stage.v
// @Author       :  Jiangxuan Li
// @Created      :  2022/5/1 22:28:59
// @Description  :  write back stage
// 
// -----------------------------------------------------------------------------
// History
// -----------------------------------------------------------------------------
// Ver  :| Author  :| Mod. Date          :| Changes Made :|
// 0.1   | Jx L     | 2022/5/1 22:28:59 | original
// =============================================================================

//- 这一级是个纯组合逻辑了
module wb_stage (
	 input clk    // Clock
	,input rst_n  // Asynchronous reset active low

	,input  [31:0] 	ms_mem_out
    ,input  [37:0]  ms2ws_bus

	,output [ 4:0]  ws_rd
	,output 		ws_reg_wen
	,output [31:0]  ws_reg_wdata
    ,output         ws_ready
);

//- bus 解释
wire [31:0] ms_alu_result;
wire [ 4:0] ms_rd;
wire [ 1:0] ms_ctrl;
assign {
    ms_alu_result,
    ms_rd,
    ms_ctrl
} = ms2ws_bus;

wire   mem2reg      = ms_ctrl[1];
assign ws_reg_wen   = ms_ctrl[0];

assign ws_reg_wdata = mem2reg == 1'b1 ? ms_mem_out : ms_alu_result;
assign ws_rd        = ms_rd;
// 设置为 1，时钟接收前面的数据
assign ws_ready     = 1'b1;

endmodule
