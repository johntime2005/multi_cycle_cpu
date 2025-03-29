`timescale 1ns / 1ps
///decode模块测试
module tb;

    // 输入信号
    reg         ID_valid;
    reg [63:0]  IF_ID_bus_r;
    reg [31:0]  rs_value;
    reg [31:0]  rt_value;
    reg         flush_pipeline;

    // 输出信号
    wire [4:0]  rs;
    wire [4:0]  rt;
    wire [32:0] jbr_bus;
    wire        jbr_not_link;
    wire        ID_over;
    wire [151:0] ID_EXE_bus;
    wire [31:0]  ID_pc;
    wire        exception_flag;
    wire [1:0]  exception_type;
    wire        eret_executed;
    wire [1:0]  id_exception_type;
    wire        id_exception_flag;

    // 实例化被测模块
    decode uut (
        .ID_valid(ID_valid),
        .IF_ID_bus_r(IF_ID_bus_r),
        .rs_value(rs_value),
        .rt_value(rt_value),
        .flush_pipeline(flush_pipeline),
        .rs(rs),
        .rt(rt),
        .jbr_bus(jbr_bus),
        .jbr_not_link(jbr_not_link),
        .ID_over(ID_over),
        .ID_EXE_bus(ID_EXE_bus),
        .ID_pc(ID_pc),
        .exception_flag(exception_flag),
        .exception_type(exception_type),
        .eret_executed(eret_executed),
        .id_exception_type(id_exception_type),
        .id_exception_flag(id_exception_flag)
    );

    // 时钟生成（周期10ns）
    reg clk;
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // 测试流程
    initial begin
        // 初始化信号
        ID_valid = 0;
        IF_ID_bus_r = 0;
        rs_value = 0;
        rt_value = 0;
        flush_pipeline = 0;

        // 等待全局复位（如果有）
        #20;

        //============= 测试用例1：合法指令（ADDU）不触发异常 =============
        $display("\n[测试 1] 合法指令测试");
        ID_valid = 1;
        // 构造指令：ADDU $1, $2, $3 (op=0, funct=0b100001)
        IF_ID_bus_r = {32'h00400000, 32'b000000_00010_00011_00001_00000_100001};
        rs_value = 32'h1234;
        rt_value = 32'h5678;
        #10;
        check_results(
            .expected_exception(0),
            .expected_type(2'b00),  // 默认类型
            .test_name("测试 1")
        );

        //============= 测试用例2：非法指令触发异常 =============
        $display("\n[测试 2] 非法指令测试");
        // 构造无效指令：op=6'b111111（未定义）
        IF_ID_bus_r = {32'h00400004, 32'b111111_00000_00000_00000_00000_000000};
        #10;
        check_results(
            .expected_exception(1),
            .expected_type(2'b01),
            .test_name("测试 2")
        );

        //============= 测试用例3：异常后发送合法指令 =============
        $display("\n[测试 3] 异常后恢复测试");
        // 恢复合法指令：ADDIU $1, $2, 0x1234
        IF_ID_bus_r = {32'h00400008, 32'b001001_00010_00001_0001001000110100};
        #10;
        check_results(
            .expected_exception(0),
            .expected_type(2'b00),  // 默认类型
            .test_name("测试 3")
        );

        //============= 测试用例4：流水线冲刷时抑制异常 =============
        $display("\n[测试 4] 流水线冲刷测试");
        flush_pipeline = 1;
        IF_ID_bus_r = {32'h0040000C, 32'b111111_00000_00000_00000_00000_000000};
        #10;
        check_results(
            .expected_exception(0),
            .expected_type(2'b00),  // 默认类型
            .test_name("测试 4")
        );
        flush_pipeline = 0;

        //============= 测试用例5：ERET指令检测 =============
        $display("\n[测试 5] ERET指令测试");
        // 构造ERET指令（op=6'b010000, funct=6'b011000）
        IF_ID_bus_r = {32'h00400010, 32'b010000_00000_00000_00000_00000_011000};
        #10;
        if (eret_executed !== 1) begin
            $display("[错误] 测试 5: ERET未正确识别");
            $display("实际eret_executed=%b，期望值=1", eret_executed);
        end else begin
            $display("[通过] 测试 5: ERET指令检测通过");
        end

        // 结束测试
        #10;
        $display("\n所有测试完成");
        $finish;
    end

    // 结果检查任务
    task check_results;
        input expected_exception;
        input [1:0] expected_type;
        input [128:0] test_name;
        begin
            if (exception_flag !== expected_exception) begin
                $display("[错误] %s: 异常标志错误", test_name);
                $display("实际exception_flag=%b，期望值=%b",
                        exception_flag, expected_exception);
            end
            else if ((expected_exception) && (exception_type !== expected_type)) begin
                $display("[错误] %s: 异常类型错误", test_name);
                $display("实际exception_type=%b，期望值=%b",
                        exception_type, expected_type);
            end
            else begin
                $display("[通过] %s 通过", test_name);
            end
            $display("----------------------------------------");
        end
    endtask

endmodule