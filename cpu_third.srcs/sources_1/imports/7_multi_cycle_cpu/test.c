#include <stdio.h>

// 全局变量，用于测试数据存储与加载
volatile int globalVar = 0;

// 基本算术函数，测试函数调用
int add(int a, int b) {
    return a + b;
}

int sub(int a, int b) {
    return a - b;
}

int mul(int a, int b) {
    return a * b;
}

int divi(int a, int b) {
    return a / b;
}

int mod(int a, int b) {
    return a % b;
}

// 递归测试函数（阶乘）
int factorial(int n) {
    if(n <= 1)
        return 1;
    else
        return n * factorial(n - 1);
}

// 递归测试函数（斐波那契数列）
int fib(int n) {
    if(n <= 1)
        return n;
    return fib(n - 1) + fib(n - 2);
}

int main() {
    int a = 5, b = 3;

    // 算术运算测试
    int result_add = add(a, b);
    int result_sub = sub(a, b);
    int result_mul = mul(a, b);
    int result_div = divi(a, b);
    int result_mod = mod(a, b);

    // 测试全局变量及循环指令（数据存储、加载及分支）
    globalVar = 100;
    for (int i = 0; i < 10; i++) {
        globalVar += i;
    }

    // // 打印算术运算结果
    // printf("Add: %d\n", result_add);
    // printf("Sub: %d\n", result_sub);
    // printf("Mul: %d\n", result_mul);
    // printf("Div: %d\n", result_div);
    // printf("Mod: %d\n", result_mod);

    // // 测试递归调用（阶乘和斐波那契）
    // printf("Factorial(5): %d\n", factorial(5));
    // printf("Fibonacci(10): %d\n", fib(10));

    // // 打印全局变量运算结果
    // printf("GlobalVar after loop: %d\n", globalVar);

    return 0;
}