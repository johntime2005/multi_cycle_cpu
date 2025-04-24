`timescale 1ns / 1ps
module alu(
    input  [12:0] alu_control,
    input  [31:0] alu_src1,
    input  [31:0] alu_src2,
    output [31:0] alu_result,
    output        overflow
);

wire alu_div  = alu_control[12];
wire alu_add  = alu_control[11];
wire alu_sub  = alu_control[10];
wire alu_slt  = alu_control[9];
wire alu_sltu = alu_control[8];
wire alu_and  = alu_control[7];
wire alu_nor  = alu_control[6];
wire alu_or   = alu_control[5];
wire alu_xor  = alu_control[4];
wire alu_sll  = alu_control[3];
wire alu_srl  = alu_control[2];
wire alu_sra  = alu_control[1];
wire alu_lui  = alu_control[0];

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
wire [31:0] div_result;

assign and_result = alu_src1 & alu_src2;
assign or_result  = alu_src1 | alu_src2;
assign nor_result = ~or_result;
assign xor_result = alu_src1 ^ alu_src2;
assign lui_result = {alu_src2[15:0], 16'd0};
assign div_result = (alu_src2 != 0) ? alu_src1 / alu_src2 : 32'd0;

wire [31:0] adder_operand1 = alu_src1;
wire [31:0] adder_operand2 = alu_add ? alu_src2 : ~alu_src2;
wire        adder_cin      = ~alu_add;
wire        adder_cout;
wire        adder_overflow_flag;

adder adder_module(
    .operand1(adder_operand1),
    .operand2(adder_operand2),
    .cin     (adder_cin),
    .result  (add_sub_result),
    .cout    (adder_cout),
    .overflow_flag(adder_overflow_flag)
);

// Òç³ö¼ì²âÂß¼­
assign overflow = (alu_add && adder_overflow_flag) ||
                  (alu_sub && (alu_src1[31] != alu_src2[31]) && (add_sub_result[31] != alu_src1[31]));

assign slt_result = {31'd0, 
    (alu_src1[31] & ~alu_src2[31]) | 
    (~(alu_src1[31] ^ alu_src2[31]) & add_sub_result[31])};
assign sltu_result = {31'd0, ~adder_cout};

wire [4:0] shamt = alu_src1[4:0];
assign sll_result = alu_src2 << shamt;
assign srl_result = alu_src2 >> shamt;
assign sra_result = $signed(alu_src2) >>> shamt;

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