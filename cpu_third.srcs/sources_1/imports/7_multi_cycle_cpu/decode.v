`timescale 1ns / 1ps
//*************************************************************************

//   > 文件名: decode.v

//   > 描述  : 多周期CPU的译码模块（支持异常处理）

//   > 作者  : LOONGSON

//   > 日期  : 2016-04-14

//   > 修改  : 添加异常处理机制（2023-10-20）+ 完整修正版（2024-03-25）

//*************************************************************************

module decode (
    // 基本输入

    input        ID_valid,     // 译码阶段有效信号

    input [63:0] IF_ID_bus_r,  // IF->ID总线 {指令, PC}

    input [31:0] rs_value,     // 第一源操作数值

    input [31:0] rt_value,     // 第二源操作数值

    input [ 5:0] irq,          // 新增: 中断请求输入 (从 multi_cycle_cpu 传递)


    // 基本输出

    output     [  4:0] rs,            // 第一源操作数地址

    output     [  4:0] rt,            // 第二源操作数地址

    output reg [ 32:0] jbr_bus,       // 跳转总线 {jbr_taken, jbr_target}

    output reg         jbr_not_link,  // 非link类跳转指令

    output             ID_over,       // ID模块执行完成

    output reg [156:0] ID_EXE_bus,    // ID->EXE总线（含异常/中断信号）

    output     [ 31:0] ID_pc,         // 当前PC值

    output             eret_executed, // 新增: ERET 指令执行信号


    // 异常/中断信号输出给 exception_controller

    output reg [1:0] id_exception_type,  // ID阶段异常类型

    output reg       id_exception_flag,  // ID阶段异常标志

    output reg [1:0] id_interrupt_type,  // ID阶段中断类型

    output reg       id_interrupt_flag   // ID阶段中断标志

);

  //======================== 信号解析 ========================

  // IF->ID总线解析

  wire [31:0] pc;
  wire [31:0] inst;
  assign {inst, pc} = IF_ID_bus_r;  // 修改解包顺序

  assign ID_pc = pc;

  // 指令字段解析

  wire [5:0] op = inst[31:26];
  assign rs = inst[25:21];
  assign rt = inst[20:16];
  wire [4:0] rd = inst[15:11];
  wire [4:0] sa = inst[10:6];
  wire [5:0] funct = inst[5:0];
  wire [15:0] imm = inst[15:0];
  wire [25:0] target = inst[25:0];

  //======================== 指令译码 ========================

  // R型指令识别

  wire inst_ADDU = (op == 6'b000000) & (funct == 6'b100001);
  wire inst_SUBU = (op == 6'b000000) & (funct == 6'b100011);
  wire inst_SLT = (op == 6'b000000) & (funct == 6'b101010);
  wire inst_SLTU = (op == 6'b000000) & (funct == 6'b101011);
  wire inst_AND = (op == 6'b000000) & (funct == 6'b100100);
  wire inst_OR = (op == 6'b000000) & (funct == 6'b100101);
  wire inst_XOR = (op == 6'b000000) & (funct == 6'b100110);
  wire inst_NOR = (op == 6'b000000) & (funct == 6'b100111);
  wire inst_SLL   = (op == 6'b000000) & (funct == 6'b000000) & (rd != 0 || sa != 0 || rt != 0); // NOP 是 SLL $0,$0,0

  wire inst_SRL = (op == 6'b000000) & (funct == 6'b000010);
  wire inst_SRA = (op == 6'b000000) & (funct == 6'b000011);
  wire inst_SLLV = (op == 6'b000000) & (funct == 6'b000100);
  wire inst_SRLV = (op == 6'b000000) & (funct == 6'b000110);
  wire inst_SRAV = (op == 6'b000000) & (funct == 6'b000111);
  wire inst_JR = (op == 6'b000000) & (funct == 6'b001000);
  wire inst_JALR = (op == 6'b000000) & (funct == 6'b001001);
  wire inst_DIV = (op == 6'b000000) & (funct == 6'b011010);  // DIV 指令

  wire inst_NOP = (inst == 32'b0);  // NOP


  // I型指令识别

  wire inst_ADDIU = (op == 6'b001001);
  wire inst_SLTI = (op == 6'b001010);
  wire inst_SLTIU = (op == 6'b001011);
  wire inst_ANDI = (op == 6'b001100);
  wire inst_ORI = (op == 6'b001101);
  wire inst_XORI = (op == 6'b001110);
  wire inst_LUI = (op == 6'b001111);  // LUI rt, imm

  wire inst_LW = (op == 6'b100011);
  wire inst_SW = (op == 6'b101011);
  wire inst_LB = (op == 6'b100000);
  wire inst_LBU = (op == 6'b100100);
  wire inst_LH = (op == 6'b100001);
  wire inst_LHU = (op == 6'b100101);
  wire inst_SB = (op == 6'b101000);
  wire inst_SH = (op == 6'b101001);
  wire inst_BEQ = (op == 6'b000100);
  wire inst_BNE = (op == 6'b000101);
  wire inst_BGEZ = (op == 6'b000001) & (rt == 5'b00001);
  wire inst_BGTZ = (op == 6'b000111) & (rt == 5'b00000);
  wire inst_BLEZ = (op == 6'b000110) & (rt == 5'b00000);
  wire inst_BLTZ = (op == 6'b000001) & (rt == 5'b00000);

  // J型指令识别

  wire inst_J = (op == 6'b000010);
  wire inst_JAL = (op == 6'b000011);

  // 特殊指令

  wire inst_ERET = (op == 6'b010000) & (funct == 6'b011000);  // ERET

  assign eret_executed = inst_ERET && ID_valid;  // ERET 执行信号


  //======================== 异常/中断处理 ========================

  wire is_ri = !(inst_ADDU | inst_SUBU | inst_SLT | inst_SLTU |

               inst_AND | inst_OR | inst_XOR | inst_NOR |

               inst_SLL | inst_SRL | inst_SRA | inst_SLLV |

               inst_SRLV | inst_SRAV | inst_JR | inst_JALR | inst_DIV |

               inst_ADDIU | inst_SLTI | inst_SLTIU | inst_ANDI |

               inst_ORI | inst_XORI | inst_LUI | inst_LW | inst_SW |

               inst_LB | inst_LBU | inst_LH | inst_LHU | inst_SB |

               inst_SH | inst_BEQ | inst_BNE | inst_BGEZ | inst_BGTZ |

               inst_BLEZ | inst_BLTZ | inst_J | inst_JAL | inst_NOP |

               inst_ERET); // 添加 NOP 和 ERET 到合法指令列表


  wire is_adel_fetch = (pc[1:0] != 2'b00);  // 取指地址错


  always @(*) begin
    // 默认值

    id_exception_flag = 1'b0;
    id_exception_type = 2'b00;  // 对应 AdEL/AdES

    id_interrupt_flag = 1'b0;
    id_interrupt_type = 2'b01;  // 对应 Int


    if (ID_valid) begin
      // 1. 检测取指地址错 (AdEL) - 最高优先级

      if (is_adel_fetch) begin
        id_exception_flag = 1'b1;
        id_exception_type = 2'b00;  // AdEL

      end  // 2. 检测保留指令 (RI)

      else if (is_ri) begin
        id_exception_flag = 1'b1;
        id_exception_type = 2'b10;  // RI

      end  // 3. 检测中断 (如果无异常)

      else if (|irq) begin  // 简化：只要有中断请求就标记

        id_interrupt_flag = 1'b1;
        // id_interrupt_type 已设为 2'b01

      end
    end
  end

  //======================== 控制信号生成 ========================

  // ALU 控制信号 (13位)

  // [12]: DIV, [11]: ADD, [10]: SUB, [9]: SLT, [8]: SLTU, [7]: AND, [6]: NOR, [5]: OR, [4]: XOR, [3]: SLL, [2]: SRL, [1]: SRA, [0]: LUI

  reg [12:0] alu_control_out;
  always @(*) begin
    if (inst_ADDU || inst_ADDIU || inst_LW || inst_SW || inst_LB || inst_LBU || inst_LH || inst_LHU || inst_SB || inst_SH)
      alu_control_out = 13'b0_1_0_00_000_0000;  // ADD

    else if (inst_SUBU || inst_BEQ || inst_BNE || inst_BGEZ || inst_BGTZ || inst_BLEZ || inst_BLTZ)
      alu_control_out = 13'b0_0_1_00_000_0000;  // SUB

    else if (inst_SLT || inst_SLTI) alu_control_out = 13'b0_0_0_10_000_0000;  // SLT

    else if (inst_SLTU || inst_SLTIU) alu_control_out = 13'b0_0_0_01_000_0000;  // SLTU

    else if (inst_AND || inst_ANDI) alu_control_out = 13'b0_0_0_00_100_0000;  // AND

    else if (inst_NOR) alu_control_out = 13'b0_0_0_00_010_0000;  // NOR

    else if (inst_OR || inst_ORI) alu_control_out = 13'b0_0_0_00_001_0000;  // OR

    else if (inst_XOR || inst_XORI) alu_control_out = 13'b0_0_0_00_000_1000;  // XOR

    else if (inst_SLL || inst_SLLV)  // SLLV 在 ALU 中使用 rs_value 作为 shamt

      alu_control_out = 13'b0_0_0_00_000_0100;  // SLL

    else if (inst_SRL || inst_SRLV)  // SRLV 在 ALU 中使用 rs_value 作为 shamt

      alu_control_out = 13'b0_0_0_00_000_0010;  // SRL

    else if (inst_SRA || inst_SRAV)  // SRAV 在 ALU 中使用 rs_value 作为 shamt

      alu_control_out = 13'b0_0_0_00_000_0001;  // SRA

    else if (inst_LUI) alu_control_out = 13'b0_0_0_00_000_0000_1;  // LUI

    else if (inst_DIV) alu_control_out = 13'b1_0_0_00_000_0000;  // DIV

    else alu_control_out = 13'b0;  // 默认 (NOP, J, JR, JAL, JALR, ERET)

  end

  // ALU 操作数选择

  reg  [31:0] alu_operand1_out;
  reg  [31:0] alu_operand2_out;
  wire [31:0] imm_zext = {16'b0, imm};  // 零扩展立即数

  wire [31:0] imm_sext = {{16{imm[15]}}, imm};  // 符号扩展立即数


  always @(*) begin
    // 操作数 1 选择

    if (inst_SLL || inst_SRL || inst_SRA)
      alu_operand1_out = {27'b0, sa};  // 移位指令使用 shamt

    else if (inst_SLLV || inst_SRLV || inst_SRAV)
      alu_operand1_out = rs_value;  // 变量移位使用 rs

    else alu_operand1_out = rs_value;  // 默认使用 rs


    // 操作数 2 选择

    if (op == 6'b000000)  // R型 (移位除外)

      alu_operand2_out = rt_value;
    else if (inst_ADDIU || inst_SLTI || inst_LW || inst_SW || inst_LB || inst_LH || inst_SB || inst_SH ||

             inst_BEQ || inst_BNE || inst_BGEZ || inst_BGTZ || inst_BLEZ || inst_BLTZ)
      alu_operand2_out = imm_sext;  // 使用符号扩展立即数

    else if (inst_SLTIU || inst_ANDI || inst_ORI || inst_XORI || inst_LUI || inst_LBU || inst_LHU)
      alu_operand2_out = imm_zext; // 使用零扩展立即数 (LUI 在这里使用低16位，ALU 处理移位)

    else alu_operand2_out = rt_value;  // 默认 (例如，使用 shamt 的移位)

  end

  // 寄存器写控制

  reg rf_wen_out;
  reg [4:0] rf_wdest_out;
  always @(*) begin
    rf_wen_out = ID_valid && !(inst_SW || inst_SB || inst_SH || inst_BEQ || inst_BNE || inst_BGEZ || inst_BGTZ || inst_BLEZ || inst_BLTZ || inst_J || inst_JR || inst_ERET || inst_NOP || id_exception_flag || id_interrupt_flag); // store, branch, jump, ERET, NOP 或异常/中断时不写

    if (inst_JAL) rf_wdest_out = 5'd31;  // $ra

    else if (inst_JALR) rf_wdest_out = rd;  // 目标由 rd 指定

    else if (op == 6'b000000)  // R型

      rf_wdest_out = rd;
    else  // I型 (ADDIU, SLTI, SLTIU, ANDI, ORI, XORI, LUI, LW, LB, LBU, LH, LHU)

      rf_wdest_out = rt;
  end

  // 存储器控制 (4位)

  // [3]: Load, [2]: Store, [1]: Word/Half, [0]: Half/Byte

  reg [3:0] mem_control_out;
  always @(*) begin
    mem_control_out = 4'b0;
    if (inst_LW || inst_LB || inst_LBU || inst_LH || inst_LHU)  // Load

      mem_control_out[3] = 1'b1;
    if (inst_SW || inst_SB || inst_SH)  // Store

      mem_control_out[2] = 1'b1;
    if (inst_LW || inst_SW)  // Word

      mem_control_out[1] = 1'b1;
    if (inst_LH || inst_LHU || inst_SH)  // Half

      mem_control_out[0] = 1'b1;
    // Byte 使用 [1:0] = 2'b00

  end

  // 待存储数据

  wire [31:0] store_data_out = rt_value;

  //======================== 跳转逻辑 ========================

  reg jbr_taken;
  reg [31:0] jbr_target;
  wire        br_taken = (inst_BEQ  & (rs_value == rt_value)) |

                      (inst_BNE  & (rs_value != rt_value)) |

                      (inst_BGEZ & (~rs_value[31])) |

                      (inst_BGTZ & (~rs_value[31] && (rs_value != 0))) |

                      (inst_BLEZ & ( rs_value[31] || (rs_value == 0))) |

                      (inst_BLTZ & rs_value[31]);

  wire [31:0] br_target = pc + 4 + {imm_sext[29:0], 2'b00};  // 分支目标相对于 PC+4

  wire [31:0] j_target = {pc[31:28], target, 2'b00};  // 跳转目标


  always @(*) begin
    jbr_taken = (br_taken | inst_J | inst_JAL | inst_JR | inst_JALR) && ID_valid;
    if (inst_J | inst_JAL) jbr_target = j_target;
    else if (inst_JR | inst_JALR) jbr_target = rs_value;
    else  // 分支

      jbr_target = br_target;

    jbr_bus = {jbr_taken, jbr_target};
    jbr_not_link = jbr_taken & ~(inst_JAL | inst_JALR);
  end

  //======================== 总线输出 ========================

  assign ID_over = ID_valid;  // 译码总是在一周期内完成


  always @(*) begin
    // 位宽: 2(int_type)+1(int_flag)+2(exc_type)+1(exc_flag)+13(alu_ctrl)+32(op1)+32(op2)+4(mem_ctrl)+32(store_data)+1(rf_wen)+5(rf_dest)+32(pc) = 157 bits -> [156:0]

    ID_EXE_bus = {
      id_interrupt_type,  // [156:155]

      id_interrupt_flag,  // [154]

      id_exception_type,  // [153:152]

      id_exception_flag,  // [151]

      alu_control_out,  // [150:138]

      alu_operand1_out,  // [137:106]

      alu_operand2_out,  // [105:74]

      mem_control_out,  // [73:70]

      store_data_out,  // [69:38]

      rf_wen_out,  // [37]

      rf_wdest_out,  // [36:32]

      pc  // [31:0]

    };
  end

endmodule
