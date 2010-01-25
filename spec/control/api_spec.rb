require 'ronin/control/api'

require 'spec_helper'

describe Control::API do
  it "should provide the names of all support control methods" do
    Control::API.control_methods.should_not be_empty
  end
end
