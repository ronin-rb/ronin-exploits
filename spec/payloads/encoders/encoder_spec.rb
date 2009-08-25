require 'ronin/payloads/encoders/encoder'

require 'spec_helper'

describe Payloads::Encoders::Encoder do
  before(:all) do
    @encoder = Payloads::Encoders::Encoder.new(:name => 'test')
    @data = 'some data'
  end

  it "should require a name" do
    encoder = Payloads::Encoders::Encoder.new
    encoder.should_not be_valid

    encoder = Payloads::Encoders::Encoder.new(:name => 'encoder')
    encoder.should be_valid
  end

  it "should provide a #call method" do
    @encoder.respond_to?(:call).should == true
  end

  it "should return the data to be encoded by default" do
    @encoder.call(@data).should == @data
  end

  it "should have a custom inspect method" do
    @encoder.inspect.should == '#<Ronin::Payloads::Encoders::Encoder: test>'
  end
end
