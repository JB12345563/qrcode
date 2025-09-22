# QRCode

`rqrcode_core` is a library for encoding QR Codes in pure Ruby. It has a simple interface with all the standard qrcode options. It was originally adapted in 2008 from a Javascript library by [Kazuhiko Arase](https://github.com/kazuhikoarase).

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

## Basic Usage

``` ruby
require "rqrcode_core"
qr = QRCode::Code.new("https://kyan.com")
puts qr.to_s
```

Output:

    xxxxxxx x  x x   x x  xx  xxxxxxx
    x     x  xxx  xxxxxx xxx  x     x
    x xxx x  xxxxx x       xx x xxx x
    ... etc

## Multiple Encoding Support

``` ruby
require "rqrcode_core"
qr = QRCode::Code.new([
	{data: "byteencoded", mode: :byte_8bit},
	{data: "A1" * 100, mode: :alphanumeric},
	{data: "1" * 500, mode: :number}
])
```

This will create a QR Code with byte encoded, alphanumeric and number segments. Any combination of encodings/segments will work provided it fits within size limits.

## Doing your own rendering

``` ruby
require "rqrcode_core"

qr = QRCode::Code.new("https://kyan.com")
qr.modules.each do |row|
	row.each do |col|
		print col ? "#" : " "
	end
	
	print "\n"
end
```

### Options

The library expects a string or array (for multiple encodings) to be parsed in, other args are optional.

    data - the string or array you wish to encode
    
    size - the size (integer) of the QR Code (defaults to smallest size needed to encode the string)
    
    max_size - the max_size (Integer) of the QR Code (default QRCode::Util.max_size)
    
    level  - the error correction level, can be:
      * Level :l 7%  of code can be restored
      * Level :m 15% of code can be restored
      * Level :q 25% of code can be restored
      * Level :h 30% of code can be restored (default :h)
    
    mode - the mode of the QR Code (defaults to alphanumeric or byte_8bit, depending on the input data, only used when data is a string):
      * :number
      * :alphanumeric
      * :byte_8bit

#### Example

``` ruby
QRCode::Code.new("http://kyan.com", size: 2, level: :m, mode: :byte_8bit)
```

## Development

### Tests

You can run the test suite using:

    $ ./bin/setup
    $ rake

or try the project from the console with:

    $ ./bin/console

### Linting

The project uses [standardrb](https://github.com/testdouble/standard) and can be run with:

    $ ./bin/setup
    $ rake standard # check
    $ rake standard:fix # fix

## Experimental

On 64 bit systems when generating lots of QR Codes the lib will consume more memory than on a 32 bit systems during the internal "right shift zero fill" steps (this is expected). In tests though, it's shown that by forcing the lib to think you're on a 32 systems greatly reduces the memory footprint. This could of course have undesired consequences too\! but if you're happy to try, you can use the `RQRCODE_CORE_ARCH_BITS` ENV to make this change. e.g `RQRCODE_CORE_ARCH_BITS=32`.

## Releases

There are no documented releases.

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
