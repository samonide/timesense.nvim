# Changelog

All notable changes to Timesense.nvim will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.1.0] - 2026-01-13

### Fixed
- Critical bug: Function calls inside loops now correctly multiply complexity (e.g., sort in loop = O(n² log n))
- Critical bug: Overall complexity now takes maximum across all operations, not just last value
- Bug: Sequential operations at same nesting level now properly compared

### Added
- Range-based for loop detection (`for(auto x : container)`)
- Bitwise optimization patterns (`i & (i-1)`, bit shifts)
- Unordered map/set operations with O(1) average complexity
- Comprehensive STL function support (50+ functions):
  - Container methods: `.insert()`, `.find()`, `.erase()`, `.count()`, `.lower_bound()`, `.upper_bound()`
  - String operations: `.substr()`, `.find()`, `.compare()`
  - Memory operations: `memset()`, `memcpy()`
  - Heap operations: `push_heap()`, `pop_heap()`, `make_heap()`, `sort_heap()`
  - More STL: `stable_sort`, `equal_range`, `copy`, `move`, `rotate`, `unique`, `remove`, `accumulate`
- Algorithm-specific complexity detection:
  - Graph algorithms: DFS/BFS O(V+E), Dijkstra O(E log V), Floyd-Warshall O(n³), Bellman-Ford O(V×E)
  - DSU/Union-Find: O(α(n)) amortized
  - Segment Tree/Fenwick Tree: O(log n) operations
  - Trie operations: O(L) where L is string length
  - KMP/Z-algorithm: O(n)
  - Sieve of Eratosthenes: O(n log log n)
  - Matrix multiplication: O(n³)
  - GCD: O(log n)
- Space complexity detection for:
  - All STL containers (set, map, unordered_set/map, priority_queue, queue, stack, deque)
  - 2D structures and DP tables
  - Graph adjacency lists O(V+E)
  - Segment/Fenwick trees O(n)
  - DSU parent arrays O(n)
- Enhanced complexity hierarchy with O(α(n)), O(L), O(n log log n), O(V+E), O(V×E), O(E log V)
- Improved display location detection (handles #define, class, struct declarations)

### Changed
- Function calls now respect loop nesting when calculating effective complexity
- Space complexity now uses `get_dominant_complexity()` for proper comparison
- Display checks first 100 lines (up from 50) for better header detection

## [1.0.0] - 2026-01-11

Initial release.
