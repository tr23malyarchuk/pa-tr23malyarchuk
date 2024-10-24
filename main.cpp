#include <iostream>
#include "Arctangent.h"

int main() // instantiating the class and calling the function
{
    Arctangent arctan;
    double x = 0.5;
    int n = 10;

    double result = arctan.FuncA(x, n);
    std::cout << "Arctangent of " << x << " is approximately: " << result << std::endl;

    return 0;
}
