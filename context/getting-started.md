# Getting Started

This guide explains how to get started with `qrcode` to generate QR codes in Ruby.

## Installation

Add the gem to your project:

```bash
$ bundle add qrcode
```

## Core Concepts

`qrcode` provides a simple and flexible way to generate QR codes with multiple output formats:

- Text output using Unicode block characters for terminal display
- SVG output for scalable vector graphics
- Multiple error correction levels (L, M, Q, H) for different damage tolerance requirements

## Usage

The simplest way to generate a QR code is using the convenience methods:

### Text Output

Generate QR codes as text art for terminal display:

```ruby
require "qrcode"

# Basic text output
puts QRCode.text("Hello World")

# Customized text output
puts QRCode.text("Hello World", border: 4)
```

This will display a QR code using Unicode half-height block characters that can be scanned from your terminal.

### SVG Output

Generate QR codes as scalable vector graphics:

```ruby
require "qrcode"

# Basic SVG output
svg_content = QRCode.svg("Hello World")
File.write("qrcode.svg", svg_content)

# Customized SVG output
svg_content = QRCode.svg("Hello World", 
		cell_size: 20, 
		border: 3,
		dark_color: "#000080",
		light_color: "#f0f0f0"
)
```

### Error Correction Levels

QR codes support four standardized error correction levels:

```ruby
# Low error correction (~7% recovery) - maximum data capacity
QRCode.text("Data", level: :l)

# Medium error correction (~15% recovery) - balanced
QRCode.text("Data", level: :m)

# Quartile error correction (~25% recovery) - good for damaged surfaces
QRCode.text("Data", level: :q)

# High error correction (~30% recovery) - maximum damage tolerance
QRCode.text("Data", level: :h)
```

Higher error correction levels make QR codes more resilient to damage but reduce the amount of data that can be stored.

### Encoding Modes

The library automatically detects the optimal encoding mode for your data:

```ruby
# Automatically uses numeric encoding (most efficient for numbers)
QRCode.text("12345")

# Automatically uses alphanumeric encoding (efficient for uppercase + numbers)
QRCode.text("HELLO123")

# Uses binary encoding (for mixed case, symbols, etc.)
QRCode.text("Hello World!")
```

You can also specify the encoding mode explicitly:

```ruby
# Force specific encoding modes
QRCode.text("12345", mode: :numeric)
QRCode.text("HELLO", mode: :alphanumeric)  
QRCode.text("data", mode: :binary)
```

## Command Line Usage

The project includes bake tasks for command-line QR code generation:

```bash
# Generate text QR code
$ bake qrcode:text "Hello World"

# Generate SVG QR code
$ bake qrcode:svg "Hello World"

# Save SVG to file
$ bake qrcode:save "Hello World" output.svg
```

## Advanced Usage

### Multi-Segment QR Codes

For optimal encoding of mixed data types, you can create multi-segment QR codes:

```ruby
# Optimize encoding by using different modes for different parts
multi_data = [
		{data: "12345", mode: :numeric},
		{data: "HELLO", mode: :alphanumeric}, 
		{data: "world!", mode: :binary}
]

qr_code = QRCode.text(multi_data)
```

### Custom Size Control

Control the QR code version (size) explicitly:

```ruby
# Force specific QR code size (version)
QRCode.text("Data", size: 5)  # Creates a 37x37 module QR code

# Set maximum allowed size
QRCode.text("Large data", max_size: 10)  # Auto-size up to version 10
```

QR code versions range from 1 (21x21 modules) to 40 (177x177 modules), with each version adding 4 modules per side.
