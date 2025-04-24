#include <stdio.h>
// 覆盖所有MIPS指令类型
volatile int global_var = 0; // 用于内存访问

int main() {
  /* R型指令示例 */
  int a = 5;      // addiu (I型)
  int b = 3;      // addiu (I型)
  int c = a + b;  // add (R型)
  int d = c << 2; // sll (R型)
  int e = a & b;  // and (R型)

  /* I型取数/存数指令 */
  global_var = e;     // sw (I型存数)
  int f = global_var; // lw (I型取数)

  /* I型条件判断 */
  if (f > 0) { // slt + bne (I型+R型)
    a = f - 1; // addiu (I型)
  } else {
    a = f + 1; // addiu (I型)
  }

  /* J型指令 (通过函数调用) */
  int g = a > 0 ? a : -a; // jal (J型) + jr $ra (R型)

  return 0;
}
