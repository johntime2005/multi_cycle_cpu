`timescale 1ns / 1ps
//*************************************************************************
// 文件名称   : regfile.v
// 功能说明   : 实现一个三端口寄存器文件
//              - 两个读端口：组合逻辑读操作
//              - 一个写端口：在时钟上升沿写入数据（寄存器0始终为0）
// 作者       : LOONGSON
// 创建日期   : 2016-04-14
// 修改说明   : 重新整理注释信息
//*************************************************************************
module regfile(
    input             clk,       // 时钟信号
    input             resetn,    // 新增: 复位信号，低电平有效
    input             wen,       // 写使能
    input      [4:0]  raddr1,    // 读端口1地址
    input      [4:0]  raddr2,    // 读端口2地址
    input      [4:0]  waddr,     // 写端口地址
    input      [31:0] wdata,     // 待写入数据
    output reg [31:0] rdata1,    // 读端口1输出数据
    output reg [31:0] rdata2,    // 读端口2输出数据
    input      [4:0]  test_addr, // 调试接口地址
    output reg [31:0] test_data  // 调试接口输出数据
    );

    // 定义32个32位寄存器
    reg [31:0] rf[31:0];
    integer i; // 声明 integer 用于 for 循环

    // 写操作：在时钟上升沿写数据；异步复位时初始化所有寄存器
    always @(posedge clk or negedge resetn) begin // 添加 negedge resetn
        if (!resetn) begin
            // 异步复位：所有寄存器初始化为0
            for (i = 0; i < 32; i = i + 1) begin // 使用已声明的 i
                rf[i] <= 32'd0;
            end
        end else begin
            // 正常操作：如果写使能有效，并且写地址不为0，则写入数据
            if (wen && (waddr != 5'd0)) begin
                rf[waddr] <= wdata;
            end
        end
    end

    // 读端口1：根据 raddr1 地址读取数据，寄存器0始终返回0
    always @(*) begin
        if (raddr1 == 5'd0) begin
            rdata1 <= 32'd0;
        end else begin
            rdata1 <= rf[raddr1]; // 直接索引读取
        end
    end

    // 读端口2：根据 raddr2 地址读取数据，同样寄存器0返回0
    always @(*) begin
         if (raddr2 == 5'd0) begin
            rdata2 <= 32'd0;
        end else begin
            rdata2 <= rf[raddr2]; // 直接索引读取
        end
    end

    // 调试接口：根据 test_addr 输出对应寄存器的内容，寄存器0始终输出0
    always @(*) begin
        if (test_addr == 5'd0) begin
            test_data <= 32'd0;
        end else begin
            test_data <= rf[test_addr]; // 直接索引读取
        end
    end

endmodule