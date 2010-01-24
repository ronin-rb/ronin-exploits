require 'ronin/gen/payloads/shellcode'
require 'ronin/payloads/shellcode'

require 'spec_helper'
require 'gen/payloads/payload_examples'

require 'tmpdir'
require 'fileutils'

describe Gen::Payloads::Shellcode do
  before(:all) do
    @path = File.join(Dir.tmpdir,'generated_payload.rb')

    Gen::Payloads::Shellcode.generate(
      {
        :control_methods => ['code_exec']
      },
      [@path]
    )

    @payload = Payloads::Shellcode.load_from(@path)
  end

  it_should_behave_like "a Payload"

  it "should define a Shellcode payload" do
    @payload.class.should == Payloads::Shellcode
  end

  after(:all) do
    FileUtils.rm(@path)
  end
end
