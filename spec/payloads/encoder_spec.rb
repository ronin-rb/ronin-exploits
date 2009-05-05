require 'ronin/payloads/encoder'

require 'spec_helper'

describe Payloads::Encoder do
  before(:all) do
    @encoder = Payloads::Encoder.new
    @data = 'some data'
  end

  it "should provide a #call method" do
    @encoder.respond_to?(:call).should == true
  end

  it "should return the data to be encoded by default" do
    @encoder.call(@data).should == @data
  end
end
