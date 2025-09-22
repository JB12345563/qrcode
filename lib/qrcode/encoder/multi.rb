# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021, by Sam Sayer.
# Copyright, 2021, by Duncan Robertson.
# Copyright, 2025, by Samuel Williams.

module QRCode
	module Encoder
		class Multi
			def initialize(data)
				@data = data
			end
			
			def write(buffer)
				@data.each {|seg| seg.writer.write(buffer)}
			end
		end
	end
end
