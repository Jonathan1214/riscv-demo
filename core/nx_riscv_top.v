// =============================================================================
// @File         :  nx_riscv_top.v
// @Author       :  Jiangxuan Li
// @Created      :  2022/5/2 11:04:58
// @Description  :  nx-riscv_top
//
// -----------------------------------------------------------------------------
// History
// -----------------------------------------------------------------------------
// Ver  :| Author  :| Mod. Date          :| Changes Made :|
// 0.1   | Jx L     | 2022/5/2 11:04:58 | original
// =============================================================================

module nx_riscv_top (
     input clk    // Clock
    ,input rst_n  // Asynchronous reset active low

// 测试端口
// 初始化 inst ram
    ,input        inst_ram_wen
    ,input [31:0] inst_ram_waddr
    ,input [31:0] inst_ram_wdata

// 初始化 data_ram
    ,input        data_ram_wen_initial
    ,input [31:0] data_ram_waddr_initial
    ,input [31:0] data_ram_wdata_initial

// 初始化 regfile
    ,input        regfile_wen_initial
    ,input [ 4:0] regfile_waddr_initial
    ,input [31:0] regfile_wdata_initial
);

// if stage wire
wire [31:0] pre_pc;
wire [31:0] pc_src;
wire [31:0] fs_nx_pc;
wire [31:0] inst_ram_raddr;

// access instr mem
wire [31:0] wdata;
wire        wen;
wire [31:0] waddr;
wire [31:0] instr_mem;

// id stage wire
wire [31:0] ds_pc;
wire [31:0] ds_nx_pc;
wire [31:0] ds_instr;
wire [ 4:0] ds_rd_in;
wire        ds_reg_wen;
wire [31:0] ds_reg_wdata;
wire [31:0] ds_src1;
wire [31:0] ds_src2;
wire [31:0] ds_imm;
wire [ 4:0] ds_rd_out;
wire [11:0] ds_alu_control;
wire [ 5:0] ds_ctrl;


// exe stage wire
wire [31:0] es_pc;
wire [31:0] es_nx_pc;
wire [31:0] es_alu_src1;
wire [31:0] es_alu_src2;
wire [31:0] es_imm;
wire [11:0] es_alu_control;
wire [ 4:0] ds_rd;
wire [ 4:0] es_rd ;
// write data to data ram
wire [31:0] es_wr_data;
wire [ 5:0] es_ctrl;
wire        es_zero;
wire [31:0] es_alu_result;


// mem stage wire
wire        ren;
wire [31:0] alu_result;
wire [31:0] addr;
wire [31:0] wr_data;
wire [31:0] mem_out_data;
wire [31:0] ms_alu_result;
// rd for R type
wire [ 4:0] ms_rd;
wire        pc;
wire        zero;
wire [ 5:0] ms_ctrl;

// wb stage wire
wire [ 4:0] ws_rd;
wire        ws_reg_wen;
wire [31:0] ws_reg_wdata;

// memory wire connect

wire  inst_ram_ren = 1'b1;
wire [31:0] inst_ram_addr ;
wire [31:0] inst_ram_rdata;

// 根据读写位置控制
assign inst_ram_addr = inst_ram_wen ? inst_ram_waddr : inst_ram_raddr;

wire data_ram_ren  ;
wire data_ram_wen  ;
wire [31:0] data_ram_addr ;
wire [31:0] data_ram_wdata;
wire [31:0] data_ram_rdata;

assign data_ram_ren   = es_ctrl[3]    ;
assign mem_out_data   = data_ram_rdata;

// 2022/05/03 23:04:39
//- 增加 data ram 的初始化数据选择，用于测试
assign data_ram_wen   = es_ctrl[2] | data_ram_wen_initial;
assign data_ram_addr  = data_ram_wen_initial ? data_ram_waddr_initial : es_alu_result ;
assign data_ram_wdata = data_ram_wen_initial ? data_ram_waddr_initial : es_wr_data    ;

// if stage wire connect
assign pre_pc = es_nx_pc;

// id stage wire connect
assign ds_pc           = fs_nx_pc    ;
assign ds_instr        = inst_ram_rdata;

