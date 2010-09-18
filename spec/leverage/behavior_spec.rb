require 'spec_helper'
require 'ronin/leverage/behavior'

describe Leverage::Behavior do
  it "should require name and description attributes" do
    behavior = Leverage::Behavior.new
    behavior.should_not be_valid

    behavior.name = 'arbitrary lol injection'
    behavior.should_not be_valid

    behavior.description = %{Allows for the arbitrary injection of lolz.}
    behavior.should be_valid
  end

  it "should be able to convert to a String" do
    behavior = Leverage::Behavior.new(
      :name => 'test',
      :description => 'This is a test.'
    )

    behavior.to_s.should == 'test'
  end

  it "should be able to convert to a Symbol" do
    behavior = Leverage::Behavior.new(
      :name => 'test',
      :description => 'This is a test.'
    )

    behavior.to_sym.should == :test
  end
end
