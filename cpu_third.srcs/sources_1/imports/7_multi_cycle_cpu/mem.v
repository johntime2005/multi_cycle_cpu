`timescale 1ns / 1ps
//*************************************************************************
// 文件名       : mem.v
// 功能         : 实现多周期CPU中MEM阶段的数据存储操作，支持异常处理
// 作者         : LOONGSON
// 创建日期     : 2016-04-14
// 修改日期     : 2023-10-20
// 修改内容     : 添加对前面所有模块定义的异常的处理
//*************************************************************************

module mem(
    // 时钟与控制信号
    input              clk,          // 时钟信号
    input              MEM_valid,    // MEM阶段有效信号

    // EXE->MEM阶段总线，包含以下字段：
    // [107:106] - exception_type : 异常类型（从EXE阶段传递）
    // [105]     - exception_flag : 异常标志（从EXE阶段传递）
    // [104:101] - mem_control    : MEM控制信号
    // [100:69]  - store_data     : 存储数据
    // [68:37]   - alu_result     : ALU计算结果
    // [36]      - rf_wen         : 寄存器写使能
    // [35:31]   - rf_wdest       : 寄存器写目标地址
    // [30:0]    - pc             : 当前PC值
    input      [107:0] EXE_MEM_bus_r,

    // 数据存储器接口
    input      [31:0] dm_rdata,      // 数据存储器读取数据
    output     [31:0] dm_addr,       // 数据存储器地址
    output reg [ 3:0] dm_wen,        // 数据存储器写使能
    output reg [31:0] dm_wdata,      // 数据存储器写数据

    // MEM阶段输出总线信息
    output             MEM_over,     // MEM阶段结束信号
    output    [ 69:0]  MEM_WB_bus,   // MEM->WB阶段总线

    // 输出当前PC
    output     [31:0] MEM_pc         // 当前PC值
);

//========================== 提取EXE->MEM阶段总线 ==========================
wire exception_flag_from_exe;  // 异常标志
wire [1:0] exception_type_from_exe;  // 异常类型
wire [3:0] mem_control;              // MEM控制信号
wire [31:0] store_data;              // 存储数据
wire [31:0] alu_result;              // ALU计算结果
wire rf_wen;                         // 寄存器写使能
wire [4:0] rf_wdest;                 // 寄存器写目标地址
wire [31:0] pc;                      // 当前PC值

assign {
    exception_type_from_exe,  // [107:106]
    exception_flag_from_exe,  // [105]
    mem_control,              // [104:101]
    store_data,               // [100:69]
    alu_result,               // [68:37]
    rf_wen,                   // [36]
    rf_wdest,                 // [35:31]
    pc                        // [30:0]
} = EXE_MEM_bus_r;

//========================== MEM控制信号解析 ==========================
wire inst_load;   // load指令标志
wire inst_store;  // store指令标志
wire ls_word;     // 数据类型：1-字（word），0-半字或字节
wire lb_sign;     // load字节是否符号扩展：1-符号扩展，0-无符号扩展

assign {
    inst_load,
    inst_store,
    ls_word,
    lb_sign
} = mem_control;

//========================== 地址未对齐异常检测 ==========================
reg addr_error;
always @(*) begin
    addr_error = 1'b0;  // 初始化为无异常
    if (MEM_valid) begin
        if ((inst_load || inst_store) && ls_word && (alu_result[1:0] != 2'b00)) begin
            // 如果是字（word）访问，但地址未对齐（低两位非0）
            addr_error = 1'b1;
        end
        else if ((inst_load || inst_store) && !ls_word && alu_result[0] != 1'b0) begin
            // 如果是半字（halfword）访问，但地址未对齐（最低位非0）
            addr_error = 1'b1;
        end
    end
end

//========================== 异常信号合并 ==========================
reg exception_flag;
reg [1:0] exception_type;

always @(*) begin
    // 初始化异常标志和类型
    exception_flag = exception_flag_from_exe;
    exception_type = exception_type_from_exe;

    // 检测地址未对齐异常
    if (addr_error) begin
        exception_flag = 1'b1;
        exception_type = 2'b01;  // 地址未对齐异常
    end
end

//========================== 数据存储器写操作 ==========================
assign dm_addr = alu_result;  // 数据存储器地址直接由ALU结果提供

always @(*) begin
    if (MEM_valid && inst_store && !exception_flag) begin
        if (ls_word) begin
            dm_wen <= 4'b1111; // 写整个字（4字节）
        end
        else begin
            // 写单字节，根据地址低两位决定写哪个字节
            case (dm_addr[1:0])
                2'b00: dm_wen <= 4'b0001;
                2'b01: dm_wen <= 4'b0010;
                2'b10: dm_wen <= 4'b0100;
                2'b11: dm_wen <= 4'b1000;
                default: dm_wen <= 4'b0000;
            endcase
        end
    end
    else begin
        dm_wen <= 4'b0000; // 非store操作或异常时，不写数据存储器
    end
end

always @(*) begin
    if (ls_word) begin
        dm_wdata <= store_data; // 写整个字
    end
    else begin
        // 写单字节，根据地址低两位调整数据位置
        case (dm_addr[1:0])
            2'b00: dm_wdata <= store_data;
            2'b01: dm_wdata <= {16'd0, store_data[7:0], 8'd0};
            2'b10: dm_wdata <= {8'd0, store_data[7:0], 16'd0};
            2'b11: dm_wdata <= {store_data[7:0], 24'd0};
            default: dm_wdata <= store_data;
        endcase
    end
end

//========================== 构造 MEM->WB 总线 ==========================
assign MEM_WB_bus = {
    exception_flag,    // [69] 异常标志
    exception_type,    // [68:67] 异常类型
    rf_wen,            // [66] 寄存器写使能
    rf_wdest,          // [65:61] 寄存器写目标地址
    alu_result,        // [60:29] ALU结果或数据存储器读取结果
    pc                 // [28:0] 当前PC值
};

//========================== MEM阶段完成信号 ==========================
assign MEM_over = MEM_valid && !exception_flag;  // 异常时阻止阶段完成

//========================== 输出当前PC ==========================
assign MEM_pc = pc;

endmodule