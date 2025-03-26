`timescale 1ns / 1ps
//*************************************************************************
//   > 文件名: mem.v
//   > 描述  : 多周期CPU的?存模?
//   > 作者  : LOONGSON
//   > 日期  : 2016-04-14
//*************************************************************************

module mem(
    // 基本??和?位
    input              clk,          // ??信号
    input              MEM_valid,    // ?存?有效信号(高?平有效)
    
    // 来自?行?段的??
    input      [105:0] EXE_MEM_bus_r, // EXE->MEM??(包含控制信号和数据)
    
    // 数据存?器接口
    input      [ 31:0] dm_rdata,     // 从数据存?器?取的数据
    output     [ 31:0] dm_addr,      // 数据存?器??地址
    output reg [  3:0] dm_wen,       // 数据存?器写使能(按字?使能)
    output reg [ 31:0] dm_wdata,     // 写入数据存?器的数据
    
    // 流水?控制信号
    output             MEM_over,     // MEM?段?行完成信号
    output    [ 69:0]  MEM_WB_bus,   // MEM->WB??(??到写回?段的信息)
    
    // ???出
    output     [ 31:0] MEM_pc        // 当前指令PC?(用于??)
);

//================================ EXE->MEM??分解 ================================
// ??包含以下字段(按从高位到低位?序):
// [105:102] - mem_control : ?存控制信号
// [101:70]  - store_data  : 存?数据
// [69:38]   - alu_result  : ALU?算?果
// [37]      - rf_wen      : 寄存器文件写使能
// [36:32]   - rf_wdest    : 寄存器文件写入地址
// [31:0]    - pc          : 当前指令PC?

wire [3 :0] mem_control;  // ?存控制信号
wire [31:0] store_data;   // 存?数据
wire [31:0] alu_result;   // ALU?算?果
wire        rf_wen;       // 寄存器文件写使能
wire [4:0] rf_wdest;      // 寄存器文件写入地址
wire [31:0] pc;           // 当前指令PC?

assign {
    mem_control,
    store_data,
    alu_result,
    rf_wen,
    rf_wdest,
    pc
} = EXE_MEM_bus_r;

//============================= ?存控制信号分解 =============================
wire inst_load;   // load指令?志
wire inst_store;  // store指令?志
wire ls_word;     // ???度(0:字?, 1:字)
wire lb_sign;     // 加?字?符号?展?志(1:有符号, 0:无符号)

assign {
    inst_load,
    inst_store,
    ls_word,
    lb_sign
} = mem_control;

//============================= 存?器???? ==============================

// 存?器地址(直接使用ALU?算?果)
assign dm_addr = alu_result;

// 存?器写使能生成??(?合??)
always @ (*) begin
    if (MEM_valid && inst_store) begin // 有效?存周期且是store指令
        if (ls_word) begin
            dm_wen <= 4'b1111; // 字存?(4字?全部使能)
        end
        else begin // 字?存?(根据地址低2位??使能字?)
            case (dm_addr[1:0])
                2'b00: dm_wen <= 4'b0001; // 字?0
                2'b01: dm_wen <= 4'b0010; // 字?1
                2'b10: dm_wen <= 4'b0100; // 字?2
                2'b11: dm_wen <= 4'b1000; // 字?3
                default: dm_wen <= 4'b0000;
            endcase
        end
    end
    else begin
        dm_wen <= 4'b0000; // 非store指令?禁止写入
    end
end

// 存?器写数据生成(?合??)
always @ (*) begin
    if (ls_word) begin
        dm_wdata <= store_data; // 字存?直接写入
    end
    else begin // 字?存?需要将数据放到正?的字?位置
        case (dm_addr[1:0])
            2'b00: dm_wdata <= store_data;
            2'b01: dm_wdata <= {16'd0, store_data[7:0], 8'd0};
            2'b10: dm_wdata <= {8'd0, store_data[7:0], 16'd0};
            2'b11: dm_wdata <= {store_data[7:0], 24'd0};
            default: dm_wdata <= store_data;
        endcase
    end
end

//============================= 加?数据?理?? ==============================

// 加?数据的符号位??
wire load_sign;
assign load_sign = (dm_addr[1:0]==2'd0) ? dm_rdata[7] :
                  (dm_addr[1:0]==2'd1) ? dm_rdata[15] :
                  (dm_addr[1:0]==2'd2) ? dm_rdata[23] : 
                  dm_rdata[31];

// 加?数据的字???
wire [31:0] load_result;
assign load_result[7:0] = (dm_addr[1:0]==2'd0) ? dm_rdata[7:0] :
                         (dm_addr[1:0]==2'd1) ? dm_rdata[15:8] :
                         (dm_addr[1:0]==2'd2) ? dm_rdata[23:16] :
                         dm_rdata[31:24];

// 加?数据的高位?理(符号?展或零?展)
assign load_result[31:8] = ls_word ? dm_rdata[31:8] : // 字加?直接取高位
                          {24{lb_sign & load_sign}}; // 字?加??符号?展

//============================= ?存?段完成信号 ==============================

// 由于存?器??可能需要多个周期，特?是load操作需要等待数据返回
// ?里使用MEM_valid_r来??前一周期状?
reg MEM_valid_r;
always @(posedge clk) begin
    MEM_valid_r <= MEM_valid;
end

// load操作需要?个周期完成(?出地址和接收数据)
// 其他操作(如store和ALU操作)一个周期完成
assign MEM_over = inst_load ? MEM_valid_r : MEM_valid;

//============================= MEM->WB???装 ==============================

// ??写回数据: load指令使用存?器数据，其他指令使用ALU?果
wire [31:0] mem_result;
assign mem_result = inst_load ? load_result : alu_result;

// MEM->WB??包含以下字段(从高位到低位):
// [69]      - rf_wen     : 寄存器文件写使能
// [68:64]   - rf_wdest   : 寄存器文件写入地址
// [63:32]   - mem_result : 写回数据(存?器或ALU?果)
// [31:0]    - pc         : 当前指令PC?(用于??和?常?理)
assign MEM_WB_bus = {
    rf_wen,
    rf_wdest,
    mem_result,
    pc
};

//============================= ???出 ==============================

// ?出当前PC?用于??
assign MEM_pc = pc;

endmodule