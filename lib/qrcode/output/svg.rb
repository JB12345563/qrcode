# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Samuel Williams.

module QRCode
	module Output
		# SVG renderer for scalable vector graphics
		class SVG
			attr_reader :qrcode, :cell_size, :border, :dark_color, :light_color
			
			def initialize(qrcode, cell_size: 10, border: 2, dark_color: "#000000", light_color: "#ffffff")
				@qrcode = qrcode
				@cell_size = cell_size
				@border = border
				@dark_color = dark_color
				@light_color = light_color
			end
			
			# @returns [Boolean] true if background should be transparent
			def transparent?
				@light_color.nil? || @light_color == "transparent"
			end
			
			def render
				total_size = (qrcode.size + (border * 2)) * cell_size
				
				svg = []
				svg << %[<?xml version="1.0" encoding="UTF-8"?>]
				svg << %[<svg xmlns="http://www.w3.org/2000/svg" width="#{total_size}" height="#{total_size}" viewBox="0 0 #{total_size} #{total_size}">]
				
				# Background rectangle (only if not transparent)
				unless transparent?
					svg << %[  <rect x="0" y="0" width="#{total_size}" height="#{total_size}" fill="#{light_color}"/>]
				end
				
				# Generate dark modules as rectangles
				qrcode.size.times do |row|
					qrcode.size.times do |col|
						if qrcode.checked?(row, col)
							x = (col + border) * cell_size
							y = (row + border) * cell_size
							svg << %[  <rect x="#{x}" y="#{y}" width="#{cell_size}" height="#{cell_size}" fill="#{dark_color}"/>]
						end
					end
				end
				
				svg << %[</svg>]
				svg.join("\n")
			end
		end
	end
end
