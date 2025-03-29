`timescale 1ns / 1ps

//**************************************************************
//  > 文件名: cp0.v
//  > 描述  : CP0 协处理器寄存器模块 (修正版)
//  > 功能  : 实现 EPC, Cause, Status 寄存器的读写
//**************************************************************

module cp0(
    input              clk,
    input              resetn,

    // 写控制信号 (来自 exception_controller)
    input              wen,                // CP0 写使能
    input      [31:0]  epc_in,             // 待写入的 EPC 值
    input      [4:0]   cause_exccode_in,   // 待写入的 Cause[6:2] ExcCode

    // ERET 信号 (来自 decode)
    input              eret_executed,      // ERET 指令执行标志

    // 读输出信号
    output wire [31:0]  epc_out,            // EPC 寄存器输出 (改为 wire)
    output wire [31:0]  cause_out,          // Cause 寄存器输出 (改为 wire)
    output wire [31:0]  status_out          // Status 寄存器输出 (改为 wire)
);

    // CP0 寄存器声明
    reg [31:0] EPC_reg;
    reg [31:0] Cause_reg;
    reg [31:0] Status_reg;

    // Cause 寄存器字段 (简化)
    // Cause[31]    : BD (Branch Delay) - 简化为 0
    // Cause[6:2]   : ExcCode
    // Cause[1]     : IP1 (Interrupt Pending 1) - 简化为 0
    // Cause[0]     : IP0 (Interrupt Pending 0) - 简化为 0

    // Status 寄存器字段 (简化)
    // Status[1]    : EXL (Exception Level)
    // Status[0]    : IE (Interrupt Enable) - 简化为 1 (中断默认使能)

    // CP0 寄存器读写逻辑
    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            // 复位状态
            EPC_reg    <= 32'b0;
            Cause_reg  <= 32'b0;
            Status_reg <= 32'h00000001; // EXL=0, IE=1 (默认)
        end else begin
            // 写操作 (由 exception_controller 控制)
            if (wen) begin
                EPC_reg    <= epc_in;
                // 更新 Cause 寄存器: 设置 ExcCode, 清除 BD (简化)
                Cause_reg  <= {25'b0, cause_exccode_in, 2'b0}; // BD=0, IP=0
                // 更新 Status 寄存器: 设置 EXL=1
                Status_reg <= {Status_reg[31:2], 1'b1, Status_reg[0]}; // Set EXL
            end
            // ERET 操作
            else if (eret_executed) begin
                // 更新 Status 寄存器: 清除 EXL=0
                Status_reg <= {Status_reg[31:2], 1'b0, Status_reg[0]}; // Clear EXL
            end
            // else: 保持寄存器值不变
        end
    end

    // 输出赋值
    assign epc_out    = EPC_reg;
    assign cause_out  = Cause_reg;
    assign status_out = Status_reg;

endmodule