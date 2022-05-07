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


// pipeline signal
wire fs_valid;
wire ds_ready;
wire ds_valid;
wire es_ready;
wire es_valid;
wire ms_ready;
wire ms_valid;
wire ws_ready;

// bus signal
wire [150:0] ds2es_bus;
wire [106:0] es2ms_bus;
wire [ 37:0] ms2ws_bus;

wire [31:0] pre_pc;
wire        pc_src;

wire [31:0] fs_pc;
wire [31:0] fs_inst;

wire [ 4:0] regfile_waddr;
wire        regfile_wen;
wire [31:0] regfile_wdata;

// instruction ram signal
wire [31:0] inst_ram_addr;
wire        inst_ram_ren;
wire [31:0] inst_ram_raddr;
wire [31:0] inst_ram_rdata;

// data ram signals
wire         data_ram_wen  ;
wire         data_ram_ren  ;
wire [ 31:0] data_ram_addr ;
wire [ 31:0] data_ram_wdata;
wire [ 31:0] data_ram_rdata;
//- for test
wire         data_ram_wen_t;
wire [ 31:0] data_ram_addr_t;
wire [ 31:0] data_ram_wdata_t;

wire [ 31:0] ms_mem_out    ;
wire [ 31:0] ms_pc         ;

wire [ 4:0] ws_rd;
wire        ws_reg_wen;
wire [31:0] ws_reg_wdata;

// 做一个选择，初始化ram时使用 waddr
assign inst_ram_addr = inst_ram_wen ? inst_ram_waddr
                         : inst_ram_raddr;
assign pre_pc         = ms_pc;

assign regfile_wen    = ws_reg_wen | regfile_wen_initial;
assign regfile_waddr  = regfile_wen_initial ? regfile_waddr_initial : ws_rd;
assign regfile_wdata  = regfile_wen_initial ? regfile_wdata_initial : ws_reg_wdata;

assign data_ram_wen_t = data_ram_wen | data_ram_wen_initial;
assign data_ram_addr_t = data_ram_wen_initial ? data_ram_waddr_initial : data_ram_addr;
assign data_ram_wdata_t = data_ram_wen_initial ? data_ram_wdata_initial : data_ram_wdata;


if_stage U_if_stage (
    .clk             (clk ),
    .rst_n           (rst_n),
    .ds_ready        (ds_ready ),
    .fs_valid        (fs_valid ),
    .pre_pc          (pre_pc ),
    .pc_src          (pc_src ),
    .fs_pc           (fs_pc ),
    .fs_inst         (fs_inst ),
    .inst_ram_ren    (inst_ram_ren ),
    .inst_ram_raddr  (inst_ram_raddr ),
    .inst_ram_rdata  (inst_ram_rdata)
);

id_stage U_id_stage (
      .clk           (clk ),
      .rst_n         (rst_n ),
      .fs_valid      (fs_valid ),
      .es_ready      (es_ready ),
      .ds_valid      (ds_valid ),
      .ds_ready      (ds_ready ),
      .fs_inst       (fs_inst ),
      .fs_pc         (fs_pc ),
      .regfile_waddr (regfile_waddr ),
      .regfile_wen   (regfile_wen ),
      .regfile_wdata (regfile_wdata ),
      .ds2es_bus     ( ds2es_bus)
    );

exe_stage U_exe_stage (
      .clk        (clk ),
      .rst_n      (rst_n ),
      .ms_ready   (ms_ready ),
      .ds_valid   (ds_valid ),
      .es_valid   (es_valid ),
      .es_ready   (es_ready ),
      .ds2es_bus  (ds2es_bus ),
      .es2ms_bus  ( es2ms_bus)
    );

mem_stage U_mem_stage (
      .clk            (clk            ),
      .rst_n          (rst_n          ),
      .es_valid       (es_valid       ),
      .ws_ready       (ws_ready       ),
      .ms_ready       (ms_ready       ),
      .ms_valid       (ms_valid       ),
      .data_ram_wen   (data_ram_wen   ),
      .data_ram_ren   (data_ram_ren   ),
      .data_ram_addr  (data_ram_addr  ),
      .data_ram_wdata (data_ram_wdata ),
      .data_ram_rdata (data_ram_rdata ),
      .ms_mem_out     (ms_mem_out     ),
      .pc_src         (pc_src         ),
      .ms_pc          (ms_pc          ),
      .es2ms_bus      (es2ms_bus      ),
      .ms2ws_bus      (ms2ws_bus      )
    );
  

wb_stage U_wb_stage (
      .clk           (clk          ),
      .rst_n         (rst_n        ),
      .ms_mem_out    (ms_mem_out   ),
      .ms2ws_bus     (ms2ws_bus    ),
      .ws_rd         (ws_rd        ),
      .ws_reg_wen    (ws_reg_wen   ),
      .ws_reg_wdata  (ws_reg_wdata ),
      .ws_ready      (ws_ready)
    );
  

memory_md U_inst_mem (
        .clk   (clk),
        .ren   (inst_ram_ren  ),
        // 地址是需要处理的
        .wen   (inst_ram_wen  ),
        .addr  (inst_ram_addr[17:2] ),
        .wdata (inst_ram_wdata),
        .rdata (inst_ram_rdata)
    );

localparam DEPTH = 1024;
memory_md #(
        .DEPTH(DEPTH)
    ) U_data_mem (
        .clk   (clk),
        .ren   (data_ram_ren  ),
        .wen   (data_ram_wen_t  ),
        .addr  (data_ram_addr_t[17:2] ),
        .wdata (data_ram_wdata_t),
        .rdata (data_ram_rdata)
    );

endmodule
