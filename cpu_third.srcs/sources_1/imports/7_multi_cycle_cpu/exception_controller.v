module exception_controller(
    input [1:0] id_exception_type,    // 译码阶段异常类型（非法指令）
    input       id_exception_flag,
    input [1:0] exe_exception_type,   // 执行阶段异常类型（除零、溢出）
    input       exe_exception_flag,
    input [1:0] mem_exception_type,   // 存储阶段异常类型（地址未对齐）
    input       mem_exception_flag,
    output reg  exception_triggered,  // 全局异常触发信号
    output reg [1:0] final_exception_type // 最终异常类型
);
    always @(*) begin
        // 优先级：执行阶段异常 > 存储阶段异常 > 译码阶段异常
        if (exe_exception_flag) begin
            exception_triggered = 1'b1;
            final_exception_type = exe_exception_type;
        end else if (mem_exception_flag) begin
            exception_triggered = 1'b1;
            final_exception_type = mem_exception_type;
        end else if (id_exception_flag) begin
            exception_triggered = 1'b1;
            final_exception_type = id_exception_type;
        end else begin
            exception_triggered = 1'b0;
            final_exception_type = 2'b00;
        end
    end
endmodule