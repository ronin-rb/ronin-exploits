require 'spec_helper'
require 'ronin/payloads/encoder'

describe Payloads::Encoder do
  before(:all) do
    @encoder = Payloads::Encoder.new(:name => 'test')
    @data = 'some data'
  end

  it "should require a name" do
    encoder = Payloads::Encoder.new
    encoder.should_not be_valid

    encoder = Payloads::Encoder.new(:name => 'encoder')
    encoder.should be_valid
  end

  it "should provide a #encode method" do
    @encoder.should respond_to(:encode)
  end

  it "should return the data to be encoded by default" do
    @encoder.encode(@data).should == @data
  end

  it "should have a custom inspect method" do
    @encoder.inspect.should == '#<Ronin::Payloads::Encoder: test>'
  end
end
