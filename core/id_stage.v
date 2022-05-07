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
	//- Clock
	//- positive edge
	 input  clk
	,input  rst_n  //- Asynchronous reset active low

// pipeline control
    ,input  fs_valid    //- inst fetch stage valid
    ,input  es_ready    //- exe stage ready
    ,output ds_valid    // inst decoder stage valid
    ,output ds_ready    // inst decoder stage ready

// for branch
	,input  [31:0] fs_inst
	,input  [31:0] fs_pc

// write regfile
	,input  [ 4:0] regfile_waddr
	,input  	   regfile_wen
	,input  [31:0] regfile_wdata

    ,output reg [150:0] ds2es_bus
);

wire [31:0] ds_pc         ;
wire [31:0] ds_src1       ;
wire [31:0] ds_src2       ;
wire [31:0] ds_imm        ;
wire [ 4:0] ds_rd         ;
wire [11:0] ds_alu_control;

//- alu_src_op,     // 5
//- branch    ,     // 4
//- mem_read  ,     // 3
//- mem_write ,     // 2
//- mem2reg   ,     // 1
//- reg_write       // 0
wire [ 5:0] ds_ctrl       ;

assign ds_pc = fs_pc;

wire [4:0] rs1;
wire [4:0] rs2;
wire [4:0] rd;
wire [2:0] funct3;
wire [6:0] funct7;
wire [6:0] opcode;

assign rs2    = fs_inst[24:20];
assign rs1    = fs_inst[19:15];
assign rd     = fs_inst[11:7 ];
assign funct3 = fs_inst[14:12];
assign funct7 = fs_inst[31:25];
assign opcode = fs_inst[ 6:0 ];


assign ds_rd  = rd;

// decoder
wire [  7:0] funct3_d;
wire [127:0] funct7_d;
wire [127:0] op_d;

