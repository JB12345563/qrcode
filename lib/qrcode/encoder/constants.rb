# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2008-2025, by Duncan Robertson.
# Copyright, 2025, by Samuel Williams.

module QRCode
	MODE = {
		mode_number: 1 << 0,      # 1 (binary: 0001)
		mode_alpha_numk: 1 << 1,  # 2 (binary: 0010)
		mode_8bit_byte: 1 << 2    # 4 (binary: 0100)
	}.freeze
	
	MODE_NAME = {
		number: :mode_number,
		alphanumeric: :mode_alpha_numk,
		byte_8bit: :mode_8bit_byte,
		multi: :mode_multi
	}.freeze
	
	ERROR_CORRECT_LEVEL = {
		l: 1,
		m: 0,
		q: 3,
		h: 2
	}.freeze
	
	MASK_PATTERN = {
		pattern000: 0,
		pattern001: 1,
		pattern010: 2,
		pattern011: 3,
		pattern100: 4,
		pattern101: 5,
		pattern110: 6,
		pattern111: 7
	}.freeze
	
	MASK_COMPUTATIONS = [
		proc { |i, j| (i + j) % 2 == 0 },
		proc { |i, j| i % 2 == 0 },
		proc { |i, j| j % 3 == 0 },
		proc { |i, j| (i + j) % 3 == 0 },
		proc { |i, j| ((i / 2) + (j / 3)) % 2 == 0 },
		proc { |i, j| ((i * j) % 2) + ((i * j) % 3) == 0 },
		proc { |i, j| (((i * j) % 2) + ((i * j) % 3)) % 2 == 0 },
		proc { |i, j| (((i * j) % 3) + ((i + j) % 2)) % 2 == 0 }
	].freeze
	
	POSITION_PATTERN_LENGTH = (7 + 1) * 2 + 1
	FORMAT_INFO_LENGTH = 15
	
	# max bits by version
	# version 1: 26 x 26 = 676
	# version 40: 177 x 177 = 31329
	# 31329 / 8 = 3916 bytes
	MAX_BITS = {
		l: [152, 272, 440, 640, 864, 1088, 1248, 1552, 1856, 2192, 2592, 2960, 3424, 3688, 4184, 4712, 5176, 5768, 6360, 6888, 7456, 8048, 8752, 9392, 10208, 10960, 11744, 12248, 13048, 13880, 14744, 15640, 16568, 17528, 18448, 19472, 20528, 21616, 22496, 23648],
		m: [128, 224, 352, 512, 688, 864, 992, 1232, 1456, 1728, 2032, 2320, 2672, 2920, 3320, 3624, 4056, 4504, 5016, 5352, 5712, 6256, 6880, 7312, 8000, 8496, 9024, 9544, 10136, 10984, 11640, 12328, 13048, 13800, 14496, 15312, 15936, 16816, 17728, 18672],
		q: [104, 176, 272, 384, 496, 608, 704, 880, 1056, 1232, 1440, 1648, 1952, 2088, 2360, 2600, 2936, 3176, 3560, 3880, 4096, 4544, 4912, 5312, 5744, 6032, 6464, 6968, 7288, 7880, 8264, 8920, 9368, 9848, 10288, 10832, 11408, 12016, 12656, 13328],
		h: [72, 128, 208, 288, 368, 480, 528, 688, 800, 976, 1120, 1264, 1440, 1576, 1784, 2024, 2264, 2504, 2728, 3080, 3248, 3536, 3712, 4112, 4304, 4768, 5024, 5288, 5608, 5960, 6344, 6760, 7208, 7688, 7888, 8432, 8768, 9136, 9776, 10208]
	}.freeze
	
	class ArgumentError < ::ArgumentError; end
	
	class RuntimeError < ::RuntimeError; end
end
