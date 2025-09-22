# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Samuel Williams.

require "qrcode"

describe QRCode::Output::SVG do
	let(:qr_code) {QRCode::Encoder::Code.build("TEST")}
	
	it "can create SVG renderer with default options" do
		renderer = QRCode::Output::SVG.new(qr_code)
		expect(renderer.cell_size).to be == 10
		expect(renderer.border).to be == 2
		expect(renderer.dark_color).to be == "#000000"
		expect(renderer.light_color).to be == "#ffffff"
		expect(renderer.qrcode).to be == qr_code
	end
	
	it "can create SVG renderer with custom options" do
		renderer = QRCode::Output::SVG.new(qr_code, 
			cell_size: 20, 
			border: 5, 
			dark_color: "#ff0000", 
			light_color: "#00ff00"
		)
		expect(renderer.cell_size).to be == 20
		expect(renderer.border).to be == 5
		expect(renderer.dark_color).to be == "#ff0000"
		expect(renderer.light_color).to be == "#00ff00"
	end
	
	it "renders valid SVG output" do
		renderer = QRCode::Output::SVG.new(qr_code, cell_size: 10, border: 2)
		svg = renderer.render
		
		# Should contain XML declaration
		expect(svg).to be(:include?, '<?xml version="1.0" encoding="UTF-8"?>')
		
		# Should contain SVG root element
		expect(svg).to be(:include?, '<svg xmlns="http://www.w3.org/2000/svg"')
		expect(svg).to be(:include?, "</svg>")
		
		# Should contain background rectangle
		expect(svg).to be(:include?, '<rect x="0" y="0"')
		
		# Should be properly closed
		expect(svg).to be(:include?, "</svg>")
	end
	
	it "calculates correct SVG dimensions" do
		cell_size = 5
		border = 3
		renderer = QRCode::Output::SVG.new(qr_code, cell_size: cell_size, border: border)
		svg = renderer.render
		
		expected_size = (qr_code.size + (border * 2)) * cell_size
		expect(svg).to be(:include?, "width=\"#{expected_size}\"")
		expect(svg).to be(:include?, "height=\"#{expected_size}\"")
		expect(svg).to be(:include?, "viewBox=\"0 0 #{expected_size} #{expected_size}\"")
	end
	
	it "uses correct colors" do
		dark_color = "#123456"
		light_color = "#abcdef"
		renderer = QRCode::Output::SVG.new(qr_code, dark_color: dark_color, light_color: light_color)
		svg = renderer.render
		
		expect(svg).to be(:include?, "fill=\"#{light_color}\"")  # Background
		expect(svg).to be(:include?, "fill=\"#{dark_color}\"")   # Dark modules
	end
	
	it "generates rectangles for dark modules" do
		renderer = QRCode::Output::SVG.new(qr_code, cell_size: 10, border: 1)
		svg = renderer.render
		
		# Count dark modules in QR code
		dark_count = 0
		qr_code.size.times do |row|
			qr_code.size.times do |col|
				dark_count += 1 if qr_code.checked?(row, col)
			end
		end
		
		# Should have background rect + one rect per dark module
		rect_count = svg.scan(/<rect/).size
		expect(rect_count).to be == (1 + dark_count)  # 1 background + dark modules
	end
	
	it "positions rectangles correctly" do
		cell_size = 8
		border = 2
		renderer = QRCode::Output::SVG.new(qr_code, cell_size: cell_size, border: border)
		svg = renderer.render
		
		# Check that first dark module is positioned correctly
		# Find first dark module
		first_dark_row, first_dark_col = nil, nil
		qr_code.size.times do |row|
			qr_code.size.times do |col|
				if qr_code.checked?(row, col)
					first_dark_row, first_dark_col = row, col
					break
				end
			end
			break if first_dark_row
		end
		
		if first_dark_row
			expected_x = (first_dark_col + border) * cell_size
			expected_y = (first_dark_row + border) * cell_size
			expect(svg).to be(:include?, "x=\"#{expected_x}\" y=\"#{expected_y}\"")
		end
	end
	
	it "produces consistent output for same input" do
		renderer1 = QRCode::Output::SVG.new(qr_code, cell_size: 10, border: 2)
		renderer2 = QRCode::Output::SVG.new(qr_code, cell_size: 10, border: 2)
		
		expect(renderer1.render).to be == renderer2.render
	end
	
	it "handles zero border correctly" do
		renderer = QRCode::Output::SVG.new(qr_code, border: 0)
		svg = renderer.render
		
		expected_size = qr_code.size * renderer.cell_size
		expect(svg).to be(:include?, "width=\"#{expected_size}\"")
		expect(svg).to be(:include?, "height=\"#{expected_size}\"")
	end
	
	it "supports transparent background" do
		# Test with nil light_color
		renderer_nil = QRCode::Output::SVG.new(qr_code, light_color: nil)
		svg_nil = renderer_nil.render
		expect(renderer_nil.transparent?).to be == true
		expect(svg_nil).not.to be(:include?, "fill=\"#{renderer_nil.light_color}\"")
		
		# Test with 'transparent' keyword
		renderer_transparent = QRCode::Output::SVG.new(qr_code, light_color: "transparent")
		svg_transparent = renderer_transparent.render
		expect(renderer_transparent.transparent?).to be == true
		expect(svg_transparent).not.to be(:include?, "fill=\"transparent\"")
		
		# Test that solid background still works
		renderer_solid = QRCode::Output::SVG.new(qr_code, light_color: "#ffffff")
		svg_solid = renderer_solid.render
		expect(renderer_solid.transparent?).to be == false
		expect(svg_solid).to be(:include?, "fill=\"#ffffff\"")
	end
end

describe "QRCode.svg convenience method" do
	it "generates SVG output directly" do
		svg = QRCode.svg("TEST", cell_size: 5, border: 1)
		expect(svg).to be_a(String)
		expect(svg).to be(:include?, '<?xml version="1.0" encoding="UTF-8"?>')
		expect(svg).to be(:include?, '<svg xmlns="http://www.w3.org/2000/svg"')
		expect(svg).to be(:include?, "</svg>")
	end
	
	it "passes options correctly" do
		svg = QRCode.svg("TEST", cell_size: 20, border: 5, dark_color: "#ff0000", light_color: "#0000ff")
		
		expect(svg).to be(:include?, "fill=\"#0000ff\"")  # Light color
		expect(svg).to be(:include?, "fill=\"#ff0000\"")  # Dark color
		
		# Check dimensions with custom options
		expected_size = (21 + (5 * 2)) * 20  # 21 is QR size for "TEST"
		expect(svg).to be(:include?, "width=\"#{expected_size}\"")
	end
	
	it "works with different data inputs" do
		# Test numeric data
		svg_numeric = QRCode.svg("12345")
		expect(svg_numeric).to be(:include?, "<svg")
		
		# Test alphanumeric data
		svg_alpha = QRCode.svg("HELLO123")
		expect(svg_alpha).to be(:include?, "<svg")
		
		# Test longer data
		svg_long = QRCode.svg("This is a longer test string")
		expect(svg_long).to be(:include?, "<svg")
	end
end