// 2022/4/30 21:59:14
// 指令译码，选择最简单的方式
decoder_2_8   U_dec_funct3 (.in(funct3), .out(funct3_d));
decoder_7_128 U_dec_funct7 (.in(funct7), .out(funct7_d));
decoder_7_128 U_dec_opcode (.in(opcode), .out(op_d))    ;

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
assign imm_I  = fs_inst[31:20];											// I type
assign imm_S  = {fs_inst[31:25], fs_inst[11:7]};							// S type
assign imm_B  = {fs_inst[31], fs_inst[7], fs_inst[30:25], fs_inst[11:8], 1'b0}; // B type
assign imm_U  = fs_inst[31:12];											// U type
assign imm_J  = {fs_inst[31], fs_inst[19:12], fs_inst[20], fs_inst[30:21]};		// J type

assign R_type = op_d[7'h33]                                       ;
// 立即数类型
assign I_type = op_d[7'h03]   | op_d[7'h0F] | op_d[7'h13]
				| (op_d[7'h23] & funct3_d[3'b011]) | op_d[7'h67] | op_d[7'h73];
assign S_type = op_d[7'h23] & ~funct3_d[3'b011]                   ;
assign B_type = op_d[7'h63]                                       ;
assign U_type = op_d[7'h37] | op_d[7'h17]                         ;
assign J_type = op_d[7'h6F]                                       ;

// output ds_imm
// sign-extend
assign ds_imm =  ({32{I_type}} & {{20{imm_I[11]}}, imm_I})
			| ({32{S_type}} & {{20{imm_S[11]}}, imm_S});

// 2022/3/22 23:18:06
// TODO 添加更多控制逻辑
// 2022/4/30 17:04:33
// 译码阶段需要产生控制逻辑
wire op_add ;	//- 加法操作
wire op_sub ;	//- 减法操作
wire op_slt ;	//- 有符号比较，小于置位
wire op_sltu;	//- 无符号比较，小于置位
wire op_and ;	//- 按位与
wire op_nor ;	//- 按位或非
wire op_or  ;	//- 按位或
wire op_xor ;	//- 按位异或
wire op_sll ;	//- 逻辑左移
wire op_srl ; 	//- 逻辑右移
wire op_sra ;	//- 算术右移
wire op_lui ;	//- 高位加载

wire inst_lw ;
wire inst_sw ;
wire inst_beq;
wire inst_add;
wire inst_sub;
wire inst_and;
wire inst_or ;

assign inst_lw = funct3_d[3'b010] & op_d[7'h03]                  ;
assign inst_sw = funct3_d[3'b010] & op_d[7'h23]                  ;
assign inst_beq= funct3_d[3'b000] & op_d[7'h63]                  ;
assign inst_add= funct3_d[3'b000] & op_d[7'h33] & funct7_d[7'h00];
assign inst_sub= funct3_d[3'b000] & op_d[7'h33] & funct7_d[7'h20];
assign inst_and= funct3_d[3'b111] & op_d[7'h33] & funct7_d[7'h00];
assign inst_or = funct3_d[3'b110] & op_d[7'h33] & funct7_d[7'h00];

assign op_add  = inst_lw  | inst_sw | inst_add;
assign op_sub  = inst_sub | inst_beq          ;
assign op_slt  = 0                            ;
assign op_sltu = 0                            ;
assign op_and  = inst_and                     ;
assign op_nor  = 0                            ;
assign op_or   = inst_or                      ;
assign op_xor  = 0                            ;
assign op_sll  = 0                            ;
assign op_srl  = 0                            ;
assign op_sra  = 0                            ;
assign op_lui  = 0                            ;


assign  ds_alu_control[ 0] = op_add ;
assign  ds_alu_control[ 1] = op_sub ;
assign  ds_alu_control[ 2] = op_slt ;
assign  ds_alu_control[ 3] = op_sltu;
assign  ds_alu_control[ 4] = op_and ;
assign  ds_alu_control[ 5] = op_nor ;
assign  ds_alu_control[ 6] = op_or  ;
assign  ds_alu_control[ 7] = op_xor ;
assign  ds_alu_control[ 8] = op_sll ;
assign  ds_alu_control[ 9] = op_srl ;
assign  ds_alu_control[10] = op_sra ;
assign  ds_alu_control[11] = op_lui ;

// 2022/5/1 15:30:26
// 生成其他控制信号
wire branch    ;		     // branch
wire mem_read  ;		     // data ram read
wire mem_write ;       // data ram write
wire mem2reg   ;       // if data writen to regfile comes from data ram
wire alu_src_op;	      // select ds_src2 for alu
wire reg_write ;		     // regfile write enable

assign alu_src_op   = inst_lw | inst_sw;
assign branch		= inst_beq;
assign mem_read		= inst_lw;
assign mem_write	= inst_sw;
assign mem2reg		= inst_lw;
assign reg_write  	= R_type  | inst_lw;

assign ds_ctrl = {
    alu_src_op,     // 5
    branch    ,     // 4
    mem_read  ,     // 3
    mem_write ,     // 2
    mem2reg   ,     // 1
    reg_write       // 0
};

wire [146:0] ds2es_bus_reg;
assign ds2es_bus_reg = {
    ds_pc         , // 150:119
    ds_src1       , // 118:87
    ds_src2       , // 86:55
    ds_imm        , // 54:23
    ds_rd         , // 22:18
    ds_alu_control, // 17:6
    ds_ctrl         //  5:0
};

reg    ds_ready_pre                                ;
wire   ds_ok_go = 1'b1                             ;
assign ds_ready = !fs_valid || ds_ok_go && es_ready;
assign ds_valid = ds_ready_pre && ds_ok_go         ;

always @(posedge clk or negedge rst_n) begin
    if (rst_n == 1'b0) begin
        ds_ready_pre <= 0;
    end
    else if (ds_ready) begin
        ds_ready_pre <= fs_valid;
    end

    // bus 无需 reset
    if (fs_valid && ds_ready) begin
        ds2es_bus <= ds2es_bus_reg;
    end
end

// 寄存器堆
regfile inst_regfile
	(
		.clk       (clk          ),
		.rd_addr_1 (rs1          ),
		.data_o_1  (ds_src1      ),
		.rd_addr_2 (rs2          ),
		.data_o_2  (ds_src2      ),
		.wr_addr   (regfile_waddr),
		.wr_en     (regfile_wen  ),
		.wr_data   (regfile_wdata)
	);


endmodule

