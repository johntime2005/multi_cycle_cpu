`timescale 1ns / 1ps
//*************************************************************************
//   > 文件名: fetch.v
//   > 描述  : 多周期CPU的取指模块（支持异常处理）
//   > 作者  : LOONGSON
//   > 日期  : 2016-04-14
//   > 修改  : 添加异常处理机制（2023-10-20）
//*************************************************************************
// `define STARTADDR     32'd0       // 程序起始地址为0 (使用 32'hbfc00000)
`define RESET_ADDR    32'hbfc00000 // MIPS 复位地址

module fetch(
    // 基础信号
    input             clk,        // 时钟
    input             resetn,     // 复位信号，低电平有效
    input             IF_valid,   // 取指阶段有效信号
    input             next_fetch, // 取下一条指令，用于锁存PC值

    // 指令和数据
    input      [31:0] inst,       // 从inst_rom取出的指令
    input      [32:0] jbr_bus,    // 跳转总线 {jbr_taken, jbr_target}

    // 异常/中断/ERET 处理信号
    input             exception_triggered, // 异常/中断触发信号 (来自 exception_controller)
    input      [31:0] exception_vector_pc, // 异常向量地址 (来自 exception_controller)
    input             eret_executed,       // 新增: ERET指令执行信号 (来自 decode)
    input      [31:0] cp0_epc_out,         // 新增: 从 CP0 读出的 EPC

    // 输出信号
    output     [31:0] inst_addr,  // 发往inst_rom的取指地址
    output            IF_over,    // IF模块执行完成 (改为组合逻辑)
    output     [63:0] IF_ID_bus,  // IF->ID总线 {指令, PC}
    output     [31:0] IF_pc,      // 当前PC值（用于显示）
    output     [31:0] IF_inst     // 当前指令（用于显示）
);

//-----{程序计数器PC}begin---------------------------------------------
    reg  [31:0] pc_reg;           // PC寄存器
    wire [31:0] next_pc;          // 下一周期PC值
    wire [31:0] pc_plus_4;        // 顺序PC值（PC+4）
    wire        jbr_taken;        // 跳转使能
    wire [31:0] jbr_target;       // 跳转目标地址

    assign {jbr_taken, jbr_target} = jbr_bus; // 解析跳转总线

    // 计算顺序PC（PC+4）
    assign pc_plus_4 = pc_reg + 4;

    // 下一PC值优先级：复位 > 异常/中断 > ERET > 跳转 > 顺序执行
    assign next_pc = !resetn             ? `RESET_ADDR :         // 复位
                     exception_triggered ? exception_vector_pc : // 异常/中断跳转
                     eret_executed       ? cp0_epc_out :         // ERET 跳转到 EPC
                     jbr_taken           ? jbr_target :          // 分支/跳转
                                           pc_plus_4;             // 顺序执行

    // PC寄存器更新
    always @(posedge clk) begin
        if (!resetn) begin
            pc_reg <= `RESET_ADDR;     // 复位时PC初始化
        end else if (next_fetch || exception_triggered || eret_executed) begin // 在需要取下一条指令、发生异常或执行ERET时更新PC
            pc_reg <= next_pc;
        end
        // else: 保持 PC 不变 (例如当前指令未完成，或流水线暂停)
    end

    // 输出当前 PC 值
    assign IF_pc = pc_reg;
//-----{程序计数器PC}end-----------------------------------------------

//-----{发往inst_rom的取指地址}begin------------------------------------
    assign inst_addr = pc_reg;        // 直接输出PC值
//-----{发往inst_rom的取指地址}end--------------------------------------

//-----{IF执行完成标志}begin-------------------------------------------
    // 简化：假设取指总是在 IF_valid 有效时完成
    assign IF_over = IF_valid;
//-----{IF执行完成标志}end---------------------------------------------

//-----{IF->ID总线}begin-----------------------------------------------
    // IF->ID 总线: {指令, pc}
    // 在 multi_cycle_cpu.v 中处理异常时的清零
    assign IF_ID_bus = {inst, pc_reg};
    assign IF_inst   = inst; // 直接透传指令用于显示
//-----{IF->ID总线}end-------------------------------------------------

endmodule