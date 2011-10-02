require 'spec_helper'
require 'ronin/code/sql/factory'

describe Code::SQL::Factory do
  before(:all) do
    @sql = Code::SQL::Factory.new
  end

  it "should allow creating fragments" do
    frag = @sql[1, :eq, 1]

    frag.should be_kind_of(Code::SQL::Fragment)
  end

  it "should allow creating functions" do
    func = @sql.max(:users)

    func.should be_kind_of(Code::SQL::Function)
  end
end
