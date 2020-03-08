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

      expect {
        subject.test!
      }.to raise_error(Behaviors::TestFailed)

      subject.host = 'localhost'
      expect(subject.test!).to eq(true)
    end

    it "should test the port is set" do
      subject.port = nil

      expect {
        subject.test!
      }.to raise_error(Behaviors::TestFailed)

      subject.port = 9999
      expect(subject.test!).to eq(true)
    end

    context "protocol" do
      it "should accept :tcp" do
        subject.protocol = :tcp
        expect(subject.test!).to eq(true)
      end

      it "should accept :udp" do
        subject.protocol = :udp
        expect(subject.test!).to eq(true)
      end

      it "should test that protocol is either :tcp or :udp" do
        subject.protocol = :fail

        expect {
          subject.test!
        }.to raise_error(Behaviors::TestFailed)
      end
    end
  end
end
