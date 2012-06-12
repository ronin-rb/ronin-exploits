require 'spec_helper'
require 'gen/generators/spec_helper'

shared_examples_for "a generated Payload" do
  it "should set the name property" do
    subject.name.should == Gen::Generators::Payloads::Payload.name
  end

  it "should set the description property" do
    subject.description.should == Gen::Generators::Payloads::Payload.description
  end

  it "should define a default author" do
    subject.authors.length.should == 1
  end
end
