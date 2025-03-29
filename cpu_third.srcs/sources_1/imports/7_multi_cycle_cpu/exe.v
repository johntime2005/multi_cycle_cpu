`timescale 1ns / 1ps
module exe(
    input         EXE_valid,          // 执行阶段有效信号
    input [156:0] ID_EXE_bus_r,       // 来自ID->EXE流水线寄存器的总线 (更新位宽)
    // input         flush_pipeline, // 假设由控制器处理刷新
    output reg [1:0] exe_exception_type, // 输出给异常控制器的本级异常类型
    output reg       exe_exception_flag, // 输出给异常控制器的本级异常标志
    output [108:0] EXE_MEM_bus,        // 输出到EXE->MEM流水线的总线 (更新位宽)
    output [31:0]  EXE_pc              // 输出PC给异常控制器和显示
);

wire [1:0]  interrupt_type_from_id; // 新增：来自ID阶段的中断类型
wire        interrupt_flag_from_id; // 新增：来自ID阶段的中断标志
wire [1:0]  exception_type_from_id; // 来自ID阶段的异常类型
wire        exception_flag_from_id; // 来自ID阶段的异常标志
wire [12:0] alu_control;            // ALU控制信号
wire [31:0] alu_operand1;           // ALU操作数1
wire [31:0] alu_operand2;           // ALU操作数2
wire [3:0]  mem_control;            // 存储器控制信号
wire [31:0] store_data;             // 待存储数据
wire        rf_wen;                 // 寄存器文件写使能
wire [4:0]  rf_wdest;               // 寄存器文件写目标地址
wire [31:0] pc;                     // 当前指令PC

// 更新解包逻辑，假设中断信息在高位
assign {
    interrupt_type_from_id,  // [156:155] 新增
    interrupt_flag_from_id,  // [154]     新增
    exception_type_from_id,  // [153:152]
    exception_flag_from_id,  // [151]
    alu_control,             // [150:138]
    alu_operand1,            // [137:106]
    alu_operand2,            // [105:74]
    mem_control,             // [73:70]
    store_data,              // [69:38]
    rf_wen,                  // [37]
    rf_wdest,                // [36:32]
    pc                       // [31:0]
} = ID_EXE_bus_r;

wire [31:0] alu_result;     // ALU计算结果
wire        alu_overflow;   // ALU溢出标志

alu alu_module(
    .alu_control  (alu_control),
    .alu_src1     (alu_operand1),
    .alu_src2     (alu_operand2),
    .alu_result   (alu_result),
    .overflow     (alu_overflow)
);

// 用于传递到MEM阶段的最终异常状态
reg [1:0]  current_exception_type; // 当前（本级或传递的）异常类型
reg        current_exception_flag; // 当前（本级或传递的）异常标志

always @(*) begin
    // 默认：本阶段无异常或无传递异常
    current_exception_flag = 1'b0;
    current_exception_type = 2'b00;
    exe_exception_flag = 1'b0; // 输出给异常控制器的默认值
    exe_exception_type = 2'b00; // 输出给异常控制器的默认值

    if (EXE_valid) begin
        // 1. 检查本地EXE阶段异常（最高优先级）
        if (alu_overflow) begin // 算术溢出异常
            current_exception_flag = 1'b1;
            current_exception_type = 2'b11; // Ovf (溢出)
            exe_exception_flag = 1'b1;      // 报告本地异常
            exe_exception_type = 2'b11;
        end
        // else if (alu_control[12] && (alu_operand2 == 0)) begin // 除零异常 (假设)
        //     current_exception_flag = 1'b1;
        //     current_exception_type = 2'b10; // Dz (除零)
        //     exe_exception_flag = 1'b1;      // 报告本地异常
        //     exe_exception_type = 2'b10;
        // end
        // 2. 如果无本地异常，检查来自ID阶段的异常
        else if (exception_flag_from_id) begin
             current_exception_flag = 1'b1;
             current_exception_type = exception_type_from_id; // 传递 AdEL, AdES, RI 等异常
             // 此处不设置 exe_exception_flag/type，因为ID阶段已报告
        end
        // 3. 如果无其他异常，检查来自ID阶段的中断
        else if (interrupt_flag_from_id) begin
             current_exception_flag = 1'b1;
             current_exception_type = interrupt_type_from_id; // 传递 Int (中断)
             // 此处不设置 exe_exception_flag/type，因为ID阶段已报告
        end
    end
end

// 输出赋值
assign EXE_pc = pc; // 传递PC给异常控制器和显示

// 赋值输出到MEM阶段的总线 (传递最终确定的异常状态)
// 位宽: 2 (type) + 1 (flag) + 4 (mem_ctrl) + 32 (alu_res) + 32 (store_data) + 1 (rf_wen) + 5 (rf_dest) + 32 (pc) = 109 bits -> [108:0]
assign EXE_MEM_bus = {
    current_exception_type, // [108:107] 截至EXE阶段确定的最终异常类型
    current_exception_flag, // [106]     截至EXE阶段确定的最终异常标志
    mem_control,            // [105:102] 存储器控制信号
    alu_result,             // [101:70]  ALU计算结果
    store_data,             // [69:38]   从ID阶段传递过来的存储数据
    rf_wen,                 // [37]      从ID阶段传递过来的写使能
    rf_wdest,               // [36:32]   从ID阶段传递过来的写目标寄存器
    pc                      // [31:0]    从ID阶段传递过来的PC
};

endmodule