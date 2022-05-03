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

module wb_stage (
	 input clk    // Clock
	,input rst_n  // Asynchronous reset active low
	
	,input  [31:0] 	ms_mem_out
	,input  [31:0] 	ms_alu_result
	,input  [ 5:0] 	ms_ctrl

	,input  [ 4:0] 	ms_rd

	,output [ 4:0]  ws_rd
	,output 		ws_reg_wen
	,output [31:0]  ws_reg_wdata
);

wire   mem2reg      = ms_ctrl[1];

assign ws_reg_wen   = ms_ctrl[0];
assign ws_reg_wdata = mem2reg == 1'b1 ? ms_mem_out : ms_alu_result;
assign ws_rd        = ms_rd;


endmodule
