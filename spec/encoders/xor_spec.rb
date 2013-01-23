require 'spec_helper'
require 'ronin/encoders/xor'

describe Encoders::XOR do
  before(:all) do
    @data = "\x00\x01\x90ABC123[]{}'"
  end

  it "should encode-out unwanted characters" do
    disallow = [0x00, 0x01, 0x90]
    xor = Encoders::XOR.new(disallow: disallow)

    xor.encode(@data).each_byte do |b|
      disallow.should_not include(b)
    end
  end
end
