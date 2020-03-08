require 'spec_helper'
require 'ronin/gen/generators/payloads/binary_payload'
require 'ronin/payloads/binary_payload'

require 'gen/generators/payloads/payload_examples'
require 'tmpdir'
require 'fileutils'

describe Gen::Generators::Payloads::BinaryPayload do
  let(:path) { File.join(Dir.tmpdir,'generated_binary_payload.rb') }

  before(:all) do
    described_class.generate(path, edit: false)
  end

  subject { Payloads::BinaryPayload.load_object(path) }

  it_should_behave_like "a generated Payload"

  it "should define a BinaryPayload" do
    expect(subject.class).to eq(Payloads::BinaryPayload)
  end

  after(:all) { FileUtils.rm(path) }
end
