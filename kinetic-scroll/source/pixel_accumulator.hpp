#pragma once
#include <cmath>

// Toolkit wheel adapters often round deltas to integer pixels. Never send
// zero-sized movement during a fling; preserve its remainder for later frames.
struct PixelAccumulator {
    double remainder = 0;
    double take(double delta) {
        if (delta * remainder < 0)
            remainder = 0;
        remainder += delta;
        const double whole = std::trunc(remainder);
        remainder -= whole;
        return whole;
    }
    void reset() { remainder = 0; }
};
