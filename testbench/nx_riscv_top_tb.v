// =============================================================================
// @File         :  nx_riscv_top_tb.v
// @Author       :  Jiangxuan Li
// @Created      :  2022/05/03 09:55:21
// @Description  :  nx_rsicv_top testbench
//
// -----------------------------------------------------------------------------
// History
// -----------------------------------------------------------------------------
// Ver  :| Author  :| Mod. Date          :| Changes Made :|
// 0.1   | Jx L     | 2022/05/03 09:55:21 | original
// =============================================================================

`timescale 1ns/1ns
//- 50 MHz clock
`define PERIOD 20

module nx_riscv_top_tb;

    // Parameters


// Ports
reg clk = 0;
reg rst_n = 0;
reg inst_ram_wen;
reg [31:0] inst_ram_waddr;
reg [31:0] inst_ram_wdata;
reg         data_ram_wen_initial;
reg [31:0] data_ram_waddr_initial;
reg [31:0] data_ram_wdata_initial;
reg         regfile_wen_initial;
reg [ 4:0] regfile_waddr_initial;
reg [31:0] regfile_wdata_initial;

    always
        #(`PERIOD/2)  clk = !clk ;


    task sys_reset;
        input [31:0] rt_time;
        begin
            rst_n = 1'b0;
            #rt_time;
            rst_n = 1'b1;
        end
    endtask



    integer i;
    task initial_inst_ram;
        input [31:0] addr;
        input [31:0] data;
        begin
            // add rs1 rs2 rd
            inst_ram_waddr = addr;
            // inst_ram_wdata = 32'b0000000_00001_00010_000_0110011;
            inst_ram_wdata = data;
            inst_ram_wen = 1'b1;
            #`PERIOD;
            inst_ram_wen = 0;
        end
    endtask
    
    task initial_regfile;
        input  [ 4:0] addr;
        input  [31:0] data;
        begin
            regfile_waddr_initial = addr;
            regfile_wdata_initial = data;
            regfile_wen_initial   = 1;
            #`PERIOD;
            regfile_wen_initial = 0;
        end
    endtask

    //- 初始化 data ram
    task intial_data_ram;
        input [31:0] addr;
        input [31:0] data;
        begin
            data_ram_waddr_initial = addr;
            data_ram_wdata_initial = data;
            data_ram_wen_initial = 1;
            #`PERIOD;
            data_ram_wen_initial = 0;
        end
    endtask

    initial
        begin
            // reset 10 clk
            sys_reset(55);
            // test a add 
            initial_inst_ram(32'h0000_0008, 32'b0000000_00001_00010_000_00011_0110011);
            initial_regfile(5'b00001, 38);
            initial_regfile(5'b00010, 22);
            sys_reset(55);
            #(`PERIOD*10);
            $finish;
        end

    initial begin
        $dumpfile("top_dump.vcd");
        $dumpvars(0, nx_riscv_top_tb);
    end

    nx_riscv_top 
    nx_riscv_top_dut (
      .clk                    (clk                    ),
      .rst_n                  (rst_n                  ),
      .inst_ram_wen           (inst_ram_wen           ),
      .inst_ram_waddr         (inst_ram_waddr         ),
      .inst_ram_wdata         (inst_ram_wdata         ),
      .data_ram_wen_initial   (data_ram_wen_initial   ),
      .data_ram_waddr_initial (data_ram_waddr_initial ),
      .data_ram_wdata_initial (data_ram_wdata_initial ),
      .regfile_wen_initial    (regfile_wen_initial    ),
      .regfile_waddr_initial  (regfile_waddr_initial  ),
      .regfile_wdata_initial  ( regfile_wdata_initial )
    );
  

endmodule


