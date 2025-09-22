# frozen_string_literal: true

require "qrcode"
require "qrcode"

describe QRCode::QRSegment do
  PAYLOAD = [{data: "byteencoded", mode: :byte_8bit}, {data: "A1" * 107, mode: :alphanumeric}, {data: "1" * 498, mode: :number}]

  it "handles multi payloads" do
    QRCode::QRCode.new(PAYLOAD, level: :l)
    QRCode::QRCode.new(PAYLOAD, level: :m)
    QRCode::QRCode.new(PAYLOAD, level: :q)
    QRCode::QRCode.new(PAYLOAD)
    QRCode::QRCode.new(PAYLOAD, level: :l, max_size: 22)
  end

  it "handles invalid code configs" do
    expect do
      QRCode::QRCode.new(:not_a_string_or_array)
    end.to raise_exception(QRCode::QRCodeArgumentError)

    expect do
      QRCode::QRCode.new(PAYLOAD << :not_a_segment)
    end.to raise_exception(QRCode::QRCodeArgumentError)
  end
end
