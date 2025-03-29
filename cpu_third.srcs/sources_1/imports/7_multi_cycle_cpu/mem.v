`timescale 1ns / 1ps
//*************************************************************************
// 文件名       : mem.v
// 功能         : 实现多周期CPU中MEM阶段的数据存储操作，支持异常处理
// 作者         : LOONGSON
// 创建日期     : 2016-04-14
// 修改日期     : 2024-03-25
// 修改内容     :
//   1. 统一异常信号输出为 mem_exception_type/flag
//   2. 优化地址未对齐检测逻辑
//   3. 明确数据存储器读写控制
//*************************************************************************

module mem(
    // 时钟与控制信号
    input              clk,             // 时钟信号
    input              MEM_valid,       // MEM阶段有效信号

    // EXE->MEM阶段总线
    input      [108:0] EXE_MEM_bus_r,   // 总线输入

    // 数据存储器接口
    input      [31:0]  dm_rdata,        // 数据存储器读取数据
    output     [31:0]  dm_addr,         // 数据存储器地址
    output reg [3:0]   dm_wen,          // 数据存储器写使能
    output reg [31:0]  dm_wdata,        // 数据存储器写数据

    // 输出信号
    output             MEM_over,        // MEM阶段结束信号
    output    [72:0]   MEM_WB_bus,      // MEM->WB阶段总线 (更新位宽)
    output    [31:0]   MEM_pc,          // 当前PC值

    // 新增异常信号输出
    output reg [1:0]   mem_exception_type, // MEM阶段异常类型
    output reg         mem_exception_flag  // MEM阶段异常标志
);

//========================== 总线信号解析 ==========================
wire [1:0]  prev_exception_type; // 来自 EXE 阶段的异常类型
wire        prev_exception_flag; // 来自 EXE 阶段的异常标志
wire [3:0]  mem_control;         // 存储器控制信号
wire [31:0] alu_result;          // ALU 计算结果 (通常是地址或透传数据)
wire [31:0] store_data_in;       // 来自 EXE 的待存储数据
wire        rf_wen_in;           // 来自 EXE 的写使能
wire [4:0]  rf_wdest_in;         // 来自 EXE 的写目标
wire [31:0] pc;                  // 来自 EXE 的 PC

assign {
    prev_exception_type, // [108:107]
    prev_exception_flag, // [106]
    mem_control,         // [105:102]
    alu_result,          // [101:70]
    store_data_in,       // [69:38]
    rf_wen_in,           // [37]
    rf_wdest_in,         // [36:32]
    pc                   // [31:0]
} = EXE_MEM_bus_r;

//========================== MEM控制信号解析 ==========================
wire inst_load   = mem_control[3];
wire inst_store  = mem_control[2];
wire ls_word     = mem_control[1];
wire ls_byte     = mem_control[0]; // 注意：这里命名为 ls_byte，但实际表示是否为半字或字节
wire is_halfword = !ls_word && ls_byte; // 修正：半字判断
wire is_byte     = !ls_word && !ls_byte; // 修正：字节判断

//========================== 地址未对齐异常检测 ==========================
wire addr_misaligned =
    (inst_load || inst_store) &&
    ((ls_word && (alu_result[1:0] != 2'b00)) || // 字访问，地址低两位不为0
     (is_halfword && alu_result[0]));          // 半字访问，地址最低位不为0

//========================== 异常信号处理 ==========================
// 用于传递到 WB 阶段的最终异常状态
reg [1:0]  current_exception_type;
reg        current_exception_flag;

always @(*) begin
    // 默认继承 EXE 阶段的异常
    current_exception_flag = prev_exception_flag;
    current_exception_type = prev_exception_type;
    mem_exception_flag = 1'b0; // 本级异常标志默认 0
    mem_exception_type = 2'b00;

    // 检测MEM阶段异常（优先级高于EXE异常）
    if (MEM_valid && addr_misaligned) begin
        current_exception_flag = 1'b1; // 更新传递给 WB 的标志
        mem_exception_flag = 1'b1;     // 设置本级异常标志
        if (inst_load) begin
            current_exception_type = 2'b00; // AdEL (加载地址错)
            mem_exception_type = 2'b00;
        end else begin // inst_store
            current_exception_type = 2'b01; // AdES (存储地址错)
            mem_exception_type = 2'b01;
        end
    end
    // else: 继承 prev_exception_flag 和 prev_exception_type
end

//========================== 数据存储器操作 ==========================
assign dm_addr = alu_result;  // 地址直接使用ALU结果

// 写使能生成
always @(*) begin
    dm_wen = 4'b0; // 默认不写
    if (MEM_valid && inst_store && !current_exception_flag) begin // 使用 current_exception_flag 防止在任何先前或当前异常时写入
        if (ls_word) begin
            dm_wen = 4'b1111;  // 字写入
        end else if (is_halfword) begin
            // 根据地址对齐修正半字写使能
            dm_wen = (alu_result[1] == 1'b0) ? 4'b0011 : 4'b1100; // 低半字或高半字
        end else begin // is_byte
            dm_wen = (1 << alu_result[1:0]);  // 字节写入
        end
    end
end

// 写数据生成
always @(*) begin
    // 修正写入数据的对齐
    if (ls_word) begin
        dm_wdata = store_data_in;
    end else if (is_halfword) begin
        // 根据地址选择写入高半字或低半字
        dm_wdata = (alu_result[1] == 1'b0) ? {16'b0, store_data_in[15:0]} : {store_data_in[15:0], 16'b0};
    end else begin // is_byte
        // 根据地址将字节写入对应位置
        dm_wdata = store_data_in[7:0] << (8 * alu_result[1:0]);
    end
end

//========================== MEM->WB总线构造 ==========================
wire [31:0] wb_data = inst_load ? dm_rdata : alu_result;  // 选择写回数据

// 格式匹配 wb.v 解析: {exception_flag, exception_type, wen, wdest, mem_result, pc}
// 位宽: 1 + 2 + 1 + 5 + 32 + 32 = 73 bits -> [72:0]
// 确认 wb.v 解析逻辑与此处的总线结构一致

assign MEM_WB_bus = { // 输出 73 位 [72:0]
    current_exception_flag, // [72]     截至 MEM 阶段的最终异常标志
    current_exception_type, // [71:70]  截至 MEM 阶段的最终异常类型
    rf_wen_in,              // [69]     来自 ID/EXE 的原始写使能
    rf_wdest_in,            // [68:64]  原始写目标寄存器
    wb_data,                // [63:32]  待写回的数据
    pc                      // [31:0]   指令的 PC
};

//========================== 输出信号 ==========================
assign MEM_over = MEM_valid; // 假设访存一周期完成
assign MEM_pc = pc;

endmodule