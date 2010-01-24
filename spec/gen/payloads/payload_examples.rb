require 'spec_helper'

shared_examples_for "a Payload" do
  it "should set the name property" do
    @payload.name.should == Gen::Payloads::Payload::DEFAULT_NAME
  end

  it "should set the description property" do
    @payload.description.should == Gen::Payloads::Payload::DEFAULT_DESCRIPTION
  end

  it "should defines an author" do
    @payload.authors.length.should == 1
    @payload.authors.first.name.should == Author::ANONYMOUSE
  end

  it "should define control methods" do
    @payload.respond_to?(:code_exec).should == true
  end
end
