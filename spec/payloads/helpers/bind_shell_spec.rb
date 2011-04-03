require 'spec_helper'
require 'ronin/payloads/payload'
require 'ronin/payloads/helpers/bind_shell'

describe Payloads::Helpers::BindShell do
  subject do
    Payloads::Payload.object do
      helper :bind_shell
    end
  end

  it { should have_param(:host) }
  it { should have_param(:port) }
  it { should have_param(:protocol) }

  describe "#verify!" do
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

    context "protocol" do
      it "should accept :tcp" do
        subject.protocol = :tcp
        subject.verify!.should == true
      end

      it "should accept :udp" do
        subject.protocol = :udp
        subject.verify!.should == true
      end

      it "should verify that protocol is either :tcp or :udp" do
        subject.protocol = :fail

        lambda {
          subject.verify!
        }.should raise_error(Engine::VerificationFailed)
      end
    end
  end
end
