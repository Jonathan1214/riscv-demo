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
	
	,input 			ren

	,input  [31:0]  alu_result

	,input 	[31:0] 	addr
	,input 	[31:0] 	wr_data
	,output [31:0]  mem_out_data
	,output [31:0]  ms_alu_result

// rd for R type
	,input  [ 4:0]  es_rd
	,output [ 4:0]	ms_rd
	
	,input 	[ 5:0] 	es_ctrl
	,input 			pc
	,input 			zero
	,output 		pc_src

	,output [ 5:0]  ms_ctrl
);

wire   branch   	 = es_ctrl[5];
assign pc_src 		 = branch & zero;
assign ms_alu_result = alu_result;
assign ms_ctrl 		 = es_ctrl;

// data ram

localparam DEPTH = 1024;
memory_md #(
		.DEPTH(DEPTH)
	) U_data_mem (
		.clk   (clk),
		.ren   (ren),
		.wen   (wen),
		.addr  (addr),
		.wdata (wr_data),
		.rdata (mem_out_data)
	);


endmodule
