`timescale 1ns / 1ps
//*************************************************************************
//   > 文件名: wb.v
//   > 描述  : 多周期CPU的写回模块，支持异常处理
//   > 作者  : LOONGSON
//   > 日期  : 2016-04-14
//   > 修改  : 添加异常处理机制（2023-10-20）
//*************************************************************************
module wb(
    input         WB_valid,     // 写回阶段有效信号
    input  [72:0] MEM_WB_bus_r, // MEM->WB总线
    output        rf_wen,       // 寄存器写使能
    output [ 4:0] rf_wdest,     // 寄存器写地址
    output [31:0] rf_wdata,     // 寄存器写数据
    output        WB_over,      // WB模块执行完成

    // 显示PC
    output [31:0] WB_pc
);

//-----{MEM->WB总线解析}begin---------------------------------------
    // 从 MEM->WB 总线中提取信号
    wire exception_flag;        // 异常标志
    wire [1:0] exception_type;  // 异常类型
    wire wen;                   // 原始写使能信号
    wire [4:0] wdest;           // 原始写地址
    wire [31:0] mem_result;     // 写回数据
    wire [31:0] pc;             // 当前PC值

    // 解析更新后的 73 位总线
    assign {
        exception_flag,         // [72]
        exception_type,         // [71:70]
        wen,                    // [69]
        wdest,                  // [68:64]
        mem_result,             // [63:32]
        pc                      // [31:0]
    } = MEM_WB_bus_r;
//-----{MEM->WB总线解析}end-----------------------------------------

//-----{WB执行完成信号}begin---------------------------------------
    assign WB_over = WB_valid;
//-----{WB执行完成信号}end-----------------------------------------

//-----{异常处理逻辑}begin-----------------------------------------
    // 如果发生异常，则阻止寄存器写回
    wire valid_write = WB_valid && !exception_flag;
//-----{异常处理逻辑}end-------------------------------------------

//-----{WB->regfile信号生成}begin----------------------------------
    assign rf_wen   = wen & valid_write; // 仅在无异常时写回寄存器
    assign rf_wdest = wdest;             // 写回目标寄存器地址
    assign rf_wdata = mem_result;        // 写回数据
//-----{WB->regfile信号生成}end-------------------------------------

//-----{显示WB模块的PC值}begin-------------------------------------
    assign WB_pc = pc;
//-----{显示WB模块的PC值}end---------------------------------------

endmodule

