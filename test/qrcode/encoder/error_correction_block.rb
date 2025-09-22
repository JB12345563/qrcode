# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Samuel Williams.

require "qrcode"

describe QRCode::Encoder::ErrorCorrectionBlock do
	it "creates block with correct attributes" do
		block = QRCode::Encoder::ErrorCorrectionBlock.new(26, 19)
		expect(block.total_count).to be == 26
		expect(block.data_count).to be == 19
	end
	
	it "calculates error correction count correctly" do
		block = QRCode::Encoder::ErrorCorrectionBlock.new(26, 19)
		error_count = block.total_count - block.data_count
		expect(error_count).to be == 7  # 26 - 19 = 7 error correction codewords
	end
	
	describe "ErrorCorrectionBlock.for" do
		it "creates blocks for version 1, level L" do
			blocks = QRCode::Encoder::ErrorCorrectionBlock.for(1, QRCode::Encoder::ERROR_CORRECTION_LEVEL[:l])
			expect(blocks.size).to be == 1
			expect(blocks.first.total_count).to be == 26
			expect(blocks.first.data_count).to be == 19
		end
		
		it "creates blocks for version 1, level H" do
			blocks = QRCode::Encoder::ErrorCorrectionBlock.for(1, QRCode::Encoder::ERROR_CORRECTION_LEVEL[:h])
			expect(blocks.size).to be == 1
			expect(blocks.first.total_count).to be == 26
			expect(blocks.first.data_count).to be == 9  # Much less data for high error correction
		end
		
		it "creates multiple blocks for higher versions" do
			# Version 5 with level L should have 1 block
			blocks_v5_l = QRCode::Encoder::ErrorCorrectionBlock.for(5, QRCode::Encoder::ERROR_CORRECTION_LEVEL[:l])
			expect(blocks_v5_l.size).to be == 1
			
			# Higher versions with higher error correction often have multiple blocks
			blocks_v10_h = QRCode::Encoder::ErrorCorrectionBlock.for(10, QRCode::Encoder::ERROR_CORRECTION_LEVEL[:h])
			expect(blocks_v10_h.size).to be >= 1
		end
		
		it "raises error for invalid version" do
			expect do
				QRCode::Encoder::ErrorCorrectionBlock.for(0, QRCode::Encoder::ERROR_CORRECTION_LEVEL[:l])
			end.to raise_exception(RuntimeError)
			
			expect do
				QRCode::Encoder::ErrorCorrectionBlock.for(41, QRCode::Encoder::ERROR_CORRECTION_LEVEL[:l])
			end.to raise_exception(RuntimeError)
		end
		
		it "raises error for invalid error correction level" do
			expect do
				QRCode::Encoder::ErrorCorrectionBlock.for(1, 999)
			end.to raise_exception(RuntimeError)
		end
	end
	
	describe "ErrorCorrectionBlock.table_entry_for" do
		it "returns correct table entry for version 1" do
			entry_l = QRCode::Encoder::ErrorCorrectionBlock.table_entry_for(1, QRCode::Encoder::ERROR_CORRECTION_LEVEL[:l])
			expect(entry_l).to be == [1, 26, 19]
			
			entry_h = QRCode::Encoder::ErrorCorrectionBlock.table_entry_for(1, QRCode::Encoder::ERROR_CORRECTION_LEVEL[:h])
			expect(entry_h).to be == [1, 26, 9]
		end
		
		it "returns different entries for different versions" do
			entry_v1 = QRCode::Encoder::ErrorCorrectionBlock.table_entry_for(1, QRCode::Encoder::ERROR_CORRECTION_LEVEL[:m])
			entry_v2 = QRCode::Encoder::ErrorCorrectionBlock.table_entry_for(2, QRCode::Encoder::ERROR_CORRECTION_LEVEL[:m])
			
			expect(entry_v1).not.to be == entry_v2
			expect(entry_v2[1]).to be > entry_v1[1]  # Version 2 should have more total codewords
		end
		
		it "shows error correction trade-off" do
			# For same version, higher error correction = less data capacity
			v5_l = QRCode::Encoder::ErrorCorrectionBlock.table_entry_for(5, QRCode::Encoder::ERROR_CORRECTION_LEVEL[:l])
			v5_h = QRCode::Encoder::ErrorCorrectionBlock.table_entry_for(5, QRCode::Encoder::ERROR_CORRECTION_LEVEL[:h])
			
			# Same total codewords, but L level has more data capacity than H level
			expect(v5_l[2]).to be > v5_h[2]  # L has more data codewords than H
		end
	end
	
	describe "error correction levels" do
		it "has correct error correction percentages" do
			# Test that higher levels provide more error correction
			v10_blocks = {}
			[:l, :m, :q, :h].each do |level|
				blocks = QRCode::Encoder::ErrorCorrectionBlock.for(10, QRCode::Encoder::ERROR_CORRECTION_LEVEL[level])
				total_data = blocks.sum(&:data_count)
				total_codewords = blocks.sum(&:total_count)
				error_codewords = total_codewords - total_data
				error_percentage = (error_codewords.to_f / total_codewords * 100).round
				
				v10_blocks[level] = error_percentage
			end
			
			# Error correction should increase: L < M < Q < H
			expect(v10_blocks[:l]).to be < v10_blocks[:m]
			expect(v10_blocks[:m]).to be < v10_blocks[:q]
			expect(v10_blocks[:q]).to be < v10_blocks[:h]
		end
	end
end
