require 'spec_helper'
require 'ronin/code/sql/function'

describe Code::SQL::Function do
  it "should encode functions with no arguments" do
    func = Code::SQL::Function.new('now')

    func.to_s.should == 'now()'
  end

  it "should encode functions with one argument" do
    func = Code::SQL::Function.new('max',[:id])

    func.to_s.should == 'max(id)'
  end

  it "should encode functions with more than one argument" do
    func = Code::SQL::Function.new('mid',[:city,1,4])

    func.to_s.should == 'mid(city,1,4)'
  end
end
