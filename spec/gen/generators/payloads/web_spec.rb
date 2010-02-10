require 'ronin/gen/generators/payloads/web'
require 'ronin/payloads/web'

require 'spec_helper'
require 'gen/generators/payloads/payload_examples'

require 'tmpdir'
require 'fileutils'

describe Gen::Generators::Payloads::Web do
  before(:all) do
    @path = File.join(Dir.tmpdir,'generated_payload.rb')

    Gen::Generators::Payloads::Web.generate(
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
