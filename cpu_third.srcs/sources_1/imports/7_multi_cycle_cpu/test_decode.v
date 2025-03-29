// verilog
`timescale 1ns / 1ps
module test_decode;

    // 输入信号
    reg         ID_valid;
    reg [63:0]  IF_ID_bus_r; // {指令, PC}
    reg [31:0]  rs_value;
    reg [31:0]  rt_value;
    reg [5:0]   irq; // 新增
    // reg         flush_pipeline; // 移除

    // 输出信号
    wire [4:0]  rs;
    wire [4:0]  rt;
    wire [32:0] jbr_bus;
    wire        jbr_not_link;
    wire        ID_over;
    wire [156:0] ID_EXE_bus; // 更新位宽
    wire [31:0]  ID_pc;
    // wire        exception_flag; // 移除
    // wire [1:0]  exception_type; // 移除
    // wire        eret_executed; // 移除
    wire [1:0]  id_exception_type; // 使用新名称
    wire        id_exception_flag; // 使用新名称
    wire [1:0]  id_interrupt_type; // 新增
    wire        id_interrupt_flag; // 新增

    // 实例化被测模块
    decode uut (
        .ID_valid(ID_valid),
        .IF_ID_bus_r(IF_ID_bus_r),
        .rs_value(rs_value),
        .rt_value(rt_value),
        .irq(irq), // 连接 irq
        // .flush_pipeline(flush_pipeline), // 移除
        .rs(rs),
        .rt(rt),
        .jbr_bus(jbr_bus),
        .jbr_not_link(jbr_not_link),
        .ID_over(ID_over),
        .ID_EXE_bus(ID_EXE_bus),
        .ID_pc(ID_pc),
        // .exception_flag(exception_flag), // 移除
        // .exception_type(exception_type), // 移除
        // .eret_executed(eret_executed), // 移除
        .id_exception_type(id_exception_type), // 连接新名称
        .id_exception_flag(id_exception_flag), // 连接新名称
        .id_interrupt_type(id_interrupt_type), // 连接新名称
        .id_interrupt_flag(id_interrupt_flag)  // 连接新名称
    );

    initial begin
        $display("==== decode.v 异常/中断检测测试 ====");

        // 初始化
        ID_valid = 0;
        IF_ID_bus_r = 0;
        rs_value = 0;
        rt_value = 0;
        irq = 0;
        // flush_pipeline = 0; // 移除
        #10;

        // 1. 合法指令（ADDU），不应触发异常/中断
        $display("[测试 1] 合法指令 ADDU");
        ID_valid = 1;
        IF_ID_bus_r = {32'b000000_00010_00011_00001_00000_100001, 32'h00400000}; // ADDU $1,$2,$3 @ 0x400000
        #10;
        check_exception(0, 2'b00, 0, "合法指令 ADDU");

        // 2. 非法指令（未定义op），应触发 RI 异常
        $display("[测试 2] 非法指令");
        IF_ID_bus_r = {32'b111111_00000_00000_00000_00000_000000, 32'h00400004}; // 无效操作码 @ 0x400004
        #10;
        check_exception(1, 2'b10, 0, "非法指令 (RI)"); // 2'b10 代表 RI

        // 3. 取指地址错 (AdEL)
        $display("[测试 3] 取指地址错");
        IF_ID_bus_r = {32'b001001_00010_00001_0001001000110100, 32'h00400009}; // ADDIU @ 0x400009 (未对齐)
        #10;
        check_exception(1, 2'b00, 0, "取指地址错 (AdEL)"); // 2'b00 代表 AdEL

        // 4. 中断请求 (无异常时)
        $display("[测试 4] 中断请求");
        irq = 6'b000001; // 置位 IRQ0
        IF_ID_bus_r = {32'b000000_00010_00011_00001_00000_100001, 32'h0040000C}; // ADDU @ 0x40000C
        #10;
        check_exception(0, 2'b00, 1, "中断请求");
        irq = 6'b000000; // 复位 IRQ

        // 5. 异常优先于中断
        $display("[测试 5] 异常优先于中断");
        irq = 6'b000001; // 置位 IRQ0
        IF_ID_bus_r = {32'b111111_00000_00000_00000_00000_000000, 32'h00400010}; // 无效操作码 @ 0x400010
        #10;
        check_exception(1, 2'b10, 0, "异常优先于中断 (RI)"); // 期望 RI, 而不是中断
        irq = 6'b000000; // 复位 IRQ

        // 6. ERET 指令 (不应产生异常)
        $display("[测试 6] ERET 指令");
        IF_ID_bus_r = {32'b010000_10000_00000_00000_00000_011000, 32'h00400014}; // ERET @ 0x400014
        #10;
        check_exception(0, 2'b00, 0, "ERET 指令");
        // ERET 执行信号已移除, CP0 处理返回

        $display("==== decode.v 异常/中断检测测试结束 ====");
        $finish;
    end

    // 检查异常/中断输出
    task check_exception;
        input expected_exc_flag;
        input [1:0] expected_exc_type;
        input expected_int_flag;
        input [127:0] testname;
        begin
            if (id_exception_flag !== expected_exc_flag) begin
                $display("[失败] %s: id_exception_flag=%b, 期望=%b", testname, id_exception_flag, expected_exc_flag);
            end else if (id_exception_flag && (id_exception_type !== expected_exc_type)) begin
                $display("[失败] %s: id_exception_type=%b, 期望=%b", testname, id_exception_type, expected_exc_type);
            end else if (id_interrupt_flag !== expected_int_flag) begin
                 $display("[失败] %s: id_interrupt_flag=%b, 期望=%b", testname, id_interrupt_flag, expected_int_flag);
            end else begin
                $display("[通过] %s", testname);
            end
        end
    endtask

endmodule