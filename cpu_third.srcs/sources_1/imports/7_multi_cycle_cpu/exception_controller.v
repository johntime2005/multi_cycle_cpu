`timescale 1ns / 1ps

//**************************************************************
//  > 文件名: exception_controller.v
//  > 描述  : 异常优先级控制器
//  > 功能  : 从各阶段接收异常信息，统一裁决，输出给 CP0
//**************************************************************

module exception_controller(
    input [1:0]  id_exception_type,     // ID阶段异常类型（非法指令）
    input        id_exception_flag,
    input [1:0]  exe_exception_type,    // EXE阶段异常类型（除零/溢出）
    input        exe_exception_flag,
    input [1:0]  mem_exception_type,    // MEM阶段异常类型（地址未对齐）
    input        mem_exception_flag,
    input [31:0] mem_pc,                // 当前PC（异常PC）

    output reg        exception_triggered,    // 全局异常标志（用于Fetch）
    output reg [1:0]  final_exception_type,   // 最终异常类型（可用于显示）

    // 送给 CP0 模块的接口
    output reg [31:0] cp0_pc,
    output reg [1:0]  cp0_exception_type,
    output reg        cp0_exception_flag
);

    always @(*) begin
        // 默认值
        exception_triggered = 1'b0;
        final_exception_type = 2'b00;

        cp0_exception_flag  = 1'b0;
        cp0_exception_type  = 2'b00;
        cp0_pc              = 32'd0;

        // 优先级：EXE > MEM > ID
        if (exe_exception_flag) begin
            exception_triggered = 1'b1;
            final_exception_type = exe_exception_type;

            cp0_exception_flag  = 1'b1;
            cp0_exception_type  = exe_exception_type;
            cp0_pc              = mem_pc;  // 用MEM阶段的PC保存异常地址
        end else if (mem_exception_flag) begin
            exception_triggered = 1'b1;
            final_exception_type = mem_exception_type;

            cp0_exception_flag  = 1'b1;
            cp0_exception_type  = mem_exception_type;
            cp0_pc              = mem_pc;
        end else if (id_exception_flag) begin
            exception_triggered = 1'b1;
            final_exception_type = id_exception_type;

            cp0_exception_flag  = 1'b1;
            cp0_exception_type  = id_exception_type;
            cp0_pc              = mem_pc;  // 默认统一用MEM阶段PC
        end
    end

endmodule
