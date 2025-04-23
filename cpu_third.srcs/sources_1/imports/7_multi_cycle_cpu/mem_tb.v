`timescale 1ns / 1ps

module tb_mem;

    // 输入信号
    reg              clk;
    reg              MEM_valid;
    reg [107:0]      EXE_MEM_bus_r;
    reg [31:0]       dm_rdata;
    reg              flush_pipeline;

    // 输出信号
    wire [31:0]      dm_addr;
    wire [3:0]       dm_wen;
    wire [31:0]      dm_wdata;
    wire             MEM_over;
    wire [69:0]      MEM_WB_bus;
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
        .flush_pipeline(flush_pipeline),
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
        flush_pipeline = 0;

        // 等待全局复位
        #20;

        //============= 测试用例1：正常字对齐访问 =============
        $display("\n[Test 1] 正常字对齐访问");
        MEM_valid = 1;
        EXE_MEM_bus_r = {2'b00, 1'b0, 4'b1000, 32'h12345678, 32'h00000004, 1'b1, 5'd1, 32'h00400000};
        #10;
        check_results(
            .expected_exception(0),
            .expected_type(2'b00),
            .test_name("Test 1")
        );

        //============= 测试用例2：地址未对齐异常（字操作） =============
        $display("\n[Test 2] 地址未对齐异常（字操作）");
        MEM_valid = 1;
        EXE_MEM_bus_r = {2'b00, 1'b0, 4'b1000, 32'h12345678, 32'h00000003, 1'b1, 5'd1, 32'h00400004};
        #10;
        check_results(
            .expected_exception(1),
            .expected_type(2'b01),
            .test_name("Test 2")
        );

        //============= 测试用例3：流水线冲刷测试 =============
        $display("\n[Test 3] 流水线冲刷测试");
        flush_pipeline = 1;
        MEM_valid = 1;
        EXE_MEM_bus_r = {2'b00, 1'b0, 4'b1000, 32'h12345678, 32'h00000003, 1'b1, 5'd1, 32'h0040000C};
        #10;
        check_results(
            .expected_exception(0),
            .expected_type(2'b00),
            .test_name("Test 3")
        );
        flush_pipeline = 0;

        // 测试结束
        $display("\n所有测试完成");
        $finish;
    end

    // 结果检查任务
    task check_results;
        input expected_exception;
        input [1:0] expected_type;
        input [128:0] test_name;
        begin
            if (mem_exception_flag !== expected_exception) begin
                $display("[ERROR] %s: 异常标志错误", test_name);
                $display("实际mem_exception_flag=%b，期望值=%b", 
                        mem_exception_flag, expected_exception);
            end
            else if ((expected_exception) && (mem_exception_type !== expected_type)) begin
                $display("[ERROR] %s: 异常类型错误", test_name);
                $display("实际mem_exception_type=%b，期望值=%b",
                        mem_exception_type, expected_type);
            end
            else begin
                $display("[PASS] %s 通过", test_name);
            end
            $display("----------------------------------------");
        end
    endtask

endmodule