// MIPS汇编代码 - 中断测试
// CPU复位向量: 0xBFC00000
// 外部中断的ISR放置在 0xBFC00080。
// 您的CPU的 exception_controller 必须在中断发生时将PC导向 0xBFC00080。

.set noreorder  // 禁止汇编器重排指令
.set noat       // 禁止汇编器使用 $at (保留给异常处理程序)

.text           // 代码段开始
.globl _start   // 使 _start 标签全局可见，链接器会用到
_start:                     // CPU执行的起始点 (地址 0xBFC00000, COE文件索引 0)

    // --- 初始化CP0 Status寄存器以使能中断 ---
    // 目标: Status.IE = 1 (中断使能), Status.EXL = 0 (不在异常状态)
    mfc0 $t0, $12           // 将 CP0_STATUS ($12) 寄存器的值读入 $t0
    ori  $t0, $t0, 0x0001   // 设置 $t0 中的 IE 位 (bit 0) 为 1
    andi $t0, $t0, 0xFFFD   // 清除 $t0 中的 EXL 位 (bit 1) 为 0 (通过与 ~0x0002 进行与操作)
    mtc0 $t0, $12           // 将修改后的 $t0 写回 CP0_STATUS ($12) 寄存器

    // --- 初始化计数器寄存器 ---
    addiu $s0, $zero, 0     // $s0 = main_loop_counter (主循环计数器), 初始化为0
    addiu $s1, $zero, 0     // $s1 = interrupt_service_routine_execution_count (ISR执行计数器), 初始化为0

main_loop:                  // 主执行循环标签
    addiu $s0, $s0, 1       // 主循环计数器 ($s0) 递增
                            // 测试平台 (testbench) 应在CPU执行此循环时断言 'irq' 信号。
    nop                     // 占位指令，模拟一些工作或提供观察点
    nop                     // 占位指令
    nop                     // 占位指令
    beq $zero, $zero, main_loop // 无条件跳转回 main_loop, 形成无限循环
    nop                     // 分支延迟槽指令 (beq之后总是会执行一条指令)

    // --- 使用NOP指令填充，以确保ISR位于0xBFC00080 ---
    // 到目前为止的指令 (mfc0, ori, andi, mtc0, addiu, addiu, addiu, nop, nop, nop, beq, nop) 共12条。
    // 这12条指令占据的地址范围是 0xBFC00000 到 0xBFC0002C。
    // 下一条指令的地址是 0xBFC00030 (即第13条指令，COE索引12)。
    // ISR的目标起始地址是 0xBFC00080 (即第33条指令，COE索引32)。
    // 因此，我们需要填充 COE索引12 到 COE索引31 的位置，共 31 - 12 + 1 = 20 条NOP指令。
    // 这些NOP将占据地址从 0xBFC00030 到 0xBFC0007C。

    nop // COE索引 12 (地址 0xBFC00030)
    nop // COE索引 13
    nop // COE索引 14
    nop // COE索引 15
    nop // COE索引 16
    nop // COE索引 17
    nop // COE索引 18
    nop // COE索引 19
    nop // COE索引 20
    nop // COE索引 21
    nop // COE索引 22
    nop // COE索引 23
    nop // COE索引 24
    nop // COE索引 25
    nop // COE索引 26
    nop // COE索引 27
    nop // COE索引 28
    nop // COE索引 29
    nop // COE索引 30
    nop // COE索引 31 (地址 0xBFC0007C)

// --- 中断服务程序 (ISR) ---
// 此ISR必须位于您的 exception_controller 在中断时跳转到的地址。
// 在此示例中，我们假定该地址为 0xBFC00080。
// 绝对地址: 0xBFC00080 (COE文件索引 32)
isr_handler_asm:
    // 这是一个非常简单的ISR。
    // 真实的ISR通常会首先保存必要的上下文 (例如 $at, $v0-$v1, $a0-$a3, $t0-$t9, $ra 等寄存器)。
    // 它可能还会检查CP0_CAUSE寄存器以确定中断的具体来源（如果支持多个中断源）。
    addiu $s1, $s1, 1       // ISR执行计数器 ($s1) 递增

    eret                    // 从异常/中断返回。CPU会恢复到CP0_EPC指向的指令继续执行，
                            // 并将CP0_Status的EXL位清零。
    nop                     // eret之后的指令。虽然eret会刷新流水线，但放置一条NOP是MIPS编程的好习惯。
                            // 这条指令理论上不应被执行。
// 程序结束
/*
观察CPU的行为：
CPU应能检测到中断。
exception_controller 应发出 exception_triggered 信号。
fetch 模块应将PC设置为 0xBFC00080。
位于 0xBFC00080 的ISR代码 (isr_handler_asm) 开始执行，$s1 寄存器的值会增加。
eret 指令执行后，CPU应返回到 main_loop 中被中断指令之后的位置继续执行。
通过仿真器或CPU的调试接口（如果您的设计支持，例如通过 rf_data 读取寄存器值）检查 $s0（主循环计数器）和 $s1（ISR执行计数器）的值。每次中断被成功处理后，$s1 的值都应该增加1。
*/