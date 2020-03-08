require 'spec_helper'
require 'ronin/encoders/encoder'

describe Encoders::Encoder do
  subject { described_class.new(name: 'test') }

  let(:data) { 'some data' }

  it "should require a name" do
    encoder = described_class.new
    expect(encoder).not_to be_valid

    encoder = described_class.new(:name => 'encoder')
    expect(encoder).to be_valid
  end

  describe "#encode" do
    it { should respond_to(:encode) }

    it "should return the data to be encoded by default" do
      expect(subject.encode(data)).to eq(data)
    end
  end

  it "should have a custom inspect method" do
    expect(subject.inspect).to eq('#<Ronin::Encoders::Encoder: test>')
  end
end
