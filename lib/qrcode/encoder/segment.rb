# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021, by Sam Sayer.
# Copyright, 2021-2025, by Duncan Robertson.
# Copyright, 2025, by Samuel Williams.

require_relative "constants"
require_relative "numeric"
require_relative "alphanumeric"
require_relative "multi"
require_relative "byte_8bit"
require_relative "util"

module QRCode
	module Encoder
		class Segment
			attr_reader :data, :mode
			
			def initialize(data:, mode: nil)
				@data = data
				@mode = MODE_NAME.dig(mode&.to_sym)
				
				# If mode is not explicitly found choose mode according to data type
				@mode ||= if Encoder::Numeric.valid_data?(@data)
					MODE_NAME[:number]
				elsif Encoder::Alphanumeric.valid_data?(@data)
					MODE_NAME[:alphanumeric]
				else
					MODE_NAME[:byte_8bit]
				end
			end
			
			def size(version)
				4 + header_size(version) + content_size
			end
			
			def header_size(version)
				Encoder::Util.get_length_in_bits(MODE[mode], version)
			end
			
			def content_size
				chunk_size, bit_length, extra = case mode
				when :mode_number
					[3, Numeric::NUMBER_LENGTH[3], Numeric::NUMBER_LENGTH[data_length % 3] || 0]
				when :mode_alpha_numk
					[2, 11, 6]
				when :mode_8bit_byte
					[1, 8, 0]
				end
				
				(data_length / chunk_size) * bit_length + (((data_length % chunk_size) == 0) ? 0 : extra)
			end
			
			def writer
				case mode
				when :mode_number
					Encoder::Numeric.new(data)
				when :mode_alpha_numk
					Encoder::Alphanumeric.new(data)
				when :mode_multi
					Encoder::Multi.new(data)
				else
					Encoder::Byte8bit.new(data)
				end
			end
			
			private
			
			def data_length
				data.bytesize
			end
		end
	end
end
