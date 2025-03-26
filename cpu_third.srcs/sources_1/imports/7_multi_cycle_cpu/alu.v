`timescale 1ns / 1ps
//*************************************************************************
// ALU?? (Arithmetic Logic Unit)
// ??         : LOONGSON
// ????     : 2016-04-14
// ??         : ???????????????????????
//*************************************************************************
module alu(
    input  [11:0] alu_control,  // ALU??????????????????
    input  [31:0] alu_src1,     // ALU?????1
    input  [31:0] alu_src2,     // ALU?????2
    output [31:0] alu_result    // ALU????
    );

    // ??????????????????
    wire alu_add;   // ????
    wire alu_sub;   // ????
    wire alu_slt;   // ?????????
    wire alu_sltu;  // ?????????
    wire alu_and;   // ???????
    wire alu_nor;   // ????????
    wire alu_or;    // ???????
    wire alu_xor;   // ????????
    wire alu_sll;   // ??????
    wire alu_srl;   // ??????
    wire alu_sra;   // ??????
    wire alu_lui;   // load upper immediate????

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

    // ?????????
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

    // ???
    assign and_result = alu_src1 & alu_src2;      // ???
    assign or_result  = alu_src1 | alu_src2;       // ???
    assign nor_result = ~or_result;                // ????
    assign xor_result = alu_src1 ^ alu_src2;        // ????
    assign lui_result = {alu_src2[15:0], 16'd0};    // ???????

    //--- ??????slt ? sltu ???? begin ----------------------
    // ???/????????
    wire [31:0] adder_operand1;
    wire [31:0] adder_operand2;
    wire        adder_cin;
    wire [31:0] adder_result;
    wire        adder_cout;
    assign adder_operand1 = alu_src1; 
    // ???????alu_src2???????????
    assign adder_operand2 = alu_add ? alu_src2 : ~alu_src2; 
    // ??????????0???????????1?2??????
    assign adder_cin      = ~alu_add; 
    adder adder_module(
        .operand1(adder_operand1),
        .operand2(adder_operand2),
        .cin     (adder_cin     ),
        .result  (adder_result  ),
        .cout    (adder_cout    )
    );

    // ?????????
    assign add_sub_result = adder_result;

    // ??????????????????????0
    assign slt_result[31:1] = 31'd0;
    // ?src1???src2???????????????????src1??src2
    assign slt_result[0]    = (alu_src1[31] & ~alu_src2[31]) | (~(alu_src1[31]^alu_src2[31]) & adder_result[31]);

    // ??????????????carry???carry?0????????
    assign sltu_result = {31'd0, ~adder_cout};
    //--- ??????slt ? sltu ???? end ------------------------

    //--- ?????? begin ----------------------------------------------
    // ????????????
    wire [4:0] shf;
    assign shf = alu_src1[4:0];
    wire [1:0] shf_1_0;
    wire [1:0] shf_3_2;
    assign shf_1_0 = shf[1:0];
    assign shf_3_2 = shf[3:2];
    
    // ???? (SLL)
    wire [31:0] sll_step1;
    wire [31:0] sll_step2;
    // ???2???????
    assign sll_step1 = {32{shf_1_0 == 2'b00}} & alu_src2                   | 
                       {32{shf_1_0 == 2'b01}} & {alu_src2[30:0], 1'd0}     | 
                       {32{shf_1_0 == 2'b10}} & {alu_src2[29:0], 2'd0}     | 
                       {32{shf_1_0 == 2'b11}} & {alu_src2[28:0], 3'd0};
    // ??????????
    assign sll_step2 = {32{shf_3_2 == 2'b00}} & sll_step1                  | 
                       {32{shf_3_2 == 2'b01}} & {sll_step1[27:0], 4'd0}    | 
                       {32{shf_3_2 == 2'b10}} & {sll_step1[23:0], 8'd0}    | 
                       {32{shf_3_2 == 2'b11}} & {sll_step1[19:0], 12'd0};
    // ?????1?????16?
    assign sll_result = shf[4] ? {sll_step2[15:0], 16'd0} : sll_step2;

    // ???? (SRL)
    wire [31:0] srl_step1;
    wire [31:0] srl_step2;
    // ???2?????????????????0
    assign srl_step1 = {32{shf_1_0 == 2'b00}} & alu_src2                   | 
                       {32{shf_1_0 == 2'b01}} & {1'd0, alu_src2[31:1]}     | 
                       {32{shf_1_0 == 2'b10}} & {2'd0, alu_src2[31:2]}     | 
                       {32{shf_1_0 == 2'b11}} & {3'd0, alu_src2[31:3]};
    // ??????????
    assign srl_step2 = {32{shf_3_2 == 2'b00}} & srl_step1                  | 
                       {32{shf_3_2 == 2'b01}} & {4'd0, srl_step1[31:4]}    | 
                       {32{shf_3_2 == 2'b10}} & {8'd0, srl_step1[31:8]}    | 
                       {32{shf_3_2 == 2'b11}} & {12'd0, srl_step1[31:12]};
    assign srl_result = shf[4] ? {16'd0, srl_step2[31:16]} : srl_step2;

    // ???? (SRA)
    wire [31:0] sra_step1;
    wire [31:0] sra_step2;
    // ??2????????????????
    assign sra_step1 = {32{shf_1_0 == 2'b00}} & alu_src2                                 | 
                       {32{shf_1_0 == 2'b01}} & {alu_src2[31], alu_src2[31:1]}           | 
                       {32{shf_1_0 == 2'b10}} & {{2{alu_src2[31]}}, alu_src2[31:2]}      | 
                       {32{shf_1_0 == 2'b11}} & {{3{alu_src2[31]}}, alu_src2[31:3]};
    // ?????????
    assign sra_step2 = {32{shf_3_2 == 2'b00}} & sra_step1                                | 
                       {32{shf_3_2 == 2'b01}} & {{4{ sra_step1[31]}}, sra_step1[31:4]}    | 
                       {32{shf_3_2 == 2'b10}} & {{8{ sra_step1[31]}}, sra_step1[31:8]}    | 
                       {32{shf_3_2 == 2'b11}} & {{12{sra_step1[31]}}, sra_step1[31:12]};
    assign sra_result = shf[4] ? {{16{sra_step2[31]}}, sra_step2[31:16]} : sra_step2;
    //--- ?????? end ----------------------------------------------

    // ????????????????
    assign alu_result = (alu_add|alu_sub) ? add_sub_result :
                        alu_slt           ? slt_result :
                        alu_sltu          ? sltu_result :
                        alu_and           ? and_result :
                        alu_nor           ? nor_result :
                        alu_or            ? or_result  :
                        alu_xor           ? xor_result :
                        alu_sll           ? sll_result :
                        alu_srl           ? srl_result :
                        alu_sra           ? sra_result :
                        alu_lui           ? lui_result :
                        32'd0;
endmodule