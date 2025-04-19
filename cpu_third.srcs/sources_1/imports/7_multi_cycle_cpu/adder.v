`timescale 1ns / 1ps
//*************************************************************************
//   > 文件名: adder.v
//   > 描述  : 加法器，支持无符号进位和符号溢出检测
//   > 作者  : LOONGSON
//   > 日期  : 2016-04-14
//*************************************************************************
module adder(
    input  [31:0] operand1,    // 操作数1
    input  [31:0] operand2,    // 操作数2
    input         cin,         // 进位输入
    output [31:0] result,      // 加法结果
    output        cout,        // 无符号进位输出
    output        overflow_flag // 符号溢出标志
    );

    // 加法运算
    assign {cout, result} = operand1 + operand2 + cin;

    // 符号溢出检测
    assign overflow_flag = (operand1[31] == operand2[31]) && (result[31] != operand1[31]);

endmodule
