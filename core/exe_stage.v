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

    ,input  ms_ready
    ,input  ds_valid
    ,output es_valid
    ,output es_ready

    ,input  [150:0] ds2es_bus
    ,output reg [106:0] es2ms_bus
);


wire  [31:0] ds_pc;
wire  [31:0] ds_src1;
wire  [31:0] ds_src2;
wire  [31:0] ds_imm;
wire  [11:0] ds_alu_control;
wire  [ 5:0] ds_ctrl;
wire  [ 4:0] ds_rd;

wire [31:0] es_pc;
wire [31:0] es_alu_result;
wire [31:0] es_data_ram_wdata;
wire [ 4:0] es_rd;
wire [ 4:0] es_ctrl;
wire 		es_zero;

assign  {
    ds_pc         , // 146:115
    ds_src1       , // 114:83
    ds_src2       , // 82:51
    ds_imm        , // 50:19
    ds_rd         , // 22:18
    ds_alu_control, // 17:6
    ds_ctrl         //  5:0
} = ds2es_bus;

assign es_data_ram_wdata = ds_src2;
assign es_rd   = ds_rd;

wire branch;		// branch
wire mem_read;		// data ram read
wire mem_write;     // data ram write
wire mem2reg;       // if data writen to regfile comes from data ram
// this stage used
wire alu_src_op;	// select src2 for alu
wire reg_write;		// regfile write enable

assign alu_src_op = ds_ctrl[5];
assign branch	  = ds_ctrl[4];
assign mem_read	  = ds_ctrl[3];
assign mem_write  = ds_ctrl[2];
assign mem2reg	  = ds_ctrl[1];
assign reg_write  = ds_ctrl[0];

assign es_ctrl = ds_ctrl[4:0];

// beq
assign es_pc = ds_pc + ds_imm;

// 选择 ALU src2 输入
wire [31:0] alu_src2_true = alu_src_op ? ds_imm : ds_src2;

alu U_alu
	(
		.alu_control (ds_alu_control),
		.alu_src1    (ds_src1       ),
		.alu_src2    (alu_src2_true ),
		.alu_result  (es_alu_result ),
		.zero		 (es_zero       )
	);

wire [106:0] es2ms_bus_reg;
assign es2ms_bus_reg = {
    es_pc,              // 106:75
    es_alu_result,      // 74:43
    es_data_ram_wdata,  // 42:11
    es_rd,              // 10:6
    es_ctrl,            // 5:1
    es_zero             // 0
};

wire es_ok_go = 1'b1;
reg es_valid_pre;
assign es_ready = !ds_valid || es_ok_go && ms_ready;
assign es_valid = es_valid_pre && es_ok_go;

always @(posedge clk or negedge rst_n) begin
    if (rst_n == 1'b0) begin
        es_valid_pre <= 0;
    end
    else if (es_ready) begin
        es_valid_pre <= ds_valid;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (rst_n == 0) begin
        es2ms_bus <= 0;
    end
    else if (es_ready && ds_valid) begin
        es2ms_bus <= es2ms_bus_reg;
    end
end

endmodule
