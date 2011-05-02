require 'spec_helper'
require 'ronin/encoders/encoder'

describe Encoders::Encoder do
  subject { described_class.new(:name => 'test') }

  let(:data) { 'some data' }

  it "should require a name" do
    encoder = described_class.new
    encoder.should_not be_valid

    encoder = described_class.new(:name => 'encoder')
    encoder.should be_valid
  end

  describe "#encode" do
    it { should respond_to(:encode) }

    it "should return the data to be encoded by default" do
      subject.encode(data).should == data
    end
  end

  it "should have a custom inspect method" do
    subject.inspect.should == '#<Ronin::Encoders::Encoder: test>'
  end
end
