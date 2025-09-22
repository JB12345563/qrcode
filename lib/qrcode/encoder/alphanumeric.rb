# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2012, by Björn Blomqvist.
# Copyright, 2012, by xn.
# Copyright, 2019-2021, by Duncan Robertson.
# Copyright, 2025, by Samuel Williams.

module QRCode
	module Encoder
		ALPHANUMERIC = [
			"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F", "G", "H", "I",
			"J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", " ", "$",
			"%", "*", "+", "-", ".", "/", ":"
		].freeze
		
		class Alphanumeric
			def initialize(data)
				unless Encoder::Alphanumeric.valid_data?(data)
					raise ArgumentError, "Not a alpha numeric uppercase string `#{data}`"
				end
				
				@data = data
			end
			
			def self.valid_data?(data)
				(data.chars - ALPHANUMERIC).empty?
			end
			
			def write(buffer)
				buffer.alphanumeric_encoding_start(@data.size)
				
				@data.size.times do |i|
					if i % 2 == 0
						if i == (@data.size - 1)
							value = ALPHANUMERIC.index(@data[i])
							buffer.put(value, 6)
						else
							value = (ALPHANUMERIC.index(@data[i]) * 45) + ALPHANUMERIC.index(@data[i + 1])
							buffer.put(value, 11)
						end
					end
				end
			end
		end
	end
end
