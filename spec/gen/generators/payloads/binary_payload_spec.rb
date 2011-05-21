require 'spec_helper'
require 'ronin/gen/generators/payloads/binary_payload'
require 'ronin/payloads/binary_payload'

require 'gen/generators/payloads/payload_examples'
require 'tmpdir'
require 'fileutils'

describe Gen::Generators::Payloads::BinaryPayload do
  before(:all) do
    @path = File.join(Dir.tmpdir,'generated_binary_payload.rb')

    described_class.generate(
      {:leverages => ['shell']},
      [@path]
    )
  end

  subject { Payloads::BinaryPayload.load_object(@path) }

  it_should_behave_like "a Payload"

  it "should define a BinaryPayload" do
    subject.class.should == Payloads::BinaryPayload
  end

  after(:all) { FileUtils.rm(@path) }
end
