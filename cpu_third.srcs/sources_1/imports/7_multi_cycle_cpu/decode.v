`timescale 1ns / 1ps
//*************************************************************************
//   > 文件名: decode.v
//   > 描述  : 多周期CPU的译码模块（支持异常处理）
//   > 作者  : LOONGSON
//   > 日期  : 2016-04-14
//   > 修改  : 添加异常处理机制（2023-10-20）+ 完整修正版（2024-03-25）
//*************************************************************************
module decode(
    // 基本输入
    input              ID_valid,      // 译码阶段有效信号
    input      [63:0]  IF_ID_bus_r,   // IF->ID总线 {PC, 指令}
    input      [31:0]  rs_value,      // 第一源操作数值
    input      [31:0]  rt_value,      // 第二源操作数值
    input              flush_pipeline,// 流水线冲刷信号
    
    // 基本输出
    output     [4:0]   rs,            // 第一源操作数地址 
    output     [4:0]   rt,            // 第二源操作数地址
    output     [32:0]  jbr_bus,       // 跳转总线 {jbr_taken, jbr_target}
    output             jbr_not_link,  // 非link类跳转指令
    output             ID_over,       // ID模块执行完成
    output     [151:0] ID_EXE_bus,    // ID->EXE总线（含异常信号）
    output     [31:0]  ID_pc,         // 当前PC值
    
    // 异常信号
    output reg         exception_flag,// 异常触发标志
    output reg [1:0]   exception_type,// 异常类型
    output             eret_executed,  // ERET执行信号
     output reg [1:0]  id_exception_type, // ID阶段异常类型
    output reg        id_exception_flag // ID阶段异常标志
);

//======================== 信号解析 ========================
// IF->ID总线解析
wire [31:0] pc;
wire [31:0] inst;
assign {pc, inst} = IF_ID_bus_r;
assign ID_pc = pc;

// 指令字段解析
wire [5:0]  op     = inst[31:26];
wire [4:0]  rs     = inst[25:21];
wire [4:0]  rt     = inst[20:16];
wire [4:0]  rd     = inst[15:11];
wire [4:0]  sa     = inst[10:6];
wire [5:0]  funct  = inst[5:0];
wire [15:0] imm    = inst[15:0];
wire [25:0] target = inst[25:0];

//======================== 指令译码 ========================
// R型指令识别
wire inst_ADDU  = (op == 6'b000000) & (funct == 6'b100001);
wire inst_SUBU  = (op == 6'b000000) & (funct == 6'b100011);
wire inst_SLT   = (op == 6'b000000) & (funct == 6'b101010);
wire inst_SLTU  = (op == 6'b000000) & (funct == 6'b101011);
wire inst_AND   = (op == 6'b000000) & (funct == 6'b100100);
wire inst_OR    = (op == 6'b000000) & (funct == 6'b100101);
wire inst_XOR   = (op == 6'b000000) & (funct == 6'b100110);
wire inst_NOR   = (op == 6'b000000) & (funct == 6'b100111);
wire inst_SLL   = (op == 6'b000000) & (funct == 6'b000000);
wire inst_SRL   = (op == 6'b000000) & (funct == 6'b000010);
wire inst_SRA   = (op == 6'b000000) & (funct == 6'b000011);
wire inst_SLLV  = (op == 6'b000000) & (funct == 6'b000100);
wire inst_SRLV  = (op == 6'b000000) & (funct == 6'b000110);
wire inst_SRAV  = (op == 6'b000000) & (funct == 6'b000111);
wire inst_JR    = (op == 6'b000000) & (funct == 6'b001000);
wire inst_JALR  = (op == 6'b000000) & (funct == 6'b001001);
wire inst_div   = (op == 6'b000000) & (funct == 6'b011010);

// I型指令识别
wire inst_ADDIU = (op == 6'b001001);
wire inst_SLTI  = (op == 6'b001010);
wire inst_SLTIU = (op == 6'b001011);
wire inst_ANDI  = (op == 6'b001100);
wire inst_ORI   = (op == 6'b001101);
wire inst_XORI  = (op == 6'b001110);
wire inst_LUI   = (op == 6'b001111) & (rs == 5'b0);
wire inst_LW    = (op == 6'b100011);
wire inst_SW    = (op == 6'b101011);
wire inst_LB    = (op == 6'b100000);
wire inst_LBU   = (op == 6'b100100);
wire inst_LH    = (op == 6'b100001);
wire inst_LHU   = (op == 6'b100101);
wire inst_SB    = (op == 6'b101000);
wire inst_SH    = (op == 6'b101001);
wire inst_BEQ   = (op == 6'b000100);
wire inst_BNE   = (op == 6'b000101);
wire inst_BGEZ  = (op == 6'b000001) & (rt == 5'b00001);
wire inst_BGTZ  = (op == 6'b000111) & (rt == 5'b00000);
wire inst_BLEZ  = (op == 6'b000110) & (rt == 5'b00000);
wire inst_BLTZ  = (op == 6'b000001) & (rt == 5'b00000);

// J型指令识别
wire inst_J     = (op == 6'b000010);
wire inst_JAL   = (op == 6'b000011);

// 特殊指令
wire inst_ERET  = (op == 6'b010000) & (funct == 6'b011000);
assign eret_executed = inst_ERET;

//======================== 异常处理 ========================
wire valid_instruction = inst_ADDU | inst_SUBU | inst_SLT | inst_SLTU | 
                        inst_AND | inst_OR | inst_XOR | inst_NOR | 
                        inst_SLL | inst_SRL | inst_SRA | inst_SLLV | 
                        inst_SRLV | inst_SRAV | inst_JR | inst_JALR | 
                        inst_ADDIU | inst_SLTI | inst_SLTIU | inst_ANDI | 
                        inst_ORI | inst_XORI | inst_LUI | inst_LW | inst_SW | 
                        inst_LB | inst_LBU | inst_LH | inst_LHU | inst_SB | 
                        inst_SH | inst_BEQ | inst_BNE | inst_BGEZ | inst_BGTZ | 
                        inst_BLEZ | inst_BLTZ | inst_J | inst_JAL | inst_div | 
                        inst_ERET;

always @(*) begin
    exception_flag = 1'b0;
    exception_type = 2'b00;
    if (ID_valid && !flush_pipeline && !valid_instruction) begin
        exception_flag = 1'b1;
        exception_type = 2'b01; // 非法指令
    end
    // debug输出
    // synthesis translate_off
    if (ID_valid && !flush_pipeline)
        $display("decode: inst=%h, valid=%b, exception_flag=%b, exception_type=%b", inst, valid_instruction, exception_flag, exception_type);
    // synthesis translate_on
end

always @(*) begin
    id_exception_type = exception_type; // 内部信号 -> 输出端口
    id_exception_flag = exception_flag;
end

//======================== 控制信号生成 ========================
// ALU控制信号
reg [3:0] alu_control;
always @(*) begin
    case(op)
        6'b000000: begin // R-type
            case(funct)
                6'b100001: alu_control = 4'b0001; // ADDU
                6'b100011: alu_control = 4'b0010; // SUBU
                6'b101010: alu_control = 4'b0011; // SLT
                6'b101011: alu_control = 4'b0100; // SLTU
                6'b100100: alu_control = 4'b0101; // AND
                6'b100101: alu_control = 4'b0110; // OR
                6'b100110: alu_control = 4'b0111; // XOR
                6'b100111: alu_control = 4'b1000; // NOR
                default:   alu_control = 4'b0000;
            endcase
        end
        6'b001001: alu_control = 4'b0001; // ADDIU
        6'b001010: alu_control = 4'b0011; // SLTI
        6'b001011: alu_control = 4'b0100; // SLTIU
        6'b001100: alu_control = 4'b0101; // ANDI
        6'b001101: alu_control = 4'b0110; // ORI
        6'b001110: alu_control = 4'b0111; // XORI
        6'b001111: alu_control = 4'b1001; // LUI
        default:    alu_control = 4'b0000;
    endcase
end

// 寄存器控制
wire [31:0] imm_ext = (op == 6'b001100 || op == 6'b001101 || op == 6'b001110) ? 
                     {16'b0, imm} : {{16{imm[15]}}, imm}; // 立即数扩展

wire [31:0] alu_operand1 = (inst_SLL | inst_SRL | inst_SRA) ? {27'b0, sa} : rs_value;
wire [31:0] alu_operand2 = (op == 6'b000000) ? rt_value : imm_ext;

wire rf_wen = ID_valid && !flush_pipeline && 
             !(inst_SW | inst_SB | inst_SH | inst_BEQ | inst_BNE | 
              inst_J | inst_JR | inst_ERET);

wire [4:0] rf_wdest = inst_JAL  ? 5'd31 : 
                     inst_JALR ? rd    : 
                     (op == 6'b000000) ? rd : rt;

// 存储器控制
wire        load_flag  = inst_LW | inst_LB | inst_LBU | inst_LH | inst_LHU;
wire        store_flag = inst_SW | inst_SB | inst_SH;
wire [1:0]  data_type;
assign data_type = (inst_LW | inst_SW)  ? 2'b10 : // 字
                  (inst_LH | inst_LHU | inst_SH) ? 2'b01 : // 半字
                  (inst_LB | inst_LBU | inst_SB) ? 2'b00 : // 字节
                  2'b00;
wire [3:0] mem_control = {load_flag, store_flag, data_type};
wire [31:0] store_data = rt_value;

//======================== 跳转逻辑 ========================
wire        jbr_taken;
wire [31:0] jbr_target;
wire        br_taken = (inst_BEQ  & (rs_value == rt_value)) |
                      (inst_BNE  & (rs_value != rt_value)) |
                      (inst_BGEZ & (~rs_value[31])) |
                      (inst_BGTZ & (~rs_value[31] && (rs_value != 0))) |
                      (inst_BLEZ & ( rs_value[31] || (rs_value == 0))) |
                      (inst_BLTZ & rs_value[31]);

wire [31:0] br_target = pc + {{14{imm[15]}}, imm, 2'b00};
wire [31:0] j_target  = {pc[31:28], target, 2'b00};

assign jbr_taken  = br_taken | inst_J | inst_JAL | inst_JR | inst_JALR;
assign jbr_target  = (inst_J | inst_JAL) ? j_target : 
                    (inst_JR | inst_JALR) ? rs_value : br_target;
assign jbr_bus = flush_pipeline ? 33'b0 : {jbr_taken, jbr_target};  // 冲刷时清零跳转总线
assign jbr_not_link = jbr_taken & ~(inst_JAL | inst_JALR);

//======================== 总线输出 ========================
assign ID_over = ID_valid & ~flush_pipeline;  // 冲刷时无效
assign ID_EXE_bus = flush_pipeline ? 152'b0 : {  // 冲刷时清零总线
    exception_type,     // [151:150]
    exception_flag,     // [149]
    alu_control,        // [148:145]
    4'b0,               // 补齐4位
    alu_operand1,       // [144:113]
    alu_operand2,       // [112:81]
    mem_control,        // [80:77]
    store_data,         // [76:45]
    rf_wen,             // [44]
    rf_wdest,           // [43:39]
    pc                  // [38:7]
};

endmodule