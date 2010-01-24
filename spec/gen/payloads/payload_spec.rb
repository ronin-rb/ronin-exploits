require 'ronin/gen/payloads/payload'
require 'ronin/payloads/payload'

require 'spec_helper'
require 'gen/payloads/payload_examples'

require 'tmpdir'
require 'fileutils'

describe Gen::Payloads::Payload do
  before(:all) do
    @path = File.join(Dir.tmpdir,'generated_payload.rb')

    Gen::Payloads::Payload.generate(
      {},
      [@path]
    )

    @payload = Payloads::Payload.load_from(@path)
  end

  it_should_behave_like "a Payload"

  it "should define a Payload" do
    @payload.class.should == Payloads::Payload
  end

  after(:all) do
    FileUtils.rm(@path)
  end
end
