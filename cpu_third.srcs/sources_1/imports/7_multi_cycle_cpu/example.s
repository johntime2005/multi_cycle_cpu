.file   "example.c"
    .section    .mdebug.abi32
    .previous
    .nan    legacy
    .module fp=xx
    .module nooddspreg
    .module arch=mips32r2
    .text

    .globl _start
_start:                     # 程序入口点
    .align  2
    la      $t9, main       # 加载 main 的地址（绝对地址）
    jalr    $t9
    nop                     # 延迟槽指令

    .rdata
    .section    .sdata
    .align  2
$LC0:
    .ascii  "Sum: %d\012\000"    # 字符串常量

    .text
    .align  2
    .globl  main
    .type   main, @function
main:
    # 建立栈帧
    addiu   $sp, $sp, -48
    sw      $ra, 44($sp)       # 保存返回地址
    sw      $fp, 40($sp)
    move    $fp, $sp

    # 初始化变量
    li      $2, 5             # a = 5
    sw      $2, 28($fp)
    li      $2, 10            # b = 10
    sw      $2, 32($fp)

    # 计算 sum = a + b
    lw      $3, 28($fp)
    lw      $2, 32($fp)
    addu    $2, $3, $2
    sw      $2, 36($fp)

    # 调用 printf 输出结果
    lw      $5, 36($fp)       # 将 sum 加载到 $5 （为 printf 第1个参数）
    la      $4, $LC0          # 加载格式化字符串地址到 $4 （为 printf 第2个参数）
    la      $t9, printf       # 加载 printf 的地址到 $t9
    jalr    $t9              # 调用 printf
    nop

    # 返回主程序
    move    $2, $0           # 返回值 0
    move    $sp, $fp
    lw      $ra, 44($sp)
    lw      $fp, 40($sp)
    addiu   $sp, $sp, 48
    jr      $ra
    nop

    .size   main, .-main
    .ident  "GCC: (Ubuntu 12.3.0-17ubuntu1) 12.3.0"
    .section    .note.GNU-stack,"",@progbits