# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Samuel Williams.

def initialize(context)
	super
	
	require "qrcode"
end

# Generate a QR code as text art and print it to the console.
# @parameter data [String] The data to encode in the QR code.
# @parameter border [Integer] The border size in characters (default: 2).
def text(data, border: 2)
	puts QRCode.text(data, border: border)
end

# Generate a QR code as SVG and print it to the console.
# @parameter data [String] The data to encode in the QR code.
# @parameter cell_size [Integer] The size of each cell in pixels (default: 10).
# @parameter border [Integer] The border size in cells (default: 2).
# @parameter dark_color [String] The color for dark modules (default: '#000000').
# @parameter light_color [String] The color for light modules (default: '#ffffff').
def svg(data, cell_size: 10, border: 2, dark_color: "#000000", light_color: "#ffffff")
	puts QRCode.svg(data, 
		cell_size: cell_size, 
		border: border, 
		dark_color: dark_color, 
		light_color: light_color
	)
end
