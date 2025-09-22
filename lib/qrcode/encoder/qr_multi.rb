# frozen_string_literal: true

module QRCode
  class QRMulti
    def initialize(data)
      @data = data
    end

    def write(buffer)
      @data.each { |seg| seg.writer.write(buffer) }
    end
  end
end
