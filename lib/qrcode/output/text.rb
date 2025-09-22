# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Samuel Williams.

module QRCode
	module Output
		# Text renderer using Unicode half-height block characters
		class Text
			# Unicode block characters for different combinations
			BLOCKS = {
				[false, false] => " ",   # Both light - single space
				[false, true]  => "▄",   # Top light, bottom dark
				[true, false]  => "▀",   # Top dark, bottom light  
				[true, true]   => "█"    # Both dark - full block
			}.freeze
			
			attr_reader :qrcode, :border
			
			def initialize(qrcode, border: 2)
				@qrcode = qrcode
				@border = border
			end
			
			def render
				lines = []
				
				# Add top border
				border.times do
					lines << " " * total_width
				end
				
				# Process QR code in pairs of rows to use half-height blocks
				(0...qrcode.size).step(2) do |row|
					line = " " * border  # Left border
					
					qrcode.size.times do |col|
						top = qrcode.checked?(row, col)
						bottom = (row + 1 < qrcode.size) ? qrcode.checked?(row + 1, col) : false
						line += BLOCKS[[top, bottom]]
					end
					
					line += " " * border  # Right border
					lines << line
				end
				
				# Add bottom border
				border.times do
					lines << " " * total_width
				end
				
				lines.join("\n")
			end
			
			private
			
			def total_width
				qrcode.size + (border * 2)
			end
		end
	end
end
