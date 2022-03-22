// =============================================================================
// @File         :  if_stage.v
// @Author       :  Jiangxuan Li
// @Created      :  2022/3/22 22:32:58
// @Description  :  instruction fetching
// 
// -----------------------------------------------------------------------------
// History
// -----------------------------------------------------------------------------
// Ver  :| Author  :| Mod. Date          :| Changes Made :|
// 0.1   | Jx L     | 2022/3/22 22:32:58 | original
// =============================================================================

module if_stage (
	 input clk    // Clock
	,input rst_n  // Asynchronous reset active low

	,input [31:0] pc
	,input ren
	,output reg [31:0] instr

	,input [31:0] wdata
	,input wen
	,input waddr
	
);

memory_md inst_memory_md (
		.clk   (clk),
		.ren   (ren),
		.raddr (pc),
		.wen   (wen),
		.waddr (waddr),
		.wdata (wdata),
		.rdata (instr)
	);



endmodule
