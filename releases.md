# Releases

## v0.2.0

  - Added transparent SVG background support using `light_color: nil` or `light_color: "transparent"`.

## v0.1.0

  - **Breaking**: Complete refactor of encoder architecture with cleaner segment-based design.
  - **Breaking**: Renamed `RSBlock` to `ErrorCorrectionBlock` with cleaner method names (`for`, `table_entry_for`).
  - **Breaking**: Simplified `Code` constructor to take segments array, added `Code.build()` factory method.
  - **Breaking**: Removed redundant `Multi` class - multi-segment support now built into `Code` directly.
  - **Breaking**: Renamed ASCII output to Text output (`QRCode.text()` instead of `QRCode.ascii()`).
  - **Breaking**: Renamed `ERROR_CORRECT_LEVEL` to `ERROR_CORRECTION_LEVEL` for better grammar.
  - Added self-contained segment classes: `Segment`, `NumericSegment`, `AlphanumericSegment`.
  - Added comprehensive test coverage for output functionality (Text and SVG).
  - Added `size` alias for `module_count` for cleaner API.
  - Added proper documentation explaining error correction level encoding from ISO/IEC 18004.
  - Added getting started guide with comprehensive usage examples.
  - Improved code organization with `QRCode::Encoder` namespace for all encoding classes.
  - Removed QR prefix from encoder file and class names for cleaner codebase.
