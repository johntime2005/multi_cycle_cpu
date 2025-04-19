`timescale 1ns / 1ps

//****************************************************************
//  > 文件名: cp0.v
//  > 描述  : 多周期CPU的异常控制模块 CP0
//  > 功能  : 管理 EPC, Cause, Status 等寄存器，支持异常处理与返回
//****************************************************************

module cp0(
    input              clk,
    input              resetn,

    // 异常输入接口
    input              exception_flag,       // 异常发生标志
    input      [1:0]   exception_type,       // 异常类型编码
    input      [31:0]  pc_current,           // 当前PC（发生异常时的指令地址）

    // 写EPC控制信号
    input              eret_executed,        // 执行ERET指令

    // EPC输出
    output reg [31:0]  EPC,                  // 异常返回地址

    // 输出信号用于Fetch跳转判断
    output             exception_triggered,  // 给Fetch.v使用
    output             status_exl            // Status寄存器的EXL位（可扩展）
);

    // Cause寄存器（简单实现：只记录类型）
    reg [1:0] cause;

    // Status寄存器（这里只实现EXL位）
    reg status_EXL;

    // 异常触发信号同步处理
    reg exception_flag_sync;
    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            exception_flag_sync <= 1'b0;
        end else begin
            exception_flag_sync <= exception_flag;
        end
    end

    assign exception_triggered = exception_flag_sync;
    assign status_exl = status_EXL;

    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            EPC <= 32'b0;
            cause <= 2'b00;
            status_EXL <= 1'b0;
        end else begin
            if (exception_flag) begin
                EPC <= pc_current;         // 保存异常时PC
                cause <= exception_type;   // 保存异常类型
                status_EXL <= 1'b1;        // 设置EXL，进入异常状态
            end else if (eret_executed) begin
                status_EXL <= 1'b0;        // 清除异常状态，返回用户态
            end
        end
    end

endmodule
