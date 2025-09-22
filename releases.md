# Releases

## Unreleased

- **Breaking**: Complete refactor of encoder architecture with cleaner segment-based design.
- **Breaking**: Renamed `RSBlock` to `ErrorCorrectionBlock` with cleaner method names (`for`, `table_entry_for`).
- **Breaking**: Simplified `Code` constructor to take segments array, added `Code.build()` factory method.
- **Breaking**: Removed redundant `Multi` class - multi-segment support now built into `Code` directly.
- Added self-contained segment classes: `Segment`, `NumericSegment`, `AlphanumericSegment`.
- Added comprehensive test coverage for output functionality (Text and SVG).
- Added `size` alias for `module_count` for cleaner API.
- Added proper documentation explaining error correction level encoding from ISO/IEC 18004.
- Improved code organization with `QRCode::Encoder` namespace for all encoding classes.
- Removed QR prefix from encoder file and class names for cleaner codebase.
