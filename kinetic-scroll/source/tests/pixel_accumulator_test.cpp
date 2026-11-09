#include "pixel_accumulator.hpp"
#include <cassert>
#include <cmath>
#include <iostream>
int main() {
    for (double sign : {-1., 1.}) {
        PixelAccumulator a;
        double input = 0, output = 0;
        for (int i = 0; i < 1000; ++i) {
            const double delta = sign * 0.2 * std::exp(-i / 300.);
            const double sent = a.take(delta);
            input += delta;
            output += sent;
            assert(sent == 0 || (sent * sign >= 1 && sent == std::trunc(sent)));
        }
        assert(std::abs(input - output) < 1.);
        a.reset();
        assert(a.take(sign * 0.75) == 0);
        assert(a.take(-sign * 0.75) == 0);
        assert(a.take(-sign * 0.75) == -sign);
    }
    std::cout << "PASS: both directions preserve travel, omit subpixel events, and reset on reversal\n";
}
