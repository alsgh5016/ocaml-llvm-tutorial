/* compile with: clang -emit-llvm -c hello.c -o hello.bc */
#include <stdio.h>

int compute_factorial(int n) {
    if (n <= 1) {
        return 1;
    } else {
        return n * compute_factorial(n - 1);
    }
}

int compute_sum(int n) {
    int sum = 0;
    for (int i = 1; i <= n; ++i) {
        sum += i;
    }
    return sum;
}

int main() {
    int number = 5;
    
    printf("Computing the factorial of %d\n", number);
    int factorial = compute_factorial(number);
    printf("Factorial: %d\n", factorial);
    
    printf("Computing the sum of numbers up to %d\n", number);
    int sum = compute_sum(number);
    printf("Sum: %d\n", sum);

    if (factorial > sum) {
        printf("Factorial is greater than sum\n");
    } else {
        printf("Sum is greater than or equal to factorial\n");
    }

    return 0;
}
