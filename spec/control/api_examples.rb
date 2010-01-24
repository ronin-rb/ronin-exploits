require 'ronin/control/api'

require 'spec_helper'

shared_examples_for "Control API" do
  it "should have control methods" do
    @controller.control_methods.should_not be_empty
  end

  it "should not mark normal instance methods as control methods" do
    @controller.control_methods.include?(:build).should == false
    @controller.control_methods.include?(:deploy).should == false
  end
end
