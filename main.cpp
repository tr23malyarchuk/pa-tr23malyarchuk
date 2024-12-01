#include <iostream>
#include <vector>
#include <algorithm>
#include "Arctangent.h"

int main() {
    Arctangent arctan;
    int n = 10; // Number of terms in the series

    // Array of x values to compute arctangent
    std::vector<double> x_values = {0.1, 0.5, 0.2, 0.7, 0.3};
    std::vector<double> results;

    // Calculate arctangent for each x value
    for (double x : x_values) {
        double result = arctan.FuncA(x, n);
        std::cout << "Arctangent of " << x << " is approximately: " << result << std::endl;
        results.push_back(result);
    }

    // Sort the results in ascending order
    std::sort(results.begin(), results.end());

    // Display sorted results
    std::cout << "\nSorted arctangent values:" << std::endl;
    for (double result : results) {
        std::cout << result << " ";
    }
    std::cout << std::endl;

    return 0;
}

