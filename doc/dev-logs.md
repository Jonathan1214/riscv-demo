date：2021.03.20

目标是实现 RV32I，作为起步的练习，先实现如下 7 条指令：

+ lw,  load word
+ sw,  store word
+ beq, branch equal
+ add, add
+ sub, subtract
+ and, and
+ or,  or

指令格式列出如下：

form:`funct               funct3          opcode`

lw:  `imm[11:0]       rs1 010 rd          0000011`
sw:  `imm[11:5]   rs2 rs1 010 imm[4:0]    0100011`
beq: `im[12|10:5] rs2 rs1 000 imm[4:1|11] 1100011`
add: `0000000     rs2 rs1 000 rd          0110011`
sub: `0100000     rs2 rs1 000 rd          0110011`
and: `0000000     rs2 rs1 111 rd          0110011`
or:  `0000000     rs2 rs1 110 rd          0110011`

在具体实现之前，还要先实现两个 32 位宽的存储器，分别用作指令存储和数据存储。

---

2022/3/22 23:34:56

增加了简单的取值和译码模块，还需要设计控制模块。

---

2022/4/30 17:03:13

接着做吧



---
