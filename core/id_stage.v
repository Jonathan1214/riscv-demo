// =============================================================================
// @File         :  id_stage.v
// @Author       :  Jiangxuan Li
// @Created      :  2022/3/22 22:49:01
// @Description  :  instruction decoding
// 
// -----------------------------------------------------------------------------
// History
// -----------------------------------------------------------------------------
// Ver  :| Author  :| Mod. Date          :| Changes Made :|
// 0.1   | Jx L     | 2022/3/22 22:49:01 | original
// =============================================================================

module id_stage (
	 input  clk    // Clock
	,input  rst_n  // Asynchronous reset active low

	,input  [31:0] instr

	// 延迟之后的写入
	,input  [4 :0] waddr
	,input  wen
	,input  [31:0] wdata

	,output [31:0] src1
	,output [31:0] src2
);

wire [4:0] rs1;
wire [4:0] rs2;
wire [4:0] rd;
wire [2:0] funct3;
wire [6:0] funct7;
wire [6:0] opcode;

wire [11:0] imm_I;
wire [11:0] imm_S;
wire [12:0] imm_B;
wire [19:0] imm_U;
wire [19:0] imm_J;

assign rs2    = instr[24:20];
assign rs1    = instr[19:15];
assign rd     = instr[11:7 ];
assign funct3 = instr[14:12];
assign funct7 = instr[31:25];
assign opcode = instr[6:0];

assign imm_I  = instr[31:20];
assign imm_S  = {instr[31:25], instr[11:7]};
assign imm_B  = {instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
assign imm_U  = instr[31:12];
assign imm_J  = {instr[31], instr[19:12], instr[20], instr[30:21]};


// 2022/3/22 23:18:06
//TODO 添加更多控制逻辑






// 寄存器堆
regfile inst_regfile
	(
		.clk       (clk),
		.rd_addr_1 (rs1),
		.data_o_1  (src1),
		.rd_addr_2 (rs2),
		.data_o_2  (src2),
		.wr_addr   (waddr),
		.wr_en     (wen),
		.wr_data   (wdata)
	);


endmodule

