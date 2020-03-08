require 'spec_helper'
require 'gen/generators/spec_helper'

shared_examples_for "a generated Payload" do
  it "should set the name property" do
    expect(subject.name).to eq(Gen::Generators::Payloads::Payload.name)
  end

  it "should set the description property" do
    expect(subject.description).to eq(Gen::Generators::Payloads::Payload.description)
  end

  it "should define a default author" do
    expect(subject.authors.length).to eq(1)
  end
end
