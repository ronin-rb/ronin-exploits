require 'ronin/payloads/payload'

require 'spec_helper'

describe Payloads::Payload do
  it "should require a name attribute" do
    @payload = Payloads::Payload.new(:object_path => 'test.rb')
    @payload.should_not be_valid

    @payload.name = 'test'
    @payload.should be_valid
  end

  it "should have a unique name and version" do
    @first_payload = Payloads::Payload.new(
      :object_path => 'test.rb',
      :name => 'test',
      :version => '0.0.1'
    )
    @first_payload.should be_valid

    @second_payload = Payloads::Payload.new(
      :object_path => 'other.rb',
      :name => 'test',
      :version => '0.0.1'
    )
    @second_payload.should_not be_valid

    @third_payload = Payloads::Payload.new(
      :object_path => 'other.rb',
      :name => 'test',
      :version => '0.0.2'
    )
    @third_payload.should be_valid
  end
end
