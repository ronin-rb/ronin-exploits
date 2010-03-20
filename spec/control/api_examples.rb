require 'ronin/control/api'

require 'spec_helper'

shared_examples_for "Control API" do
  it "should have control methods" do
    @controller.control_methods.should =~ [:file_read, :file_write]
  end

  it "should populate the controlled behaviors relationship" do
    behavior_names = @controller.controlled_behaviors.map do |control|
      control.behavior.name.to_sym
    end

    @controller.control_methods.should =~ behavior_names
  end

  it "should allow calling the control methods" do
    @controller.file_read('path').should == 'data'
  end

  it "should raise an exception for undefined control methods" do
    lambda {
      @controller.code_exec('code')
    }.should raise_error(Control::NotControlled)
  end

  it "should raise an exception for unknown control methods" do
    lambda {
      @controller.undefined_control_method
    }.should raise_error(NoMethodError)
  end
end
