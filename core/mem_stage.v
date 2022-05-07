// =============================================================================
// @File         :  mem_stage.v
// @Author       :  Jiangxuan Li
// @Created      :  2022/5/1 12:00:44
// @Description  :  access memory
// 
// -----------------------------------------------------------------------------
// History
// -----------------------------------------------------------------------------
// Ver  :| Author  :| Mod. Date          :| Changes Made :|
// 0.1   | Jx L     | 2022/5/1 12:00:44 | original
// =============================================================================


module mem_stage (
	 input 			clk    // Clock
	,input 			rst_n  // Asynchronous reset active low

    ,input  es_valid
    ,input  ws_ready
    ,output ms_ready
    ,output ms_valid

    ,output             data_ram_wen     //- data ram write enable
    ,output             data_ram_ren     //- data ram read enable
    ,output     [31:0]  data_ram_addr    //- data ram addr
    ,output     [31:0]  data_ram_wdata
    ,input      [31:0]  data_ram_rdata   //- data ram output data
    ,output     [31:0]  ms_mem_out       //- data out from current stage

	,output 		    pc_src          //- pc src
    ,output     [31:0]  ms_pc

    ,input      [106:0] es2ms_bus
    ,output reg [ 37:0] ms2ws_bus
);

wire [31:0] es_pc            ;
wire [31:0] es_alu_result    ;
wire [31:0] es_data_ram_wdata;
wire [ 4:0] es_rd            ;
wire [ 4:0] es_ctrl          ;
wire 		es_zero          ;

assign {
    es_pc,              // 106:75
    es_alu_result,      // 74:43
    es_data_ram_wdata,  // 42:11
    es_rd,              // 10:6
    es_ctrl,            // 5:1
    es_zero             // 0
} = es2ms_bus;

wire branch                  ;
wire mem_read                ;
wire mem_write               ;

assign branch    = es_ctrl[4];
assign mem_read  = es_ctrl[3];
assign mem_write = es_ctrl[2];

wire [31:0] ms_alu_result;
wire [ 4:0] ms_rd        ;
wire [ 1:0] ms_ctrl      ;

// 不寄存的信号直接输出
assign pc_src        = branch & es_zero;
assign ms_pc         = es_pc;

// 寄存到 write back stage
assign ms_alu_result = es_alu_result    ;
assign ms_rd         = es_rd            ;
assign ms_ctrl       = es_ctrl[1:0]     ;

wire [37:0] ms2ws_bus_reg;
assign ms2ws_bus_reg = {
    ms_alu_result,      // 37:6
    ms_rd        ,      // 5:1
    ms_ctrl             // 1:0
};

wire ms_ok_go = 1'b1;
reg  ms_valid_pre;
//- !es_valid 用于清空流水线
assign ms_ready = !es_valid || ms_ok_go && ws_ready;
assign ms_valid = ms_valid_pre && ms_ok_go;

always @(posedge clk or negedge rst_n) begin
    if (rst_n == 1'b0) begin
        ms_valid_pre <= 0;
    end
    else if (ms_ready) begin
        ms_valid_pre <= es_valid;
    end

    // bus 无需复位
    if (ms_ready && es_valid) begin
        ms2ws_bus <= ms2ws_bus_reg;
    end
end

assign data_ram_wen  = mem_write && ms_ready && es_valid;   //- data ram write enable
assign data_ram_ren  = mem_read  && ms_ready && es_valid;   //- data ram read enable
assign data_ram_addr = es_alu_result                    ;   //- data ram addr
assign data_ram_wdata = es_data_ram_wdata;
assign ms_mem_out    = data_ram_rdata                   ;

endmodule
