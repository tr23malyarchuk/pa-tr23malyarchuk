#define TEST_MODE

#include <iostream>
#include <cassert>
#include <cmath>
#include <ctime>
#include <cstdlib>

#include "HTTP_Server.cpp"

void test_all() {
    double x = 0.5;
    int n = 10;
    double result;

    clock_t total_start = clock();

    clock_t start = clock();
    for (int i = 0; i < 10000; ++i) {
        result = calculate_arctangent(x, n);
    }
    clock_t end = clock();
    double arctangent_time = ((double)(end - start)) / CLOCKS_PER_SEC;
    std::cout << "Arctangent calculation time: " << arctangent_time << " seconds" << std::endl;

    int size = 100000;
    double *array_large = (double *)malloc(size * sizeof(double));

    for (int i = 0; i < size; ++i) {
        array_large[i] = calculate_arctangent(0.5 + i * 0.01, 100);
    }

    start = clock();
    sort_array(array_large, size);
    end = clock();
    double sorting_time = ((double)(end - start)) / CLOCKS_PER_SEC;
    std::cout << "Sorting time: " << sorting_time << " seconds" << std::endl;

    free(array_large);

    clock_t total_end = clock();
    double total_time = ((double)(total_end - total_start)) / CLOCKS_PER_SEC;

    std::cout << "Total calculation time: " << total_time << " seconds" << std::endl;

    assert(total_time >= 5.0 && total_time <= 20.0);

    std::cout << "All tests passed!" << std::endl;
}

int main() {
    test_all();
    return 0;
}

