require 'spec_helper'
require 'ronin/leverage/api'

describe Leverage::API do
  let(:leverage_class) do
    Class.new do
      include Ronin::Leverage::API

      leverage :shell
    end
  end

  context "class-leval" do
    subject { leverage_class }

    it "should have leveraged resources" do
      subject.leverages.should_not be_empty
      subject.leverages.should include(:shell)
    end
  end

  context "instance-level" do
    subject { leverage_class.new }

    it "should have leveraged resources" do
      subject.leveraged.should_not be_empty
      subject.leveraged.should have_key(:shell)
    end

    it "should define methods for accessing the resources" do
      obj = Class.new { include Ronin::Leverage::API }.new
      obj.instance_eval { leverage :shell }

      obj.should respond_to(:shell)
    end

    it "should initialize all leveraged resources objects" do
      subject.leveraged.should_not be_empty
    end

    it "should provide arbitrary access to resources" do
      subject.leveraged[:shell].should_not be_nil
    end

    it "should raise an exception for unknown resources" do
      lambda {
        subject.instance_eval { leverage :fail }
      }.should raise_error(RuntimeError)
    end
  end
end
