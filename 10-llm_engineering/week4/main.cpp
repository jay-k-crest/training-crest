#include <bits/stdc++.h>
using namespace std;

static inline uint32_t lcg_next(uint32_t &x) {
    // a = 1664525, c = 1013904223, modulus 2^32 (implicit overflow)
    x = uint32_t(1664525u * x + 1013904223u);
    return x;
}

static long long max_subarray_sum(int n, uint32_t seed, int min_val, int max_val) {
    const int range = max_val - min_val + 1;
    vector<int> a;
    a.reserve(n);
    uint32_t cur = seed;
    for (int i = 0; i < n; ++i) {
        cur = lcg_next(cur);
        a.push_back(int(cur % uint32_t(range)) + min_val);
    }

    long long best = LLONG_MIN;
    long long cur_sum = 0;
    for (int v : a) {
        cur_sum = max<long long>(v, cur_sum + v);
        best = max(best, cur_sum);
    }
    return best;
}

static long long total_max_subarray_sum(int n, uint32_t initial_seed, int min_val, int max_val) {
    uint32_t gen = initial_seed;
    long long total = 0;
    for (int i = 0; i < 20; ++i) {
        uint32_t seed = lcg_next(gen);
        total += max_subarray_sum(n, seed, min_val, max_val);
    }
    return total;
}

int main() {
    ios::sync_with_stdio(false);
    cin.tie(nullptr);

    const int n = 10000;
    const uint32_t initial_seed = 42;
    const int min_val = -10;
    const int max_val = 10;

    auto start = chrono::high_resolution_clock::now();
    long long result = total_max_subarray_sum(n, initial_seed, min_val, max_val);
    auto end = chrono::high_resolution_clock::now();

    chrono::duration<double> elapsed = end - start;

    cout << "Total Maximum Subarray Sum (20 runs): " << result << "\n";
    cout << "Execution Time: " << fixed << setprecision(6) << elapsed.count() << " seconds\n";
    return 0;
}