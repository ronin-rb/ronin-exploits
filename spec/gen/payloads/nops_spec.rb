require 'ronin/gen/payloads/nops'
require 'ronin/payloads/nops'

require 'spec_helper'
require 'gen/payloads/payload_examples'

require 'tmpdir'
require 'fileutils'

describe Gen::Payloads::Nops do
  before(:all) do
    @path = File.join(Dir.tmpdir,'generated_payload.rb')

    Gen::Payloads::Nops.generate(
      {},
      [@path]
    )

    @payload = Payloads::Nops.load_from(@path)
  end

  it_should_behave_like "a Payload"

  it "should define a Nops payload" do
    @payload.class.should == Payloads::Nops
  end

  after(:all) do
    FileUtils.rm(@path)
  end
end
