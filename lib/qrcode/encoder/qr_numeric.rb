# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2015, by Tonči Damjanić.
# Copyright, 2015-2016, by Bjorn Blomqvist.
# Copyright, 2015-2016, by Fabio Napoleoni.
# Copyright, 2016, by Christian Campbell.
# Copyright, 2019-2021, by Duncan Robertson.
# Copyright, 2021, by Sam Sayer.
# Copyright, 2025, by Samuel Williams.

module QRCode
	NUMERIC = %w[0 1 2 3 4 5 6 7 8 9].freeze
	
	class QRNumeric
		def initialize(data)
			raise ArgumentError, "Not a numeric string `#{data}`" unless QRNumeric.valid_data?(data)
			
			@data = data
		end
		
		def self.valid_data?(data)
			(data.chars - NUMERIC).empty?
		end
		
		def write(buffer)
			buffer.numeric_encoding_start(@data.size)
			
			@data.size.times do |i|
				if i % 3 == 0
					chars = @data[i, 3]
					bit_length = get_bit_length(chars.length)
					buffer.put(get_code(chars), bit_length)
				end
			end
		end
		
				private
		
		NUMBER_LENGTH = {
			3 => 10,
			2 => 7,
			1 => 4
		}.freeze
		
		def get_bit_length(length)
			NUMBER_LENGTH[length]
		end
		
		def get_code(chars)
			chars.to_i
		end
	end
end
