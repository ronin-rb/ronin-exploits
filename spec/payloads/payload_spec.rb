require 'spec_helper'
require 'ronin/payloads/payload'

require 'helpers/payloads'

describe Payloads::Payload do
  include Helpers

  before(:each) do
    @payload = load_payload('simple')
  end

  it "should require a name attribute" do
    payload = Payloads::Payload.new
    payload.should_not be_valid

    payload.name = 'test'
    payload.should be_valid
  end

  it "should have a unique name and version" do
    first_payload = Payloads::Payload.create(
      :name => 'test',
      :version => '0.0.1'
    )
    first_payload.should be_valid

    second_payload = Payloads::Payload.new(
      :name => 'test',
      :version => '0.0.1'
    )
    second_payload.should_not be_valid

    third_payload = Payloads::Payload.new(
      :name => 'test',
      :version => '0.0.2'
    )
    third_payload.should be_valid
  end

  it "should initialize all parameters by default" do
    @payload.params.should_not be_empty
  end

  it "should not have an Arch by default" do
    @payload.arch.should be_nil
  end

  it "should not have an OS by default" do
    @payload.os.should be_nil
  end

  it "should allow for the extending of Helper modules" do
    @payload.instance_eval { helper :bind_shell }.should == true
  end

  it "should raise an UnknownHelper when extending an unknown helper" do
    lambda {
      @payload.instance_eval { helper :obvious_not_there }
    }.should raise_error(Payloads::UnknownHelper)
  end

  it "should not have an exploit by default" do
    @payload.exploit.should be_nil
  end

  it "should store the raw payload in the @raw_payload instance variable" do
    @payload.build!
    @payload.raw_payload.should == "code.func"
  end

  it "should return the raw payload when calling build!" do
    @payload.build!
    @payload.raw_payload.should == "code.func"
  end

  it "should use parameters in the building of the payload" do
    @payload.custom = 'hello'
    @payload.build!
    @payload.raw_payload.should == "code.hello"
  end
end
