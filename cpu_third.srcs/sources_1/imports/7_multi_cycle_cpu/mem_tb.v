`timescale 1ns / 1ps

module tb_mem;

    // 输入信号
    reg              clk;
    reg              MEM_valid;
    reg [108:0]      EXE_MEM_bus_r; // 更新位宽
    reg [31:0]       dm_rdata;
    // reg              flush_pipeline; // 移除

    // 输出信号
    wire [31:0]      dm_addr;
    wire [3:0]       dm_wen;
    wire [31:0]      dm_wdata;
    wire             MEM_over;
    wire [72:0]      MEM_WB_bus; // 更新位宽
    wire [31:0]      MEM_pc;
    wire [1:0]       mem_exception_type;
    wire             mem_exception_flag;

    // 实例化被测模块
    mem uut (
        .clk(clk),
        .MEM_valid(MEM_valid),
        .EXE_MEM_bus_r(EXE_MEM_bus_r),
        .dm_rdata(dm_rdata),
        .dm_addr(dm_addr),
        .dm_wen(dm_wen),
        .dm_wdata(dm_wdata),
        .MEM_over(MEM_over),
        .MEM_WB_bus(MEM_WB_bus),
        .MEM_pc(MEM_pc),
        // .flush_pipeline(flush_pipeline), // 移除
        .mem_exception_type(mem_exception_type),
        .mem_exception_flag(mem_exception_flag)
    );

    // 时钟生成（周期10ns）
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // 测试流程
    initial begin
        // 初始化信号
        MEM_valid = 0;
        EXE_MEM_bus_r = 0;
        dm_rdata = 0;
        // flush_pipeline = 0; // 移除

        // 等待全局复位
        #20;

        //============= Test Case 1: Normal Word Aligned Load =============
        $display("\n[Test 1] Normal Word Aligned Load");
        MEM_valid = 1;
        // EXE_MEM_bus: {prev_exc_type, prev_exc_flag, mem_ctrl(LW), alu_res(addr), store_data, rf_wen, rf_dest, pc}
        EXE_MEM_bus_r = {2'b00, 1'b0, 4'b1010, 32'h00000004, 32'h0, 1'b1, 5'd1, 32'h00400000}; // LW $1, offset($?) -> mem_ctrl=1010, addr=4
        dm_rdata = 32'hAAAAAAAA; // Data read from RAM
        #10;
        check_results(0, 2'b00, "Test 1: Load Word Aligned");
        // Check MEM_WB_bus data
        if (MEM_WB_bus[63:32] !== 32'hAAAAAAAA) $display("[FAIL] Test 1: WB Data mismatch. Got %h", MEM_WB_bus[63:32]);

        //============= Test Case 2: Address Unaligned Exception (Word Load) =============
        $display("\n[Test 2] Address Unaligned Exception (Word Load)");
        MEM_valid = 1;
        EXE_MEM_bus_r = {2'b00, 1'b0, 4'b1010, 32'h00000003, 32'h0, 1'b1, 5'd1, 32'h00400004}; // LW, addr=3 (Unaligned)
        #10;
        check_results(1, 2'b00, "Test 2: Load Word Unaligned (AdEL)"); // Expect AdEL (2'b00)

        //============= Test Case 3: Address Unaligned Exception (Word Store) =============
        $display("\n[Test 3] Address Unaligned Exception (Word Store)");
        MEM_valid = 1;
        EXE_MEM_bus_r = {2'b00, 1'b0, 4'b0110, 32'h00000002, 32'hBBBBBBBB, 1'b0, 5'd0, 32'h00400008}; // SW, addr=2 (Unaligned), data=BBBBBBBB
        #10;
        check_results(1, 2'b01, "Test 3: Store Word Unaligned (AdES)"); // Expect AdES (2'b01)
        if (dm_wen !== 4'b0000) $display("[FAIL] Test 3: dm_wen should be 0 on exception. Got %b", dm_wen);

        //============= Test Case 4: Inherit EXE Stage Exception =============
        $display("\n[Test 4] Inherit EXE Stage Exception");
        MEM_valid = 1;
        // EXE_MEM_bus from EXE with Ovf exception
        EXE_MEM_bus_r = {2'b11, 1'b1, 4'b0000, 32'h00000008, 32'h0, 1'b1, 5'd2, 32'h0040000C}; // Ovf (2'b11) flag set
        #10;
        // MEM stage should not generate a new exception, but should pass Ovf flag
        check_results(0, 2'b00, "Test 4: Pass Through EXE Exception"); // Check mem_exception_flag/type (this stage)
        // Check MEM_WB_bus exception info
        if (MEM_WB_bus[72] !== 1'b1 || MEM_WB_bus[71:70] !== 2'b11) $display("[FAIL] Test 4: WB bus exception mismatch. Got flag=%b, type=%b", MEM_WB_bus[72], MEM_WB_bus[71:70]);

        //============= Test Case 5: Sequential Operations - Normal Store followed by Unaligned Store =============
        $display("\n[Test 5] Sequential Operations - Normal Store followed by Unaligned Store");
        // Step 1: Normal Word Aligned Store
        MEM_valid = 1;
        // EXE_MEM_bus: {prev_exc_type, prev_exc_flag, mem_ctrl(SW), alu_res(addr), store_data, rf_wen, rf_dest, pc}
        EXE_MEM_bus_r = {2'b00, 1'b0, 4'b0110, 32'h00000010, 32'hCCCCCCCC, 1'b0, 5'd0, 32'h00400010}; // SW, addr=16 (Aligned), data=CCCCCCCC
        #10;
        check_results(0, 2'b00, "Test 5.1: Normal Store Word Aligned");
        if (dm_wen !== 4'b1111) $display("[FAIL] Test 5.1: dm_wen should be 4'b1111 for normal store. Got %b", dm_wen);
        if (dm_wdata !== 32'hCCCCCCCC) $display("[FAIL] Test 5.1: dm_wdata mismatch for normal store. Got %h", dm_wdata);

        // Step 2: Address Unaligned Word Store (Should trigger AdES)
        MEM_valid = 1;
        EXE_MEM_bus_r = {2'b00, 1'b0, 4'b0110, 32'h00000011, 32'hDDDDDDDD, 1'b0, 5'd0, 32'h00400014}; // SW, addr=17 (Unaligned), data=DDDDDDDD
        #10;
        check_results(1, 2'b01, "Test 5.2: Store Word Unaligned (AdES)");
        if (dm_wen !== 4'b0000) $display("[FAIL] Test 5.2: dm_wen should be 0 on exception. Got %b", dm_wen);


        // 测试结束
        $display("\nAll tests completed");
        $finish;
    end

    // 结果检查任务 (检查本级异常)
    task check_results;
        input expected_exception;
        input [1:0] expected_type;
        input [128:0] test_name;
        begin
            if (mem_exception_flag !== expected_exception) begin
                $display("[ERROR] %s: This stage's exception flag error", test_name);
                $display("Actual mem_exception_flag=%b, Expected=%b",
                        mem_exception_flag, expected_exception);
            end
            else if ((expected_exception) && (mem_exception_type !== expected_type)) begin
                $display("[ERROR] %s: This stage's exception type error", test_name);
                $display("Actual mem_exception_type=%b, Expected=%b",
                        mem_exception_type, expected_type);
            end
            else begin
                $display("[PASS] %s Passed", test_name);
            end
            $display("----------------------------------------");
        end
    endtask

endmodule