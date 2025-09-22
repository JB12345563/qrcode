# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2019-2020, by Duncan Robertson.
# Copyright, 2020, by Nathaniel Roman.
# Copyright, 2025, by Samuel Williams.

require_relative "qrcode/version"
require_relative "qrcode/encoder"
require_relative "qrcode/output/text"
require_relative "qrcode/output/svg"

module QRCode
	# Convenience method to create a QR code and render as text
	def self.text(data, **options)
		qr = Encoder::Code.new(data)
		Output::Text.new(qr, **options).render
	end
	
	# Convenience method to create a QR code and render as SVG
	def self.svg(data, **options)
		qr = Encoder::Code.new(data)
		Output::SVG.new(qr, **options).render
	end
end
