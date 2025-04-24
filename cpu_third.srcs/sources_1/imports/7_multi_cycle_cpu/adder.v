`timescale 1ns / 1ps
module adder(
    input  [31:0] operand1,
    input  [31:0] operand2,
    input         cin,
    output [31:0] result,
    output        cout,
    output        overflow_flag
);
    assign {cout, result} = operand1 + operand2 + cin;
    assign overflow_flag = (operand1[31] == operand2[31]) && (result[31] != operand1[31]);
endmodule
