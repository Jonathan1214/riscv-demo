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

// for branch
	,input  [31:0] pc
	,output [31:0] nx_pc

	,input  [31:0] instr

// write regfile
	,input  [ 4:0] waddr
	,input  reg_wen
	,input  [31:0] wdata

// for alu
	,output [31:0] src1
	,output [31:0] src2
	,output [31:0] imm

// rd for R type
	,output [ 4:0] ds_rd

// control signals
	,output [11:0] alu_control
	,output [ 5:0] ds_ctrl
);

assign nx_pc = pc;

wire [4:0] rs1;
wire [4:0] rs2;
wire [2:0] funct3;
wire [6:0] funct7;
wire [6:0] opcode;

assign rs2    = instr[24:20];
assign rs1    = instr[19:15];
assign rd     = instr[11:7 ];
assign funct3 = instr[14:12];
assign funct7 = instr[31:25];
assign opcode = instr[ 6:0 ];

// decoder
wire [  7:0] funct3_d;
wire [127:0] funct7_d;
wire [127:0] op_d;

// 2022/4/30 21:59:14
// 指令译码，选择最简单的方式
decoder_2_8   U_dec_funct3 (.in(funct3), .out(funct3_d));
decoder_7_128 U_dec_funct7 (.in(funct7), .out(funct7_d));
decoder_7_128 U_dec_opcode (.in(opcode), .out(op_d));

wire [11:0] imm_I;
wire [11:0] imm_S;
wire [12:0] imm_B;
wire [19:0] imm_U;
wire [19:0] imm_J;

wire R_type;
wire I_type;
wire S_type;
wire B_type;
wire U_type;
wire J_type;

// 立即数选择
assign imm_I  = instr[31:20];											// I type
assign imm_S  = {instr[31:25], instr[11:7]};							// S type
assign imm_B  = {instr[31], instr[7], instr[30:25], instr[11:8], 1'b0}; // B type
assign imm_U  = instr[31:12];											// U type
assign imm_J  = {instr[31], instr[19:12], instr[20], instr[30:21]};		// J type

assign R_type = op_d[7'h33];
// 立即数类型
assign I_type = op_d[7'h03]   | op_d[7'h0F] | op_d[7'h13]
				| (op_d[7'h23] & funct3_d[3'b011]) | op_d[7'h67] | op_d[7'h73];
assign S_type = op_d[7'h23] & ~funct3_d[3'b011];
assign B_type = op_d[7'h63];
assign U_type = op_d[7'h37] | op_d[7'h17];
assign J_type = op_d[7'h6F];

// output imm
// sign-extend
assign imm =  ({32{I_type}} & {{20{imm_I[11]}}, imm_I})
			| ({32{S_type}} & {{20{imm_S[11]}}, imm_S});

// 2022/3/22 23:18:06
// TODO 添加更多控制逻辑
// 2022/4/30 17:04:33
// 译码阶段需要产生控制逻辑
wire op_add;	//! 加法操作
wire op_sub;	//! 减法操作
wire op_slt;	//! 有符号比较，小于置位
wire op_sltu;	//! 无符号比较，小于置位
wire op_and;	//! 按位与
wire op_nor;	//! 按位或非
wire op_or;		//! 按位或
wire op_xor;	//! 按位异或
wire op_sll;	//! 逻辑左移
wire op_srl; 	//! 逻辑右移
wire op_sra;	//! 算术右移
wire op_lui;	//! 高位加载

assign  alu_control[ 0] = op_add ;
assign  alu_control[ 1] = op_sub ;
assign  alu_control[ 2] = op_slt ;
assign  alu_control[ 3] = op_sltu;
assign  alu_control[ 4] = op_and ;
assign  alu_control[ 5] = op_nor ;
assign  alu_control[ 6] = op_or  ;
assign  alu_control[ 7] = op_xor ;
assign  alu_control[ 8] = op_sll ;
assign  alu_control[ 9] = op_srl ;
assign  alu_control[10] = op_sra ;
assign  alu_control[11] = op_lui ;

wire inst_lw  = funct3_d[3'b010] & op_d[7'h03];
wire inst_sw  = funct3_d[3'b010] & op_d[7'h23];
wire inst_beq = funct3_d[3'b000] & op_d[7'h63];
wire inst_add = funct3_d[3'b000] & op_d[7'h33] & funct7_d[7'h00];
wire inst_sub = funct3_d[3'b000] & op_d[7'h33] & funct7_d[7'h20];
wire inst_and = funct3_d[3'b111] & op_d[7'h33] & funct7_d[7'h00];
wire inst_or  = funct3_d[3'b110] & op_d[7'h33] & funct7_d[7'h00];

assign op_add = inst_lw  | inst_sw | inst_add;
assign op_sub = inst_sub | inst_beq;
assign op_and = inst_add;
assign op_or  = inst_or;


// 2022/5/1 15:30:26
// 生成其他控制信号
wire branch;		// branch
wire mem_read;		// data ram read
wire mem_write;     // data ram write
wire mem2reg;       // if data writen to regfile comes from data ram
wire alu_src_op;	// select src2 for alu
wire reg_write;		// regfile write enable

assign branch		= inst_beq;
assign mem_read		= inst_lw;
assign mem_write	= inst_sw;
assign mem2reg		= inst_lw;
assign alu_src_op   = inst_lw | inst_sw;
assign reg_write  	= R_type  | inst_lw;

assign ds_ctrl = {branch,
				  mem_read,
				  mem_write,
				  mem2reg,
				  alu_src_op,
				  reg_write
				  };




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

