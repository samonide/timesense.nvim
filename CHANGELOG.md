# Changelog

All notable changes to Timesense.nvim will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial release of Timesense.nvim
- Basic C/C++ complexity analysis
- Time complexity detection for loops (for, while, do-while)
- Logarithmic loop detection (i *= 2, i /= 2)
- Square root loop detection (i * i < n)
- Nested loop complexity multiplication
- STL function complexity detection (sort, binary_search, etc.)
- Space complexity analysis for arrays and vectors
- 2D array/vector detection
- Virtual text display using extmarks
- Commands: complexity, hide, toggle, constraints
- Configuration options for icons and highlighting
- Problem constraint management
- Vim help documentation
- Examples and quick start guide

### Features in Development
- Python language support
- Java language support
- Recursion complexity detection
- More STL function patterns
- Dynamic programming pattern detection
- Graph algorithm complexity hints

## [1.0.0] - 2026-01-11

Initial release.
