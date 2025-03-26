`timescale 1ns / 1ps
//*************************************************************************
// 文件名       : mem.v
// 功能         : 实现多周期CPU中MEM阶段的数据存储操作
// 作者         : LOONGSON
// 创建日期     : 2016-04-14
//*************************************************************************

module mem(
    // 时钟及控制信号
    input              clk,          // 时钟信号
    input              MEM_valid,    // MEM阶段有效信号
    
    // EXE->MEM阶段总线，包含以下各字段：
// [105:102] - mem_control : MEM控制信号
// [101:70]  - store_data  : 存储数据
// [69:38]   - alu_result  : ALU运算结果
// [37]      - rf_wen      : 寄存器写使能
// [36:32]   - rf_wdest    : 寄存器写目的地址
// [31:0]    - pc          : 当前PC值
    input      [105:0] EXE_MEM_bus_r,
    
    // 数据存储器接口
    input      [31:0] dm_rdata,     // 数据存储器读数据
    output     [31:0] dm_addr,      // 数据存储器地址
    output reg [ 3:0] dm_wen,       // 数据存储器写使能
    output reg [31:0] dm_wdata,     // 数据存储器写数据
    
    // MEM阶段输出总线信息
    output             MEM_over,     // MEM阶段结束信号
    output    [ 69:0]  MEM_WB_bus,   // MEM->WB阶段总线
    
    // 输出当前PC
    output     [31:0] MEM_pc        // 当前PC值
);

//========================== 提取EXE->MEM阶段总线 ==========================

wire [3 :0] mem_control;  // MEM控制信号
wire [31:0] store_data;   // 存储数据
wire [31:0] alu_result;   // ALU运算结果
wire        rf_wen;       // 寄存器写使能
wire [4:0]  rf_wdest;     // 寄存器写目的地址
wire [31:0] pc;           // 当前PC值

assign {
    mem_control,
    store_data,
    alu_result,
    rf_wen,
    rf_wdest,
    pc
} = EXE_MEM_bus_r;

//======================== 解析MEM控制信号 ================================

wire inst_load;   // load指令标志
wire inst_store;  // store指令标志
wire ls_word;     // 存取数据类型：1-字(word)，0-半字或字节
wire lb_sign;     // load字节是否带符号扩展：1-带符号，0-无符号

assign {
    inst_load,
    inst_store,
    ls_word,
    lb_sign
} = mem_control;

//======================== 数据存储器写操作 ================================

// 存储器地址直接由ALU运算结果给出
assign dm_addr = alu_result;

// 根据store指令和数据类型产生写使能信号
always @ (*) begin
    if (MEM_valid && inst_store) begin // 当有效且为store指令时
        if (ls_word) begin
            dm_wen <= 4'b1111; // 写整字（4字节）
        end
        else begin // 写单字节，根据地址低2位决定使能哪一个字节
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
        dm_wen <= 4'b0000; // 非store操作时，不写数据存储器
    end
end

// 根据数据类型调整写数据
always @ (*) begin
    if (ls_word) begin
        dm_wdata <= store_data; // 写整字数据
    end
    else begin // 写单字节数据时，将数据扩充到32位，按地址低两位调整位置
        case (dm_addr[1:0])
            2'b00: dm_wdata <= store_data;
            2'b01: dm_wdata <= {16'd0, store_data[7:0], 8'd0};
            2'b10: dm_wdata <= {8'd0, store_data[7:0], 16'd0};
            2'b11: dm_wdata <= {store_data[7:0], 24'd0};
            default: dm_wdata <= store_data;
        endcase
    end
end

//======================== 处理数据存储器读取 ================================

// 对于load操作，需要根据存储器地址和数据类型进行读取处理
wire load_sign;  // 被加载数据的符号位
assign load_sign = (dm_addr[1:0] == 2'd0) ? dm_rdata[7]  :
                   (dm_addr[1:0] == 2'd1) ? dm_rdata[15] :
                   (dm_addr[1:0] == 2'd2) ? dm_rdata[23] :
                                            dm_rdata[31];

// 读取单字节数据（8位）扩展到32位
wire [31:0] load_result;
assign load_result[7:0] = (dm_addr[1:0] == 2'd0) ? dm_rdata[7:0]  :
                          (dm_addr[1:0] == 2'd1) ? dm_rdata[15:8] :
                          (dm_addr[1:0] == 2'd2) ? dm_rdata[23:16] :
                                                   dm_rdata[31:24];
assign load_result[31:8] = ls_word ? dm_rdata[31:8] : // 如果是字(load word)，则直接扩展
                           {24{lb_sign & load_sign}}; // 否则进行符号扩展（lb），无符号则扩0

//======================== MEM阶段完成信号处理 ================================

// 对于load指令，MEM_over信号延迟一拍，否则直接传递MEM_valid
reg MEM_valid_r;
always @(posedge clk) begin
    MEM_valid_r <= MEM_valid;
end

assign MEM_over = inst_load ? MEM_valid_r : MEM_valid;

//======================== 构造 MEM->WB阶段总线 ================================

// 总线格式：
// [69]      - rf_wen     : 寄存器写使能
// [68:64]   - rf_wdest   : 寄存器写目的地址
// [63:32]   - mem_result : 数据存储器数据或者ALU结果
// [31:0]    - pc         : 当前PC值
wire [31:0] mem_result;
assign mem_result = inst_load ? load_result : alu_result;

assign MEM_WB_bus = {
    rf_wen,
    rf_wdest,
    mem_result,
    pc
};

//======================== 输出PC ================================
assign MEM_pc = pc;

endmodule