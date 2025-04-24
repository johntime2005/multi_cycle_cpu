`timescale 1ns / 1ps

module cp0(
    input              clk,
    input              resetn,
    input              exception_flag,
    input      [1:0]   exception_type,
    input      [31:0]  pc_current,
    input              eret_executed,
    output reg [31:0]  EPC,
    output             exception_triggered,
    output             status_exl
);

    // 同步寄存器
    reg exception_flag_sync1, exception_flag_sync2;
    // Cause寄存器
    reg [1:0] cause;
    // Status寄存器（仅实现EXL位）
    reg status_EXL;

    // 同步异常信号
    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            exception_flag_sync1 <= 1'b0;
            exception_flag_sync2 <= 1'b0;
        end else begin
            exception_flag_sync1 <= exception_flag;
            exception_flag_sync2 <= exception_flag_sync1;
        end
    end

    // 主控制逻辑
    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            EPC <= 32'b0;
            cause <= 2'b00;
            status_EXL <= 1'b0;
        end else begin
            if (exception_flag_sync2) begin
                EPC <= pc_current;
                cause <= exception_type;
                status_EXL <= 1'b1;
            end
            if (eret_executed) begin
                status_EXL <= 1'b0;
            end
        end
    end

    assign exception_triggered = exception_flag_sync2;
    assign status_exl = status_EXL;

endmodule