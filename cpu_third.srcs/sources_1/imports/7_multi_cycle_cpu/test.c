// 用于中断测试的概念性C代码。
// 实际运行在CPU上的代码是 test.s 文件中的汇编代码。

// 全局变量，由中断服务程序 (ISR) 递增
volatile int interrupt_service_routine_executed_count = 0;
volatile int main_loop_count = 0;

// 概念性的ISR - 在真实MIPS硬件上，这将是汇编代码。
// CPU的异常控制器必须配置为在发生中断时跳转到
// 'isr_handler_asm' (在test.s中定义) 的地址。
void __attribute__ ((interrupt)) conceptual_isr_handler(void) {
    interrupt_service_routine_executed_count++;
    // 在真实的MIPS ISR中，使用 'eret' 指令返回。
}

int main() {
    // 在汇编代码 (test.s) 中，我们将执行以下操作：
    // 1. 初始化CP0 Status寄存器以使能中断:
    //    - 设置 Status.IE = 1 (Interrupt Enable)
    //    - 确保 Status.EXL = 0 (Not in Exception Level)

    // 主循环，用于测试中断响应
    // 测试平台 (testbench) 应在CPU执行此循环时，
    // 通过设置 'irq' 输入信号来模拟一个外部中断。
    while (1) {
        main_loop_count++;
        // 可以在此处添加一些简单的操作或延迟
        // 以便在模拟中观察 main_loop_count 的变化
        for (volatile int i = 0; i < 5; i++); // 模拟少量工作
    }

    return 0; // 在裸机中断测试中，程序通常不会执行到这里
}
