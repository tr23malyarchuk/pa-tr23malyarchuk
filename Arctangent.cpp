#include "Arctangent.h"
#include <cmath>

double Arctangent::FuncA(double x, int n) // calculating arctg(x) function
{
    double sum_n = 0;

    for (int i = 0; i < n; ++i) {
        double term = (pow(-1, i) * pow(x, 2 * i + 1)) / (2 * i + 1);
        sum_n += term;
    }

    return sum_n;
}
