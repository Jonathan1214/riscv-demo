// =============================================================================
// @File         :  mem_stage.v
// @Author       :  Jiangxuan Li
// @Created      :  2022/5/1 12:00:44
// @Description  :  access memory
// 
// -----------------------------------------------------------------------------
// History
// -----------------------------------------------------------------------------
// Ver  :| Author  :| Mod. Date          :| Changes Made :|
// 0.1   | Jx L     | 2022/5/1 12:00:44 | original
// =============================================================================


module mem_stage (
	 input 			clk    // Clock
	,input 			rst_n  // Asynchronous reset active low

	,input  [31:0]  mem_out_data
	,output [31:0]  ms_mem_out

	,input  [31:0]  es_alu_result
	,output [31:0]  ms_alu_result

// rd for R type
	,input  [ 4:0]  es_rd
	,output [ 4:0]	ms_rd
	
	,input 	[ 5:0] 	es_ctrl
	,input 			zero
	,output 		pc_src

	//- mem stage 寄存的控制信号
	,output [ 5:0]  ms_ctrl
);

wire branch     = es_ctrl[4];
wire mem_read	= es_ctrl[3];
wire mem_write  = es_ctrl[2];

assign ms_mem_out    = mem_out_data;
assign pc_src        = branch & zero;
assign ms_alu_result = es_alu_result;
// 2022/5/2 10:54:58
// 可以将先下一级传递的 ctrl 信号调整更短
assign ms_ctrl = es_ctrl;
assign ms_rd   = es_rd;
// data ram


endmodule
