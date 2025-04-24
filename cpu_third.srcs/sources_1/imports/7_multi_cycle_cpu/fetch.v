`timescale 1ns / 1ps
//*************************************************************************
//   > 文件名: fetch.v
//   > 描述  : 多周期CPU的取指模块（支持异常处理）
//   > 作者  : LOONGSON
//   > 日期  : 2016-04-14
//   > 修改  : 添加异常处理机制（2023-10-20）
//*************************************************************************
`define STARTADDR     32'd0       // 程序起始地址为0
`define EXCEPTION_VEC 32'h80000080 // MIPS标准异常入口地址

module fetch(
    // 基础信号
    input             clk,        // 时钟
    input             resetn,     // 复位信号，低电平有效
    input             IF_valid,   // 取指阶段有效信号
    input             next_fetch, // 取下一条指令，用于锁存PC值
    
    // 指令和数据
    input      [31:0] inst,       // 从inst_rom取出的指令
    input      [32:0] jbr_bus,    // 跳转总线 {jbr_taken, jbr_target}
    
    // 异常处理新增信号
    input             exception_triggered, // 异常触发信号（来自控制模块）
    input      [31:0] EPC,        // 异常程序计数器（来自regfile.v）
    input             eret_executed, // ERET指令执行信号
    
    // 输出信号
    output     [31:0] inst_addr,  // 发往inst_rom的取指地址
    output reg        IF_over,    // IF模块执行完成
    output     [63:0] IF_ID_bus,  // IF->ID总线 {PC, inst}
    output     [31:0] IF_pc,      // 当前PC值（用于显示）
    output     [31:0] IF_inst     // 当前指令（用于显示）
);

//-----{程序计数器PC}begin---------------------------------------------
    reg  [31:0] pc;               // PC寄存器
    wire [31:0] next_pc;          // 下一周期PC值
    wire [31:0] seq_pc;           // 顺序PC值（PC+4）
    wire        jbr_taken;        // 跳转使能
    wire [31:0] jbr_target;       // 跳转目标地址
    reg         flush_pipeline;   // 流水线冲刷标志
    
    assign {jbr_taken, jbr_target} = jbr_bus; // 解析跳转总线
    
    // 计算顺序PC（PC+4）
    assign seq_pc[31:2] = pc[31:2] + 1'b1;
    assign seq_pc[1:0]  = pc[1:0];
    
    // 下一PC值优先级：异常 > ERET > 跳转 > 顺序执行
    assign next_pc = exception_triggered ? `EXCEPTION_VEC : // 异常跳转
                     eret_executed       ? EPC :            // ERET返回
                     jbr_taken           ? jbr_target :     // 分支/跳转
                                           seq_pc;          // 顺序执行
    
    // PC寄存器更新
    always @(posedge clk) begin
        if (!resetn) begin
            pc <= `STARTADDR;     // 复位时PC初始化为0
            flush_pipeline <= 1'b0; // 清空流水线
        end
        else if (next_fetch) begin
            pc <= next_pc;        // 正常更新PC
            flush_pipeline <= eret_executed || exception_triggered; // 冲刷流水线
        end
    end
    
    // 输出当前PC值（用于保存到EPC）
    assign IF_pc = pc;
//-----{程序计数器PC}end-----------------------------------------------

//-----{发往inst_rom的取指地址}begin------------------------------------
    assign inst_addr = pc;        // 直接输出PC值
//-----{发往inst_rom的取指地址}end--------------------------------------

//-----{IF执行完成标志}begin-------------------------------------------
    always @(posedge clk) begin
        if (flush_pipeline) begin
            IF_over <= 1'b0;      // 冲刷流水线时，标志无效
        end else begin
            IF_over <= IF_valid;  // IF_valid延迟一拍作为完成标志
        end
    end
//-----{IF执行完成标志}end---------------------------------------------

//-----{IF->ID总线}begin-----------------------------------------------
    assign IF_ID_bus = flush_pipeline ? 64'b0 : {pc, inst}; // 冲刷流水线时清空总线
    assign IF_inst   = flush_pipeline ? 32'b0 : inst;      // 冲刷流水线时清空指令
    assign IF_pc     = flush_pipeline ? 32'b0 : pc;        // 冲刷流水线时清空PC
//-----{IF->ID总线}end-------------------------------------------------

endmodule