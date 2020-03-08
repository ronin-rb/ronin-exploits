require 'spec_helper'
require 'ronin/payloads/payload'

require 'helpers/payloads'

describe Payloads::Payload do
  include Helpers

  let(:payload) { load_payload('simple') }

  it "should require a name attribute" do
    payload = Payloads::Payload.new
    expect(payload).not_to be_valid

    payload.name = 'test'
    expect(payload).to be_valid
  end

  it "should have a unique name and version" do
    first_payload = Payloads::Payload.create(
      name: 'test',
      version: '0.0.1'
    )
    expect(first_payload).to be_valid

    second_payload = Payloads::Payload.new(
      name: 'test',
      version: '0.0.1'
    )
    expect(second_payload).not_to be_valid

    third_payload = Payloads::Payload.new(
      name: 'test',
      version: '0.0.2'
    )
    expect(third_payload).to be_valid
  end

  it "should initialize all parameters by default" do
    expect(payload.params).not_to be_empty
  end

  it "should not have an Arch by default" do
    expect(payload.arch).to be_nil
  end

  it "should not have an OS by default" do
    expect(payload.os).to be_nil
  end

  describe "helpers" do
    it "should allow for the extending of Helper modules" do
      expect(payload.instance_eval { helper :bind_shell }).to eq(true)
    end

    it "should raise an UnknownHelper when extending an unknown helper" do
      expect {
        payload.instance_eval { helper :obvious_not_there }
      }.to raise_error(Payloads::UnknownHelper)
    end
  end

  it "should not have an exploit by default" do
    expect(payload.exploit).to be_nil
  end

  describe "#build!" do
    it "should store the raw payload in the @raw_payload instance variable" do
      payload.build!
      expect(payload.raw_payload).to eq("code.func")
    end

    it "should return the raw payload when calling build!" do
      payload.build!
      expect(payload.raw_payload).to eq("code.func")
    end

    it "should use parameters in the building of the payload" do
      payload.custom = 'hello'

      payload.build!
      expect(payload.raw_payload).to eq("code.hello")
    end
  end
end
