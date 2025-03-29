`timescale 1ns / 1ps

//**************************************************************
//  > 文件名: exception_controller.v
//  > 描述  : 异常/中断优先级控制器 (修正版)
//  > 功能  : 从各阶段接收异常/中断信息，统一裁决，输出给 CP0 和 Fetch
//**************************************************************

module exception_controller (
    input clk,
    input resetn,

    // 来自 ID 阶段的信号
    input [1:0]  id_exception_type,  // 异常类型 (例如: 2'b00=AdEL, 2'b10=RI)
    input        id_exception_flag,  // 异常标志
    input [31:0] id_pc,              // ID 阶段 PC
    input [1:0]  id_interrupt_type,  // 中断类型 (例如: 2'b01=Int)
    input        id_interrupt_flag,  // 中断标志

    // 来自 EXE 阶段的信号
    input [1:0]  exe_exception_type, // 异常类型 (例如: 2'b11=Ovf)
    input        exe_exception_flag, // 异常标志
    input [31:0] exe_pc,             // EXE 阶段 PC

    // 来自 MEM 阶段的信号
    input [1:0]  mem_exception_type, // 异常类型 (例如: 2'b00=AdEL, 2'b01=AdES)
    input        mem_exception_flag, // 异常标志
    input [31:0] mem_pc,             // MEM 阶段 PC

    // 来自 CP0 Status 寄存器的信号
    input        cp0_status_exl,     // 新增: Status.EXL 位 (用于判断是否在异常处理中)
    input        cp0_status_ie,      // 新增: Status.IE 位 (全局中断使能)

    // 输出信号
    output reg        exception_triggered,    // 最终异常/中断触发信号 (给 FSM, Fetch, 流水线寄存器)
    output reg [4:0]  final_exception_type, // 最终确定的异常类型 (ExcCode for CP0 Cause)
    output reg [31:0] epc_out,              // 计算出的 EPC (给 CP0 EPC 寄存器)
    output            cp0_pc,               // 异常处理入口地址 (给 Fetch 阶段)
    output reg        cp0_write_enable      // CP0 寄存器写使能信号 (给 CP0 模块)
);

    // MIPS ExcCode 定义 (部分)
    parameter EXCCODE_INT   = 5'd0;  // 中断
    parameter EXCCODE_ADEL  = 5'd4;  // 地址错 (取指或数据虚地址) - Load/Fetch
    parameter EXCCODE_ADES  = 5'd5;  // 地址错 (数据虚地址) - Store
    parameter EXCCODE_RI    = 5'd10; // 保留指令
    parameter EXCCODE_OVF   = 5'd12; // 算术溢出

    // 内部信号
    reg [31:0] epc_candidate;
    reg [4:0]  cause_candidate;
    reg        trigger_candidate;
    wire       interrupt_enabled = cp0_status_ie && !cp0_status_exl; // 中断条件：IE=1 且 EXL=0

    // 异常处理入口地址 (通用异常)
    assign cp0_pc = 32'h8000_0180; // 假设 BEV=0

    // 优先级判断逻辑: MEM > EXE > ID(Exc) > ID(Int if enabled)
    always @(*) begin
        // 默认值
        trigger_candidate = 1'b0;
        cause_candidate   = EXCCODE_INT; // 默认为中断，如果没有其他异常
        epc_candidate     = 32'b0;
        cp0_write_enable  = 1'b0;

        // 1. 检查 MEM 阶段异常 (最高优先级)
        if (mem_exception_flag) begin
            trigger_candidate = 1'b1;
            epc_candidate     = mem_pc; // 异常指令地址
            cause_candidate   = (mem_exception_type == 2'b00) ? EXCCODE_ADEL : EXCCODE_ADES;
            cp0_write_enable  = 1'b1;
        end
        // 2. 检查 EXE 阶段异常
        else if (exe_exception_flag) begin
            trigger_candidate = 1'b1;
            epc_candidate     = exe_pc; // 异常指令地址
            cause_candidate   = (exe_exception_type == 2'b11) ? EXCCODE_OVF : 5'b0; // 其他类型待补充
            cp0_write_enable  = 1'b1;
        end
        // 3. 检查 ID 阶段异常
        else if (id_exception_flag) begin
            trigger_candidate = 1'b1;
            epc_candidate     = id_pc; // 异常指令地址
            if (id_exception_type == 2'b00) begin // AdEL (Fetch)
                cause_candidate = EXCCODE_ADEL;
            end else if (id_exception_type == 2'b10) begin // RI
                cause_candidate = EXCCODE_RI;
            end else begin // 其他类型待补充
                cause_candidate = 5'b0;
            end
            cp0_write_enable  = 1'b1;
        end
        // 4. 检查 ID 阶段中断 (最低优先级，且中断使能)
        else if (id_interrupt_flag && interrupt_enabled) begin
            trigger_candidate = 1'b1;
            // MIPS 中断 EPC 处理:
            // 如果异常发生在分支延迟槽指令，EPC = 分支指令地址 - 4
            // 否则，EPC = 导致异常的指令地址
            // 对于中断，通常 EPC = 被中断指令的下一条指令地址 (id_pc + 4)
            // 但如果中断发生在分支延迟槽，EPC = 分支指令地址
            // 简化处理：假设中断不在分支延迟槽发生
            epc_candidate     = id_pc + 4; // 中断时 EPC 通常是下一条指令地址
            cause_candidate   = EXCCODE_INT;
            cp0_write_enable  = 1'b1;
        end

        // 最终输出赋值 (组合逻辑)
        exception_triggered  = trigger_candidate;
        final_exception_type = cause_candidate;
        epc_out              = epc_candidate;
        // cp0_write_enable 在上面已赋值
    end

endmodule
