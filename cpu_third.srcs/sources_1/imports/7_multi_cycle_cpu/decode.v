`timescale 1ns / 1ps
//*************************************************************************
//   > 文件名: decode.v
//   > 描述  : 多周期CPU的译码模块（支持异常处理）
//   > 作者  : LOONGSON
//   > 日期  : 2016-04-14
//   > 修改  : 添加异常处理机制（2023-10-20）
//*************************************************************************
module decode(                      // 译码模块
    input              ID_valid,    // 译码阶段有效信号
    input      [63:0]  IF_ID_bus_r, // IF->ID总线 {PC, 指令}
    input      [31:0]  rs_value,    // 第一源操作数值
    input      [31:0]  rt_value,    // 第二源操作数值
    output     [4:0]   rs,          // 第一源操作数地址 
    output     [4:0]   rt,          // 第二源操作数地址
    output     [32:0]  jbr_bus,     // 跳转总线 {jbr_taken, jbr_target}
    output             jbr_not_link,// 指令为跳转分支指令,且非link类指令
    output             ID_over,     // ID模块执行完成
    output     [151:0] ID_EXE_bus,  // ID->EXE总线（扩展异常信号）
    output     [31:0]  ID_pc,       // 当前PC值（用于显示）

    // 新增异常信号
    output reg         exception_flag,  // 异常触发标志
    output reg [1:0]   exception_type,  // 异常类型（01=非法指令）
    output             eret_executed    // ERET指令执行信号
);

//-----{IF->ID总线解析}begin---------------------------------------
wire [31:0] pc;
wire [31:0] inst;
assign {pc, inst} = IF_ID_bus_r;  // 解析PC和指令
//-----{IF->ID总线解析}end-----------------------------------------

//-----{指令译码（操作码解析）}begin-------------------------------
wire [5:0] op;        // 操作码
wire [4:0] rd;        // 目标操作数地址
wire [4:0] sa;        // 移位量
wire [5:0] funct;     // 功能码
wire [15:0] imm;      // 立即数
wire [15:0] offset;   // 地址偏移
wire [25:0] target;   // 跳转目标地址

assign op     = inst[31:26];  // 操作码
assign rs     = inst[25:21];  // 源操作数1地址
assign rt     = inst[20:16];  // 源操作数2地址
assign rd     = inst[15:11];  // 目标操作数地址
assign sa     = inst[10:6];   // 移位量
assign funct  = inst[5:0];    // 功能码
assign imm    = inst[15:0];   // 立即数
assign offset = inst[15:0];   // 地址偏移
assign target = inst[25:0];   // 跳转目标地址

//-----{指令类型识别}begin-----------------------------------------
// 合法指令定义（覆盖所有支持的指令）
wire inst_ADDU, inst_SUBU, inst_SLT, inst_AND;
wire inst_NOR, inst_OR, inst_XOR, inst_SLL;
wire inst_SRL, inst_ADDIU, inst_BEQ, inst_BNE;
wire inst_LW, inst_SW, inst_LUI, inst_J;
wire inst_SLTU, inst_JALR, inst_JR, inst_SLLV;
wire inst_SRA, inst_SRAV, inst_SRLV, inst_SLTIU;
wire inst_SLTI, inst_BGEZ, inst_BGTZ, inst_BLEZ;
wire inst_BLTZ, inst_LB, inst_LBU, inst_SB;
wire inst_ANDI, inst_ORI, inst_XORI, inst_JAL;

wire op_zero;  // 操作码全0（R型指令）
wire sa_zero;  // sa域全0
assign op_zero = ~(|op);
assign sa_zero = ~(|sa);

// R型指令识别
assign inst_ADDU  = op_zero & sa_zero    & (funct == 6'b100001); // 无符号加
assign inst_SUBU  = op_zero & sa_zero    & (funct == 6'b100011); // 无符号减
assign inst_SLT   = op_zero & sa_zero    & (funct == 6'b101010); // 有符号小于置位
assign inst_SLTU  = op_zero & sa_zero    & (funct == 6'b101011); // 无符号小于置位
assign inst_JALR  = op_zero & (rt==5'd0) & (rd==5'd31) & sa_zero & (funct == 6'b001001); // 跳转并链接
assign inst_JR    = op_zero & (rt==5'd0) & (rd==5'd0)  & sa_zero & (funct == 6'b001000); // 跳转
assign inst_AND   = op_zero & sa_zero    & (funct == 6'b100100); // 逻辑与
assign inst_NOR   = op_zero & sa_zero    & (funct == 6'b100111); // 逻辑或非
assign inst_OR    = op_zero & sa_zero    & (funct == 6'b100101); // 逻辑或
assign inst_XOR   = op_zero & sa_zero    & (funct == 6'b100110); // 逻辑异或
assign inst_SLL   = op_zero & (rs==5'd0) & (funct == 6'b000000); // 逻辑左移
assign inst_SLLV  = op_zero & sa_zero    & (funct == 6'b000100); // 变量逻辑左移
assign inst_SRA   = op_zero & (rs==5'd0) & (funct == 6'b000011); // 算术右移
assign inst_SRAV  = op_zero & sa_zero    & (funct == 6'b000111); // 变量算术右移
assign inst_SRL   = op_zero & (rs==5'd0) & (funct == 6'b000010); // 逻辑右移
assign inst_SRLV  = op_zero & sa_zero    & (funct == 6'b000110); // 变量逻辑右移

// I型指令识别
assign inst_ADDIU = (op == 6'b001001);              // 无符号立即数加
assign inst_SLTI  = (op == 6'b001010);              // 有符号立即数小于置位
assign inst_SLTIU = (op == 6'b001011);              // 无符号立即数小于置位
assign inst_BEQ   = (op == 6'b000100);              // 等于分支
assign inst_BGEZ  = (op == 6'b000001) & (rt==5'd1); // 大于等于零分支
assign inst_BGTZ  = (op == 6'b000111) & (rt==5'd0); // 大于零分支
assign inst_BLEZ  = (op == 6'b000110) & (rt==5'd0); // 小于等于零分支
assign inst_BLTZ  = (op == 6'b000001) & (rt==5'd0); // 小于零分支
assign inst_BNE   = (op == 6'b000101);              // 不等于分支
assign inst_LW    = (op == 6'b100011);              // 加载字
assign inst_SW    = (op == 6'b101011);              // 存储字
assign inst_LB    = (op == 6'b100000);              // 加载字节（符号扩展）
assign inst_LBU   = (op == 6'b100100);              // 加载字节（无符号扩展）
assign inst_SB    = (op == 6'b101000);              // 存储字节
assign inst_ANDI  = (op == 6'b001100);              // 立即数逻辑与
assign inst_LUI   = (op == 6'b001111) & (rs==5'd0); // 立即数加载高位
assign inst_ORI   = (op == 6'b001101);              // 立即数逻辑或
assign inst_XORI  = (op == 6'b001110);              // 立即数逻辑异或

// J型指令识别
assign inst_J     = (op == 6'b000010);              // 跳转
assign inst_JAL   = (op == 6'b000011);              // 跳转并链接

//-----{ERET指令识别（COP0指令）}begin-----------------------------
wire inst_ERET = (op == 6'b010000) && (funct == 6'b011000); // ERET指令
assign eret_executed = inst_ERET;  // 输出ERET执行信号
//-----{ERET指令识别}end-------------------------------------------

//-----{非法指令检测}begin-----------------------------------------
// 检查指令是否未被任何合法指令覆盖
wire valid_instruction = 
    inst_ADDU | inst_SUBU | inst_SLT | inst_SLTU | inst_JALR | inst_JR |
    inst_AND | inst_NOR | inst_OR | inst_XOR | inst_SLL | inst_SLLV |
    inst_SRA | inst_SRAV | inst_SRL | inst_SRLV | inst_ADDIU | inst_SLTI |
    inst_SLTIU | inst_BEQ | inst_BGEZ | inst_BGTZ | inst_BLEZ | inst_BLTZ |
    inst_BNE | inst_LW | inst_SW | inst_LB | inst_LBU | inst_SB | inst_ANDI |
    inst_LUI | inst_ORI | inst_XORI | inst_J | inst_JAL | inst_ERET;

always @(*) begin
    if (ID_valid && !valid_instruction) begin  // 仅在译码有效时检测
        exception_flag = 1'b1;
        exception_type = 2'b01;  // 异常类型：非法指令
    end else begin
        exception_flag = 1'b0;
        exception_type = 2'b00;  // 无异常
    end
end
//-----{非法指令检测}end-------------------------------------------

//-----{跳转逻辑}begin---------------------------------------------
wire inst_jr;     // 寄存器跳转指令
wire inst_j_link; // 链接跳转指令
assign inst_jr     = inst_JALR | inst_JR;
assign inst_j_link = inst_JAL  | inst_JALR;
assign jbr_not_link= inst_J    | inst_JR | inst_BEQ | inst_BNE | 
                     inst_BGEZ | inst_BGTZ | inst_BLEZ | inst_BLTZ;

// 跳转目标计算
wire        j_taken;
wire [31:0] j_target;
assign j_taken = inst_J | inst_JAL | inst_jr;
assign j_target = inst_jr ? rs_value : {pc[31:28], target, 2'b00};

// 分支逻辑
wire rs_equal_rt = (rs_value == rt_value);
wire rs_ez       = ~(|rs_value);
wire rs_ltz      = rs_value[31];
wire br_taken;
wire [31:0] br_target;
assign br_taken = inst_BEQ  & rs_equal_rt    |
                  inst_BNE  & ~rs_equal_rt   |
                  inst_BGEZ & ~rs_ltz        |
                  inst_BGTZ & ~rs_ltz & ~rs_ez |
                  inst_BLEZ & (rs_ltz | rs_ez) |
                  inst_BLTZ & rs_ltz;
assign br_target[31:2] = pc[31:2] + {{14{offset[15]}}, offset};
assign br_target[1:0]  = pc[1:0];

// 跳转总线生成
wire jbr_taken;
wire [31:0] jbr_target;
assign jbr_taken  = j_taken | br_taken;
assign jbr_target = j_taken ? j_target : br_target;
assign jbr_bus = {jbr_taken, jbr_target};
//-----{跳转逻辑}end-----------------------------------------------

//-----{ID执行完成标志}begin----------------------------------------
assign ID_over = ID_valid;  // ID阶段一周期完成
//-----{ID执行完成标志}end------------------------------------------

//-----{ID->EXE总线生成}begin---------------------------------------
// ALU操作数生成
wire [11:0] alu_control;
wire [31:0] alu_operand1;
wire [31:0] alu_operand2;
assign alu_operand1 = inst_j_link ? pc : 
                      inst_shf_sa ? {27'd0, sa} : rs_value;
assign alu_operand2 = inst_j_link ? 32'd4 :
                      inst_imm_zero ? {16'd0, imm} :
                      inst_imm_sign ? {{16{imm[15]}}, imm} : rt_value;

// ALU控制信号
assign alu_control = {
    inst_add,   // [11] 加
    inst_sub,   // [10] 减
    inst_slt,   // [9]  有符号小于置位
    inst_sltu,  // [8]  无符号小于置位
    inst_and,   // [7]  逻辑与
    inst_nor,   // [6]  逻辑或非
    inst_or,    // [5]  逻辑或
    inst_xor,   // [4]  逻辑异或
    inst_sll,   // [3]  逻辑左移
    inst_srl,   // [2]  逻辑右移
    inst_sra,   // [1]  算术右移
    inst_lui    // [0]  加载高位
};

// MEM控制信号
wire lb_sign = inst_LB;
wire ls_word = inst_LW | inst_SW;
wire [3:0] mem_control = {inst_load, inst_store, ls_word, lb_sign};

// 寄存器回写控制
wire inst_wdest_rt = inst_imm_zero | inst_ADDIU | inst_SLTI | 
                     inst_SLTIU | inst_load;
wire inst_wdest_31 = inst_JAL;
wire inst_wdest_rd = inst_ADDU | inst_SUBU | inst_SLT | inst_SLTU | 
                     inst_JALR | inst_AND | inst_NOR | inst_OR | 
                     inst_XOR | inst_SLL | inst_SLLV | inst_SRA | 
                     inst_SRAV | inst_SRL | inst_SRLV;
wire rf_wen = inst_wdest_rt | inst_wdest_31 | inst_wdest_rd;
wire [4:0] rf_wdest = inst_wdest_rt ? rt :
                      inst_wdest_31 ? 5'd31 :
                      inst_wdest_rd ? rd : 5'd0;

// 存储数据
wire [31:0] store_data = rt_value;

// ID->EXE总线（扩展异常信号）
assign ID_EXE_bus = {
    exception_type,     // [151:150] 异常类型
    exception_flag,     // [149]     异常标志
    alu_control,        // [148:137] ALU控制
    alu_operand1,       // [136:105] ALU操作数1
    alu_operand2,       // [104:73]  ALU操作数2
    mem_control,        // [72:69]   MEM控制
    store_data,         // [68:37]   存储数据
    rf_wen,             // [36]      寄存器写使能
    rf_wdest,           // [35:31]   目标寄存器地址
    pc                  // [30:0]    PC值
};
//-----{ID->EXE总线生成}end-----------------------------------------

//-----{显示信号}begin----------------------------------------------
assign ID_pc = pc;  // 输出当前PC值
//-----{显示信号}end------------------------------------------------

endmodule