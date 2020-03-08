require 'spec_helper'
require 'ronin/gen/generators/payloads/web'
require 'ronin/payloads/web'

require 'gen/generators/payloads/payload_examples'
require 'tmpdir'
require 'fileutils'

describe Gen::Generators::Payloads::Web do
  let(:path) { File.join(Dir.tmpdir,'generated_web_payload.rb') }

  before(:all) do
    described_class.generate(path, edit: false)
  end

  subject { Payloads::Web.load_object(path) }

  it_should_behave_like "a generated Payload"

  it "should define a Web payload" do
    expect(subject.class).to eq(Payloads::Web)
  end

  after(:all) { FileUtils.rm(path) }
end