// 2022/05/03 23:02:42
//- 增加了用于测试的初始化使能
//- 关于 regfile 的初始化
assign ds_rd_in        = regfile_wen_initial ? regfile_waddr_initial : ws_rd;
assign ds_reg_wen      = ws_reg_wen  | regfile_wen_initial;
assign ds_reg_wdata    = regfile_wen_initial ? regfile_wdata_initial : ws_reg_wdata;

// exe stage wire connect
assign es_pc          = ds_pc;
assign es_alu_src1    = ds_src1;
assign es_alu_src2    = ds_src2;
assign es_alu_control = ds_alu_control;
assign ds_rd          = ds_rd_out;

// mem stage wire connect

// wb stage wire connect


if_stage inst_if_stage
    (
        .clk           (clk          ),
        .rst_n         (rst_n        ),
        .pre_pc        (pre_pc       ),
        .pc_src        (pc_src       ),
        .nx_pc         (fs_nx_pc     ),
        .inst_ram_raddr(inst_ram_raddr)
    );

id_stage inst_id_stage
    (
        .clk         (clk           ),
        .rst_n       (rst_n         ),
        .pc          (ds_pc         ),
        .nx_pc       (ds_nx_pc      ),
        .instr       (ds_instr      ),
        .ds_rd_in    (ds_rd_in      ),
        .reg_wen     (ds_reg_wen    ),
        .wdata       (ds_reg_wdata  ),
        .src1        (ds_src1       ),
        .src2        (ds_src2       ),
        .imm         (imm           ),
        .ds_rd_out   (ds_rd_out     ),
        .alu_control (ds_alu_control),
        .ds_ctrl     (ds_ctrl       )
    );


exe_stage inst_exe_stage
    (
        .clk         (clk           ),
        .rst_n       (rst_n         ),
        .pc          (es_pc         ),
        .nx_pc       (es_nx_pc      ),
        .alu_src1    (es_alu_src1   ),
        .alu_src2    (es_alu_src2   ),
        .imm         (imm           ),
        .alu_control (es_alu_control),
        .ds_ctrl     (ds_ctrl       ),
        .ds_rd       (ds_rd         ),
        .es_rd       (es_rd         ),
        .wr_data     (es_wr_data    ),
        .es_ctrl     (es_ctrl       ),
        .zero        (es_zero       ),
        .alu_result  (es_alu_result )
    );

mem_stage inst_mem_stage
    (
      .clk           (clk           ),
      .rst_n         (rst_n         ),
      .mem_out_data  (mem_out_data  ),
      .ms_mem_out    (ms_mem_out    ),
      .es_alu_result (es_alu_result ),
      .ms_alu_result (ms_alu_result ),
      .es_rd         (es_rd         ),
      .ms_rd         (ms_rd         ),
      .es_ctrl       (es_ctrl       ),
      .zero          (zero          ),
      .pc_src        (pc_src        ),
      .ms_ctrl       (ms_ctrl       )
    );


wb_stage inst_wb_stage
    (
        .clk           (clk          ),
        .rst_n         (rst_n        ),
        .ms_mem_out    (ms_mem_out   ),
        .ms_alu_result (ms_alu_result),
        .ms_ctrl       (ms_ctrl      ),
        .ms_rd         (ms_rd        ),
        .ws_rd         (ws_rd        ),
        .ws_reg_wen    (ws_reg_wen   ),
        .ws_reg_wdata  (ws_wdata     )
    );


memory_md U_inst_mem (
        .clk   (clk),
        .ren   (inst_ram_ren  ),
        // 地址是需要处理的
        .wen   (inst_ram_wen  ),
        .addr  (inst_ram_addr ),
        .wdata (inst_ram_wdata),
        .rdata (inst_ram_rdata)
    );

localparam DEPTH = 1024;
memory_md #(
        .DEPTH(DEPTH)
    ) U_data_mem (
        .clk   (clk),
        .ren   (data_ram_ren  ),
        .wen   (data_ram_wen  ),
        .addr  (data_ram_addr ),
        .wdata (data_ram_wdata),
        .rdata (data_ram_rdata)
    );

endmodule
