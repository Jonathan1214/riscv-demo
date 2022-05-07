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

// pipeline 信号
    ,input             ds_ready
    ,output reg        fs_valid

	,input      [31:0] pre_pc
	,input 		       pc_src

	,output reg [31:0] fs_pc    //- 传递给 ds 的 pc
    ,output     [31:0] fs_inst

    ,output        inst_ram_ren
	,output [31:0] inst_ram_raddr
    ,input  [31:0] inst_ram_rdata
);

wire [31:0] pc;
wire [31:0] n_pc;

// pc 自增值
assign n_pc = fs_pc + 32'd4;
assign pc   = pc_src == 1'b1 ? pre_pc : n_pc;

// 为了将 PC 与 inst 做对齐 插入一级流水和寄存器
wire fs_ready;
wire fs_valid_pre;
// 用 fs_ok_go 控制流水线是否前进
wire fs_ok_go;

assign fs_valid_pre = rst_n;
assign fs_ready     = !fs_valid_pre || ds_ready;
always @(posedge clk or negedge rst_n) begin
    if (rst_n == 1'b0) begin
        fs_valid <= 0;
    end
    else if (fs_ready) begin
        fs_valid <= fs_valid_pre;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (rst_n == 1'b0) begin
        // 复位值要选择一下，看协议规定的是多少确定
        fs_pc <= 0;
    end
    else if (fs_valid_pre && fs_ready) begin
        // 可以实现阻塞，但是 pc 还是会一直增大，因此还要再对 pc 做处理
        fs_pc <= pc;
    end
end

assign inst_ram_ren   = fs_valid_pre && fs_ready;
assign inst_ram_raddr = pc;
assign fs_inst        = inst_ram_rdata;

endmodule
