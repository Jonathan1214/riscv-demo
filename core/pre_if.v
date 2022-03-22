// =============================================================================
// @File         :  pre_if.v
// @Author       :  Jiangxuan Li
// @Created      :  2022/3/20 21:38:04
// @Description  :  pre if
// 
// -----------------------------------------------------------------------------
// History
// -----------------------------------------------------------------------------
// Ver  :| Author  :| Mod. Date          :| Changes Made :|
// 0.1   | Jx L     | 2022/3/20 21:38:04 | original
// =============================================================================
`include "include.h"

module pre_if (
	 input  	clk    // Clock
	,input  	rst_n

	,input  	[31:0] nextpc
	,output reg [31:0] pc
);



always @(posedge clk or negedge rst_n) begin
	// 2022/3/20 21:41:12
	// 初始化位置应该是可以选择的
	if (rst_n == 1'b0)
		pc <= 0;
	else
		pc <= nextpc;
end


endmodule
