require 'spec_helper'
require 'ronin/gen/generators/payloads/web'
require 'ronin/payloads/web'

require 'gen/generators/payloads/payload_examples'
require 'tmpdir'
require 'fileutils'

describe Gen::Generators::Payloads::Web do
  before(:all) do
    @path = File.join(Dir.tmpdir,'generated_web_payload.rb')

    Gen::Generators::Payloads::Web.generate(
      {:leverages => ['shell']},
      [@path]
    )
  end

  subject { Payloads::Web.load_object(@path) }

  it_should_behave_like "a generated Payload"

  it "should define a Web payload" do
    subject.class.should == Payloads::Web
  end

  after(:all) { FileUtils.rm(@path) }
end
