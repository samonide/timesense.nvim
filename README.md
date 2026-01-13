# Timesense.nvim

Complexity analyzer and coding stats tracker for competitive programming.

## Features

- **Inline complexity hints** - Displays time/space complexity on every loop and function call
- **Overall complexity summary** - Shows `Time: O(n log n) | Space: O(n)` at the top of your file
- **Comprehensive pattern detection** - 50+ STL functions, graph algorithms, data structures
- **Nested operation support** - Correctly handles sort inside loops, multiple nested structures
- **Coding statistics** - Track time spent coding by language
- **Zero dependencies** - Fully offline, no external tools required

## Supported Patterns

### Time Complexity Detection
- **Loops**: for, while, do-while, range-based for
- **STL Functions**: sort, binary_search, lower_bound, set/map operations, heap operations, and 40+ more
- **Algorithms**: DFS/BFS, Dijkstra, Floyd-Warshall, DSU, Segment Trees, KMP, Sieve
- **Optimizations**: Bitwise patterns (i & (i-1)), logarithmic loops, sqrt loops

### Space Complexity Detection
- Arrays, vectors, sets, maps, unordered containers
- 2D structures and DP tables
- Graph adjacency lists
- Segment/Fenwick trees, DSU arrays

## Installation

```lua
-- lazy.nvim
{
  'samonide/timesense.nvim',
  config = function()
    require('timesense').setup()
  end,
  cmd = 'Timesense',
  ft = { 'cpp', 'c' },
}
```

## Quick Start

```vim
:Timesense complexity   " Analyze code complexity
:Timesense stats        " View coding statistics
:Timesense toggle       " Show/hide hints
```

See [USAGE.md](USAGE.md) for detailed documentation.

## Requirements

- Neovim 0.8+
- Currently supports C/C++ (Python/Java planned)

## Disclaimer

This project used AI assistance (GitHub Copilot) for code comments, documentation, and development guidance.

## License

MIT
