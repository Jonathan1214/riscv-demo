// =============================================================================
// @File         :  regfile.v
// @Author       :  Jiangxuan Li
// @Created      :  2022/3/16 21:30:57
// @Description  :  register file
// 
// -----------------------------------------------------------------------------
// History
// -----------------------------------------------------------------------------
// Ver  :| Author  :| Mod. Date          :| Changes Made :|
// 0.1   | Jx L     | 2022/3/16 21:30:57 | original
// =============================================================================

// 2022/3/16 21:39:55
// 这里是否需要复位？

module regfile (
	input clk,    // Clock
	// input rst_n,

	input  [4 :0] rd_addr_1,
	output [31:0] data_o_1,

	input  [4 :0] rd_addr_2,
	output [31:0] data_o_2,

	input  [4 :0] wr_addr,
	input  wr_en,
	input  [31:0] wr_data  
);

reg [31:0] files [0:31];

always @(posedge clk) begin
	if (wr_en == 1'b1)
		files[wr_addr] <= wr_data;
end

assign data_o_1 = rd_addr_1 == 5'd0 ? 32'd0 : files[rd_addr_1];
assign data_o_2 = rd_addr_2 == 5'd0 ? 32'd0 : files[rd_addr_2];


endmodule