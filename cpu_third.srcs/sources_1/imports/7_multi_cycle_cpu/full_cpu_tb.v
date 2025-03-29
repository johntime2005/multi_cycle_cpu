`timescale 1ns/1ps

module full_cpu_tb();

// 全局信号定义
reg          clk;
reg          reset_n; // 应为 resetn
// reg          flush_pipeline; // 移除，由 exception_triggered 控制
integer      testcase;
integer      success_count;
integer      fail_count;
reg  [5:0]   irq; // 新增中断输入

// 时钟生成：100MHz
always #5 clk = ~clk;

//------------------------ Decode模块相关信号 ------------------------
reg  [63:0] IF_ID_bus_r;
wire [4:0]  decode_rs, decode_rt;
wire [32:0] decode_jbr_bus;
wire        decode_jbr_not_link;
wire        decode_ID_over;
wire [156:0] decode_ID_EXE_bus; // 更新位宽
wire [31:0]  decode_ID_pc;
wire [1:0]  decode_id_exception_type; // 更新名称
wire        decode_id_exception_flag; // 更新名称
wire [1:0]  decode_id_interrupt_type; // 新增
wire        decode_id_interrupt_flag; // 新增
wire        decode_eret_executed;     // 新增

decode decode_dut (
    .ID_valid(1'b1), // 简化测试，假设一直有效
    .IF_ID_bus_r(IF_ID_bus_r),
    .rs_value(32'h0), // 简化测试
    .rt_value(32'h0), // 简化测试
    .irq(irq),        // 连接中断
    // .flush_pipeline(flush_pipeline), // 移除
    .rs(decode_rs),
    .rt(decode_rt),
    .jbr_bus(decode_jbr_bus),
    .jbr_not_link(decode_jbr_not_link),
    .ID_over(decode_ID_over),
    .ID_EXE_bus(decode_ID_EXE_bus),
    .ID_pc(decode_ID_pc),
    .eret_executed(decode_eret_executed),
    .id_exception_type(decode_id_exception_type),
    .id_exception_flag(decode_id_exception_flag),
    .id_interrupt_type(decode_id_interrupt_type),
    .id_interrupt_flag(decode_id_interrupt_flag)
);

//------------------------ EXE模块相关信号 --------------------------
reg  [156:0] ID_EXE_bus_r; // 更新位宽
wire         exe_EXE_over;
wire [108:0] exe_EXE_MEM_bus; // 更新位宽
wire [1:0]   exe_exception_type;
wire         exe_exception_flag;
wire [31:0]  exe_EXE_pc;

exe exe_dut (
    .EXE_valid(1'b1), // 简化测试
    .ID_EXE_bus_r(ID_EXE_bus_r),
    // .flush_pipeline(flush_pipeline), // 移除
    .exe_exception_type(exe_exception_type),
    .exe_exception_flag(exe_exception_flag),
    .EXE_MEM_bus(exe_EXE_MEM_bus),
    .EXE_pc(exe_EXE_pc)
    // .EXE_over(exe_EXE_over) // 可选连接
);

//------------------------ MEM模块相关信号 --------------------------
reg  [108:0] EXE_MEM_bus_r; // 更新位宽
wire         mem_MEM_over;
wire [72:0]  mem_MEM_WB_bus; // 更新位宽
wire [1:0]   mem_exception_type;
wire         mem_exception_flag;
wire [31:0]  dm_addr;
wire [3:0]   dm_wen;
wire [31:0]  mem_MEM_pc;

mem mem_dut (
    .clk(clk),
    .MEM_valid(1'b1), // 简化测试
    .EXE_MEM_bus_r(EXE_MEM_bus_r),
    .dm_rdata(32'h0), // 简化测试
    .dm_addr(dm_addr),
    .dm_wen(dm_wen),
    .dm_wdata(), // 可选连接
    .MEM_over(mem_MEM_over),
    .MEM_WB_bus(mem_MEM_WB_bus),
    .MEM_pc(mem_MEM_pc),
    // .flush_pipeline(flush_pipeline), // 移除
    .mem_exception_type(mem_exception_type),
    .mem_exception_flag(mem_exception_flag)
);

//------------------------ 测试初始化 -------------------------------
initial begin
    // 初始化信号
    clk = 0;
    reset_n = 0; // 应为 resetn
    // flush_pipeline = 0; // 移除
    irq = 6'b0;
    testcase = 0;
    success_count = 0;
    fail_count = 0;

    // 复位过程
    #20 reset_n = 1; // 应为 resetn
    #10;

    $display("[信息] 开始执行异常测试基准");

    // 执行Decode模块测试
    test_decode_illegal_instruction(32'hFC000000);    // 非法指令
    test_decode_eret_instruction(32'h42000018);       // ERET指令
    test_decode_adel_fetch(32'h00400001);             // 取指地址错

    // 执行EXE模块测试
    test_exe_overflow();                             // 溢出异常

    // 执行MEM模块测试
    test_mem_misaligned_load(32'h00000001);           // Load地址未对齐 (AdEL)
    test_mem_misaligned_store(32'h00000003);          // Store地址未对齐 (AdES)

    // 显示测试结果
    $display("\n[测试结果] 总测试用例: %0d", testcase);
    $display("[测试结果] 成功: %0d, 失败: %0d", success_count, fail_count);
    #100 $finish;
end

//------------------------ Decode测试任务 --------------------------
task test_decode_illegal_instruction;
input [31:0] inst;
begin
    testcase = testcase + 1;
    $display("\n测试用例 %0d: 非法指令测试", testcase);

    IF_ID_bus_r = {inst, 32'h00400000}; // PC = 0x400000
    #10;

    if (decode_id_exception_flag && decode_id_exception_type == 2'b10) begin // RI = 2'b10
        success_count = success_count + 1;
        $display("[通过] 非法指令测试成功");
    end else begin
        fail_count = fail_count + 1;
        $display("[失败] 异常类型:%b 标志:%b",
                decode_id_exception_type, decode_id_exception_flag);
    end
end
endtask

task test_decode_eret_instruction;
input [31:0] inst;
begin
    testcase = testcase + 1;
    $display("\n测试用例 %0d: ERET指令测试", testcase);

    IF_ID_bus_r = {inst, 32'h00400004}; // PC = 0x400004
    #10;

    if (decode_eret_executed && !decode_id_exception_flag) begin
        success_count = success_count + 1;
        $display("[通过] ERET指令识别成功");
    end else begin
        fail_count = fail_count + 1;
        $display("[失败] ERET信号:%b, 异常标志:%b", decode_eret_executed, decode_id_exception_flag);
    end
end
endtask

task test_decode_adel_fetch;
input [31:0] pc_addr;
begin
    testcase = testcase + 1;
    $display("\n测试用例 %0d: 取指地址错测试", testcase);

    IF_ID_bus_r = {32'h00000000, pc_addr}; // 在未对齐地址处的 NOP
    #10;

    if (decode_id_exception_flag && decode_id_exception_type == 2'b00) begin // AdEL = 2'b00
        success_count = success_count + 1;
        $display("[通过] 取指地址错测试成功");
    end else begin
        fail_count = fail_count + 1;
        $display("[失败] 异常类型:%b 标志:%b",
                decode_id_exception_type, decode_id_exception_flag);
    end
end
endtask


//------------------------ EXE测试任务 ----------------------------
task test_exe_overflow;
begin
    testcase = testcase + 1;
    $display("\n测试用例 %0d: 算术溢出测试", testcase);

    // 构建 ID_EXE_bus_r: {int_type, int_flag, exc_type, exc_flag, alu_ctrl(ADD), op1, op2, ...}
    ID_EXE_bus_r = {
        2'b00, 1'b0, // 无中断
        2'b00, 1'b0, // 无 ID 异常
        13'b0_1_0_00_000_0000, // ADD 的 ALU 控制信号
        32'h7FFFFFFF,  // 操作数 1 (最大正数)
        32'h00000001,  // 操作数 2
        4'b0000,       // mem_control
        32'h0,         // store_data
        1'b1,          // rf_wen (示例)
        5'd1,          // rf_wdest (示例)
        32'h00400008   // pc
    };
    #10;

    if (exe_exception_flag && exe_exception_type == 2'b11) begin // Ovf = 2'b11
        success_count = success_count + 1;
        $display("[通过] 溢出异常测试成功");
    end else begin
        fail_count = fail_count + 1;
        $display("[失败] 类型:%b 标志:%b", exe_exception_type, exe_exception_flag);
    end
end
endtask

//------------------------ MEM测试任务 ----------------------------
task test_mem_misaligned_load;
input [31:0] addr;
begin
    testcase = testcase + 1;
    $display("\n测试用例 %0d: Load地址未对齐测试", testcase);

    // 构建 EXE_MEM_bus_r: {exc_type, exc_flag, mem_ctrl(LW), alu_res(addr), ...}
    EXE_MEM_bus_r = {
        2'b00, 1'b0, // 无 EXE 异常
        4'b1010,     // LW 的 mem_control
        addr,        // alu_result (地址)
        32'h0,       // store_data
        1'b1,        // rf_wen (示例)
        5'd2,        // rf_wdest (示例)
        32'h0040000C // pc
    };
    #10;

    if (mem_exception_flag && mem_exception_type == 2'b00) begin // AdEL = 2'b00
        success_count = success_count + 1;
        $display("[通过] Load地址未对齐测试成功");
    end else begin
        fail_count = fail_count + 1;
        $display("[失败] 类型:%b 标志:%b", mem_exception_type, mem_exception_flag);
    end
end
endtask

task test_mem_misaligned_store;
input [31:0] addr;
begin
    testcase = testcase + 1;
    $display("\n测试用例 %0d: Store地址未对齐测试", testcase);

    // 构建 EXE_MEM_bus_r: {exc_type, exc_flag, mem_ctrl(SW), alu_res(addr), store_data, ...}
     EXE_MEM_bus_r = {
        2'b00, 1'b0, // 无 EXE 异常
        4'b0110,     // SW 的 mem_control
        addr,        // alu_result (地址)
        32'hDEADBEEF,// store_data
        1'b0,        // rf_wen (SW 不写 GPR)
        5'd0,        // rf_wdest
        32'h00400010 // pc
    };
    #10;

    if (mem_exception_flag && mem_exception_type == 2'b01) begin // AdES = 2'b01
        success_count = success_count + 1;
        $display("[通过] Store地址未对齐测试成功");
    end else begin
        fail_count = fail_count + 1;
        $display("[失败] 类型:%b 标志:%b", mem_exception_type, mem_exception_flag);
    end
end
endtask


// 波形记录
initial begin
    $dumpfile("full_cpu_waves.vcd");
    $dumpvars(0, full_cpu_tb);
end

endmodule