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

        //============= 测试用例1：正常字对齐 Load =============
        $display("\n[测试 1] 正常字对齐 Load");
        MEM_valid = 1;
        // EXE_MEM_bus: {prev_exc_type, prev_exc_flag, mem_ctrl(LW), alu_res(addr), store_data, rf_wen, rf_dest, pc}
        EXE_MEM_bus_r = {2'b00, 1'b0, 4'b1010, 32'h00000004, 32'h0, 1'b1, 5'd1, 32'h00400000}; // LW $1, offset($?) -> mem_ctrl=1010, addr=4
        dm_rdata = 32'hAAAAAAAA; // 从 RAM 读取的数据
        #10;
        check_results(0, 2'b00, "测试 1: Load Word Aligned");
        // 检查 MEM_WB_bus 数据
        if (MEM_WB_bus[63:32] !== 32'hAAAAAAAA) $display("[失败] 测试 1: WB 数据不匹配. 得到 %h", MEM_WB_bus[63:32]);

        //============= 测试用例2：地址未对齐异常（字 Load） =============
        $display("\n[测试 2] 地址未对齐异常（字 Load）");
        MEM_valid = 1;
        EXE_MEM_bus_r = {2'b00, 1'b0, 4'b1010, 32'h00000003, 32'h0, 1'b1, 5'd1, 32'h00400004}; // LW, addr=3 (未对齐)
        #10;
        check_results(1, 2'b00, "测试 2: Load Word Unaligned (AdEL)"); // 期望 AdEL (2'b00)

        //============= 测试用例3：地址未对齐异常（字 Store） =============
        $display("\n[测试 3] 地址未对齐异常（字 Store）");
        MEM_valid = 1;
        EXE_MEM_bus_r = {2'b00, 1'b0, 4'b0110, 32'h00000002, 32'hBBBBBBBB, 1'b0, 5'd0, 32'h00400008}; // SW, addr=2 (未对齐), data=BBBBBBBB
        #10;
        check_results(1, 2'b01, "测试 3: Store Word Unaligned (AdES)"); // 期望 AdES (2'b01)
        if (dm_wen !== 4'b0000) $display("[失败] 测试 3: 异常时 dm_wen 应为 0. 得到 %b", dm_wen);

        //============= 测试用例4：继承 EXE 阶段异常 =============
        $display("\n[测试 4] 继承 EXE 阶段异常");
        MEM_valid = 1;
        // 来自 EXE 的带有 Ovf 异常的 EXE_MEM_bus
        EXE_MEM_bus_r = {2'b11, 1'b1, 4'b0000, 32'h00000008, 32'h0, 1'b1, 5'd2, 32'h0040000C}; // Ovf (2'b11) 标志置位
        #10;
        // MEM 阶段不应产生新异常，但应传递 Ovf 标志
        check_results(0, 2'b00, "测试 4: Pass Through EXE Exception"); // 检查 mem_exception_flag/type (本级)
        // 检查 MEM_WB_bus 异常信息
        if (MEM_WB_bus[72] !== 1'b1 || MEM_WB_bus[71:70] !== 2'b11) $display("[失败] 测试 4: WB 总线异常不匹配. 得到 flag=%b, type=%b", MEM_WB_bus[72], MEM_WB_bus[71:70]);


        // 测试结束
        $display("\n所有测试完成");
        $finish;
    end

    // 结果检查任务 (检查本级异常)
    task check_results;
        input expected_exception;
        input [1:0] expected_type;
        input [128:0] test_name;
        begin
            if (mem_exception_flag !== expected_exception) begin
                $display("[错误] %s: 本级异常标志错误", test_name);
                $display("实际 mem_exception_flag=%b，期望值=%b",
                        mem_exception_flag, expected_exception);
            end
            else if ((expected_exception) && (mem_exception_type !== expected_type)) begin
                $display("[错误] %s: 本级异常类型错误", test_name);
                $display("实际 mem_exception_type=%b，期望值=%b",
                        mem_exception_type, expected_type);
            end
            else begin
                $display("[通过] %s 通过", test_name);
            end
            $display("----------------------------------------");
        end
    endtask

endmodule