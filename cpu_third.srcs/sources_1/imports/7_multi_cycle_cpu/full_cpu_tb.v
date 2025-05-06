`timescale 1ns / 1ps

module full_cpu_tb ();

  // 全局信号定义


  reg           clk;
  reg           reset_n;  // 应为 resetn


  integer       testcase;
  integer       success_count;
  integer       fail_count;
  reg     [5:0] irq;  // 新增中断输入



  // 时钟生成：100MHz


  always #5 clk = ~clk;

  //------------------------ Decode模块相关信号 ------------------------


  reg [63:0] IF_ID_bus_r;
  wire [4:0] decode_rs, decode_rt;
  wire [ 32:0] decode_jbr_bus;
  wire         decode_jbr_not_link;
  wire         decode_ID_over;
  wire [156:0] decode_ID_EXE_bus;  // 更新位宽


  wire [ 31:0] decode_ID_pc;
  wire [  1:0] decode_id_exception_type;  // 更新名称


  wire         decode_id_exception_flag;  // 更新名称


  wire [  1:0] decode_id_interrupt_type;  // 新增


  wire         decode_id_interrupt_flag;  // 新增


  wire         decode_eret_executed;  // 新增



  decode decode_dut (
      .ID_valid(1'b1),  // 简化测试，假设一直有效


      .IF_ID_bus_r(IF_ID_bus_r),
      .rs_value   (32'h0),        // 简化测试


      .rt_value(32'h0),  // 简化测试


      .irq(irq),  // 连接中断


      .rs               (decode_rs),
      .rt               (decode_rt),
      .jbr_bus          (decode_jbr_bus),
      .jbr_not_link     (decode_jbr_not_link),
      .ID_over          (decode_ID_over),
      .ID_EXE_bus       (decode_ID_EXE_bus),
      .ID_pc            (decode_ID_pc),
      .eret_executed    (decode_eret_executed),
      .id_exception_type(decode_id_exception_type),
      .id_exception_flag(decode_id_exception_flag),
      .id_interrupt_type(decode_id_interrupt_type),
      .id_interrupt_flag(decode_id_interrupt_flag)
  );

  //------------------------ EXE模块相关信号 --------------------------


  reg  [156:0] ID_EXE_bus_r;  // 更新位宽


  wire         exe_EXE_over;
  wire [108:0] exe_EXE_MEM_bus;  // 更新位宽


  wire [  1:0] exe_exception_type;
  wire         exe_exception_flag;
  wire [ 31:0] exe_EXE_pc;

  exe exe_dut (
      .EXE_valid(1'b1),  // 简化测试


      .ID_EXE_bus_r(ID_EXE_bus_r),
      .exe_exception_type(exe_exception_type),
      .exe_exception_flag(exe_exception_flag),
      .EXE_MEM_bus(exe_EXE_MEM_bus),
      .EXE_pc(exe_EXE_pc)
  );

  //------------------------ MEM模块相关信号 --------------------------


  reg  [108:0] EXE_MEM_bus_r;  // 更新位宽


  wire         mem_MEM_over;
  wire [ 72:0] mem_MEM_WB_bus;  // 更新位宽


  wire [  1:0] mem_exception_type;
  wire         mem_exception_flag;
  wire [ 31:0] dm_addr;
  wire [  3:0] dm_wen;
  wire [ 31:0] mem_MEM_pc;

  mem mem_dut (
      .clk(clk),
      .MEM_valid(1'b1),  // 简化测试


      .EXE_MEM_bus_r(EXE_MEM_bus_r),
      .dm_rdata(32'h0),  // 简化测试


      .dm_addr(dm_addr),
      .dm_wen(dm_wen),
      .dm_wdata(),  // 可选连接


      .MEM_over(mem_MEM_over),
      .MEM_WB_bus(mem_MEM_WB_bus),
      .MEM_pc(mem_MEM_pc),
      .mem_exception_type(mem_exception_type),
      .mem_exception_flag(mem_exception_flag)
  );

  //------------------------ 测试初始化 -------------------------------


  initial begin
    // 初始化信号


    clk = 0;
    reset_n = 0;
    irq = 6'b0;
    testcase = 0;
    success_count = 0;
    fail_count = 0;

    // 复位过程


    #20 reset_n = 1;
    #10;

    $display(
        "INFO: Starting module-level exception/interrupt testbench for Decode, EXE, MEM stages.");

    // 执行Decode模块测试


    test_decode_illegal_instruction(32'hFC000000);  // 非法指令


    test_decode_eret_instruction(32'h42000018);  // ERET指令


    test_decode_adel_fetch(32'h00400001);  // 取指地址错


    test_decode_interrupt();  // 中断请求


    test_decode_adel_over_ri();  // Decode优先级: AdEL > RI



    // 执行EXE模块测试


    test_exe_overflow();  // 溢出异常


    test_exe_pass_through_id_exception();  // 透传ID阶段异常


    test_exe_pass_through_id_interrupt();  // 透传ID阶段中断


    test_exe_ovf_over_id_ri();  // EXE优先级: Ovf > ID_RI



    // 执行MEM模块测试


    test_mem_misaligned_load(32'h00000001);  // Load地址未对齐 (AdEL)


    test_mem_misaligned_store(32'h00000003);  // Store地址未对齐 (AdES)


    test_mem_pass_through_exe_exception();  // 透传EXE阶段异常


    test_mem_adel_over_exe_ovf();  // MEM优先级: AdEL > EXE_Ovf



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

      IF_ID_bus_r = {inst, 32'h00400000};  // PC = 0x400000


      irq = 6'b0;  // 确保无中断干扰


      #10;

      if (decode_id_exception_flag && decode_id_exception_type == 2'b10) begin  // RI = 2'b10


        success_count = success_count + 1;
        $display("[通过] 非法指令测试成功");
      end else begin
        fail_count = fail_count + 1;
        $display("[失败] 异常类型:%b 标志:%b", decode_id_exception_type,
                 decode_id_exception_flag);
      end
    end
  endtask

  task test_decode_eret_instruction;
    input [31:0] inst;
    begin
      testcase = testcase + 1;
      $display("\n测试用例 %0d: ERET指令测试", testcase);

      IF_ID_bus_r = {inst, 32'h00400004};  // PC = 0x400004


      irq = 6'b0;  // 确保无中断干扰


      #10;

      if (decode_eret_executed && !decode_id_exception_flag) begin
        success_count = success_count + 1;
        $display("[通过] ERET指令识别成功");
      end else begin
        fail_count = fail_count + 1;
        $display("[失败] ERET信号:%b, 异常标志:%b", decode_eret_executed,
                 decode_id_exception_flag);
      end
    end
  endtask

  task test_decode_adel_fetch;
    input [31:0] pc_addr;
    begin
      testcase = testcase + 1;
      $display("\n测试用例 %0d: 取指地址错测试 (Decode)", testcase);

      IF_ID_bus_r = {32'h00000000, pc_addr};  // 在未对齐地址处的 NOP


      irq = 6'b0;  // 确保无中断干扰


      #10;

      if (decode_id_exception_flag && decode_id_exception_type == 2'b00) begin  // AdEL = 2'b00


        success_count = success_count + 1;
        $display("[通过] 取指地址错测试成功 (Decode)");
      end else begin
        fail_count = fail_count + 1;
        $display("[失败] 取指地址错测试 (Decode): 异常类型:%b 标志:%b",
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

  //------------------------ EXE测试任务 ----------------------------


  task test_exe_overflow;
    begin
      testcase = testcase + 1;
      $display("\n测试用例 %0d: 算术溢出测试", testcase);

      // 构建 ID_EXE_bus_r: {int_type, int_flag, exc_type, exc_flag, alu_ctrl(ADD), op1, op2, ...}


      ID_EXE_bus_r = {
        2'b00,
        1'b0,  // 无中断


        2'b00,
        1'b0,  // 无 ID 异常


        13'b0_1_0_00_000_0000,  // ADD 的 ALU 控制信号


        32'h7FFFFFFF,  // 操作数 1 (最大正数)


        32'h00000001,  // 操作数 2


        4'b0000,  // mem_control


        32'h0,  // store_data


        1'b1,  // rf_wen (示例)


        5'd1,  // rf_wdest (示例)


        32'h00400008  // pc


      };
      #10;

      if (exe_exception_flag && exe_exception_type == 2'b11) begin  // Ovf = 2'b11


        success_count = success_count + 1;
        $display("[通过] 溢出异常测试成功");
      end else begin
        fail_count = fail_count + 1;
        $display("[失败] 类型:%b 标志:%b", exe_exception_type, exe_exception_flag);
      end
    end
  endtask

  task test_exe_pass_through_id_exception;
    begin
      testcase = testcase + 1;
      $display("\n测试用例 %0d: EXE透传ID阶段异常测试", testcase);

      // 模拟来自ID的RI异常


      ID_EXE_bus_r = {
        2'b00,
        1'b0,  // 无中断


        2'b10,
        1'b1,  // ID 异常: RI (类型 2'b10), 标志 1'b1


        13'b0,  // alu_control (无关)


        32'h0,  // op1


        32'h0,  // op2


        4'b0000,  // mem_control


        32'h0,  // store_data


        1'b0,  // rf_wen


        5'd0,  // rf_wdest


        32'h00400010  // pc


      };
      #10;

      // EXE本身不应产生新异常，应透传ID异常到EXE_MEM_bus


      // exe_exception_flag/type 是指EXE本级产生的异常


      // EXE_MEM_bus[108:107] 是最终传递给MEM的异常类型


      // EXE_MEM_bus[106] 是最终传递给MEM的异常标志


      if (!exe_exception_flag && exe_EXE_MEM_bus[106] && exe_EXE_MEM_bus[108:107] == 2'b10) begin
        success_count = success_count + 1;
        $display("[通过] EXE透传ID阶段RI异常测试成功");
      end else begin
        fail_count = fail_count + 1;
        $display(
            "[失败] EXE透传ID阶段RI异常: EXE本级标志:%b, MEM总线标志:%b 类型:%b",
            exe_exception_flag, exe_EXE_MEM_bus[106], exe_EXE_MEM_bus[108:107]);
      end
    end
  endtask

  task test_exe_pass_through_id_interrupt;
    begin
      testcase = testcase + 1;
      $display("\n测试用例 %0d: EXE透传ID阶段中断测试", testcase);

      // 模拟来自ID的中断


      ID_EXE_bus_r = {
        2'b01,
        1'b1,  // ID 中断: Int (类型 2'b01), 标志 1'b1


        2'b00,
        1'b0,  // 无 ID 异常


        13'b0_1_0_00_000_0000,  // alu_control (ADD, 合法操作)


        32'd1,  // op1


        32'd2,  // op2


        4'b0000,  // mem_control


        32'h0,  // store_data


        1'b1,  // rf_wen


        5'd3,  // rf_wdest


        32'h00400014  // pc


      };
      #10;

      if (!exe_exception_flag && exe_EXE_MEM_bus[106] && exe_EXE_MEM_bus[108:107] == 2'b01) begin
        success_count = success_count + 1;
        $display("[通过] EXE透传ID阶段中断测试成功");
      end else begin
        fail_count = fail_count + 1;
        $display(
            "[失败] EXE透传ID阶段中断: EXE本级标志:%b, MEM总线标志:%b 类型:%b",
            exe_exception_flag, exe_EXE_MEM_bus[106], exe_EXE_MEM_bus[108:107]);
      end
    end
  endtask

  task test_exe_ovf_over_id_ri;
    begin
      testcase = testcase + 1;
      $display("\n测试用例 %0d: EXE优先级 Ovf > ID_RI 测试", testcase);

      // 构建 ID_EXE_bus_r:

      // ID阶段有RI异常 (type 10, flag 1)

      // EXE阶段操作会导致溢出 (ADD 7FFFFFFF, 1)

      ID_EXE_bus_r = {
        2'b00,
        1'b0,  // 无中断

        2'b10,
        1'b1,  // ID 异常: RI

        13'b0_1_0_00_000_0000,  // ADD 的 ALU 控制信号

        32'h7FFFFFFF,  // 操作数 1 (最大正数)

        32'h00000001,  // 操作数 2

        4'b0000,  // mem_control

        32'h0,  // store_data

        1'b1,  // rf_wen (示例)

        5'd1,  // rf_wdest (示例)

        32'h00400020  // pc

      };
      #10;

      // 期望EXE本级产生Ovf (type 11), 该Ovf优先于ID的RI

      // exe_exception_flag 应该是1, exe_exception_type 应该是 2'b11 (Ovf)

      // 传递到EXE_MEM_bus的也应该是Ovf

      if (exe_exception_flag && exe_exception_type == 2'b11 &&

          exe_EXE_MEM_bus[106] && exe_EXE_MEM_bus[108:107] == 2'b11) begin
        success_count = success_count + 1;
        $display("[通过] EXE优先级 Ovf > ID_RI 测试成功");
      end else begin
        fail_count = fail_count + 1;
        $display(
            "[失败] EXE优先级 Ovf > ID_RI: EXE本级 flag=%b type=%b. MEM总线 flag=%b type=%b. 期望均为Ovf(1,11)",
            exe_exception_flag, exe_exception_type, exe_EXE_MEM_bus[106], exe_EXE_MEM_bus[108:107]);
      end
    end
  endtask

  //------------------------ MEM测试任务 ----------------------------


  task test_mem_misaligned_load;
    input [31:0] addr;
    begin
      testcase = testcase + 1;
      $display("\n测试用例 %0d: Load地址未对齐测试 (MEM)", testcase);

      // 构建 EXE_MEM_bus_r: {exc_type, exc_flag, mem_ctrl(LW), alu_res(addr), ...}


      EXE_MEM_bus_r = {
        2'b00,
        1'b0,  // 无 EXE 异常/中断 (清除了上一级的标志，因为MEM会自己判断)


        4'b1010,  // LW 的 mem_control


        addr,  // alu_result (地址)


        32'h0,  // store_data


        1'b1,  // rf_wen (示例)


        5'd2,  // rf_wdest (示例)


        32'h0040000C  // pc


      };
      #10;

      if (mem_exception_flag && mem_exception_type == 2'b00) begin  // AdEL = 2'b00


        success_count = success_count + 1;
        $display("[通过] Load地址未对齐测试成功 (MEM)");
      end else begin
        fail_count = fail_count + 1;
        $display("[失败] Load地址未对齐测试 (MEM): 类型:%b 标志:%b",
                 mem_exception_type, mem_exception_flag);
      end
    end
  endtask

  task test_mem_misaligned_store;
    input [31:0] addr;
    begin
      testcase = testcase + 1;
      $display("\n测试用例 %0d: Store地址未对齐测试 (MEM)", testcase);

      // 构建 EXE_MEM_bus_r: {exc_type, exc_flag, mem_ctrl(SW), alu_res(addr), store_data, ...}


      EXE_MEM_bus_r = {
        2'b00,
        1'b0,  // 无 EXE 异常/中断


        4'b0110,  // SW 的 mem_control


        addr,  // alu_result (地址)


        32'hDEADBEEF,  // store_data


        1'b0,  // rf_wen (SW 不写 GPR)


        5'd0,  // rf_wdest


        32'h00400010  // pc


      };
      #10;

      if (mem_exception_flag && mem_exception_type == 2'b01) begin  // AdES = 2'b01


        success_count = success_count + 1;
        $display("[通过] Store地址未对齐测试成功 (MEM)");
      end else begin
        fail_count = fail_count + 1;
        $display("[失败] Store地址未对齐测试 (MEM): 类型:%b 标志:%b",
                 mem_exception_type, mem_exception_flag);
      end
    end
  endtask

  task test_mem_pass_through_exe_exception;
    begin
      testcase = testcase + 1;
      $display("\n测试用例 %0d: MEM透传EXE阶段异常测试", testcase);

      // 模拟来自EXE的Ovf异常


      EXE_MEM_bus_r = {
        2'b11,
        1'b1,  // EXE 异常: Ovf (类型 2'b11), 标志 1'b1


        4'b0000,  // mem_control (无关，假设是R型指令导致Ovf，不访存)


        32'h0,  // alu_result


        32'h0,  // store_data


        1'b1,  // rf_wen


        5'd4,  // rf_wdest


        32'h00400018  // pc


      };
      #10;

      // MEM本身不应产生新异常，应透传EXE异常到MEM_WB_bus


      // mem_exception_flag/type 是指MEM本级产生的异常


      // mem_MEM_WB_bus[72] 是最终传递给WB的异常标志


      // mem_MEM_WB_bus[71:70] 是最终传递给WB的异常类型


      if (!mem_exception_flag && mem_MEM_WB_bus[72] && mem_MEM_WB_bus[71:70] == 2'b11) begin
        success_count = success_count + 1;
        $display("[通过] MEM透传EXE阶段Ovf异常测试成功");
      end else begin
        fail_count = fail_count + 1;
        $display(
            "[失败] MEM透传EXE阶段Ovf异常: MEM本级标志:%b, WB总线标志:%b 类型:%b",
            mem_exception_flag, mem_MEM_WB_bus[72], mem_MEM_WB_bus[71:70]);
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

  // 波形记录


  initial begin
    $dumpfile("full_cpu_waves.vcd");
    $dumpvars(0, full_cpu_tb);
  end

endmodule
