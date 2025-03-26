`timescale 1ns / 1ps
//*************************************************************************
//   > �ļ���: alu.v
//   > ����  ��ALUģ�飬����12�ֲ���
//   > ����  : LOONGSON
//   > ����  : 2016-04-14
//*************************************************************************
module alu(
    input  [11:0] alu_control,  // ALU�����ź�
    input  [31:0] alu_src1,     // ALU������1,Ϊ����
    input  [31:0] alu_src2,     // ALU������2��Ϊ����
    output [31:0] alu_result    // ALU���
    );

    // ALU�����źţ�������
    wire alu_add;   //�ӷ�����
    wire alu_sub;   //��������
    wire alu_slt;   //�з��űȽϣ�С����λ�����üӷ���������
    wire alu_sltu;  //�޷��űȽϣ�С����λ�����üӷ���������
    wire alu_and;   //��λ��
    wire alu_nor;   //��λ���
    wire alu_or;    //��λ��
    wire alu_xor;   //��λ���
    wire alu_sll;   //�߼�����
    wire alu_srl;   //�߼�����
    wire alu_sra;   //��������
    wire alu_lui;   //��λ����

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

    assign and_result = alu_src1 & alu_src2;      // ����Ϊ������λ��
    assign or_result  = alu_src1 | alu_src2;      // ����Ϊ������λ��
    assign nor_result = ~or_result;               // ��ǽ��Ϊ������λȡ��
    assign xor_result = alu_src1 ^ alu_src2;      // �����Ϊ������λ���
    assign lui_result = {alu_src2[15:0], 16'd0};  // ������װ�ؽ��Ϊ��������λ���߰��ֽ�

//-----{�ӷ���}begin
//add,sub,slt,sltu��ʹ�ø�ģ��
    wire [31:0] adder_operand1;
    wire [31:0] adder_operand2;
    wire        adder_cin     ;
    wire [31:0] adder_result  ;
    wire        adder_cout    ;
    assign adder_operand1 = alu_src1; 
    assign adder_operand2 = alu_add ? alu_src2 : ~alu_src2; 
    assign adder_cin      = ~alu_add; //������Ҫcin 
    adder adder_module(
    .operand1(adder_operand1),
    .operand2(adder_operand2),
    .cin     (adder_cin     ),
    .result  (adder_result  ),
    .cout    (adder_cout    )
    );

    //�Ӽ����
    assign add_sub_result = adder_result;

    //slt���
    //adder_src1[31] adder_src2[31] adder_result[31]
    //       0             1           X(0��1)       "��-��"����ȻС�ڲ�����
    //       0             0             1           ���Ϊ����˵��С��
    //       0             0             0           ���Ϊ����˵����С��
    //       1             1             1           ���Ϊ����˵��С��
    //       1             1             0           ���Ϊ����˵����С��
    //       1             0           X(0��1)       "��-��"����ȻС�ڳ���
    assign slt_result[31:1] = 31'd0;
    assign slt_result[0]    = (alu_src1[31] & ~alu_src2[31]) | (~(alu_src1[31]^alu_src2[31]) & adder_result[31]);

    //sltu���
    //����32λ�޷������Ƚϣ��൱��33λ�з�������{1'b0,src1}��{1'b0,src2}���ıȽϣ����λ0Ϊ����λ
    //�ʣ�������33λ�ӷ������Ƚϴ�С����Ҫ��{1'b0,src2}ȡ��,����Ҫ{1'b0,src1}+{1'b1,~src2}+cin
    //���˴��õ�Ϊ32λ�ӷ�����ֻ��������:                             src1   +    ~src2   +cin
    //32λ�ӷ��Ľ��Ϊ{adder_cout,adder_result},��33λ�ӷ����Ӧ��Ϊ{adder_cout+1'b1,adder_result}
    //�Ա�slt���ע�ͣ�֪������ʱ�жϴ�С���ڵڶ������������Դ������1����λΪ0��Դ������2����λΪ0
    //����ķ���λΪ1��˵��С�ڣ���adder_cout+1'b1Ϊ2'b01����adder_coutΪ0
    assign sltu_result = {31'd0, ~adder_cout};
//-----{�ӷ���}end

//-----{��λ��}begin
    // ��λ���������У�
    // ��һ��������λ����2λ��[1:0]λ����һ����λ��
    // �ڶ����ڵ�һ����λ�����ϸ�����λ��[3:2]λ���ڶ�����λ��
    // �������ڵڶ�����λ�����ϸ�����λ��[4]λ����������λ��
    wire [4:0] shf;
    assign shf = alu_src1[4:0];
    wire [1:0] shf_1_0;
    wire [1:0] shf_3_2;
    assign shf_1_0 = shf[1:0];
    assign shf_3_2 = shf[3:2];
    
     // �߼�����
    wire [31:0] sll_step1;
    wire [31:0] sll_step2;
    assign sll_step1 = {32{shf_1_0 == 2'b00}} & alu_src2                   // ��shf[1:0]="00",����λ
                     | {32{shf_1_0 == 2'b01}} & {alu_src2[30:0], 1'd0}     // ��shf[1:0]="01",����1λ
                     | {32{shf_1_0 == 2'b10}} & {alu_src2[29:0], 2'd0}     // ��shf[1:0]="10",����2λ
                     | {32{shf_1_0 == 2'b11}} & {alu_src2[28:0], 3'd0};    // ��shf[1:0]="11",����3λ
    assign sll_step2 = {32{shf_3_2 == 2'b00}} & sll_step1                  // ��shf[3:2]="00",����λ
                     | {32{shf_3_2 == 2'b01}} & {sll_step1[27:0], 4'd0}    // ��shf[3:2]="01",��һ����λ�������4λ
                     | {32{shf_3_2 == 2'b10}} & {sll_step1[23:0], 8'd0}    // ��shf[3:2]="10",��һ����λ�������8λ
                     | {32{shf_3_2 == 2'b11}} & {sll_step1[19:0], 12'd0};  // ��shf[3:2]="11",��һ����λ�������12λ
    assign sll_result = shf[4] ? {sll_step2[15:0], 16'd0} : sll_step2;     // ��shf[4]="1",�ڶ�����λ�������16λ

    // �߼�����
    wire [31:0] srl_step1;
    wire [31:0] srl_step2;
    assign srl_step1 = {32{shf_1_0 == 2'b00}} & alu_src2                   // ��shf[1:0]="00",����λ
                     | {32{shf_1_0 == 2'b01}} & {1'd0, alu_src2[31:1]}     // ��shf[1:0]="01",����1λ,��λ��0
                     | {32{shf_1_0 == 2'b10}} & {2'd0, alu_src2[31:2]}     // ��shf[1:0]="10",����2λ,��λ��0
                     | {32{shf_1_0 == 2'b11}} & {3'd0, alu_src2[31:3]};    // ��shf[1:0]="11",����3λ,��λ��0
    assign srl_step2 = {32{shf_3_2 == 2'b00}} & srl_step1                  // ��shf[3:2]="00",����λ
                     | {32{shf_3_2 == 2'b01}} & {4'd0, srl_step1[31:4]}    // ��shf[3:2]="01",��һ����λ�������4λ,��λ��0
                     | {32{shf_3_2 == 2'b10}} & {8'd0, srl_step1[31:8]}    // ��shf[3:2]="10",��һ����λ�������8λ,��λ��0
                     | {32{shf_3_2 == 2'b11}} & {12'd0, srl_step1[31:12]}; // ��shf[3:2]="11",��һ����λ�������12λ,��λ��0
    assign srl_result = shf[4] ? {16'd0, srl_step2[31:16]} : srl_step2;    // ��shf[4]="1",�ڶ�����λ�������16λ,��λ��0
 
    // ��������
    wire [31:0] sra_step1;
    wire [31:0] sra_step2;
    assign sra_step1 = {32{shf_1_0 == 2'b00}} & alu_src2                                 // ��shf[1:0]="00",����λ
                     | {32{shf_1_0 == 2'b01}} & {alu_src2[31], alu_src2[31:1]}           // ��shf[1:0]="01",����1λ,��λ������λ
                     | {32{shf_1_0 == 2'b10}} & {{2{alu_src2[31]}}, alu_src2[31:2]}      // ��shf[1:0]="10",����2λ,��λ������λ
                     | {32{shf_1_0 == 2'b11}} & {{3{alu_src2[31]}}, alu_src2[31:3]};     // ��shf[1:0]="11",����3λ,��λ������λ
    assign sra_step2 = {32{shf_3_2 == 2'b00}} & sra_step1                                // ��shf[3:2]="00",����λ
                     | {32{shf_3_2 == 2'b01}} & {{4{sra_step1[31]}}, sra_step1[31:4]}    // ��shf[3:2]="01",��һ����λ�������4λ,��λ������λ
                     | {32{shf_3_2 == 2'b10}} & {{8{sra_step1[31]}}, sra_step1[31:8]}    // ��shf[3:2]="10",��һ����λ�������8λ,��λ������λ
                     | {32{shf_3_2 == 2'b11}} & {{12{sra_step1[31]}}, sra_step1[31:12]}; // ��shf[3:2]="11",��һ����λ�������12λ,��λ������λ
    assign sra_result = shf[4] ? {{16{sra_step2[31]}}, sra_step2[31:16]} : sra_step2;    // ��shf[4]="1",�ڶ�����λ�������16λ,��λ������λ
//-----{��λ��}end

    // ѡ����Ӧ������
    assign alu_result = (alu_add|alu_sub) ? add_sub_result[31:0] : 
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
