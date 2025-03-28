#include <stdio.h>

// 基本算术函数，用于测试函数调用和算术指令
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

// 递归函数测试分支和调用指令
int fact(int n) {
    if(n <= 1)
        return 1;
    else
        return n * fact(n - 1);
}

int main() {
    int a = 5, b = 10;
    int res_add = add(a, b);
    int res_sub = sub(b, a);
    int res_mul = mul(a, b);
    int res_div = divi(b, a);
    int res_fact = fact(6);

    // 循环及数组操作测试加载存储、多次分支
    int arr[5] = {1, 2, 3, 4, 5};
    int arr_sum = 0;
    for (int i = 0; i < 5; i++) {
        arr_sum += arr[i];
    }

    // 打印测试结果
    printf("Add: %d\n", res_add);
    printf("Sub: %d\n", res_sub);
    printf("Mul: %d\n", res_mul);
    printf("Div: %d\n", res_div);
    printf("Fact(6): %d\n", res_fact);
    printf("Array Sum: %d\n", arr_sum);

    return 0;
}