# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2008-2025, by Duncan Robertson.
# Copyright, 2011, by Daniel Schierbeck.
# Copyright, 2011, by Gioele Barabucci.
# Copyright, 2012-2015, by Björn Blomqvist.
# Copyright, 2012, by xn.
# Copyright, 2013, by Yauhen Kharuzhy.
# Copyright, 2014, by Sean Doig.
# Copyright, 2015, by Tonči Damjanić.
# Copyright, 2015-2016, by Bjorn Blomqvist.
# Copyright, 2015-2016, by Fabio Napoleoni.
# Copyright, 2020, by Nathaniel Roman.
# Copyright, 2021, by Simon Schrape.
# Copyright, 2021, by Sam Sayer.
# Copyright, 2025, by Samuel Williams.

require_relative "constants"
require_relative "math"
require_relative "polynomial"
require_relative "util"
require_relative "bit_buffer"
require_relative "rs_block"
require_relative "segment"

module QRCode
	module Encoder
		# == Creation
		#
		# QRCode objects expect only one required constructor parameter
		# and an optional hash of any other. Here's a few examples:
		#
		#  qr = QRCode::Encoder::Code.new('hello world')
		#  qr = QRCode::Encoder::Code.new('hello world', size: 1, level: :m, mode: :alphanumeric)
		#
		class Code
			attr_reader :modules, :module_count, :version, :segments
			
			# Alias for module_count - the width/height of the QR code square
			alias_method :size, :module_count
			
			# Factory method to build QR code from data
			# @parameter data [String, Array] The data to encode
			# @parameter level [Symbol] Error correction level (:l, :m, :q, :h)
			# @parameter mode [Symbol] Encoding mode (:auto, :number, :alphanumeric, :byte_8bit)
			# @parameter size [Integer] QR code version (auto-detected if not specified)
			# @parameter max_size [Integer] Maximum allowed version
			def self.build(data, level: :h, mode: :auto, size: nil, max_size: nil)
				segments = Segment.build(data, mode: mode)
				new(segments, level: level, size: size, max_size: max_size)
			end
			
			# Simple constructor that takes an array of segments
			# @parameter segments [Array<Segment>] Array of segments to encode
			# @parameter level [Symbol] Error correction level (:l, :m, :q, :h)
			# @parameter size [Integer] QR code version (auto-detected if not specified)
			# @parameter max_size [Integer] Maximum allowed version
			def initialize(segments, level: :h, size: nil, max_size: nil)
				@segments = Array(segments)
				@error_correct_level = ERROR_CORRECT_LEVEL[level]
				
				unless @error_correct_level
					raise ArgumentError, "Unknown error correction level `#{level.inspect}`"
				end
				
				max_size ||= Encoder::Util.max_size
				calculated_size = size || minimum_version(limit: max_size)
				
				if calculated_size > max_size
					raise ArgumentError, "Given size greater than maximum possible size of #{max_size}"
				end
				
				@version = calculated_size
				@module_count = @version * 4 + POSITION_PATTERN_LENGTH
				@modules = Array.new(@module_count)
				@data_cache = nil
				make
			end
			
			# <tt>checked?</tt> is called with a +col+ and +row+ parameter. This will
			# return true or false based on whether that coordinate exists in the
			# matrix returned. It would normally be called while iterating through
			# <tt>modules</tt>. A simple example would be:
			#
			#  instance.checked?( 10, 10 ) => true
			#
			def checked?(row, col)
				if !row.between?(0, @module_count - 1) || !col.between?(0, @module_count - 1)
					raise RuntimeError, "Invalid row/column pair: #{row}, #{col}"
				end
				@modules[row][col]
			end
			
			# This is a public method that returns the QR Code you have
			# generated as a string. It will not be able to be read
			# in this format by a QR Code reader, but will give you an
			# idea if the final outout. It takes two optional args
			# +:dark+ and +:light+ which are there for you to choose
			# how the output looks. Here's an example of it's use:
			#
			#  instance.to_s =>
			#  xxxxxxx x  x x   x x  xx  xxxxxxx
			#  x     x  xxx  xxxxxx xxx  x     x
			#  x xxx x  xxxxx x       xx x xxx x
			#
			#  instance.to_s( dark: 'E', light: 'Q' ) =>
			#  EEEEEEEQEQQEQEQQQEQEQQEEQQEEEEEEE
			#  EQQQQQEQQEEEQQEEEEEEQEEEQQEQQQQQE
			#  EQEEEQEQQEEEEEQEQQQQQQQEEQEQEEEQE
			#
			def to_s(*args)
				options = extract_options!(args)
				dark = options[:dark] || "x"
				light = options[:light] || " "
				quiet_zone_size = options[:quiet_zone_size] || 0
				
				rows = []
				
				@modules.each do |row|
					cols = light * quiet_zone_size
					row.each do |col|
						cols += (col ? dark : light)
					end
					rows << cols
				end
				
				quiet_zone_size.times do
					rows.unshift(light * (rows.first.length / light.size))
					rows << light * (rows.first.length / light.size)
				end
				rows.join("\n")
			end
			
			# Public overide as default inspect is very verbose
			#
			#  QRCode::Encoder::Code.new('my string to generate', size: 4, level: :h)
			#  => QRCodeCore: @data='my string to generate', @error_correct_level=2, @version=4, @module_count=33
			#
			def inspect
				"QRCodeCore: @segments=#{@segments.size} segments, @error_correct_level=#{@error_correct_level}, @version=#{@version}, @module_count=#{@module_count}"
			end
			
			# Return a symbol for current error connection level
			def error_correction_level
				ERROR_CORRECT_LEVEL.invert[@error_correct_level]
			end
			
			# Return true if this QR Code includes multiple encoded segments
			def multi_segment?
				@segments.size > 1
			end
			
			# Return the primary mode used (first segment's mode)
			def mode
				@segments.first&.mode || :mode_8bit_byte
			end
			
			protected
			
			def make # :nodoc:
				prepare_common_patterns
				make_impl(false, get_best_mask_pattern)
			end
			
			private
			
			def prepare_common_patterns # :nodoc:
				@modules.map! {|row| Array.new(@module_count)}
				
				place_position_probe_pattern(0, 0)
				place_position_probe_pattern(@module_count - 7, 0)
				place_position_probe_pattern(0, @module_count - 7)
				place_position_adjust_pattern
				place_timing_pattern
				
				@common_patterns = @modules.map(&:clone)
			end
			
			def make_impl(test, mask_pattern) # :nodoc:
				@modules = @common_patterns.map(&:clone)
				
				place_format_info(test, mask_pattern)
				place_version_info(test) if @version >= 7
				
				if @data_cache.nil?
					@data_cache = Code.create_data(
						@version, @error_correct_level, @segments
					)
				end
				
				map_data(@data_cache, mask_pattern)
			end
			
			def place_position_probe_pattern(row, col) # :nodoc:
				(-1..7).each do |r|
					next unless (row + r).between?(0, @module_count - 1)
					
					(-1..7).each do |c|
						next unless (col + c).between?(0, @module_count - 1)
						
						is_vert_line = r.between?(0, 6) && (c == 0 || c == 6)
						is_horiz_line = c.between?(0, 6) && (r == 0 || r == 6)
						is_square = r.between?(2, 4) && c.between?(2, 4)
						
						is_part_of_probe = is_vert_line || is_horiz_line || is_square
						@modules[row + r][col + c] = is_part_of_probe
					end
				end
			end
			
			def get_best_mask_pattern # :nodoc:
				min_lost_point = 0
				pattern = 0
				
				8.times do |i|
					make_impl(true, i)
					lost_point = Encoder::Util.get_lost_points(modules)
					
					if i == 0 || min_lost_point > lost_point
						min_lost_point = lost_point
						pattern = i
					end
				end
				pattern
			end
			
			def place_timing_pattern # :nodoc:
				(8...@module_count - 8).each do |i|
					@modules[i][6] = @modules[6][i] = i % 2 == 0
				end
			end
			
			def place_position_adjust_pattern # :nodoc:
				positions = Encoder::Util.get_pattern_positions(@version)
				
				positions.each do |row|
					positions.each do |col|
						next unless @modules[row][col].nil?
						
						(-2..2).each do |r|
							(-2..2).each do |c|
								is_part_of_pattern = r.abs == 2 || c.abs == 2 || (r == 0 && c == 0)
								@modules[row + r][col + c] = is_part_of_pattern
							end
						end
					end
				end
			end
			
			def place_version_info(test) # :nodoc:
				bits = Encoder::Util.get_bch_version(@version)
				
				18.times do |i|
					mod = !test && ((bits >> i) & 1) == 1
					@modules[(i / 3).floor][ i % 3 + @module_count - 8 - 3 ] = mod
					@modules[i % 3 + @module_count - 8 - 3][ (i / 3).floor ] = mod
				end
			end
			
			def place_format_info(test, mask_pattern) # :nodoc:
				data = (@error_correct_level << 3 | mask_pattern)
				bits = Encoder::Util.get_bch_format_info(data)
				
				FORMAT_INFO_LENGTH.times do |i|
					mod = !test && ((bits >> i) & 1) == 1
					
					# vertical
					row = if i < 6
						i
					elsif i < 8
						i + 1
					else
						@module_count - 15 + i
					end
					@modules[row][8] = mod
					
					# horizontal
					col = if i < 8
						@module_count - i - 1
					elsif i < 9
						15 - i - 1 + 1
					else
						15 - i - 1
					end
					@modules[8][col] = mod
				end
				
				# fixed module
				@modules[@module_count - 8][8] = !test
			end
			
			def map_data(data, mask_pattern) # :nodoc:
				inc = -1
				row = @module_count - 1
				bit_index = 7
				byte_index = 0
				
				(@module_count - 1).step(1, -2) do |col|
					col -= 1 if col <= 6
					
					loop do
						2.times do |c|
							if @modules[row][col - c].nil?
								dark = false
								if byte_index < data.size && !data[byte_index].nil?
									dark = ((Encoder::Util.rszf(data[byte_index], bit_index) & 1) == 1)
								end
								mask = Encoder::Util.get_mask(mask_pattern, row, col - c)
								dark = !dark if mask
								@modules[row][ col - c ] = dark
								bit_index -= 1
								
								if bit_index == -1
									byte_index += 1
									bit_index = 7
								end
							end
						end
						
						row += inc
						
						if row < 0 || @module_count <= row
							row -= inc
							inc = -inc
							break
						end
					end
				end
			end
			
			def minimum_version(limit: Encoder::Util.max_size, version: 1)
				raise RuntimeError, "Data length exceed maximum capacity of version #{limit}" if version > limit
				
				max_size_bits = MAX_BITS[error_correction_level][version - 1]
				
				size_bits = @segments.sum {|segment| segment.bit_size(version)}
				
				return version if size_bits < max_size_bits
				
				minimum_version(limit: limit, version: version + 1)
			end
			
			def extract_options!(arr) # :nodoc:
				arr.last.is_a?(::Hash) ? arr.pop : {}
			end
			
			class << self
				def count_max_data_bits(rs_blocks) # :nodoc:
					max_data_bytes = rs_blocks.reduce(0) do |sum, rs_block|
						sum + rs_block.data_count
					end
					
					max_data_bytes * 8
				end
				
				def create_data(version, error_correct_level, segments) # :nodoc:
					rs_blocks = Encoder::RSBlock.get_rs_blocks(version, error_correct_level)
					max_data_bits = Code.count_max_data_bits(rs_blocks)
					buffer = Encoder::BitBuffer.new(version)
					
					segments.each {|segment| segment.write(buffer)}
					buffer.end_of_message(max_data_bits)
					
					if buffer.get_length_in_bits > max_data_bits
						raise RuntimeError, "code length overflow. (#{buffer.get_length_in_bits}>#{max_data_bits}). (Try a larger size!)"
					end
					
					buffer.pad_until(max_data_bits)
					
					Code.create_bytes(buffer, rs_blocks)
				end
				
				def create_bytes(buffer, rs_blocks) # :nodoc:
					offset = 0
					max_dc_count = 0
					max_ec_count = 0
					dcdata = Array.new(rs_blocks.size)
					ecdata = Array.new(rs_blocks.size)
					
					rs_blocks.each_with_index do |rs_block, r|
						dc_count = rs_block.data_count
						ec_count = rs_block.total_count - dc_count
						max_dc_count = [max_dc_count, dc_count].max
						max_ec_count = [max_ec_count, ec_count].max
						
						dcdata_block = Array.new(dc_count)
						dcdata_block.size.times do |i|
							dcdata_block[i] = 0xff & buffer.buffer[i + offset]
						end
						dcdata[r] = dcdata_block
						
						offset += dc_count
						rs_poly = Encoder::Util.get_error_correct_polynomial(ec_count)
						raw_poly = Encoder::Polynomial.new(dcdata[r], rs_poly.get_length - 1)
						mod_poly = raw_poly.mod(rs_poly)
						
						ecdata_block = Array.new(rs_poly.get_length - 1)
						ecdata_block.size.times do |i|
							mod_index = i + mod_poly.get_length - ecdata_block.size
							ecdata_block[i] = (mod_index >= 0) ? mod_poly.get(mod_index) : 0
						end
						ecdata[r] = ecdata_block
					end
					
					total_code_count = rs_blocks.reduce(0) do |sum, rs_block|
						sum + rs_block.total_count
					end
					
					data = Array.new(total_code_count)
					index = 0
					
					max_dc_count.times do |i|
						rs_blocks.size.times do |r|
							if i < dcdata[r].size
								data[index] = dcdata[r][i]
								index += 1
							end
						end
					end
					
					max_ec_count.times do |i|
						rs_blocks.size.times do |r|
							if i < ecdata[r].size
								data[index] = ecdata[r][i]
								index += 1
							end
						end
					end
					
					data
				end
			end
		end
	end
end
