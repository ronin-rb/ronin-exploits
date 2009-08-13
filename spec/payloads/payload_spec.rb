require 'ronin/payloads/payload'

require 'spec_helper'
require 'helpers/objects'
require 'controls/behaviors_examples'

describe Payloads::Payload do
  before(:each) do
    @payload = load_payload('test')
    @controler = @payload
  end

  it_should_behave_like "controls behaviors"

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

  it "should set the Arch when called with a name" do
    @payload.arch :i686
    @payload.arch.name.should == 'i686'
    @payload.arch.endian == 'little'
    @payload.arch.address_length == 4
  end

  it "should not have an OS by default" do
    @payload.os.should be_nil
  end

  it "should set the OS when called with arguments" do
    @payload.os(:name => 'FreeBSD', :version => '7.1')
    @payload.os.name.should == 'FreeBSD'
    @payload.os.version.should == '7.1'
  end

  it "should allow for the extending of Helper modules" do
    @payload.instance_eval { helper :rpc }.should == true
  end

  it "should raise an UnknownHelper when extending an unknown helper" do
    lambda {
      @payload.instance_eval { helper :obvious_not_there }
    }.should raise_error(Payloads::UnknownHelper)
  end

  it "should not have an exploit by default" do
    @payload.exploit.should be_nil
  end

  it "should be 'unbuilt' by default" do
    @payload.should_not be_built
  end

  it "should have 'built' and 'unbuilt' states" do
    @payload.should_not be_built
    @payload.build!
    @payload.should be_built
  end

  it "should store the built payload in the @payload instance variable" do
    @payload.build!
    @payload.payload.should == "code.func"
  end

  it "should return the built payload when calling build!" do
    @payload.build!
    @payload.payload.should == "code.func"
  end

  it "should use parameters in the building of the payload" do
    @payload.custom = 'hello'
    @payload.build!
    @payload.payload.should == "code.hello"
  end

  it "should be 'undeployed' by default" do
    @payload.should_not be_deployed
  end

  it "should have 'deployed' and 'undeployed' states" do
    @payload.should_not be_deployed
    @payload.build!
    @payload.deploy!
    @payload.should be_deployed
  end

  it "should have a default deployer method" do
    @payload.deploy! do |payload|
      payload.should == @payload
    end
  end

  it "should build and deploy the payload when ran" do
    @payload.run

    @payload.should be_built
    @payload.should be_deployed
  end

  it "should return the name and the version when calling to_s" do
    @payload.to_s.should == 'test 0.1'
  end

  it "should have a custom inspect method" do
    @payload.inspect.should == '#<Ronin::Payloads::Payload: test 0.1 {:custom=>"func"}>'
  end
end
