require 'spec_helper'
require 'ronin/gen/generators/payloads/payload'
require 'ronin/payloads/payload'

require 'gen/generators/payloads/payload_examples'
require 'tmpdir'
require 'fileutils'

describe Gen::Generators::Payloads::Payload do
  before(:all) do
    @path = File.join(Dir.tmpdir,'generated_payload.rb')

    Gen::Generators::Payloads::Payload.generate(
      {
        :control_methods => ['code_exec']
      },
      [@path]
    )

    @payload = Payloads::Payload.load_context(@path)
  end

  it_should_behave_like "a Payload"

  it "should define a Payload" do
    @payload.class.should == Payloads::Payload
  end

  after(:all) do
    FileUtils.rm(@path)
  end
end
