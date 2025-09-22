require_relative "../test_helper"

class RegresionTests < Minitest::Test
  # Rs block information was incomplete.
  def test_code_length_overflow_bug
    QRCode::QRCode.new("s" * 220)
    QRCode::QRCode.new("s" * 195)
  end
end
