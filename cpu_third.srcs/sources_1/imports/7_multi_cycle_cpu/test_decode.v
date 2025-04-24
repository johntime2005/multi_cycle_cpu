// verilog
`timescale 1ns / 1ps
module test_decode;

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

    initial begin
        $display("==== decode.v 异常检测测试 ====");

        // 初始化
        ID_valid = 0;
        IF_ID_bus_r = 0;
        rs_value = 0;
        rt_value = 0;
        flush_pipeline = 0;
        #10;

        // 1. 合法指令（ADDU），不应触发异常
        $display("[Test 1] 合法指令ADDU");
        ID_valid = 1;
        IF_ID_bus_r = {32'h00400000, 32'b000000_00010_00011_00001_00000_100001}; // ADDU $1,$2,$3
        #10;
        check_exception(0, 2'b00, "合法指令ADDU");

        // 2. 非法指令（未定义op），应触发decode阶段异常
        $display("[Test 2] 非法指令");
        IF_ID_bus_r = {32'h00400004, 32'b111111_00000_00000_00000_00000_000000};
        #10;
        check_exception(1, 2'b01, "非法指令");

        // 3. 冲刷时，异常应被抑制
        $display("[Test 3] 冲刷时异常抑制");
        flush_pipeline = 1;
        IF_ID_bus_r = {32'h00400008, 32'b111111_00000_00000_00000_00000_000000};
        #10;
        check_exception(0, 2'b00, "冲刷时异常抑制");
        flush_pipeline = 0;

        // 4. ERET指令识别
        $display("[Test 4] ERET指令识别");
        IF_ID_bus_r = {32'h0040000C, 32'b010000_00000_00000_00000_00000_011000};
        #10;
        if (eret_executed !== 1) begin
            $display("[FAIL] ERET指令未被识别");
        end else begin
            $display("[PASS] ERET指令识别通过");
        end

        // 5. 其他合法指令（如ORI），不应触发异常
        $display("[Test 5] 合法指令ORI");
        IF_ID_bus_r = {32'h00400010, 32'b001101_00010_00001_0000000000001010}; // ORI $1,$2,0xA
        #10;
        check_exception(0, 2'b00, "合法指令ORI");

        $display("==== decode.v 异常检测测试结束 ====");
        $finish;
    end

    // 检查异常输出
    task check_exception;
        input expected_flag;
        input [1:0] expected_type;
        input [127:0] testname;
        begin
            if (exception_flag !== expected_flag) begin
                $display("[FAIL] %s: exception_flag=%b, 期望=%b", testname, exception_flag, expected_flag);
            end else if (exception_flag && (exception_type !== expected_type)) begin
                $display("[FAIL] %s: exception_type=%b, 期望=%b", testname, exception_type, expected_type);
            end else begin
                $display("[PASS] %s", testname);
            end
        end
    endtask

endmodule