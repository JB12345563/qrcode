# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Samuel Williams.

require "qrcode"

describe QRCode::Output::Text do
	let(:qr_code) {QRCode::Encoder::Code.build("TEST")}
	
	it "can create text renderer with default border" do
		renderer = QRCode::Output::Text.new(qr_code)
		expect(renderer.border).to be == 2
		expect(renderer.qrcode).to be == qr_code
	end
	
	it "can create text renderer with custom border" do
		renderer = QRCode::Output::Text.new(qr_code, border: 5)
		expect(renderer.border).to be == 5
	end
	
	it "renders text output with correct dimensions" do
		renderer = QRCode::Output::Text.new(qr_code, border: 1)
		output = renderer.render
		lines = output.split("\n")
		
		# Should have border + (qr_size/2 rounded up) + border lines
		# For 21x21 QR code: 1 + 11 + 1 = 13 lines
		expected_lines = 1 + ((qr_code.size + 1) / 2) + 1
		expect(lines.size).to be == expected_lines
		
		# Each line should have border + qr_size + border width
		expected_width = 1 + qr_code.size + 1
		lines.each do |line|
			expect(line.length).to be == expected_width
		end
	end
	
	it "uses Unicode block characters" do
		renderer = QRCode::Output::Text.new(qr_code, border: 0)
		output = renderer.render
		
		# Should contain Unicode block characters
		expect(output).to be(:include?, "█")
	end
	
	it "handles border correctly" do
		# Test with no border
		renderer_no_border = QRCode::Output::Text.new(qr_code, border: 0)
		output_no_border = renderer_no_border.render
		lines_no_border = output_no_border.split("\n")
		
		# Test with border
		renderer_with_border = QRCode::Output::Text.new(qr_code, border: 2)
		output_with_border = renderer_with_border.render
		lines_with_border = output_with_border.split("\n")
		
		# With border should have more lines and wider lines
		expect(lines_with_border.size).to be > lines_no_border.size
		expect(lines_with_border.first.length).to be > lines_no_border.first.length
	end
	
	it "handles odd-sized QR codes correctly" do
		# QR codes are always odd-sized, but test edge case handling
		renderer = QRCode::Output::Text.new(qr_code, border: 0)
		output = renderer.render
		
		# Should not raise errors and should produce valid output
		expect(output).to be_a(String)
		expect(output.length).to be > 0
	end
	
	it "produces consistent output for same input" do
		renderer1 = QRCode::Output::Text.new(qr_code, border: 1)
		renderer2 = QRCode::Output::Text.new(qr_code, border: 1)
		
		expect(renderer1.render).to be == renderer2.render
	end
end

describe "QRCode.text convenience method" do
	it "generates text output directly" do
		output = QRCode.text("TEST", border: 1)
		expect(output).to be_a(String)
		expect(output).to be(:include?, "█")
	end
	
	it "passes options correctly" do
		output_small = QRCode.text("TEST", border: 0)
		output_large = QRCode.text("TEST", border: 3)
		
		lines_small = output_small.split("\n")
		lines_large = output_large.split("\n")
		
		expect(lines_large.size).to be > lines_small.size
		expect(lines_large.first.length).to be > lines_small.first.length
	end
end
