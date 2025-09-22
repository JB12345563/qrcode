# QRCode

A pure Ruby library for generating QR codes with multiple output formats. Generate QR codes as text art for terminal display or as scalable SVG graphics for web and print applications.

![QR Code Example](output.svg)

This is a fork of [`rqrcode_core`](https://github.com/whomwah/rqrcode_core), which was originally adapted in 2008 from a Javascript library by [Kazuhiko Arase](https://github.com/kazuhikoarase/qrcode-generator).

[![Development Status](https://github.com/socketry/qrcode/workflows/Test/badge.svg)](https://github.com/socketry/qrcode/actions?workflow=Test)

## Features

  - **Pure Ruby**: No external dependencies, works with any Ruby application.
  - **Multiple Output Formats**: Text (Unicode blocks) and SVG output built-in.
  - **Automatic Optimization**: Intelligently selects the most efficient encoding (numeric, alphanumeric, or binary).
  - **Error Correction**: Full support for all four standardized error correction levels (L, M, Q, H).
  - **Multi-Segment Encoding**: Optimize large data by mixing encoding modes in a single QR code.
  - **Command Line Tools**: Bake tasks for generating QR codes from the terminal.
  - **Standards Compliant**: Follows ISO/IEC 18004 QR Code specification.

## Usage

Please see the [project documentation](https://socketry.github.io/qrcode/) for more details.

  - [Getting Started](https://socketry.github.io/qrcode/guides/getting-started/index) - This guide explains how to get started with `qrcode` to generate QR codes in Ruby.

## Releases

Please see the [project releases](https://socketry.github.io/qrcode/releases/index) for all releases.

### v0.1.0

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

## Contributing

We welcome contributions to this project.

1.  Fork it.
2.  Create your feature branch (`git checkout -b my-new-feature`).
3.  Commit your changes (`git commit -am 'Add some feature'`).
4.  Push to the branch (`git push origin my-new-feature`).
5.  Create new Pull Request.

### Developer Certificate of Origin

In order to protect users of this project, we require all contributors to comply with the [Developer Certificate of Origin](https://developercertificate.org/). This ensures that all contributions are properly licensed and attributed.

### Community Guidelines

This project is best served by a collaborative and respectful environment. Treat each other professionally, respect differing viewpoints, and engage constructively. Harassment, discrimination, or harmful behavior is not tolerated. Communicate clearly, listen actively, and support one another. If any issues arise, please inform the project maintainers.
