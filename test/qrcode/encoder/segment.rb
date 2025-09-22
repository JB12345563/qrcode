# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021, by Sam Sayer.
# Copyright, 2021, by Duncan Robertson.
# Copyright, 2025, by Samuel Williams.

require "qrcode"
require "qrcode"

describe QRCode::Encoder::Segment do
	PAYLOAD = [{data: "byteencoded", mode: :byte_8bit}, {data: "A1" * 107, mode: :alphanumeric}, {data: "1" * 498, mode: :number}]
	
	it "handles multi payloads" do
		QRCode::Encoder::Code.new(PAYLOAD, level: :l)
		QRCode::Encoder::Code.new(PAYLOAD, level: :m)
		QRCode::Encoder::Code.new(PAYLOAD, level: :q)
		QRCode::Encoder::Code.new(PAYLOAD)
		QRCode::Encoder::Code.new(PAYLOAD, level: :l, max_size: 22)
	end
	
	it "handles invalid code configs" do
		expect do
			QRCode::Encoder::Code.new(:not_a_string_or_array)
		end.to raise_exception(ArgumentError)
		
		expect do
			QRCode::Encoder::Code.new(PAYLOAD << :not_a_segment)
		end.to raise_exception(ArgumentError)
	end
end
