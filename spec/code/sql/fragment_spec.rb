require 'spec_helper'
require 'ronin/code/sql/fragment'

describe Code::SQL::Fragment do
  it "should encode fragments with no elements" do
    frag = Code::SQL::Fragment.new []

    frag.to_s.should == ''
  end

  it "should encode fragments with one element" do
    frag = Code::SQL::Fragment.new [:id]

    frag.to_s.should == 'id'
  end

  it "should encode fragments with more than one element" do
    frag = Code::SQL::Fragment.new [:drop_table, :users]

    frag.to_s.should == 'drop_table users'
  end

  describe "to_sqli" do
    before(:all) do
      @int_frag = Code::SQL::Fragment.new [:and, 1, :eq, 1]
      @string_frag = Code::SQL::Fragment.new [:and, '1', :eq, '1']
    end

    it "should escape from integer values" do
      sqli = @int_frag.to_sqli(:escape => :integer, :value => 1)

      sqli.should == "1 and 1 = 1"
    end

    it "should escape from string values and balance the number of quotes" do
      sqli = @string_frag.to_sqli(:escape => :string, :value => 1)

      sqli.should == "1' and '1' = '1"
    end

    it "should escape from string values and terminate with a comment" do
      sqli = @int_frag.to_sqli(:escape => :string, :value => 1)

      sqli.should == "1' and 1 = 1--"
    end

    it "should escape from other SQL statements" do
      sqli = @string_frag.to_sqli(:escape => :statement)

      sqli.should == ";and '1' = '1'"
    end

    it "should encode the SQL fragment when not escaping anything" do
      sqli = @string_frag.to_sqli

      sqli.should == "and '1' = '1'"
    end

    it "should allow comment termination of the SQL fragment" do
      sqli = @string_frag.to_sqli(:terminate => true)

      sqli.should == "and '1' = '1'--"
    end

    it "should not comment terminate the SQL fragment twice" do
      sqli = @int_frag.to_sqli(
        :escape => :string,
        :value => 1,
        :terminate => true
      )

      sqli.should == "1' and 1 = 1--"
    end
  end
end
