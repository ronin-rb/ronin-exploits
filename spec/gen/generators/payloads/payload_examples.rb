require 'spec_helper'
require 'gen/generators/spec_helper'

shared_examples_for "a Payload" do
  it "should set the name property" do
    @payload.name.should == Gen::Generators::Payloads::Payload::DEFAULT_NAME
  end

  it "should set the description property" do
    @payload.description.should == Gen::Generators::Payloads::Payload::DEFAULT_DESCRIPTION
  end

  it "should not define any authors by default" do
    @payload.authors.should be_empty
  end

  it "should define leveraged resources" do
    @payload.should be_leveraged(:shell)
  end
end
