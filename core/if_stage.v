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

	,input [31:0] pre_pc
	,input 		  pc_src

	,output [31:0] nx_pc

// 2022/5/2 10:56:34
// 将 inst mem 放到模块外部，增加信号
	// 向下一级传递的信号
	,output [31:0] inst_ram_raddr
);

reg  [31:0] pc;
wire [31:0] n_pc;

assign nx_pc = pc;
// pc 自增值
assign n_pc = pc + 32'd4;

always @(posedge clk or negedge rst_n) begin
	if (rst_n == 1'b1) begin
		pc <= 0;
	end
	else if (pc_src == 1'b1) begin
		pc <= pre_pc;
	end
	else begin
		pc <= n_pc;
	end
end



endmodule
