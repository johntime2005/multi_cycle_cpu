`timescale 1ns / 1ps
module adder(
    input  [31:0] operand1, // 操作数1
    input  [31:0] operand2, // 操作数2
    input         cin,      // 进位输入
    output [31:0] result,   // 加法结果
    output        cout,     // 进位输出
    output        overflow_flag // 溢出标志
);
    // 执行加法运算
    assign {cout, result} = operand1 + operand2 + cin;
    // 检测溢出：当两个操作数符号相同，且结果符号与操作数符号不同时发生溢出
    assign overflow_flag = (operand1[31] == operand2[31]) && (result[31] != operand1[31]);
endmodule
