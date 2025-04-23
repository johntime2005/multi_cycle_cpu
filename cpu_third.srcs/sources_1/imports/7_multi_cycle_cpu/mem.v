`timescale 1ns / 1ps
//*************************************************************************
// 文件名       : mem.v
// 功能         : 实现多周期CPU中MEM阶段的数据存储操作，支持异常处理
// 作者         : LOONGSON
// 创建日期     : 2016-04-14
// 修改日期     : 2024-03-25
// 修改内容     : 
//   1. 统一异常信号输出为 exe_exception_type/flag
//   2. 优化地址未对齐检测逻辑
//   3. 明确数据存储器读写控制
//*************************************************************************

module mem(
    // 时钟与控制信号
    input              clk,             // 时钟信号
    input              MEM_valid,       // MEM阶段有效信号

    // EXE->MEM阶段总线
    input      [107:0] EXE_MEM_bus_r,   // 总线输入

    // 数据存储器接口
    input      [31:0]  dm_rdata,        // 数据存储器读取数据
    output     [31:0]  dm_addr,         // 数据存储器地址
    output reg [3:0]   dm_wen,          // 数据存储器写使能
    output reg [31:0]  dm_wdata,        // 数据存储器写数据

    // 输出信号
    output             MEM_over,        // MEM阶段结束信号
    output    [69:0]   MEM_WB_bus,      // MEM->WB阶段总线
    output    [31:0]   MEM_pc,          // 当前PC值
    input              flush_pipeline,   // 冲刷流水线信号

    // 新增异常信号输出
    output reg [1:0]   mem_exception_type, // MEM阶段异常类型
    output reg         mem_exception_flag  // MEM阶段异常标志
);

//========================== 总线信号解析 ==========================
wire [1:0]  exe_exception_type;  // EXE阶段异常类型
wire        exe_exception_flag;  // EXE阶段异常标志
wire [3:0]  mem_control;         // MEM控制信号
wire [31:0] store_data;          // 存储数据
wire [31:0] alu_result;          // ALU计算结果
wire        rf_wen;              // 寄存器写使能
wire [4:0]  rf_wdest;            // 寄存器写目标地址
wire [31:0] pc;                  // 当前PC值

assign {
    exe_exception_type,  // [107:106]
    exe_exception_flag,  // [105]
    mem_control,         // [104:101]
    store_data,          // [100:69]
    alu_result,          // [68:37]
    rf_wen,              // [36]
    rf_wdest,            // [35:31]
    pc                   // [30:0]
} = EXE_MEM_bus_r;

//========================== MEM控制信号解析 ==========================
wire inst_load   = mem_control[3];  // load指令标志
wire inst_store  = mem_control[2];  // store指令标志
wire ls_word     = mem_control[1];  // 字操作标志
wire ls_byte     = mem_control[0];  // 字节操作标志
wire is_halfword = !ls_word && !ls_byte; // 半字操作标志

//========================== 地址未对齐异常检测 ==========================
wire addr_unaligned = 
    (inst_load || inst_store) && 
    ((ls_word && (alu_result[1:0] != 2'b00)) ||  // 字未对齐
     (is_halfword && alu_result[0]));            // 半字未对齐

//========================== 异常信号处理 ==========================
always @(*) begin
    // 默认继承EXE阶段的异常
    mem_exception_flag = exe_exception_flag;
    mem_exception_type = exe_exception_type;
    
    // 检测MEM阶段异常（优先级高于EXE异常）
    if (MEM_valid && addr_unaligned) begin
        mem_exception_flag = 1'b1;
        mem_exception_type = 2'b01;  // 地址未对齐异常
    end
end

//========================== 数据存储器操作 ==========================
assign dm_addr = alu_result;  // 地址直接使用ALU结果

// 写使能生成
always @(*) begin
    if (MEM_valid && inst_store && !mem_exception_flag) begin
        if (ls_word) begin
            dm_wen = 4'b1111;  // 字写入
        end else if (is_halfword) begin
            dm_wen = {2'b00, {2{alu_result[1]}}};  // 半字写入（对齐处理）
        end else begin
            dm_wen = (1 << alu_result[1:0]);  // 字节写入
        end
    end else begin
        dm_wen = 4'b0000;  // 默认不写入
    end
end

// 写数据生成
always @(*) begin
    if (ls_word) begin
        dm_wdata = store_data;
    end else if (is_halfword) begin
        dm_wdata = alu_result[1] ? 
                  {store_data[15:0], 16'b0} :  // 高半字
                  {16'b0, store_data[15:0]};   // 低半字
    end else begin
        dm_wdata = store_data << (8 * alu_result[1:0]);  // 字节移位对齐
    end
end

//========================== MEM->WB总线构造 ==========================
wire [31:0] wb_data = inst_load ? dm_rdata : alu_result;  // 选择写回数据

assign MEM_WB_bus = flush_pipeline ? 70'b0 : {
    mem_exception_flag,  // [69]
    mem_exception_type,  // [68:67]
    rf_wen,              // [66]
    rf_wdest,            // [65:61]
    wb_data,             // [60:29] ALU结果或存储器数据
    pc                   // [28:0] 当前PC
};

//========================== 输出信号 ==========================
assign MEM_over = flush_pipeline ? 1'b0 : MEM_valid;
assign MEM_pc = pc;

endmodule