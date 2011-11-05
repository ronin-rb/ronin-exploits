require 'spec_helper'
require 'gen/generators/spec_helper'

shared_examples_for "a generated Payload" do
  it "should set the name property" do
    subject.name.should == Gen::Generators::Payloads::Payload::DEFAULT_NAME
  end

  it "should set the description property" do
    subject.description.should == Gen::Generators::Payloads::Payload::DEFAULT_DESCRIPTION
  end

  it "should not define any authors by default" do
    subject.authors.should be_empty
  end
end
