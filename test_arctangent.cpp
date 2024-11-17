#include <iostream>
#include <cassert>
#include <cmath>
#include "Arctangent.h"

void test_arctangent() {
    Arctangent arctan;
    double result = arctan.FuncA(0.5, 10);
    double expected = 0.4636476090008061;

    assert(std::abs(result - expected) < 1e-6);
}

int main() {
    test_arctangent();
    std::cout << "All tests passed!" << std::endl;
    return 0;
}

