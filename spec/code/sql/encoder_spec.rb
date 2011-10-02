require 'spec_helper'
require 'ronin/code/sql/encoder'

require 'code/sql/classes/test_encoder'

describe Code::SQL::Encoder do
  before(:all) do
    @encoder = TestEncoder.new
  end

  it "should encode a keyword" do
    @encoder.test_keyword(:id).should == "id"
  end

  it "should encode a NULL keyword" do
    @encoder.test_null().should == 'null'
  end

  it "should encode a true value" do
    @encoder.test_boolean(true).should == 'true'
  end

  it "should encode a false value" do
    @encoder.test_boolean(false).should == 'false'
  end

  it "should encode an Integer" do
    @encoder.test_integer(10).should == '10'
  end

  it "should encode a Float" do
    @encoder.test_float(0.5).should == '0.5'
  end

  it "should encode a String" do
    @encoder.test_string('hello').should == "'hello'"
  end

  it "should encode an empty Array" do
    @encoder.test_list().should == "()"
  end

  it "should encode a singleton Array" do
    @encoder.test_list(1).should == "(1)"
  end

  it "should encode an Array" do
    @encoder.test_list(1,2,3).should == "(1,2,3)"
  end

  it "should encode an empty Hash" do
    @encoder.test_hash({}).should == "()"
  end

  it "should encode a singleton Hash" do
    @encoder.test_hash({:count => 5}).should == "(count=5)"
  end

  it "should encode a single Hash" do
    update = {:user => 'bob', :password => 'lol'}

    @encoder.test_hash(update)[1..-2].split(',').should =~ [
      "user='bob'",
      "password='lol'"
    ]
  end

  it "should encode multiple elements" do
    @encoder.test(1, :eq, 1).should == ['1', '=', '1']
  end

  describe "case" do
    it "should preserve case when encoding keywords by default" do
      @encoder = TestEncoder.new

      @encoder.test_keyword(:Select).should == 'Select'
    end

    it "should allow encoding keywords in upper-case" do
      @encoder = TestEncoder.new(:case => :lower)

      @encoder.test_keyword(:ID).should == 'id'
    end

    it "should allow encoding keywords in upper-case" do
      @encoder = TestEncoder.new(:case => :upper)

      @encoder.test_keyword(:id).should == 'ID'
    end

    it "should allow encoding keywords in random-case" do
      @encoder = TestEncoder.new(:case => :random)

      @encoder.test_keyword(:select).should_not == 'select'
    end
  end

  describe "quotes" do
    it "should single-quote strings by default" do
      @encoder = TestEncoder.new

      @encoder.test_string('hello').should == "'hello'"
    end

    it "should allow double-quoting strings" do
      @encoder = TestEncoder.new(:quotes => :double)

      @encoder.test_string('hello').should == '"hello"'
    end
  end

  describe "hex_escape" do
    it "should not hex-escape strings by default" do
      @encoder = TestEncoder.new

      @encoder.test_string('hello').should == "'hello'"
    end

    it "should allow hex-escaping strings" do
      @encoder = TestEncoder.new(:hex_escape => true)

      @encoder.test_string('hello').should == "hex(0x68656c6c6f)"
    end
  end

  describe "parenthesis" do
    it "should parenthesis all lists by default" do
      @encoder = TestEncoder.new

      @encoder.test_list(1,2,3).should == "(1,2,3)"
    end

    it "should allow omitting parenthesis on non-singleton lists" do
      @encoder = TestEncoder.new(:parens => :less)

      @encoder.test_list(1,2,3).should == "1,2,3"
    end

    it "should keep parenthesis on empty lists" do
      @encoder = TestEncoder.new(:parens => :less)

      @encoder.test_list().should == "()"
    end
  end

  describe "spaces" do
    it "should space-separate elements by default" do
      @encoder = TestEncoder.new

      @encoder.test_join(:union, :select).should == "union select"
    end

    it "should allow comment-separated joining of elements" do
      @encoder = TestEncoder.new(:spaces => false)

      @encoder.test_join(:union, :select).should == "union/**/select"
    end
  end
end
