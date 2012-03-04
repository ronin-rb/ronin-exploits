require 'spec_helper'
require 'ronin/gen/generators/payloads/payload'
require 'ronin/payloads/payload'

require 'gen/generators/payloads/payload_examples'
require 'tmpdir'
require 'fileutils'

describe Gen::Generators::Payloads::Payload do
  let(:path) { File.join(Dir.tmpdir,'generated_payload.rb') }

  before(:all) do
    described_class.generate(path, :edit => false)
  end

  subject { Payloads::Payload.load_object(path) }

  it_should_behave_like "a generated Payload"

  it "should define a Payload" do
    subject.class.should == Payloads::Payload
  end

  after(:all) { FileUtils.rm(path) }
end
