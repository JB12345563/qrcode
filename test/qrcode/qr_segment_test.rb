# frozen_string_literal: true

require_relative "../test_helper"

class QRCode::QRSegmentTest < Minitest::Test
  PAYLOAD = [{data: "byteencoded", mode: :byte_8bit}, {data: "A1" * 107, mode: :alphanumeric}, {data: "1" * 498, mode: :number}]

  def test_multi_payloads
    QRCode::QRCode.new(PAYLOAD, level: :l)
    QRCode::QRCode.new(PAYLOAD, level: :m)
    QRCode::QRCode.new(PAYLOAD, level: :q)
    QRCode::QRCode.new(PAYLOAD)
    QRCode::QRCode.new(PAYLOAD, level: :l, max_size: 22)
  rescue => e
    flunk(e)
  end

  def test_invalid_code_configs
    assert_raises(QRCode::QRCodeArgumentError) {
      QRCode::QRCode.new(:not_a_string_or_array)
      QRCode::QRCode.new(PAYLOAD << :not_a_segment)
    }
  end
end
