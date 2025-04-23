`timescale 1ns / 1ps

//**************************************************************
//  > 文件名: exception_controller.v
//  > 描述  : 异常优先级控制器
//  > 功能  : 从各阶段接收异常信息，统一裁决，输出给 CP0
//**************************************************************

module exception_controller(
    input [1:0]  id_exception_type,     // ID阶段异常类型
    input        id_exception_flag,     // ID阶段异常标志
    input [31:0] id_pc,                 // ID阶段PC值
    input [1:0]  exe_exception_type,    // EXE阶段异常类型
    input        exe_exception_flag,    // EXE阶段异常标志
    input [31:0] exe_pc,                // EXE阶段PC值
    input [1:0]  mem_exception_type,    // MEM阶段异常类型
    input        mem_exception_flag,    // MEM阶段异常标志
    input [31:0] mem_pc,                // MEM阶段PC值

    output reg        exception_triggered,    // 全局异常标志
    output reg [1:0]  final_exception_type,   // 最终异常类型

    // 送给 CP0 模块的接口
    output reg [31:0] cp0_pc,                 // 异常发生时的PC
    output reg [1:0]  cp0_exception_type,     // 异常类型
    output reg        cp0_exception_flag      // 异常标志
);

    // 异常类型参数定义
    localparam EXCEPTION_NONE      = 2'b00;  // 无异常
    localparam EXCEPTION_ILLEGAL   = 2'b01;  // 非法指令异常
    localparam EXCEPTION_DIVZERO   = 2'b10;  // 除零异常
    localparam EXCEPTION_UNALIGNED = 2'b11;  // 地址未对齐异常

    // 异常优先级裁决逻辑
    always @(*) begin
        // 默认值
        exception_triggered = 1'b0;
        final_exception_type = EXCEPTION_NONE;

        cp0_exception_flag  = 1'b0;
        cp0_exception_type  = EXCEPTION_NONE;
        cp0_pc              = 32'd0;

        // 优先级：EXE > MEM > ID
        if (exe_exception_flag) begin
            // EXE阶段异常
            exception_triggered = 1'b1;
            final_exception_type = exe_exception_type;

            cp0_exception_flag  = 1'b1;
            cp0_exception_type  = exe_exception_type;
            cp0_pc              = exe_pc;  // 使用EXE阶段的PC保存异常地址
        end else if (mem_exception_flag) begin
            // MEM阶段异常
            exception_triggered = 1'b1;
            final_exception_type = mem_exception_type;

            cp0_exception_flag  = 1'b1;
            cp0_exception_type  = mem_exception_type;
            cp0_pc              = mem_pc;  // 使用MEM阶段的PC保存异常地址
        end else if (id_exception_flag) begin
            // ID阶段异常
            exception_triggered = 1'b1;
            final_exception_type = id_exception_type;

            cp0_exception_flag  = 1'b1;
            cp0_exception_type  = id_exception_type;
            cp0_pc              = id_pc;  // 使用ID阶段的PC保存异常地址
        end
    end

endmodule
