`timescale 1ns / 1ps
//*************************************************************************
//   > 文件名: exe.v
//   > 描述  : 多周期CPU的执行模块（支持异常处理）
//   > 作者  : LOONGSON
//   > 日期  : 2016-04-14
//   > 修改  : 添加对改进后的ALU的适配和异常处理机制（2023-10-20）
//            优化异常信号输出（2024-03-25）
//*************************************************************************
module exe(
    // 基础信号
    input              EXE_valid,     // 执行阶段有效信号
    input      [151:0] ID_EXE_bus_r,  // ID->EXE总线（扩展异常信号）
    output             EXE_over,      // EXE模块执行完成
    output     [107:0] EXE_MEM_bus,   // EXE->MEM总线（扩展异常信号）
    output     [31:0]  EXE_pc,        // 当前PC值（用于显示）
    input              flush_pipeline, // 冲刷流水线信号

    // 异常信号输出
    output reg [1:0]   exe_exception_type,  // EXE阶段异常类型（10=除零，11=溢出）
    output reg         exe_exception_flag   // EXE阶段异常标志
);

//-----{ID->EXE总线解析}begin---------------------------------------
wire [1:0]  exception_type_from_id;  // ID阶段传递的异常类型
wire        exception_flag_from_id;  // ID阶段传递的异常标志
wire [12:0] alu_control;             // ALU控制信号（修正为13位）
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
    alu_control,             // [148:136] 修正为13位
    alu_operand1,            // [135:104]
    alu_operand2,            // [103:72]
    mem_control,             // [71:68]
    store_data,              // [67:36]
    rf_wen,                  // [35]
    rf_wdest,                // [34:30]
    pc                       // [29:0]
} = ID_EXE_bus_r;
//-----{ID->EXE总线解析}end-----------------------------------------

//-----{ALU实例化}begin---------------------------------------------
wire [31:0] alu_result;       // ALU运算结果
wire        alu_overflow;     // ALU溢出标志

alu alu_module(
    .alu_control  (alu_control),    // ALU控制信号
    .alu_src1     (alu_operand1),   // 操作数1
    .alu_src2     (alu_operand2),   // 操作数2
    .alu_result   (alu_result) // 运算结果
   
);
//-----{ALU实例化}end-----------------------------------------------

//-----{异常检测逻辑}begin------------------------------------------
// 检测除零异常（假设alu_control[12]表示除法操作）
wire div_by_zero = EXE_valid & alu_control[12] & (alu_operand2 == 32'd0);

// 合并异常信号（优先级：EXE异常 > ID异常）
always @(*) begin
    // 默认值
    exe_exception_flag = 1'b0;
    exe_exception_type = 2'b00;

    // EXE阶段异常优先级最高
    if (div_by_zero) begin
        exe_exception_flag = 1'b1;
        exe_exception_type = 2'b10;  // 除零异常
    end
    else if (EXE_valid & alu_overflow) begin  // 直接使用alu_overflow信号
        exe_exception_flag = 1'b1;
        exe_exception_type = 2'b11;  // 溢出异常
    end
    // 传递ID阶段的异常（如果存在）
    else if (exception_flag_from_id) begin
        exe_exception_flag = exception_flag_from_id;
        exe_exception_type = exception_type_from_id;
    end
end
//-----{异常检测逻辑}end--------------------------------------------

//-----{EXE执行完成标志}begin----------------------------------------
assign EXE_over = flush_pipeline ? 1'b0 : EXE_valid; // 冲刷流水线时无效
//-----{EXE执行完成标志}end------------------------------------------

//-----{EXE->MEM总线生成}begin---------------------------------------
assign EXE_MEM_bus = flush_pipeline ? 108'b0 : {
    exe_exception_type,  // [107:106] 异常类型
    exe_exception_flag,  // [105]     异常标志
    mem_control,         // [104:101] MEM控制
    store_data,          // [100:69]  存储数据
    alu_result,          // [68:37]   ALU结果
    rf_wen,              // [36]      寄存器写使能
    rf_wdest,            // [35:31]   目标寄存器地址
    pc                   // [30:0]    PC值
};
//-----{EXE->MEM总线生成}end-----------------------------------------

//-----{显示信号}begin-----------------------------------------------
assign EXE_pc = pc;  // 输出当前PC值
//-----{显示信号}end-------------------------------------------------

endmodule