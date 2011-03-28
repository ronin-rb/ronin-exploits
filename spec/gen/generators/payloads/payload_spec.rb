require 'spec_helper'
require 'ronin/gen/generators/payloads/payload'
require 'ronin/payloads/payload'

require 'gen/generators/payloads/payload_examples'
require 'tmpdir'
require 'fileutils'

describe Gen::Generators::Payloads::Payload do
  before(:all) do
    @path = File.join(Dir.tmpdir,'generated_payload.rb')

    described_class.generate(
      {:leverages => ['shell']},
      [@path]
    )
  end

  subject { Payloads::Payload.load_object(@path) }

  it_should_behave_like "a Payload"

  it "should define a Payload" do
    subject.class.should == Payloads::Payload
  end

  after(:all) { FileUtils.rm(@path) }
end
