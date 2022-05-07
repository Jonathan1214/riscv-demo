几个 stage 之间的连线在外部看起来是 bus 形式的，在这里展开说下。

## ds2es_bus[146:0]

译码 stage 与 执行 stage 之间的 bus，其组成如下所示：

```verilog
assign ds2es_bus = {
    ds_pc         , // 146:115
    ds_src1       , // 114:83
    ds_src2       , // 82:51
    ds_imm        , // 50:19
    ds_rd         , // 22:18
    ds_alu_control, // 17:6
    ds_ctrl         //  5:0
};
```

| 信号名            | 宽度  | bus中位置  | 定义                 |
|:-------------- | --- | ------- | ------------------ |
| ds_pc          | 32  | 150:119 | pc                 |
| ds_src1        | 32  | 118:87  | regfile 中 rs1 内的数据 |
| ds_src2        | 32  | 86:55   | regfile 中 rs2 内的数据 |
| ds_imm         | 32  | 54:23   | 立即数                |
| ds_rd          | 5   | 22:18   | rd                 |
| ds_alu_control | 12  | 17:6    | ALU 控制信号           |
| ds_ctrl        | 6   | 5:0     | 其余控制信号             |

### alu 控制信号定义

alu_control 各信号定义如下表所示

| 位置  | 定义   |
|:---:| ---- |
| 0   | add  |
| 1   | sub  |
| 2   | slt  |
| 3   | sltu |
| 4   | and  |
| 5   | nor  |
| 6   | or   |
| 7   | xor  |
| 8   | sll  |
| 9   | srl  |
| 10  | sra  |
| 11  | lui  |

### ds_ctrl[5:0]

| 位置  | 定义                                                                          |
| --- | --------------------------------------------------------------------------- |
| 0   | regfile 写使能                                                                 |
| 1   | regile 写数据选择，1表示选择 data ram 中读出的数据，0 表示选择 alu_result                        |
| 2   | data ram 读使能                                                                |
| 3   | data ram 写使能                                                                |
| 4   | branch，分支使能                                                                 |
| 5   | alu_src_op，alu 的输入 alu_src2 的选择，1 表示选择 imm 立即数，0表示选择从 regfile 中 rs2 位置读出的数据 |

## es2ms_bus[146:0]


