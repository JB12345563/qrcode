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
		QRCode::Encoder::Code.build(PAYLOAD, level: :l)
		QRCode::Encoder::Code.build(PAYLOAD, level: :m)
		QRCode::Encoder::Code.build(PAYLOAD, level: :q)
		QRCode::Encoder::Code.build(PAYLOAD)
		QRCode::Encoder::Code.build(PAYLOAD, level: :l, max_size: 22)
	end
	
	it "creates different segment types correctly" do
		# Test numeric segment creation
		numeric_segments = QRCode::Encoder::Segment.build("12345", mode: :numeric)
		expect(numeric_segments.first).to be_a(QRCode::Encoder::NumericSegment)
		
		# Test alphanumeric segment creation
		alpha_segments = QRCode::Encoder::Segment.build("HELLO123", mode: :alphanumeric)
		expect(alpha_segments.first).to be_a(QRCode::Encoder::AlphanumericSegment)
		
		# Test binary segment creation
		binary_segments = QRCode::Encoder::Segment.build("hello world", mode: :binary)
		expect(binary_segments.first).to be_a(QRCode::Encoder::Segment)
		
		# Test auto-detection
		auto_segments = QRCode::Encoder::Segment.build("12345", mode: :auto)
		expect(auto_segments.first).to be_a(QRCode::Encoder::NumericSegment)
	end
	
	it "handles invalid segment data" do
		expect do
			QRCode::Encoder::NumericSegment.new("not_numeric")
		end.to raise_exception(ArgumentError)
		
		expect do
			QRCode::Encoder::AlphanumericSegment.new("lowercase_not_allowed")
		end.to raise_exception(ArgumentError)
	end
end
