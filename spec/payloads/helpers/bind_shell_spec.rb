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

  describe "#test!" do
    before(:each) do
      subject.host = 'localhost'
      subject.port = 9999

      subject.build!
    end

    it "should test the host is set" do
      subject.host = nil

      lambda {
        subject.test!
      }.should raise_error(Script::TestFailed)

      subject.host = 'localhost'
      subject.test!.should == true
    end

    it "should test the port is set" do
      subject.port = nil

      lambda {
        subject.test!
      }.should raise_error(Script::TestFailed)

      subject.port = 9999
      subject.test!.should == true
    end

    context "protocol" do
      it "should accept :tcp" do
        subject.protocol = :tcp
        subject.test!.should == true
      end

      it "should accept :udp" do
        subject.protocol = :udp
        subject.test!.should == true
      end

      it "should test that protocol is either :tcp or :udp" do
        subject.protocol = :fail

        lambda {
          subject.test!
        }.should raise_error(Script::TestFailed)
      end
    end
  end
end
