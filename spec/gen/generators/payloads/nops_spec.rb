require 'spec_helper'
require 'ronin/gen/generators/payloads/nops'
require 'ronin/payloads/nops'

require 'gen/generators/payloads/payload_examples'
require 'tmpdir'
require 'fileutils'

describe Gen::Generators::Payloads::Nops do
  before(:all) do
    @path = File.join(Dir.tmpdir,'generated_nops_payload.rb')

    described_class.generate(
      {:leverages => ['shell']},
      [@path]
    )
  end

  subject { Payloads::Nops.load_object(@path) }

  it_should_behave_like "a Payload"

  it "should define a Nops payload" do
    subject.class.should == Payloads::Nops
  end

  after(:all) { FileUtils.rm(@path) }
end
