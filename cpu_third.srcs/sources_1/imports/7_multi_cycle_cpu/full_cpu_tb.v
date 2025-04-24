`timescale 1ns/1ps

module full_cpu_tb();

// 全局信号定义
reg          clk;
reg          reset_n;
reg          flush_pipeline;
integer      testcase;
integer      success_count;
integer      fail_count;

// 时钟生成（100MHz）
always #5 clk = ~clk;

//------------------------ Decode模块测试信号 ------------------------
reg  [63:0] IF_ID_bus_r;
wire [4:0]  decode_rs, decode_rt;
wire        decode_exception_flag;
wire [1:0]  decode_exception_type;
wire        decode_eret_executed;

decode decode_dut (
    .ID_valid(1'b1),
    .IF_ID_bus_r(IF_ID_bus_r),
    .rs_value(32'h0),
    .rt_value(32'h0),
    .flush_pipeline(flush_pipeline),
    .rs(decode_rs),
    .rt(decode_rt),
    .exception_flag(decode_exception_flag),
    .exception_type(decode_exception_type),
    .eret_executed(decode_eret_executed)
);

//------------------------ EXE模块测试信号 --------------------------
reg  [151:0] ID_EXE_bus_r;
wire [1:0]   exe_exception_type;
wire         exe_exception_flag;

exe exe_dut (
    .EXE_valid(1'b1),
    .ID_EXE_bus_r(ID_EXE_bus_r),
    .flush_pipeline(flush_pipeline),
    .exe_exception_type(exe_exception_type),
    .exe_exception_flag(exe_exception_flag)
);

//------------------------ MEM模块测试信号 --------------------------
reg  [107:0] EXE_MEM_bus_r;
wire [1:0]   mem_exception_type;
wire         mem_exception_flag;
wire [31:0]  dm_addr;
wire [3:0]   dm_wen;

mem mem_dut (
    .clk(clk),
    .MEM_valid(1'b1),
    .EXE_MEM_bus_r(EXE_MEM_bus_r),
    .dm_addr(dm_addr),
    .dm_wen(dm_wen),
    .flush_pipeline(flush_pipeline),
    .mem_exception_type(mem_exception_type),
    .mem_exception_flag(mem_exception_flag)
);

//------------------------ 主测试流程 -------------------------------
initial begin
    // 初始化信号
    clk = 0;
    reset_n = 0;
    flush_pipeline = 0;
    testcase = 0;
    success_count = 0;
    fail_count = 0;
    
    // 复位过程
    #20 reset_n = 1;
    #10;
    
    $display("[信息] 开始完整异常测试套件");
    
    // 执行Decode模块测试
    test_decode_illegal_instruction(32'hFC000000);    // 非法指令
    test_decode_eret_instruction(32'h42000018);       // ERET指令
    
    // 执行EXE模块测试
    test_exe_div_by_zero();                          // 除零异常
    test_exe_overflow();                             // 溢出异常
    
    // 执行MEM模块测试
    test_mem_misaligned_word(32'h00000001);           // 字地址未对齐
    test_mem_misaligned_halfword(32'h00000003);       // 半字地址未对齐
    
    // 显示最终结果
    $display("\n[最终结果] 总测试用例: %0d", testcase);
    $display("[最终结果] 成功: %0d, 失败: %0d", success_count, fail_count);
    #100 $finish;
end

//------------------------ Decode测试任务 --------------------------
task test_decode_illegal_instruction;
input [31:0] inst;
begin
    testcase = testcase + 1;
    $display("\n测试用例 %0d: 非法指令检测", testcase);
    
    IF_ID_bus_r = {32'h00400000, inst};
    #10;
    
    if (decode_exception_flag && decode_exception_type == 2'b01) begin
        success_count = success_count + 1;
        $display("[通过] 非法指令检测成功");
    end else begin
        fail_count = fail_count + 1;
        $display("[失败] 异常类型:%b 标志:%b", 
                decode_exception_type, decode_exception_flag);
    end
end
endtask

task test_decode_eret_instruction;
input [31:0] inst;
begin
    testcase = testcase + 1;
    $display("\n测试用例 %0d: ERET指令检测", testcase);
    
    IF_ID_bus_r = {32'h00400004, inst};
    #10;
    
    if (decode_eret_executed && !decode_exception_flag) begin
        success_count = success_count + 1;
        $display("[通过] ERET指令识别成功");
    end else begin
        fail_count = fail_count + 1;
        $display("[失败] ERET信号:%b", decode_eret_executed);
    end
end
endtask

//------------------------ EXE测试任务 ----------------------------
task test_exe_div_by_zero;
begin
    testcase = testcase + 1;
    $display("\n测试用例 %0d: 除零异常检测", testcase);
    
    ID_EXE_bus_r = build_exe_bus(
        2'b00,        // 无ID异常
        1'b0,
        13'h1000,     // 除法操作
        32'h0000FFFF,
        32'h00000000  // 除数为0
    );
    #10;
    
    if (exe_exception_flag && exe_exception_type == 2'b10) begin
        success_count = success_count + 1;
        $display("[通过] 除零异常检测成功");
    end else begin
        fail_count = fail_count + 1;
        $display("[失败] 类型:%b 标志:%b", exe_exception_type, exe_exception_flag);
    end
end
endtask

task test_exe_overflow;
begin
    testcase = testcase + 1;
    $display("\n测试用例 %0d: 算术溢出检测", testcase);
    
    ID_EXE_bus_r = build_exe_bus(
        2'b00,
        1'b0,
        13'h0800,      // ADD操作
        32'h7FFFFFFF,  // 最大正数
        32'h00000001   // 加1
    );
    #10;
    
    if (exe_exception_flag && exe_exception_type == 2'b11) begin
        success_count = success_count + 1;
        $display("[通过] 溢出异常检测成功");
    end else begin
        fail_count = fail_count + 1;
        $display("[失败] 类型:%b 标志:%b", exe_exception_type, exe_exception_flag);
    end
end
endtask

//------------------------ MEM测试任务 ----------------------------
task test_mem_misaligned_word;
input [31:0] addr;
begin
    testcase = testcase + 1;
    $display("\n测试用例 %0d: 字地址未对齐检测", testcase);
    
    EXE_MEM_bus_r = build_mem_bus(
        2'b00,
        1'b0,
        4'b1100,       // 字存储
        addr
    );
    #10;
    
    if (mem_exception_flag && mem_exception_type == 2'b01) begin
        success_count = success_count + 1;
        $display("[通过] 地址未对齐检测成功");
    end else begin
        fail_count = fail_count + 1;
        $display("[失败] 类型:%b 标志:%b", mem_exception_type, mem_exception_flag);
    end
end
endtask

task test_mem_misaligned_halfword;
input [31:0] addr;
begin
    testcase = testcase + 1;
    $display("\n测试用例 %0d: 半字地址未对齐检测", testcase);
    
    EXE_MEM_bus_r = build_mem_bus(
        2'b00,
        1'b0,
        4'b1010,       // 半字存储
        addr
    );
    #10;
    
    if (mem_exception_flag && mem_exception_type == 2'b01) begin
        success_count = success_count + 1;
        $display("[通过] 半字未对齐检测成功");
    end else begin
        fail_count = fail_count + 1;
        $display("[失败] 类型:%b 标志:%b", mem_exception_type, mem_exception_flag);
    end
end
endtask

//------------------------ 总线生成函数 ---------------------------
function [151:0] build_exe_bus;
input [1:0]  ex_type;
input        ex_flag;
input [12:0] alu_ctrl;
input [31:0] op1;
input [31:0] op2;
begin
    build_exe_bus = {
        ex_type,     // [151:150]
        ex_flag,     // [149]
        alu_ctrl,    // [148:136]
        op1,         // [135:104]
        op2,         // [103:72]
        4'b0000,     // mem_control
        32'h0,       // store_data
        1'b0,        // rf_wen
        5'd0,        // rf_wdest
        32'h00400000 // pc
    };
end
endfunction

function [107:0] build_mem_bus;
input [1:0]  ex_type;
input        ex_flag;
input [3:0]  mem_ctrl;
input [31:0] addr;
begin
    build_mem_bus = {
        ex_type,     // [107:106]
        ex_flag,     // [105]
        mem_ctrl,    // [104:101]
        32'h0,       // store_data
        addr,        // alu_result
        1'b0,        // rf_wen
        5'd0,        // rf_wdest
        32'h00400000 // pc
    };
end
endfunction

// 波形记录
initial begin
    $dumpfile("full_cpu_waves.vcd");
    $dumpvars(0, full_cpu_tb);
end

endmodule