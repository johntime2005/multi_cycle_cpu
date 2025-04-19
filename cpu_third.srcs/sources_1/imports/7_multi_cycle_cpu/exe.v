`timescale 1ns / 1ps
//*************************************************************************
//   > 文件名: exe.v
//   > 描述  : 多周期CPU的执行模块（支持异常处理）
//   > 作者  : LOONGSON
//   > 日期  : 2016-04-14
//   > 修改  : 添加对改进后的ALU的适配和异常处理机制（2023-10-20）
//*************************************************************************
module exe(
    // 基础信号
    input              EXE_valid,     // 执行阶段有效信号
    input      [151:0] ID_EXE_bus_r,  // ID->EXE总线（扩展异常信号）
    output             EXE_over,      // EXE模块执行完成
    output     [107:0] EXE_MEM_bus,   // EXE->MEM总线（扩展异常信号）
    output     [31:0]  EXE_pc,        // 当前PC值（用于显示）

    // 新增异常信号
    output reg         div_by_zero,   // 除零异常标志
    output reg         overflow_flag, // 溢出异常标志
    output reg [1:0]   exception_type // 异常类型（10=除零，11=溢出）
);

//-----{ID->EXE总线解析}begin---------------------------------------
// 扩展后的总线定义：
// [151:150] exception_type_from_id
// [149]     exception_flag_from_id
// [148:0]  原有总线信号
wire [1:0]  exception_type_from_id;  // ID阶段传递的异常类型
wire        exception_flag_from_id;  // ID阶段传递的异常标志
wire [11:0] alu_control;             // ALU控制信号
wire [31:0] alu_operand1;            // ALU操作数1
wire [31:0] alu_operand2;            // ALU操作数2
wire [3:0]  mem_control;             // MEM控制信号
wire [31:0] store_data;              // 存储数据
wire        rf_wen;                  // 寄存器写使能
wire [4:0]  rf_wdest;                // 目标寄存器地址
wire [31:0] pc;                      // PC值

assign {
    exception_type_from_id,  // [151:150]
    exception_flag_from_id,  // [149]
    alu_control,             // [148:137]
    alu_operand1,            // [136:105]
    alu_operand2,            // [104:73]
    mem_control,             // [72:69]
    store_data,              // [68:37]
    rf_wen,                  // [36]
    rf_wdest,                // [35:31]
    pc                       // [30:0]
} = ID_EXE_bus_r;
//-----{ID->EXE总线解析}end-----------------------------------------

//-----{ALU实例化}begin---------------------------------------------
wire [31:0] alu_result;       // ALU运算结果
wire        alu_overflow;     // ALU溢出标志

alu alu_module(
    .alu_control  (alu_control),    // ALU控制信号
    .alu_src1     (alu_operand1),   // 操作数1
    .alu_src2     (alu_operand2),   // 操作数2
    .alu_result   (alu_result),     // 运算结果
    .overflow_flag(alu_overflow)    // 溢出标志
);
//-----{ALU实例化}end-----------------------------------------------

//-----{异常检测}begin---------------------------------------------
always @(*) begin
    // 初始化异常标志
    div_by_zero = 1'b0;
    overflow_flag = 1'b0;
    exception_type = 2'b00;

    // 检测除零异常（假设alu_control[8]表示除法）
    if (EXE_valid && alu_control[12] && (alu_operand2 == 32'd0)) begin
        div_by_zero = 1'b1;          // 触发除零异常
        exception_type = 2'b10;      // 异常类型：除零
    end
    // 检测溢出异常（加法或减法）
    else if (EXE_valid && alu_overflow) begin
        overflow_flag = 1'b1;        // 触发溢出异常
        exception_type = 2'b11;      // 异常类型：溢出
    end
end
//-----{异常检测}end------------------------------------------------

//-----{异常信号合并}begin-------------------------------------------
// 优先级：EXE阶段异常 > ID阶段异常
wire        exception_flag = div_by_zero | overflow_flag | exception_flag_from_id;
wire [1:0]  exception_type_final = div_by_zero ? 2'b10 :
                                   overflow_flag ? 2'b11 :
                                   exception_type_from_id;
//-----{异常信号合并}end---------------------------------------------

//-----{EXE执行完成标志}begin----------------------------------------
assign EXE_over = EXE_valid;  // EXE阶段一周期完成
//-----{EXE执行完成标志}end------------------------------------------

//-----{EXE->MEM总线生成}begin---------------------------------------
// 扩展后的总线定义：
// [107:106] exception_type
// [105]     exception_flag
// [104:0]  原有总线信号
assign EXE_MEM_bus = {
    exception_type_final,  // [107:106] 异常类型
    exception_flag,        // [105]     异常标志
    mem_control,           // [104:101] MEM控制
    store_data,            // [100:69]  存储数据
    alu_result,            // [68:37]   ALU结果
    rf_wen,                // [36]      寄存器写使能
    rf_wdest,              // [35:31]   目标寄存器地址
    pc                     // [30:0]    PC值
};
//-----{EXE->MEM总线生成}end-----------------------------------------

//-----{显示信号}begin-----------------------------------------------
assign EXE_pc = pc;  // 输出当前PC值
//-----{显示信号}end-------------------------------------------------

endmodule