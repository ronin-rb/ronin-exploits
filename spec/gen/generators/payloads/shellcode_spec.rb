require 'spec_helper'
require 'ronin/gen/generators/payloads/shellcode'
require 'ronin/payloads/shellcode'

require 'gen/generators/payloads/payload_examples'
require 'tmpdir'
require 'fileutils'

describe Gen::Generators::Payloads::Shellcode do
  before(:all) do
    @path = File.join(Dir.tmpdir,'generated_payload.rb')

    Gen::Generators::Payloads::Shellcode.generate(
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
