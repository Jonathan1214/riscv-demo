// =============================================================================
// @File         :  aux.v
// @Author       :  Jiangxuan Li
// @Created      :  2022/4/30 21:37:30
// @Description  :  two aux module
// 
// -----------------------------------------------------------------------------
// History
// -----------------------------------------------------------------------------
// Ver  :| Author  :| Mod. Date          :| Changes Made :|
// 0.1   | Jx L     | 2022/4/30 21:37:30 | original
// =============================================================================

// decoder 3 to 8
module decoder_2_8 (
	input  [2:0] in,
	output [7:0] out
);

genvar i;
generate
	for (i = 0; i < 8; i = i + 1) begin : gen_for_dec_2_8
		assign out[i] = (in == i);
	end
endgenerate

endmodule



// decoder 7 to 128
module decoder_7_128(
	input  [  6:0] in,
	output [127:0] out
);

genvar i;
generate
	for (i = 0; i < 128; i = i + 1) begin : gen_for_dec_7_128
		assign out[i] = (in == i);
	end
endgenerate

endmodule
