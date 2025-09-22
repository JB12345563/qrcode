# QRCode

This is a fork of [`rqrcode_core`](https://github.com/whomwah/rqrcode_core), which was originally adapted in 2008 from a Javascript library by [Kazuhiko Arase](https://github.com/kazuhikoarase/qrcode-generator).

Features:

  - `rqrcode_core` is a Ruby only library. It requires no 3rd party libraries. Just Ruby\!
  - It is an encoding library. You can't decode QR Codes with it.
  - The interface is simple and assumes you just want to encode a string into a QR Code, but also allows for encoding multiple segments.
  - QR Code is trademarked by Denso Wave inc.
  - Minimum Ruby version is `>= 3.0.0`

`rqrcode_core` is the basis of the popular `rqrcode` gem \[https://github.com/whomwah/rqrcode\]. This gem allows you to generate different renderings of your QR Code, including `png`, `svg` and `ansi`.

[![Development Status](https://github.com/socketry/qrcode/workflows/Test/badge.svg)](https://github.com/socketry/qrcode/actions?workflow=Test)

## Installation

Add this line to your application's Gemfile:

``` ruby
gem "rqrcode_core"
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rqrcode_core

## Usage

Please see the [project documentation](https://socketry.github.io/qrcode/) for more details.

  - [Getting Started](https://socketry.github.io/qrcode/guides/getting-started/index) - This guide explains how to get started with `qrcode` to generate QR codes in Ruby.

## Releases

Please see the [project releases](https://socketry.github.io/qrcode/releases/index) for all releases.

### Unreleased

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
