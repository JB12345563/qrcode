# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021, by Sam Sayer.
# Copyright, 2021-2025, by Duncan Robertson.
# Copyright, 2025, by Samuel Williams.

require_relative "constants"
require_relative "util"

module QRCode
	module Encoder
		# Base segment class - defaults to binary (8-bit byte) encoding
		class Segment
			attr_reader :data
			
			def initialize(data)
				@data = data.to_s
			end
			
			def mode
				:mode_8bit_byte
			end
			
			def bit_size(version)
				4 + header_size(version) + content_size
			end
			
			def header_size(version)
				Encoder::Util.get_length_in_bits(MODE[mode], version)
			end
			
			def content_size
				@data.bytesize * 8
			end
			
			def write(buffer)
				buffer.byte_encoding_start(@data.bytesize)
				
				@data.each_byte do |b|
					buffer.put(b, 8)
				end
			end
			
			# Factory method to build segments from various data types
			# @parameter data [String, Array, Segment] The data to encode
			# @parameter mode [Symbol] Encoding mode (:auto, :number, :alphanumeric, :byte_8bit)
			# @return [Array<Segment>] Array of segments
			def self.build(data, mode: :auto)
				case data
				when String
					[create_segment_for_data(data, mode)]
				when Array
					data.map do |item|
						case item
						when Hash
							create_segment_for_data(item[:data], item[:mode] || :auto)
						when String
							create_segment_for_data(item, mode)
						when Segment
							item
						else
							raise ArgumentError, "Array elements must be Strings, Hashes with :data key, or Segments"
						end
					end
				when Segment
					[data]
				else
					raise ArgumentError, "data must be a String, Segment, or Array"
				end
			end
			
			private_class_method def self.create_segment_for_data(data, mode)
				case mode
				when :auto
					detect_optimal_segment_class(data).new(data)
				when :number, :numeric
					NumericSegment.new(data)
				when :alphanumeric, :alpha_numk
					AlphanumericSegment.new(data)
				when :byte_8bit, :binary
					Segment.new(data)
				else
					raise ArgumentError, "Unknown mode: #{mode}"
				end
			end
			
			private_class_method def self.detect_optimal_segment_class(data)
				if NumericSegment.valid_data?(data)
					NumericSegment
				elsif AlphanumericSegment.valid_data?(data)
					AlphanumericSegment
				else
					Segment
				end
			end
		end
		
		# Numeric segment - optimized for numeric data (0-9)
		class NumericSegment < Segment
			def initialize(data)
				data_str = data.to_s
				unless self.class.valid_data?(data_str)
					raise ArgumentError, "Not a numeric string `#{data_str}`"
				end
				super(data_str)
			end
			
			def self.valid_data?(data)
				data.to_s.match?(/\A\d+\z/)
			end
			
			def mode
				:mode_number
			end
			
			def content_size
				data_length = @data.length
				case data_length % 3
				when 0
					(data_length / 3) * 10
				when 1
					((data_length / 3) * 10) + 4
				when 2
					((data_length / 3) * 10) + 7
				end
			end
			
			def write(buffer)
				buffer.numeric_encoding_start(@data.size)
				
				@data.scan(/\d{1,3}/).each do |group|
					case group.length
					when 3
						buffer.put(group.to_i, 10)
					when 2
						buffer.put(group.to_i, 7)
					when 1
						buffer.put(group.to_i, 4)
					end
				end
			end
		end
		
		# Alphanumeric segment - optimized for alphanumeric data
		class AlphanumericSegment < Segment
			ALPHANUMERIC = [
				"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F", "G", "H", "I",
				"J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", " ", "$",
				"%", "*", "+", "-", ".", "/", ":"
			].freeze
			
			def initialize(data)
				data_str = data.to_s
				unless self.class.valid_data?(data_str)
					raise ArgumentError, "Not an alphanumeric string `#{data_str}`"
				end
				super(data_str)
			end
			
			def self.valid_data?(data)
				(data.to_s.chars - ALPHANUMERIC).empty?
			end
			
			def mode
				:mode_alpha_numk
			end
			
			def content_size
				(@data.size / 2.0).ceil * 11
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
