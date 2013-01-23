require 'spec_helper'
require 'ronin/gen/generators/payloads/shellcode'
require 'ronin/payloads/shellcode'

require 'gen/generators/payloads/payload_examples'
require 'tmpdir'
require 'fileutils'

describe Gen::Generators::Payloads::Shellcode do
  let(:path) { File.join(Dir.tmpdir,'generated_shellcode_payload.rb') }

  before(:all) do
    described_class.generate(path, edit: false)
  end

  subject { Payloads::Shellcode.load_object(path) }

  it_should_behave_like "a generated Payload"

  it "should define a Shellcode payload" do
    subject.class.should == Payloads::Shellcode
  end

  after(:all) { FileUtils.rm(path) }
end
