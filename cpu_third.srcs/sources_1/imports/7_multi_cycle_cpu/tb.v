`timescale 1ns / 1ps

module tb;

    // 输入信号
    reg clk;
    reg resetn;
    reg exception_flag;
    reg [1:0] exception_type;
    reg [31:0] pc_current;
    reg eret_executed;
    
    // 输出信号
    wire [31:0] EPC;
    wire exception_triggered;
    wire status_exl;
    
    // 实例化被测模块
    cp0 uut (
        .clk(clk),
        .resetn(resetn),
        .exception_flag(exception_flag),
        .exception_type(exception_type),
        .pc_current(pc_current),
        .eret_executed(eret_executed),
        .EPC(EPC),
        .exception_triggered(exception_triggered),
        .status_exl(status_exl)
    );
    
    // 时钟生成（周期10ns）
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // 测试过程
    initial begin
        // 初始化
        resetn = 0;
        exception_flag = 0;
        exception_type = 0;
        pc_current = 0;
        eret_executed = 0;
        
        // 复位系统
        #10;
        resetn = 1;
        #10;
        
        // 测试1: 正常情况，无异常
        $display("\nTest 1: Normal operation (no exception)");
        pc_current = 32'h00400000;
        #10;
        display_signals();
        
        // 测试2: 触发异常
        $display("\nTest 2: Trigger exception");
        exception_flag = 1;
        exception_type = 2'b01;
        pc_current = 32'h00400004;
        #10;
        display_signals();
        
        // 保持异常信号
        #10;
        display_signals();
        
        // 撤销异常信号
        exception_flag = 0;
        #10;
        display_signals();
        
        // 测试3: 执行ERET指令
        $display("\nTest 3: Execute ERET instruction");
        eret_executed = 1;
        #10;
        display_signals();
        
        // 撤销ERET信号
        eret_executed = 0;
        #10;
        display_signals();
        
        // 测试4: 再次触发异常
        $display("\nTest 4: Trigger another exception");
        exception_flag = 1;
        exception_type = 2'b10;
        pc_current = 32'h00400008;
        #20;
        exception_flag = 0;
        display_signals();
        
        // 结束测试
        #10;
        $display("\nAll tests completed");
        $finish;
    end
    
    // 显示信号的辅助任务
    task display_signals;
        begin
            $display("Time=%0t: clk=%b, resetn=%b", $time, clk, resetn);
            $display("  exception_flag=%b, sync1=%b, sync2=%b", 
                    exception_flag, uut.exception_flag_sync1, uut.exception_flag_sync2);
            $display("  exception_type=%b, pc_current=%h", exception_type, pc_current);
            $display("  eret_executed=%b", eret_executed);
            $display("  Outputs: EPC=%h, exception_triggered=%b, status_exl=%b", 
                    EPC, exception_triggered, status_exl);
            $display("----------------------------------------");
        end
    endtask
    
endmodule