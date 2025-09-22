# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2008-2021, by Duncan Robertson.
# Copyright, 2009, by Tore Darell.
# Copyright, 2012-2013, by Björn Blomqvist.
# Copyright, 2012, by xn.
# Copyright, 2013, by Yauhen Kharuzhy.
# Copyright, 2025, by Samuel Williams.

module QRCode
	class Byte8bit
		def initialize(data)
			@data = data
		end
		
		def write(buffer)
			buffer.byte_encoding_start(@data.bytesize)
			
			@data.each_byte do |b|
				buffer.put(b, 8)
			end
		end
	end
end
