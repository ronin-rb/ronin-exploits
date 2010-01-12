require 'ronin/control/behavior'
require 'spec_helper'

describe Control::Behavior do
  it "should require name and description attributes" do
    behavior = Control::Behavior.new
    behavior.should_not be_valid

    behavior.name = 'arbitrary lol injection'
    behavior.should_not be_valid

    behavior.description = %{Allows for the arbitrary injection of lolz.}
    behavior.should be_valid
  end
end
