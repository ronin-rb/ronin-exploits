require 'ronin/gen/payloads/web'
require 'ronin/payloads/web'

require 'spec_helper'
require 'gen/payloads/payload_examples'

require 'tmpdir'
require 'fileutils'

describe Gen::Payloads::Web do
  before(:all) do
    @path = File.join(Dir.tmpdir,'generated_payload.rb')

    Gen::Payloads::Web.generate(
      {
        :control_methods => ['code_exec']
      },
      [@path]
    )

    @payload = Payloads::Web.load_from(@path)
  end

  it_should_behave_like "a Payload"

  it "should define a Web payload" do
    @payload.class.should == Payloads::Web
  end

  after(:all) do
    FileUtils.rm(@path)
  end
end
