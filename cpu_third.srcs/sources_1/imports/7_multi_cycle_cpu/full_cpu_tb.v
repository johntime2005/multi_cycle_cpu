`timescale 1ns / 1ps

module full_cpu_tb ();

// Global signals
reg          clk;
reg          reset_n; // Testbench internal reset signal
// reg          flush_pipeline; // Removed
integer      testcase;
integer      success_count;
integer      fail_count;
reg  [5:0]   irq;

// Clock generation: 100MHz
always #5 clk = ~clk;

//------------------------ Decode Module Signals ------------------------
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
    .ID_valid(1'b1),
    .IF_ID_bus_r(IF_ID_bus_r),
    .rs_value(32'h0),
    .rt_value(32'h0),
    .irq(irq),
    // .flush_pipeline(flush_pipeline),
    .rs(decode_rs),
    .rt(decode_rt),
    .jbr_bus(decode_jbr_bus),
    .jbr_not_link(decode_jbr_not_link),
    .ID_over(decode_ID_over),
    .ID_EXE_bus(decode_ID_EXE_bus),
    .ID_pc(decode_ID_pc),
    .eret_executed(decode_eret_executed), // Output from decode
    .id_exception_type(decode_id_exception_type),
    .id_exception_flag(decode_id_exception_flag),
    .id_interrupt_type(decode_id_interrupt_type),
    .id_interrupt_flag(decode_id_interrupt_flag)
);

//------------------------ EXE Module Signals --------------------------
reg  [156:0] ID_EXE_bus_r; // 更新位宽
wire         exe_EXE_over;
wire [108:0] exe_EXE_MEM_bus; // 更新位宽
wire [1:0]   exe_exception_type;
wire         exe_exception_flag;
wire [31:0]  exe_EXE_pc;

exe exe_dut (
    .EXE_valid(1'b1),
    .ID_EXE_bus_r(ID_EXE_bus_r),
    // .flush_pipeline(flush_pipeline),
    .exe_exception_type(exe_exception_type),
    .exe_exception_flag(exe_exception_flag),
    .EXE_MEM_bus(exe_EXE_MEM_bus),
    .EXE_pc(exe_EXE_pc)
    // .EXE_over(exe_EXE_over)
);

//------------------------ MEM Module Signals --------------------------
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
    .MEM_valid(1'b1),
    .EXE_MEM_bus_r(EXE_MEM_bus_r),
    .dm_rdata(32'h0),
    .dm_addr(dm_addr),
    .dm_wen(dm_wen),
    .dm_wdata(),
    .MEM_over(mem_MEM_over),
    .MEM_WB_bus(mem_MEM_WB_bus),
    .MEM_pc(mem_MEM_pc),
    // .flush_pipeline(flush_pipeline),
    .mem_exception_type(mem_exception_type),
    .mem_exception_flag(mem_exception_flag)
);

//------------------------ Exception Controller and CP0 Module Signals --------------------------
wire        ec_exception_triggered;
wire [4:0]  ec_final_exception_type;
wire [31:0] ec_epc_out_to_cp0;
wire [31:0] ec_cp0_pc_to_fetch; // Not fully used in this TB, but part of controller
wire        ec_cp0_write_enable;

wire [31:0] cp0_epc_out;
wire [31:0] cp0_cause_out;
wire [31:0] cp0_status_out;
wire        cp0_status_exl;
wire        cp0_status_ie;

assign cp0_status_exl = cp0_status_out[1]; // Assuming EXL is bit 1
assign cp0_status_ie  = cp0_status_out[0]; // Assuming IE is bit 0

exception_controller ec_dut (
    .clk(clk),
    .resetn(reset_n), // Connect to testbench's reset
    .id_exception_type(decode_id_exception_type),
    .id_exception_flag(decode_id_exception_flag),
    .id_pc(decode_ID_pc),
    .id_interrupt_type(decode_id_interrupt_type),
    .id_interrupt_flag(decode_id_interrupt_flag),
    .exe_exception_type(exe_exception_type),
    .exe_exception_flag(exe_exception_flag),
    .exe_pc(exe_EXE_pc),
    .mem_exception_type(mem_exception_type),
    .mem_exception_flag(mem_exception_flag),
    .mem_pc(mem_MEM_pc),
    .cp0_status_exl(cp0_status_exl),
    .cp0_status_ie(cp0_status_ie),
    .exception_triggered(ec_exception_triggered),
    .final_exception_type(ec_final_exception_type),
    .epc_out(ec_epc_out_to_cp0),
    .cp0_pc(ec_cp0_pc_to_fetch),
    .cp0_write_enable(ec_cp0_write_enable)
);

cp0 cp0_dut (
    .clk(clk),
    .resetn(reset_n), // Connect to testbench's reset
    .wen(ec_cp0_write_enable),
    .epc_in(ec_epc_out_to_cp0),
    .cause_exccode_in(ec_final_exception_type),
    .eret_executed(decode_eret_executed), // Driven by decode stage
    .epc_out(cp0_epc_out),
    .cause_out(cp0_cause_out),
    .status_out(cp0_status_out)
);


//------------------------ Test Initialization -------------------------------
initial begin
    // Initialize signals
    clk = 0;
    reset_n = 0;
    reset_n = 0;
    irq = 6'b0;
    testcase = 0;
    success_count = 0;
    fail_count = 0;
    IF_ID_bus_r = 0;
    ID_EXE_bus_r = 0;
    EXE_MEM_bus_r = 0;


    // Reset sequence
    #20 reset_n = 1;
    #10;

    $display("[INFO] Starting exception test bench");

    // Execute Decode module unit tests (optional, can be kept)
    // test_decode_illegal_instruction(32'hFC000000);
    // test_decode_eret_instruction(32'h42000018);
    // test_decode_adel_fetch(32'h00400001);

    // Execute EXE module unit tests (optional, can be kept)
    // test_exe_overflow(); // This is a unit test, we'll do a program flow test

    // Execute MEM module unit tests (optional, can be kept)
    // test_mem_misaligned_load(32'h00000001);
    // test_mem_misaligned_store(32'h00000003);

    // test_program_illegal_instruction_handling(); // You can keep or comment this out
    // test_custom_program_ri_exception(); // Keep or comment out previous custom test

    // New test for the arithmetic overflow program
    test_program_arithmetic_overflow();


    // Display test results
    $display("\n[TEST RESULTS] Total test cases: %0d", testcase);
    $display("[TEST RESULTS] Passed: %0d, Failed: %0d", success_count, fail_count);
    #100 $finish;
  end

//------------------------ Decode Test Tasks --------------------------
task test_decode_illegal_instruction;
input [31:0] inst;
begin
    testcase = testcase + 1;
    $display("\nTest Case %0d: Illegal Instruction Test", testcase);

      IF_ID_bus_r = {inst, 32'h00400000};  // PC = 0x400000


      irq = 6'b0;  // 确保无中断干扰


      #10;

      if (decode_id_exception_flag && decode_id_exception_type == 2'b10) begin  // RI = 2'b10


        success_count = success_count + 1;
        $display("[PASS] Illegal Instruction Test Passed");
    end else begin
        fail_count = fail_count + 1;
        $display("[FAIL] Exception Type:%b Flag:%b",
                decode_id_exception_type, decode_id_exception_flag);
    end
end
endtask

task test_decode_eret_instruction;
input [31:0] inst;
begin
    testcase = testcase + 1;
    $display("\nTest Case %0d: ERET Instruction Test", testcase);

      IF_ID_bus_r = {inst, 32'h00400004};  // PC = 0x400004


      irq = 6'b0;  // 确保无中断干扰


      #10;

      if (decode_eret_executed && !decode_id_exception_flag) begin
        success_count = success_count + 1;
        $display("[PASS] ERET Instruction Recognition Passed");
    end else begin
        fail_count = fail_count + 1;
        $display("[FAIL] ERET Signal:%b, Exception Flag:%b", decode_eret_executed, decode_id_exception_flag);
    end
end
endtask

task test_decode_adel_fetch;
input [31:0] pc_addr;
begin
    testcase = testcase + 1;
    $display("\nTest Case %0d: Instruction Fetch Address Error Test", testcase);

    IF_ID_bus_r = {32'h00000000, pc_addr}; // NOP at unaligned address
    #10;

      if (decode_id_exception_flag && decode_id_exception_type == 2'b00) begin  // AdEL = 2'b00


        success_count = success_count + 1;
        $display("[PASS] Instruction Fetch Address Error Test Passed");
    end else begin
        fail_count = fail_count + 1;
        $display("[FAIL] Exception Type:%b Flag:%b",
                decode_id_exception_type, decode_id_exception_flag);
    end
end
endtask

  task test_decode_interrupt;
    begin
      testcase = testcase + 1;
      $display("\n测试用例 %0d: 中断请求测试 (Decode)", testcase);

      IF_ID_bus_r = {32'h00000000, 32'h00400008};  // 合法指令 NOP @ 0x00400008


      irq = 6'b000010;  // 触发 IRQ1


      #10;

      if (decode_id_interrupt_flag && decode_id_interrupt_type == 2'b01 && !decode_id_exception_flag) begin // Int = 2'b01


        success_count = success_count + 1;
        $display("[通过] 中断请求测试成功 (Decode)");
      end else begin
        fail_count = fail_count + 1;
        $display("[失败] 中断请求测试 (Decode): 中断标志:%b 类型:%b, 异常标志:%b",
                 decode_id_interrupt_flag, decode_id_interrupt_type, decode_id_exception_flag);
      end
      irq = 6'b0;  // 清除中断请求


    end
  endtask

  task test_decode_adel_over_ri;
    begin
      testcase = testcase + 1;
      $display("\n测试用例 %0d: Decode优先级 AdEL > RI 测试", testcase);

      // 非法指令 (op=0x3F) 在未对齐地址 (0x...1)

      IF_ID_bus_r = {32'hFC000000, 32'h00400001};
      irq = 6'b0;  // 确保无中断

      #10;

      // 期望 AdEL (type 00) 优先于 RI (type 10)

      if (decode_id_exception_flag && decode_id_exception_type == 2'b00 && !decode_id_interrupt_flag) begin
        success_count = success_count + 1;
        $display("[通过] Decode优先级 AdEL > RI 测试成功");
      end else begin
        fail_count = fail_count + 1;
        $display(
            "[失败] Decode优先级 AdEL > RI: exc_flag=%b, exc_type=%b, int_flag=%b. 期望 exc_flag=1, exc_type=00, int_flag=0",
            decode_id_exception_flag, decode_id_exception_type, decode_id_interrupt_flag);
      end
    end
  endtask

//------------------------ EXE Test Task ----------------------------
task test_exe_overflow;
begin
    testcase = testcase + 1;
    $display("\nTest Case %0d: Arithmetic Overflow Test", testcase);

    // Construct ID_EXE_bus_r: {int_type, int_flag, exc_type, exc_flag, alu_ctrl(ADD), op1, op2, ...}
    ID_EXE_bus_r = {
        2'b00, 1'b0, // No interrupt
        2'b00, 1'b0, // No ID exception
        13'b0_1_0_00_000_0000, // ALU control for ADD
        32'h7FFFFFFF,  // Operand 1 (max positive)
        32'h00000001,  // Operand 2
        4'b0000,       // mem_control
        32'h0,         // store_data
        1'b1,          // rf_wen (example)
        5'd1,          // rf_wdest (example)
        32'h00400008   // pc
    };
    #10;

      if (exe_exception_flag && exe_exception_type == 2'b11) begin  // Ovf = 2'b11


        success_count = success_count + 1;
        $display("[PASS] Overflow Exception Test Passed");
    end else begin
        fail_count = fail_count + 1;
        $display("[FAIL] Type:%b Flag:%b", exe_exception_type, exe_exception_flag);
    end
end
endtask

//------------------------ MEM Test Tasks ----------------------------
task test_mem_misaligned_load;
input [31:0] addr;
begin
    testcase = testcase + 1;
    $display("\nTest Case %0d: Load Address Misaligned Test", testcase);

    // Construct EXE_MEM_bus_r: {exc_type, exc_flag, mem_ctrl(LW), alu_res(addr), ...}
    EXE_MEM_bus_r = {
        2'b00, 1'b0, // No EXE exception
        4'b1010,     // mem_control for LW
        addr,        // alu_result (address)
        32'h0,       // store_data
        1'b1,        // rf_wen (example)
        5'd2,        // rf_wdest (example)
        32'h0040000C // pc
    };
    #10;

      if (mem_exception_flag && mem_exception_type == 2'b00) begin  // AdEL = 2'b00


        success_count = success_count + 1;
        $display("[PASS] Load Address Misaligned Test Passed");
    end else begin
        fail_count = fail_count + 1;
        $display("[FAIL] Type:%b Flag:%b", mem_exception_type, mem_exception_flag);
    end
end
endtask

task test_mem_misaligned_store;
input [31:0] addr;
begin
    testcase = testcase + 1;
    $display("\nTest Case %0d: Store Address Misaligned Test", testcase);

    // Construct EXE_MEM_bus_r: {exc_type, exc_flag, mem_ctrl(SW), alu_res(addr), store_data, ...}
     EXE_MEM_bus_r = {
        2'b00, 1'b0, // No EXE exception
        4'b0110,     // mem_control for SW
        addr,        // alu_result (address)
        32'hDEADBEEF,// store_data
        1'b0,        // rf_wen (SW does not write GPR)
        5'd0,        // rf_wdest
        32'h00400010 // pc
    };
    #10;

      if (mem_exception_flag && mem_exception_type == 2'b01) begin  // AdES = 2'b01


        success_count = success_count + 1;
        $display("[PASS] Store Address Misaligned Test Passed");
    end else begin
        fail_count = fail_count + 1;
        $display("[FAIL] Type:%b Flag:%b", mem_exception_type, mem_exception_flag);
    end
end
endtask

//------------------------ New: Program Flow Exception Handling Test Task ------------------------
task test_program_illegal_instruction_handling;
    parameter PC_START = 32'hBFC00000; // Typical reset vector start
    parameter VALID_INST_A_MACHINE_CODE = 32'h00000000; // NOP
    parameter VALID_INST_B_MACHINE_CODE = 32'h2001000A; // ADDIU $1, $0, 10
    parameter ILLEGAL_INST_C_MACHINE_CODE = 32'hFFFFFFFF; // An illegal instruction
    parameter VALID_INST_D_MACHINE_CODE = 32'h20020014; // ADDIU $2, $0, 20 (Should not execute normally after exception)

    parameter EXCCODE_RI = 5'd10; // Reserved Instruction exception code
    parameter EXCEPTION_HANDLER_PC = 32'h80000180; // Default exception vector (BEV=0)

    reg [156:0] temp_id_exe_bus;
    reg [108:0] temp_exe_mem_bus;

begin
    testcase = testcase + 1;
    $display("\nTest Case %0d: Program Flow Illegal Instruction Exception Handling Test", testcase);
    $display("  Instruction Sequence: NOP -> ADDIU -> ILLEGAL -> ADDIU (post-exception)");

    // Initialize pipeline register simulation
    ID_EXE_bus_r = 0;
    EXE_MEM_bus_r = 0;

    // --- Cycle 1: Fetch/Decode VALID_INST_A (NOP) ---
    IF_ID_bus_r = {VALID_INST_A_MACHINE_CODE, PC_START};
    #10; // Clock edge
    temp_id_exe_bus = decode_ID_EXE_bus; // Capture decode output for Inst A
    $display("  Cycle 1: PC=%h, Decoded NOP. decode_id_exception_flag=%b. Propagating to ID_EXE_bus_r.", PC_START, decode_id_exception_flag);

    // --- Cycle 2: Fetch/Decode VALID_INST_B (ADDIU), EXE VALID_INST_A ---
    ID_EXE_bus_r = temp_id_exe_bus; // Load Inst A into EXE stage input
    IF_ID_bus_r = {VALID_INST_B_MACHINE_CODE, PC_START + 4};
    #10; // Clock edge
    temp_exe_mem_bus = exe_EXE_MEM_bus;   // Capture exe output for Inst A
    temp_id_exe_bus = decode_ID_EXE_bus;  // Capture decode output for Inst B
    $display("  Cycle 2: PC=%h, Decoded ADDIU. decode_id_exception_flag=%b. Inst A in EXE. Propagating.", PC_START+4, decode_id_exception_flag);

    // --- Cycle 3: Fetch/Decode ILLEGAL_INST_C, EXE VALID_INST_B, MEM VALID_INST_A ---
    EXE_MEM_bus_r = temp_exe_mem_bus; // Load Inst A into MEM stage input
    ID_EXE_bus_r = temp_id_exe_bus;   // Load Inst B into EXE stage input
    IF_ID_bus_r = {ILLEGAL_INST_C_MACHINE_CODE, PC_START + 8};
    #10; // Clock edge
    // temp_mem_wb_bus = mem_MEM_WB_bus; // Capture mem output for Inst A (if WB was present)
    temp_exe_mem_bus = exe_EXE_MEM_bus;   // Capture exe output for Inst B
    temp_id_exe_bus = decode_ID_EXE_bus;  // Capture decode output for Inst C (Illegal)
    $display("  Cycle 3: PC=%h, Decoded ILLEGAL. decode_id_exception_flag=%b, type=%b. Inst B in EXE. Inst A in MEM.", PC_START+8, decode_id_exception_flag, decode_id_exception_type);
    $display("           EXE stage (Inst B): exe_exception_flag=%b", exe_exception_flag);


    // --- Cycle 4: Fetch/Decode VALID_INST_D, EXE ILLEGAL_INST_C, MEM VALID_INST_B ---
    EXE_MEM_bus_r = temp_exe_mem_bus; // Load Inst B into MEM stage input
    ID_EXE_bus_r = temp_id_exe_bus;   // Load Inst C (Illegal) into EXE stage input
    IF_ID_bus_r = {VALID_INST_D_MACHINE_CODE, PC_START + 12}; // Simulate next fetch
    #10; // Clock edge

    $display("  Cycle 4: EXE stage (Inst C - Illegal): exe_exception_flag=%b, type=%b. PC of illegal inst (was %h)", exe_exception_flag, exe_exception_type, PC_START + 8);
    $display("           Exception Controller: ec_triggered=%b, ec_final_type=%d, ec_epc_to_cp0=%h, ec_cp0_pc_to_fetch=%h",
             ec_exception_triggered, ec_final_exception_type, ec_epc_out_to_cp0, ec_cp0_pc_to_fetch);
    $display("           CP0 State: cp0_epc_out=%h, cp0_cause_exc=%d, cp0_status_exl=%b",
             cp0_epc_out, cp0_cause_out[6:2], cp0_status_out[1]);

    // Verification after the illegal instruction should have been processed by exception controller
    if (ec_exception_triggered &&
        ec_final_exception_type == EXCCODE_RI &&
        ec_epc_out_to_cp0 == (PC_START + 8) &&   // EPC should be the address of the ILLEGAL_INST_C
        ec_cp0_pc_to_fetch == EXCEPTION_HANDLER_PC && // Next PC should be exception handler
        cp0_epc_out == (PC_START + 8) &&         // CP0.EPC updated
        cp0_cause_out[6:2] == EXCCODE_RI &&      // CP0.Cause.ExcCode updated for RI
        cp0_status_out[1] == 1'b1) begin         // CP0.Status.EXL set
        success_count = success_count + 1;
        $display("[PASS] Program Flow Illegal Instruction Exception Handling Test Passed");
    end else begin
        fail_count = fail_count + 1;
        $display("[FAIL] Program Flow Illegal Instruction Exception Handling Test Failed");
        $display("  Expected: ec_triggered=1, ec_type=%d, ec_epc=%h, ec_next_pc=%h", EXCCODE_RI, PC_START+8, EXCEPTION_HANDLER_PC);
        $display("  Expected: cp0_epc=%h, cp0_cause_exc=%d, cp0_status_exl=1", PC_START+8, EXCCODE_RI);
    end
end
endtask

//------------------------ New Task: Test Custom Program with RI Exception ------------------------
task test_custom_program_ri_exception;
    parameter PC_BASE_ADDR = 32'hBFC00000; // Starting PC for this test program

    // Machine code for test_exception.s
    parameter INST_LUI_AT_1234   = 32'h3c011234; // lui $at, 0x1234
    parameter INST_ORI_AT_5678   = 32'h34215678; // ori $at, $at, 0x5678
    parameter INST_NOP           = 32'h00000000; // nop
    parameter INST_ILLEGAL       = 32'hFFFFFFFF; // Illegal instruction
    // parameter INST_NOP_AFTER_EXC = 32'h00000000; // nop (should not execute)

    parameter EXCCODE_RI = 5'd10; // Reserved Instruction exception code
    parameter EXCEPTION_HANDLER_PC = 32'h80000180; // Default exception vector (BEV=0)

    reg [156:0] temp_id_exe_bus_prog;
    reg [108:0] temp_exe_mem_bus_prog;
    integer cycle_count;

begin
    testcase = testcase + 1;
    cycle_count = 0;
    $display("\nTest Case %0d: Custom Program with RI Exception Test", testcase);
    $display("  Program: LUI -> ORI -> NOP -> ILLEGAL -> NOP (post-exception)");

    // Initialize pipeline register simulation
    ID_EXE_bus_r = 0;
    EXE_MEM_bus_r = 0;

    // --- Cycle 1: Fetch/Decode INST_LUI_AT_1234 ---
    cycle_count = cycle_count + 1;
    IF_ID_bus_r = {INST_LUI_AT_1234, PC_BASE_ADDR};
    #10; // Clock edge
    temp_id_exe_bus_prog = decode_ID_EXE_bus;
    $display("  Cycle %0d: PC=%h, Decoded LUI. decode_exc_flag=%b.", cycle_count, PC_BASE_ADDR, decode_id_exception_flag);

    // --- Cycle 2: Fetch/Decode INST_ORI_AT_5678, EXE LUI ---
    cycle_count = cycle_count + 1;
    ID_EXE_bus_r = temp_id_exe_bus_prog;
    IF_ID_bus_r = {INST_ORI_AT_5678, PC_BASE_ADDR + 4};
    #10; // Clock edge
    temp_exe_mem_bus_prog = exe_EXE_MEM_bus;
    temp_id_exe_bus_prog = decode_ID_EXE_bus;
    $display("  Cycle %0d: PC=%h, Decoded ORI. decode_exc_flag=%b. LUI in EXE.", cycle_count, PC_BASE_ADDR + 4, decode_id_exception_flag);

    // --- Cycle 3: Fetch/Decode INST_NOP, EXE ORI, MEM LUI ---
    cycle_count = cycle_count + 1;
    EXE_MEM_bus_r = temp_exe_mem_bus_prog;
    ID_EXE_bus_r = temp_id_exe_bus_prog;
    IF_ID_bus_r = {INST_NOP, PC_BASE_ADDR + 8};
    #10; // Clock edge
    temp_exe_mem_bus_prog = exe_EXE_MEM_bus;
    temp_id_exe_bus_prog = decode_ID_EXE_bus;
    $display("  Cycle %0d: PC=%h, Decoded NOP. decode_exc_flag=%b. ORI in EXE.", cycle_count, PC_BASE_ADDR + 8, decode_id_exception_flag);

    // --- Cycle 4: Fetch/Decode INST_ILLEGAL, EXE NOP, MEM ORI ---
    cycle_count = cycle_count + 1;
    EXE_MEM_bus_r = temp_exe_mem_bus_prog;
    ID_EXE_bus_r = temp_id_exe_bus_prog; // NOP's info into EXE
    IF_ID_bus_r = {INST_ILLEGAL, PC_BASE_ADDR + 12}; // PC of the illegal instruction
    #10; // Clock edge
    temp_exe_mem_bus_prog = exe_EXE_MEM_bus; // EXE output for NOP
    temp_id_exe_bus_prog = decode_ID_EXE_bus; // Decode output for ILLEGAL instruction
    $display("  Cycle %0d: PC=%h, Decoded ILLEGAL. decode_exc_flag=%b, decode_exc_type=%b. NOP in EXE.", cycle_count, PC_BASE_ADDR + 12, decode_id_exception_flag, decode_id_exception_type);
    $display("           EXE stage (NOP): exe_exception_flag=%b", exe_exception_flag);


    // --- Cycle 5: EXE ILLEGAL. Exception should be fully processed by controller and CP0. ---
    // The 'fetch' for the instruction after ILLEGAL would be influenced by exception_triggered.
    cycle_count = cycle_count + 1;
    EXE_MEM_bus_r = temp_exe_mem_bus_prog; // NOP's info into MEM
    ID_EXE_bus_r = temp_id_exe_bus_prog;   // ILLEGAL instruction's info into EXE
                                           // decode_ID_pc will be for the instruction after ILLEGAL if fetch wasn't redirected.
    IF_ID_bus_r = {INST_NOP, PC_BASE_ADDR + 16}; // Simulate next fetch, though it should be redirected
    #10; // Clock edge
    // At this clock edge, the exception from INST_ILLEGAL (which was in decode, then its info passed to exe)
    // is processed by exception_controller and CP0.
    // exe_dut processes temp_id_exe_bus_prog (ILLEGAL_INST_C's info)

    $display("  Cycle %0d: EXE stage (ILLEGAL): exe_exception_flag=%b, exe_exception_type=%b. PC of illegal inst (was %h)", cycle_count, exe_exception_flag, exe_exception_type, PC_BASE_ADDR + 12);
    $display("           Exception Controller: ec_triggered=%b, ec_final_type=%d, ec_epc_to_cp0=%h, ec_cp0_pc_to_fetch=%h",
             ec_exception_triggered, ec_final_exception_type, ec_epc_out_to_cp0, ec_cp0_pc_to_fetch);
    $display("           CP0 State: cp0_epc_out=%h, cp0_cause_exc=%d, cp0_status_exl=%b",
             cp0_epc_out, cp0_cause_out[6:2], cp0_status_out[1]);

    // Verification
    if (ec_exception_triggered &&
        ec_final_exception_type == EXCCODE_RI &&
        ec_epc_out_to_cp0 == (PC_BASE_ADDR + 12) &&   // EPC should be the address of the ILLEGAL_INST_C
        ec_cp0_pc_to_fetch == EXCEPTION_HANDLER_PC && // Next PC should be exception handler
        cp0_epc_out == (PC_BASE_ADDR + 12) &&         // CP0.EPC updated
        cp0_cause_out[6:2] == EXCCODE_RI &&           // CP0.Cause.ExcCode updated for RI
        cp0_status_out[1] == 1'b1) begin              // CP0.Status.EXL set
        success_count = success_count + 1;
        $display("[PASS] Custom Program RI Exception Test Passed");
    end else begin
        fail_count = fail_count + 1;
        $display("[FAIL] Custom Program RI Exception Test Failed");
        $display("  Expected: ec_triggered=1, ec_type=%d, ec_epc=%h, ec_next_pc=%h", EXCCODE_RI, PC_BASE_ADDR + 12, EXCEPTION_HANDLER_PC);
        $display("  Expected: cp0_epc=%h, cp0_cause_exc=%d, cp0_status_exl=1", PC_BASE_ADDR + 12, EXCCODE_RI);
    end
end
endtask

//------------------------ New Task: Test Program with Arithmetic Overflow Exception ------------------------
task test_program_arithmetic_overflow;
    parameter PC_BASE_ADDR = 32'hBFC00000; // Starting PC for this test program

    // Machine code for the modified overflow program (from test.s)
    parameter INST_ADDIU_S0_Z_3  = 32'h24100003; // addiu $s0, $zero, 3
    parameter INST_ADDIU_S1_Z_0  = 32'h24110000; // addiu $s1, $zero, 0
    parameter INST_ADDU_S1_S1_S0 = 32'h02308821; // addu $s1, $s1, $s0
    parameter INST_ADDIU_S0_S0_M1= 32'h2610FFFF; // addiu $s0, $s0, -1
    parameter INST_BGTZ_S0_LOOP  = 32'h1E00FFFD; // bgtz $s0, loop_start (offset -3)
    parameter INST_NOP_DELAY     = 32'h00000000; // nop (delay slot)
    parameter INST_LUI_T0        = 32'h3c087fff; // lui $t0, 0x7FFF
    parameter INST_ORI_T0        = 32'h3508ffff; // ori $t0, $t0, 0xFFFF
    parameter INST_ADDIU_T1      = 32'h24090001; // addiu $t1, $zero, 1
    parameter INST_ADD_T2_T0_T1  = 32'h01095020; // add $t2, $t0, $t1  -- This will overflow
    parameter INST_NOP_AFTER_ADD = 32'h00000000; // nop
    parameter INST_BRANCH_END    = 32'h0400FFFF; // b end_loop
    parameter INST_NOP_END_DELAY = 32'h00000000; // nop (delay slot for end_loop branch)


    parameter EXCCODE_OVF = 5'd12; // Arithmetic Overflow exception code
    parameter EXCEPTION_HANDLER_PC = 32'h80000180; // Default exception vector (BEV=0)

    reg [156:0] temp_id_exe_bus_ovf;
    reg [108:0] temp_exe_mem_bus_ovf;
    integer cycle_count_ovf;
    integer current_pc;

begin
    testcase = testcase + 1;
    cycle_count_ovf = 0;
    current_pc = PC_BASE_ADDR;
    $display("\nTest Case %0d: Program with Loop and Arithmetic Overflow Exception Test", testcase);
    $display("  Program: Init -> Loop (3 times) -> Setup Overflow -> ADD (Overflows!) -> NOP ...");

    // Initialize pipeline register simulation
    ID_EXE_bus_r = 0;
    EXE_MEM_bus_r = 0;

    // Helper macro for stepping through instructions
    `define STEP_INSTRUCTION(inst_val, inst_name_str) \
        cycle_count_ovf = cycle_count_ovf + 1; \
        IF_ID_bus_r = {inst_val, current_pc}; \
        #10; /* Clock edge */ \
        EXE_MEM_bus_r = temp_exe_mem_bus_ovf; /* MEM stage gets previous EXE output */ \
        ID_EXE_bus_r = temp_id_exe_bus_ovf;   /* EXE stage gets previous ID output */ \
        temp_exe_mem_bus_ovf = exe_EXE_MEM_bus; /* Capture current EXE output */ \
        temp_id_exe_bus_ovf = decode_ID_EXE_bus; /* Capture current ID output */ \
        $display("  Cycle %0d: PC=%h, Decoded %s. ID_exc_flag=%b. EXE_exc_flag=%b (from prev inst).", cycle_count_ovf, current_pc, inst_name_str, decode_id_exception_flag, ID_EXE_bus_r[108-32-1-1]); \
        current_pc = current_pc + 4;

    // --- Initial instructions ---
    `STEP_INSTRUCTION(INST_ADDIU_S0_Z_3, "ADDIU $s0, $0, 3")
    `STEP_INSTRUCTION(INST_ADDIU_S1_Z_0, "ADDIU $s1, $0, 0")

    // --- Loop (3 iterations) ---
    // Iteration 1
    `STEP_INSTRUCTION(INST_ADDU_S1_S1_S0, "ADDU $s1, $s1, $s0 (Iter 1)")
    `STEP_INSTRUCTION(INST_ADDIU_S0_S0_M1,"ADDIU $s0, $s0, -1 (Iter 1)")
    `STEP_INSTRUCTION(INST_BGTZ_S0_LOOP,  "BGTZ $s0, loop (Iter 1)") // Branch taken
    current_pc = PC_BASE_ADDR + 8; // PC after branch for BGTZ
    `STEP_INSTRUCTION(INST_NOP_DELAY,     "NOP (Delay Slot 1)")

    // Iteration 2
    `STEP_INSTRUCTION(INST_ADDU_S1_S1_S0, "ADDU $s1, $s1, $s0 (Iter 2)")
    `STEP_INSTRUCTION(INST_ADDIU_S0_S0_M1,"ADDIU $s0, $s0, -1 (Iter 2)")
    `STEP_INSTRUCTION(INST_BGTZ_S0_LOOP,  "BGTZ $s0, loop (Iter 2)") // Branch taken
    current_pc = PC_BASE_ADDR + 8; // PC after branch for BGTZ
    `STEP_INSTRUCTION(INST_NOP_DELAY,     "NOP (Delay Slot 2)")

    // Iteration 3
    `STEP_INSTRUCTION(INST_ADDU_S1_S1_S0, "ADDU $s1, $s1, $s0 (Iter 3)")
    `STEP_INSTRUCTION(INST_ADDIU_S0_S0_M1,"ADDIU $s0, $s0, -1 (Iter 3)")
    `STEP_INSTRUCTION(INST_BGTZ_S0_LOOP,  "BGTZ $s0, loop (Iter 3)") // Branch NOT taken (s0 is 0)
    // current_pc is now PC_BASE_ADDR + 16 + 4 = PC_BASE_ADDR + 20 (after BGTZ)
    `STEP_INSTRUCTION(INST_NOP_DELAY,     "NOP (Delay Slot 3)") // Executed regardless of branch

    // --- Setup for overflow ---
    `STEP_INSTRUCTION(INST_LUI_T0,        "LUI $t0")
    `STEP_INSTRUCTION(INST_ORI_T0,        "ORI $t0")
    `STEP_INSTRUCTION(INST_ADDIU_T1,      "ADDIU $t1")

    // --- Overflowing instruction ---
    // This is the instruction that will be in EXE stage when overflow is detected and processed by controller
    parameter PC_OF_OVERFLOW_INST = PC_BASE_ADDR + 36;
    cycle_count_ovf = cycle_count_ovf + 1;
    IF_ID_bus_r = {INST_ADD_T2_T0_T1, PC_OF_OVERFLOW_INST}; // ADD into Decode
    #10; // Clock edge
    EXE_MEM_bus_r = temp_exe_mem_bus_ovf; // Previous (ADDIU $t1) into MEM
    ID_EXE_bus_r = temp_id_exe_bus_ovf;   // Previous (ADDIU $t1) decode output into EXE
    temp_exe_mem_bus_ovf = exe_EXE_MEM_bus; // EXE output for ADDIU $t1
    temp_id_exe_bus_ovf = decode_ID_EXE_bus; // Decode output for ADD (no exc flag yet)
    $display("  Cycle %0d: PC=%h, Decoded ADD (Overflowing). ID_exc_flag=%b. EXE_exc_flag=%b.", cycle_count_ovf, PC_OF_OVERFLOW_INST, decode_id_exception_flag, ID_EXE_bus_r[108-32-1-1]);
    current_pc = PC_OF_OVERFLOW_INST + 4;


    // --- Next cycle: ADD is in EXE, NOP_AFTER_ADD is in Decode. Overflow detected in EXE. ---
    cycle_count_ovf = cycle_count_ovf + 1;
    IF_ID_bus_r = {INST_NOP_AFTER_ADD, current_pc}; // NOP into Decode
    #10; // Clock edge
    // EXE_MEM_bus_r gets output of ADDIU $t1
    // ID_EXE_bus_r gets output of ADD decode (temp_id_exe_bus_ovf from previous cycle)
    // At this clock edge, ADD is in EXE stage and flags an overflow.
    // The exception_controller sees this EXE-stage exception.
    $display("  Cycle %0d: EXE stage (ADD): exe_exception_flag=%b, exe_exception_type=%b. PC of ADD (was %h)", cycle_count_ovf, exe_exception_flag, exe_exception_type, PC_OF_OVERFLOW_INST);
    $display("           Exception Controller: ec_triggered=%b, ec_final_type=%d, ec_epc_to_cp0=%h, ec_cp0_pc_to_fetch=%h",
             ec_exception_triggered, ec_final_exception_type, ec_epc_out_to_cp0, ec_cp0_pc_to_fetch);
    $display("           CP0 State: cp0_epc_out=%h, cp0_cause_exc=%d, cp0_status_exl=%b",
             cp0_epc_out, cp0_cause_out[6:2], cp0_status_out[1]);

    // Verification
    if (ec_exception_triggered &&
        ec_final_exception_type == EXCCODE_OVF &&
        ec_epc_out_to_cp0 == PC_OF_OVERFLOW_INST &&
        ec_cp0_pc_to_fetch == EXCEPTION_HANDLER_PC &&
        cp0_epc_out == PC_OF_OVERFLOW_INST &&
        cp0_cause_out[6:2] == EXCCODE_OVF &&
        cp0_status_out[1] == 1'b1) begin
        success_count = success_count + 1;
        $display("[PASS] Program with Loop and Arithmetic Overflow Exception Test Passed");
    end else begin
        fail_count = fail_count + 1;
        $display("[FAIL] Program with Loop and Arithmetic Overflow Exception Test Failed");
        $display("  Expected: ec_triggered=1, ec_final_type=%d (OVF), ec_epc=%h, ec_next_pc=%h", EXCCODE_OVF, PC_OF_OVERFLOW_INST, EXCEPTION_HANDLER_PC);
        $display("  Actual:   ec_triggered=%b, ec_final_type=%d,       ec_epc=%h, ec_next_pc=%h", ec_exception_triggered, ec_final_exception_type, ec_epc_out_to_cp0, ec_cp0_pc_to_fetch);
        $display("  Expected: cp0_epc=%h, cp0_cause_exc=%d, cp0_status_exl=1", PC_OF_OVERFLOW_INST, EXCCODE_OVF);
        $display("  Actual:   cp0_epc=%h, cp0_cause_exc=%d, cp0_status_exl=%b", cp0_epc_out, cp0_cause_out[6:2], cp0_status_out[1]);
    end
end
endtask

  task test_mem_adel_over_exe_ovf;
    begin
      testcase = testcase + 1;
      $display("\n测试用例 %0d: MEM优先级 AdEL > EXE_Ovf 测试", testcase);

      // 构建 EXE_MEM_bus_r:

      // EXE阶段有Ovf异常 (type 11, flag 1)

      // MEM阶段操作是LW，但地址未对齐 (e.g., 0x...1)

      EXE_MEM_bus_r = {
        2'b11,
        1'b1,  // EXE 异常: Ovf

        4'b1010,  // LW 的 mem_control

        32'h00000001,  // alu_result (地址, 未对齐的字加载)

        32'h0,  // store_data

        1'b1,  // rf_wen (示例)

        5'd2,  // rf_wdest (示例)

        32'h00400024  // pc

      };
      #10;

      // 期望MEM本级产生AdEL (type 00), 该AdEL优先于EXE的Ovf

      // mem_exception_flag 应该是1, mem_exception_type 应该是 2'b00 (AdEL)

      // 传递到MEM_WB_bus的也应该是AdEL

      if (mem_exception_flag && mem_exception_type == 2'b00 &&

          mem_MEM_WB_bus[72] && mem_MEM_WB_bus[71:70] == 2'b00) begin
        success_count = success_count + 1;
        $display("[通过] MEM优先级 AdEL > EXE_Ovf 测试成功");
      end else begin
        fail_count = fail_count + 1;
        $display(
            "[失败] MEM优先级 AdEL > EXE_Ovf: MEM本级 flag=%b type=%b. WB总线 flag=%b type=%b. 期望均为AdEL(1,00)",
            mem_exception_flag, mem_exception_type, mem_MEM_WB_bus[72], mem_MEM_WB_bus[71:70]);
      end
    end
  endtask

// Waveform dump
initial begin
    $dumpfile("full_cpu_waves.vcd");
    $dumpvars(0, full_cpu_tb);
  end

endmodule
