# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2008-2025, by Duncan Robertson.
# Copyright, 2012-2013, by Björn Blomqvist.
# Copyright, 2012, by xn.
# Copyright, 2015, by Tonči Damjanić.
# Copyright, 2015, by Bjorn Blomqvist.
# Copyright, 2020, by Nathaniel Roman.
# Copyright, 2025, by Samuel Williams.

require_relative "constants"
require_relative "util"

module QRCode
	module Encoder
		class BitBuffer
			attr_reader :buffer
			
			PAD0 = 0xEC
			PAD1 = 0x11
			
			def initialize(version)
				@version = version
				@buffer = []
				@length = 0
			end
			
			def get(index)
				byte_index = (index / 8).floor
				(Encoder::Util.rszf(@buffer[byte_index], 7 - index % 8) & 1) == 1
			end
			
			def put(num, length)
				(0...length).each do |i|
					put_bit((Encoder::Util.rszf(num, length - i - 1) & 1) == 1)
				end
			end
			
			def get_length_in_bits
				@length
			end
			
			def put_bit(bit)
				byte_index = (@length / 8).floor
				if @buffer.size <= byte_index
					@buffer << 0
				end
				
				if bit
					@buffer[byte_index] |= Encoder::Util.rszf(0x80, @length % 8)
				end
				
				@length += 1
			end
			
			def byte_encoding_start(length)
				put(MODE[:mode_8bit_byte], 4)
				put(length, Encoder::Util.get_length_in_bits(MODE[:mode_8bit_byte], @version))
			end
			
			def alphanumeric_encoding_start(length)
				put(MODE[:mode_alpha_numk], 4)
				put(length, Encoder::Util.get_length_in_bits(MODE[:mode_alpha_numk], @version))
			end
			
			def numeric_encoding_start(length)
				put(MODE[:mode_number], 4)
				put(length, Encoder::Util.get_length_in_bits(MODE[:mode_number], @version))
			end
			
			def pad_until(prefered_size)
				# Align on byte
				while get_length_in_bits % 8 != 0
					put_bit(false)
				end
				
				# Pad with padding code words
				while get_length_in_bits < prefered_size
					put(PAD0, 8)
					put(PAD1, 8) if get_length_in_bits < prefered_size
				end
			end
			
			def end_of_message(max_data_bits)
				put(0, 4) unless get_length_in_bits + 4 > max_data_bits
			end
		end
	end
end
