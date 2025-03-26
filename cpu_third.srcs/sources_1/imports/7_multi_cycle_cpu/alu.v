`timescale 1ns / 1ps
//*************************************************************************
// ALU模块 (Arithmetic Logic Unit)
// 作者         : LOONGSON
// 创建日期     : 2016-04-14
// 功能         : 实现加、减、有符号/无符号比较、按位运算及移位操作
//*************************************************************************
module alu(
    input  [11:0] alu_control,  // ALU控制信号，各位对应不同的运算（加、减、比较、逻辑、移位等）
    input  [31:0] alu_src1,     // 运算操作数1
    input  [31:0] alu_src2,     // 运算操作数2
    output [31:0] alu_result    // 运算结果
    );

    // 分解alu_control各个位的含义
    wire alu_add;   // 加法使能
    wire alu_sub;   // 减法使能
    wire alu_slt;   // 有符号小于比较使能
    wire alu_sltu;  // 无符号小于比较使能
    wire alu_and;   // 按位与使能
    wire alu_nor;   // 按位或非使能
    wire alu_or;    // 按位或使能
    wire alu_xor;   // 按位异或使能
    wire alu_sll;   // 逻辑左移使能
    wire alu_srl;   // 逻辑右移使能
    wire alu_sra;   // 算术右移使能
    wire alu_lui;   // load upper immediate指令使能

    assign alu_add  = alu_control[11];
    assign alu_sub  = alu_control[10];
    assign alu_slt  = alu_control[ 9];
    assign alu_sltu = alu_control[ 8];
    assign alu_and  = alu_control[ 7];
    assign alu_nor  = alu_control[ 6];
    assign alu_or   = alu_control[ 5];
    assign alu_xor  = alu_control[ 4];
    assign alu_sll  = alu_control[ 3];
    assign alu_srl  = alu_control[ 2];
    assign alu_sra  = alu_control[ 1];
    assign alu_lui  = alu_control[ 0];

    // 定义各功能运算的结果信号
    wire [31:0] add_sub_result;
    wire [31:0] slt_result;
    wire [31:0] sltu_result;
    wire [31:0] and_result;
    wire [31:0] nor_result;
    wire [31:0] or_result;
    wire [31:0] xor_result;
    wire [31:0] sll_result;
    wire [31:0] srl_result;
    wire [31:0] sra_result;
    wire [31:0] lui_result;

    // 按位运算逻辑
    assign and_result = alu_src1 & alu_src2;         // 按位与
    assign or_result  = alu_src1 | alu_src2;          // 按位或
    assign nor_result = ~or_result;                   // 按位或非（取或的反）
    assign xor_result = alu_src1 ^ alu_src2;           // 按位异或
    assign lui_result = {alu_src2[15:0], 16'd0};       // 高位加载操作，将低16位数据放高端

    // --- 加减运算与比较操作 (slt/sltu) begin -------------------------
    // 使用加法器计算加法或减法结果
    wire [31:0] adder_operand1;
    wire [31:0] adder_operand2;
    wire        adder_cin;
    wire [31:0] adder_result;
    wire        adder_cout;
    
    assign adder_operand1 = alu_src1;
    // 加法时直接用alu_src2，减法时取反alu_src2（用于2的补码减法）
    assign adder_operand2 = alu_add ? alu_src2 : ~alu_src2;
    // 加法时进位为0，减法时进位置1
    assign adder_cin      = ~alu_add;
    
    adder adder_module(
        .operand1(adder_operand1),
        .operand2(adder_operand2),
        .cin     (adder_cin),
        .result  (adder_result),
        .cout    (adder_cout)
    );
    
    // 加法与减法结果
    assign add_sub_result = adder_result;
    
    // 有符号小于比较 (slt)
    // 只保留结果的最低位，其余位补零
    assign slt_result[31:1] = 31'd0;
    // 若alu_src1为负而alu_src2为正；或者两数符号相同且减法结果为负，则认为alu_src1小于alu_src2
    assign slt_result[0]    = (alu_src1[31] & ~alu_src2[31]) | 
                              (~(alu_src1[31] ^ alu_src2[31]) & adder_result[31]);

    // 无符号小于比较 (sltu)
    // 利用加法器的进位信息，若进位为0(即~adder_cout为1)则表示alu_src1小于alu_src2
    assign sltu_result = {31'd0, ~adder_cout};
    // --- 加减运算与比较操作 end ---------------------------------------

    // --- 移位操作 begin -----------------------------------------------
    // 从alu_src1中提取移位数（取低5位）
    wire [4:0] shf;
    assign shf = alu_src1[4:0];
    wire [1:0] shf_1_0 = shf[1:0];
    wire [1:0] shf_3_2 = shf[3:2];

    // 逻辑左移 (SLL)
    wire [31:0] sll_step1;
    wire [31:0] sll_step2;
    // 根据低2位进行初步左移
    assign sll_step1 = {32{shf_1_0 == 2'b00}} & alu_src2                   | 
                       {32{shf_1_0 == 2'b01}} & {alu_src2[30:0], 1'd0}     | 
                       {32{shf_1_0 == 2'b10}} & {alu_src2[29:0], 2'd0}     | 
                       {32{shf_1_0 == 2'b11}} & {alu_src2[28:0], 3'd0};
    // 根据高2位进一步左移
    assign sll_step2 = {32{shf_3_2 == 2'b00}} & sll_step1                  | 
                       {32{shf_3_2 == 2'b01}} & {sll_step1[27:0], 4'd0}    | 
                       {32{shf_3_2 == 2'b10}} & {sll_step1[23:0], 8'd0}    | 
                       {32{shf_3_2 == 2'b11}} & {sll_step1[19:0], 12'd0};
    // 若shf的最高位为1，则再左移16位
    assign sll_result = shf[4] ? {sll_step2[15:0], 16'd0} : sll_step2;

    // 逻辑右移 (SRL)
    wire [31:0] srl_step1;
    wire [31:0] srl_step2;
    // 根据低2位右移，左侧补0
    assign srl_step1 = {32{shf_1_0 == 2'b00}} & alu_src2                   | 
                       {32{shf_1_0 == 2'b01}} & {1'd0, alu_src2[31:1]}     | 
                       {32{shf_1_0 == 2'b10}} & {2'd0, alu_src2[31:2]}     | 
                       {32{shf_1_0 == 2'b11}} & {3'd0, alu_src2[31:3]};
    // 根据高2位进一步右移
    assign srl_step2 = {32{shf_3_2 == 2'b00}} & srl_step1                  | 
                       {32{shf_3_2 == 2'b01}} & {4'd0, srl_step1[31:4]}    | 
                       {32{shf_3_2 == 2'b10}} & {8'd0, srl_step1[31:8]}    | 
                       {32{shf_3_2 == 2'b11}} & {12'd0, srl_step1[31:12]};
    assign srl_result = shf[4] ? {16'd0, srl_step2[31:16]} : srl_step2;

    // 算术右移 (SRA)
    wire [31:0] sra_step1;
    wire [31:0] sra_step2;
    // 初步右移时保持符号位扩展
    assign sra_step1 = {32{shf_1_0 == 2'b00}} & alu_src2                                 | 
                       {32{shf_1_0 == 2'b01}} & {alu_src2[31], alu_src2[31:1]}           | 
                       {32{shf_1_0 == 2'b10}} & {{2{alu_src2[31]}}, alu_src2[31:2]}      | 
                       {32{shf_1_0 == 2'b11}} & {{3{alu_src2[31]}}, alu_src2[31:3]};
    // 根据高2位进一步右移并保持符号扩展
    assign sra_step2 = {32{shf_3_2 == 2'b00}} & sra_step1                                | 
                       {32{shf_3_2 == 2'b01}} & {{4{ sra_step1[31]}}, sra_step1[31:4]}    | 
                       {32{shf_3_2 == 2'b10}} & {{8{ sra_step1[31]}}, sra_step1[31:8]}    | 
                       {32{shf_3_2 == 2'b11}} & {{12{sra_step1[31]}}, sra_step1[31:12]};
    assign sra_result = shf[4] ? {{16{sra_step2[31]}}, sra_step2[31:16]} : sra_step2;
    // --- 移位操作 end -------------------------------------------------

    // 根据控制信号选择最终的运算结果
    assign alu_result = (alu_add | alu_sub) ? add_sub_result :
                        alu_slt         ? slt_result :
                        alu_sltu        ? sltu_result :
                        alu_and         ? and_result :
                        alu_nor         ? nor_result :
                        alu_or          ? or_result  :
                        alu_xor         ? xor_result :
                        alu_sll         ? sll_result :
                        alu_srl         ? srl_result :
                        alu_sra         ? sra_result :
                        alu_lui         ? lui_result :
                        32'd0;
endmodule