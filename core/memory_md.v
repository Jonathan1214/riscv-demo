// =============================================================================
// @File         :  memory_md.v
// @Author       :  Jiangxuan Li
// @Created      :  2022/3/20 21:08:29
// @Description  :  simple memory module
// 
// -----------------------------------------------------------------------------
// History
// -----------------------------------------------------------------------------
// Ver  :| Author  :| Mod. Date          :| Changes Made :|
// 0.1   | Jx L     | 2022/3/20 21:08:29 | original
// =============================================================================
// `include "include.h"

module memory_md #(
	// 2022/3/20 21:34:23
	// 先设置一个 100 深度的 memo
	parameter DEPTH = 100,
	parameter WIDTH = 32,
	parameter WIDTH_BITS = 30
)(
	 input  	clk    // Clock
	// input rst_n,  // Asynchronous reset active low
	,input   	ren
	,input   	[WIDTH_BITS-1:0] raddr
	,input   	wen
	,input   	[WIDTH_BITS-1:0] waddr
	,input   	[WIDTH-1:0] wdata

	,output reg [WIDTH-1:0] rdata
);



reg [WIDTH-1:0] memo [0:DEPTH-1];

always @(posedge clk) begin
	if (wen == 1'b1)
		memo[waddr] <= wdata;
end

always @(posedge clk) begin
	if (ren == 1'b1)
		rdata <= memo[raddr];
end

endmodule
