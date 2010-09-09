require 'spec_helper'
require 'ronin/gen/generators/payloads/nops'
require 'ronin/payloads/nops'

require 'gen/generators/payloads/payload_examples'
require 'tmpdir'
require 'fileutils'

describe Gen::Generators::Payloads::Nops do
  before(:all) do
    @path = File.join(Dir.tmpdir,'generated_payload.rb')

    Gen::Generators::Payloads::Nops.generate(
      {
        :control_methods => ['code_exec']
      },
      [@path]
    )

    @payload = Payloads::Nops.load_context(@path)
  end

  it_should_behave_like "a Payload"

  it "should define a Nops payload" do
    @payload.class.should == Payloads::Nops
  end

  after(:all) do
    FileUtils.rm(@path)
  end
end
