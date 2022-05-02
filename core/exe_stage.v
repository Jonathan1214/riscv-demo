// =============================================================================
// @File         :  exe_stage.v
// @Author       :  Jiangxuan Li
// @Created      :  2022/4/30 17:02:03
// @Description  :  exe stage
// 
// -----------------------------------------------------------------------------
// History
// -----------------------------------------------------------------------------
// Ver  :| Author  :| Mod. Date          :| Changes Made :|
// 0.1   | Jx L     | 2022/4/30 17:02:03 | original
// =============================================================================


module exe_stage (
	 input 			clk    // Clock
	,input 			rst_n  // Asynchronous reset active low

	,input  [31:0] 	pc
	,output [31:0] 	nx_pc

	,input  [31:0]  alu_src1
	,input  [31:0]  alu_src2
	,input  [31:0] 	imm

	,input  [11:0] 	alu_control
	,input  [ 5:0] 	ds_ctrl
// rd for R type
	,input  [ 4:0]  ds_rd
	,output [ 4:0]  es_rd 

// for store data to data ram
	,output [31:0]  wr_data
	
	,output [ 5:0] 	es_ctrl
	,output 		zero
	,output [31:0] 	alu_result
);

assign wr_data = alu_src2;
assign es_rd   = ds_rd;

wire branch;		// branch
wire mem_read;		// data ram read
wire mem_write;     // data ram write
wire mem2reg;       // if data writen to regfile comes from data ram
// this stage used
wire alu_src_op;	// select src2 for alu
// ---
wire reg_write;		// regfile write enable

assign alu_src_op = ds_ctrl[5];
assign branch	  = ds_ctrl[4];
assign mem_read	  = ds_ctrl[3];
assign mem_write  = ds_ctrl[2];
assign mem2reg	  = ds_ctrl[1];
assign reg_write  = ds_ctrl[0];

assign es_ctrl = ds_ctrl;

// beq
assign nx_pc = pc + imm;

// 选择 ALU src2 输入
wire [31:0] alu_src2_true = alu_src_op ? imm : alu_src2;

alu U_alu
	(
		.alu_control (alu_control),
		.alu_src1    (alu_src1),
		.alu_src2    (alu_src2_true),
		.alu_result  (alu_result),
		.zero		 (zero)
	);


endmodule
