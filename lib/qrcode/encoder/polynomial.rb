# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2008-2021, by Duncan Robertson.
# Copyright, 2025, by Samuel Williams.

require_relative "math"

module QRCode
	class Polynomial
		def initialize(num, shift)
			raise RuntimeError, "#{num.size}/#{shift}" if num.empty?
			offset = 0
			
			while offset < num.size && num[offset] == 0
				offset += 1
			end
			
			@num = Array.new(num.size - offset + shift)
			
			(0...num.size - offset).each do |i|
				@num[i] = num[i + offset]
			end
		end
		
		def get(index)
			@num[index]
		end
		
		def get_length
			@num.size
		end
		
		def multiply(e)
			num = Array.new(get_length + e.get_length - 1)
			
			(0...get_length).each do |i|
				(0...e.get_length).each do |j|
					tmp = num[i + j].nil? ? 0 : num[i + j]
					num[i + j] = tmp ^ Math.gexp(Math.glog(get(i)) + Math.glog(e.get(j)))
				end
			end
			
			Polynomial.new(num, 0)
		end
		
		def mod(e)
			if get_length - e.get_length < 0
				return self
			end
			
			ratio = Math.glog(get(0)) - Math.glog(e.get(0))
			num = Array.new(get_length)
			
			(0...get_length).each do |i|
				num[i] = get(i)
			end
			
			(0...e.get_length).each do |i|
				tmp = num[i].nil? ? 0 : num[i]
				num[i] = tmp ^ Math.gexp(Math.glog(e.get(i)) + ratio)
			end
			
			Polynomial.new(num, 0).mod(e)
		end
	end
end
