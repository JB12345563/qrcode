# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2008-2025, by Duncan Robertson.
# Copyright, 2011, by Gioele Barabucci.
# Copyright, 2012, by xn.
# Copyright, 2013-2015, by Björn Blomqvist.
# Copyright, 2013, by Yauhen Kharuzhy.
# Copyright, 2014, by Sean Doig.
# Copyright, 2015, by Tonči Damjanić.
# Copyright, 2015-2016, by Bjorn Blomqvist.
# Copyright, 2015-2016, by Fabio Napoleoni.
# Copyright, 2021, by Sam Sayer.
# Copyright, 2025, by Samuel Williams.

require "qrcode"
require "qrcode/sample_data"

describe QRCode::Encoder do
	it "raises argument error for invalid inputs" do
		expect do
			QRCode::Encoder::Code.build(nil)
		end.to raise_exception(ArgumentError, message: be == "data must be a String, Segment, or Array")
		
		expect do
			QRCode::Encoder::Code.build({})
		end.to raise_exception(ArgumentError, message: be == "data must be a String, Segment, or Array")
		
		expect do
			QRCode::Encoder::Code.build(123)
		end.to raise_exception(ArgumentError, message: be == "data must be a String, Segment, or Array")
		
		expect do
			QRCode::Encoder::Code.build("10000000000000000000", size: 41, level: :h)
		end.to raise_exception(ArgumentError, message: be == "Given size greater than maximum possible size of 40")
		
		expect do
			QRCode::Encoder::Code.build("hello", size: 1, level: :a)
		end.to raise_exception(ArgumentError, message: be == "Unknown error correction level `:a`")
	end
	
	it "raises runtime error for invalid inputs" do
		expect do
			QRCode::Encoder::Code.build("duncan").checked?(0, 999999)
		end.to raise_exception(RuntimeError, message: be == "Invalid row/column pair: 0, 999999")
		
		expect do
			assert QRCode::Encoder::Code.build("10000000000000000000", size: 1, level: :h)
		end.to raise_exception(RuntimeError, message: be == "code length overflow. (81>72). (Try a larger size!)")
		
		expect do
			QRCode::Encoder::Util.get_mask(9, 1, 2)
		end.to raise_exception(RuntimeError, message: be == "bad mask_pattern: 9")
		
		expect do
			assert QRCode::Encoder::Util.get_length_in_bits(:duncan, 1)
		end.to raise_exception(RuntimeError, message: be == "Unknown mode: duncan")
		
		expect do
			assert QRCode::Encoder::Util.get_length_in_bits(1 << 0, 41)
		end.to raise_exception(RuntimeError, message: be == "Unknown version: 41")
	end
	
	it "creates a QR code with level H" do
		qr = QRCode::Encoder::Code.build("duncan", size: 1)
		
		expect(qr.modules.size).to be == 21
		expect(qr.modules).to be == MATRIX_1_H
		
		qr = QRCode::Encoder::Code.build("duncan", size: 1)
		expect(qr.modules).to be == MATRIX_1_H
		qr = QRCode::Encoder::Code.build("duncan", size: 1, level: :l)
		expect(qr.modules).to be == MATRIX_1_L
		qr = QRCode::Encoder::Code.build("duncan", size: 1, level: :m)
		expect(qr.modules).to be == MATRIX_1_M
		qr = QRCode::Encoder::Code.build("duncan", size: 1, level: :q)
		expect(qr.modules).to be == MATRIX_1_Q
	end
	
	it "creates a QR code with level H and size 3" do
		qr = QRCode::Encoder::Code.build("duncan", size: 3)
		
		expect(qr.modules.size).to be == 29
		expect(qr.modules).to be == MATRIX_3_H
	end
	
	it "creates a QR code with level H and size 5" do
		qr = QRCode::Encoder::Code.build("duncan", size: 5)
		
		expect(qr.modules.size).to be == 37
		expect(qr.modules).to be == MATRIX_5_H
	end
	
	it "creates a QR code with level H and size 10" do
		qr = QRCode::Encoder::Code.build("duncan", size: 10)
		
		expect(qr.modules.size).to be == 57
		expect(qr.modules).to be == MATRIX_10_H
	end
	
	it "creates a QR code with level H and size 4" do
		qr = QRCode::Encoder::Code.build("www.bbc.co.uk/programmes/b0090blw", level: :l, size: 4)
		expect(qr.modules).to be == MATRIX_4_L
		qr = QRCode::Encoder::Code.build("www.bbc.co.uk/programmes/b0090blw", level: :m, size: 4)
		expect(qr.modules).to be == MATRIX_4_M
		qr = QRCode::Encoder::Code.build("www.bbc.co.uk/programmes/b0090blw", level: :q, size: 4)
		expect(qr.modules).to be == MATRIX_4_Q
		
		qr = QRCode::Encoder::Code.build("www.bbc.co.uk/programmes/b0090blw")
		expect(qr.modules.size).to be == 33
		expect(qr.modules).to be == MATRIX_4_H
	end
	
	it "creates a QR code with level H and size 1" do
		qr = QRCode::Encoder::Code.build("duncan", size: 1)
		expect(qr.to_s[0..21]).to be == "xxxxxxx xx x  xxxxxxx\n"
		expect(qr.to_s(dark: "q", light: "n")[0..21]).to be == "qqqqqqqnqqnqnnqqqqqqq\n"
		expect(qr.to_s(dark: "@")[0..21]).to be == "@@@@@@@ @@ @  @@@@@@@\n"
	end
	
	it "creates a QR code with level H and size 1" do
		# Overflowws without the alpha version
		QRCode::Encoder::Code.build("1234567890", size: 1, level: :h)
		
		qr = QRCode::Encoder::Code.build("DUNCAN", size: 1, level: :h)
		expect(qr.to_s[0..21]).to be == "xxxxxxx xxx   xxxxxxx\n"
	end
	
	it "creates a QR code with level H and size 1" do
		expect(QRCode::Encoder::Code.build("DUNCAN", mode: :alphanumeric).mode).to be == :mode_alpha_numk
		
		expect do
			QRCode::Encoder::Code.build("Duncan", mode: :alphanumeric)
		end.to raise_exception(ArgumentError)
	end
	
	it "automatically uses numeric mode" do
		# When digit only automatically uses numeric mode, default ecc level is :h
		digits = QRCode::Encoder::Code.build("1" * 17) # Version 1, numeric mode, ECC h
		expect(digits.version).to be == 1
		expect(digits.mode).to be == :mode_number
		expect(digits.error_correction_level).to be == :h
		# When alpha automatically works
		alpha = QRCode::Encoder::Code.build("X" * 10) # Version 1, alpha mode, ECC h
		expect(alpha.version).to be == 1
		expect(alpha.mode).to be == :mode_alpha_numk
		expect(alpha.error_correction_level).to be == :h
		# Generic should use binary
		binary = QRCode::Encoder::Code.build("x" * 7) # Version 1, 8bit mode, ECC h
		expect(binary.version).to be == 1
		expect(binary.mode).to be == :mode_8bit_byte
		expect(binary.error_correction_level).to be == :h
	end
	
	it "creates a QR code with level H and size 2" do
		data = "279042272585972554922067893753871413584876543211601021503002"
		
		qr = QRCode::Encoder::Code.build(data, size: 2, level: :m, mode: :number)
		expect(qr.to_s[0..25]).to be == "xxxxxxx   x x x   xxxxxxx\n"
	end
	
	it "does not throw an error for valid inputs" do
		QRCode::Encoder::Code.build("2 1058 657682")
		QRCode::Encoder::Code.build("40952", size: 1, level: :h)
		QRCode::Encoder::Code.build("40932", size: 1, level: :h)
		QRCode::Encoder::Code.build("", size: 1, level: :h)
		QRCode::Encoder::Code.build("0", size: 1, level: :h)
	end
	
	it "raises an error for exceeding max size" do
		expect do
			QRCode::Encoder::Code.build("duncan", size: 41)
		end.to raise_exception(ArgumentError)
	end
	
	it "returns the error correction level" do
		# attr_reader was wrong
		expect(QRCode::Encoder::Code.build("a", level: :h).error_correction_level).to be == :h
	end
	
	it "returns the version table" do
		# tables in QRCode::Encoder::Code::QRMAXBITS wasn't updated to support greater versions
		expect(QRCode::Encoder::Code.build("1" * 289, level: :h, mode: :number).version).to be == 11
		expect(QRCode::Encoder::Code.build("A" * 175, level: :h, mode: :alphanumeric).version).to be == 11
		expect(QRCode::Encoder::Code.build("a" * 383, level: :h, mode: :byte_8bit).version).to be == 21
	end
	
	it "returns the levels" do
		QRCode::Encoder::Code.build("duncan", level: :l)
		QRCode::Encoder::Code.build("duncan", level: :m)
		QRCode::Encoder::Code.build("duncan", level: :q)
		QRCode::Encoder::Code.build("duncan", level: :h)
		
		%w[a b c d e f g i j k n o p r s t u v w x y z].each do |ltr|
			expect do
				QRCode::Encoder::Code.build("duncan", level: ltr.to_sym)
			end.to raise_exception(ArgumentError)
		end
	end
	
	it "supports UTF-8" do
		qr = QRCode::Encoder::Code.build("тест")
		expect(qr.modules).to be == MATRIX_UTF8_RU_TEST
	end
	
	it "supports large integers" do
		QRCode::Encoder::Code.build((1 << 64).to_s, mode: :number)
		QRCode::Encoder::Code.build(((1 << 64) + 1).to_s, mode: :number)
	end
	
	it "handles code length overflows" do
		QRCode::Encoder::Code.build("s" * 220)
		QRCode::Encoder::Code.build("s" * 195)
	end
end
