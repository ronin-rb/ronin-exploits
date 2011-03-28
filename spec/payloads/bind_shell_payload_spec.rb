require 'spec_helper'
require 'ronin/payloads/payload'
require 'ronin/payloads/helpers/bind_shell'

describe Payloads::Helpers::BindShell do
  subject do
    Payloads::Payload.object do
      helper :bind_shell
    end
  end

  it "should define a host parameter" do
    subject.should have_param(:host)
  end

  it "should define a port parameter" do
    subject.should have_param(:port)
  end

  it "should define a protocol parameter" do
    subject.should have_param(:protocol)
  end

  describe "verify!" do
    before(:each) do
      subject.host = 'localhost'
      subject.port = 9999

      subject.build!
    end

    it "should verify the host is set" do
      subject.host = nil

      lambda {
        subject.verify!
      }.should raise_error(Engine::VerificationFailed)

      subject.host = 'localhost'
      subject.verify!.should == true
    end

    it "should verify the port is set" do
      subject.port = nil

      lambda {
        subject.verify!
      }.should raise_error(Engine::VerificationFailed)

      subject.port = 9999
      subject.verify!.should == true
    end

    it "should verify that protocol is either tcp or udp" do
      subject.protocol = :fail

      lambda {
        subject.verify!
      }.should raise_error(Engine::VerificationFailed)

      subject.protocol = :tcp
      subject.verify!.should == true

      subject.protocol = :udp
      subject.verify!.should == true
    end
  end
end
