require 'spec_helper'
require 'ronin/payloads/payload'
require 'ronin/payloads/helpers/bind_shell'

describe Payloads::Helpers::BindShell do
  before(:all) do
    @payload = ronin_payload do
      helper :bind_shell
    end
  end

  it "should define a host parameter" do
    @payload.should have_param(:host)
  end

  it "should define a port parameter" do
    @payload.should have_param(:port)
  end

  it "should define a protocol parameter" do
    @payload.should have_param(:protocol)
  end

  describe "verify!" do
    before(:each) do
      @payload.host = 'localhost'
      @payload.port = 9999

      @payload.build!
    end

    it "should verify the host is set" do
      @payload.host = nil

      lambda {
        @payload.verify!
      }.should raise_error(Engine::VerificationFailed)

      @payload.host = 'localhost'
      @payload.verify!.should == true
    end

    it "should verify the port is set" do
      @payload.port = nil

      lambda {
        @payload.verify!
      }.should raise_error(Engine::VerificationFailed)

      @payload.port = 9999
      @payload.verify!.should == true
    end

    it "should verify that protocol is either tcp or udp" do
      @payload.protocol = :fail

      lambda {
        @payload.verify!
      }.should raise_error(Engine::VerificationFailed)

      @payload.protocol = :tcp
      @payload.verify!.should == true

      @payload.protocol = :udp
      @payload.verify!.should == true
    end
  end
end
