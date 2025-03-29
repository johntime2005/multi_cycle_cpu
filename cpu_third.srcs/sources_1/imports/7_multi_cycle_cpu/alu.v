`timescale 1ns / 1ps
module alu(
    input  [12:0] alu_control, // ALU 控制信号
    input  [31:0] alu_src1,    // ALU 操作数 1
    input  [31:0] alu_src2,    // ALU 操作数 2
    output [31:0] alu_result,  // ALU 计算结果
    output        overflow     // 溢出标志
);

// 解码 ALU 控制信号
wire alu_div  = alu_control[12]; // 除法
wire alu_add  = alu_control[11]; // 加法
wire alu_sub  = alu_control[10]; // 减法
wire alu_slt  = alu_control[9];  // 有符号小于比较
wire alu_sltu = alu_control[8];  // 无符号小于比较
wire alu_and  = alu_control[7];  // 逻辑与
wire alu_nor  = alu_control[6];  // 逻辑或非
wire alu_or   = alu_control[5];  // 逻辑或
wire alu_xor  = alu_control[4];  // 逻辑异或
wire alu_sll  = alu_control[3];  // 逻辑左移
wire alu_srl  = alu_control[2];  // 逻辑右移
wire alu_sra  = alu_control[1];  // 算术右移
wire alu_lui  = alu_control[0];  // LUI 指令

// 各运算单元的中间结果
wire [31:0] add_sub_result; // 加减法结果
wire [31:0] slt_result;     // 有符号小于比较结果
wire [31:0] sltu_result;    // 无符号小于比较结果
wire [31:0] and_result;     // 逻辑与结果
wire [31:0] nor_result;     // 逻辑或非结果
wire [31:0] or_result;      // 逻辑或结果
wire [31:0] xor_result;     // 逻辑异或结果
wire [31:0] sll_result;     // 逻辑左移结果
wire [31:0] srl_result;     // 逻辑右移结果
wire [31:0] sra_result;     // 算术右移结果
wire [31:0] lui_result;     // LUI 结果
wire [31:0] div_result;     // 除法结果

// 逻辑运算
assign and_result = alu_src1 & alu_src2;
assign or_result  = alu_src1 | alu_src2;
assign nor_result = ~or_result;
assign xor_result = alu_src1 ^ alu_src2;
assign lui_result = {alu_src2[15:0], 16'd0}; // LUI 将立即数加载到高16位
assign div_result = (alu_src2 != 0) ? alu_src1 / alu_src2 : 32'd0; // 简化的除法，未处理除零异常

// 加法器/减法器
wire [31:0] adder_operand1 = alu_src1;
wire [31:0] adder_operand2 = alu_add ? alu_src2 : ~alu_src2; // 减法通过取反加一实现
wire        adder_cin      = alu_sub; // 减法时进位为1
wire        adder_cout;
wire        adder_overflow_flag; // 加法器自身的溢出标志

adder adder_module(
    .operand1(adder_operand1),
    .operand2(adder_operand2),
    .cin     (adder_cin),
    .result  (add_sub_result),
    .cout    (adder_cout),
    .overflow_flag(adder_overflow_flag)
);

// 溢出检测逻辑 (针对 ADD 和 SUB)
assign overflow = (alu_add && adder_overflow_flag) || // 加法溢出
                  (alu_sub && (alu_src1[31] != alu_src2[31]) && (add_sub_result[31] != alu_src1[31])); // 减法溢出

// 比较运算
assign slt_result = {31'd0,
    (alu_src1[31] & ~alu_src2[31]) | // src1 负, src2 正 -> src1 < src2
    (~(alu_src1[31] ^ alu_src2[31]) & add_sub_result[31])}; // 符号相同，看减法结果符号位
assign sltu_result = {31'd0, ~adder_cout}; // 无符号比较，看减法是否借位 (cout=0表示借位)

// 移位运算
wire [4:0] shamt = alu_src1[4:0]; // 对于 SLLV/SRLV/SRAV, src1 是移位量寄存器的值；对于 SLL/SRL/SRA, src1 是 shamt 字段
assign sll_result = alu_src2 << shamt;
assign srl_result = alu_src2 >> shamt;
assign sra_result = $signed(alu_src2) >>> shamt; // Verilog 算术右移

// 最终结果选择
assign alu_result =
    ({32{alu_add}}  & add_sub_result) |
    ({32{alu_sub}}  & add_sub_result) |
    ({32{alu_slt}}  & slt_result)     |
    ({32{alu_sltu}} & sltu_result)    |
    ({32{alu_and}}  & and_result)     |
    ({32{alu_nor}}  & nor_result)     |
    ({32{alu_or}}   & or_result)      |
    ({32{alu_xor}}  & xor_result)     |
    ({32{alu_sll}}  & sll_result)     |
    ({32{alu_srl}}  & srl_result)     |
    ({32{alu_sra}}  & sra_result)     |
    ({32{alu_lui}}  & lui_result)     |
    ({32{alu_div}}  & div_result);

endmodule