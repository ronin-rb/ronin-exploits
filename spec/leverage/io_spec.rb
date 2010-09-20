require 'spec_helper'
require 'ronin/leverage/io'
require 'leverage/classes/fake_io'

describe Leverage::IO do
  let(:expected_blocks) { ["one\n", "two\nthree\n", "four\n"] }
  let(:expected) { expected_blocks.join }
  let(:expected_bytes) { expected_blocks.join.each_byte.to_a }
  let(:expected_chars) { expected_blocks.join.each_char.to_a }
  let(:expected_lines) { expected_blocks.join.each_line.to_a }

  subject { FakeIO.new }

  describe "initialize" do
    it "should open the IO stream" do
      subject.should_not be_closed
    end

    it "should set the file descriptor returned by io_open" do
      subject.fd.should == 3
    end
  end

  it "should close the IO stream after the given block returns" do
    io = FakeIO.open do |io|
      io.should_not be_closed
      io
    end

    io.should be_closed
  end

  it "should read each block of data" do
    subject.each_block.to_a.should == expected_blocks
  end

  it "should read all of the data" do
    subject.read.should == expected
  end

  it "should read partial sections of the data" do
    subject.read(3).should == expected[0,3]
    subject.read(1).should == expected[3,1]
  end

  it "should read individual blocks of data" do
    subject.read(4).should == expected[0,4]
  end

  it "should get a character" do
    subject.getc.should == expected_bytes.first
  end

  it "should un-get characters back into the IO stream" do
    data = subject.read(4)
    data.each_char.reverse_each { |c| subject.ungetc(c) }

    subject.read(4).should == data
  end

  it "should get a line" do
    subject.gets.should == expected_lines.first
  end

  it "should read bytes" do
    subject.readbytes(3).should == expected_bytes[0,3]
  end

  it "should read a char" do
    subject.readchar.should == expected_bytes.first
  end

  it "should read a line" do
    subject.readline.should == expected_lines.first
  end

  it "should read all lines" do
    subject.readlines.should == expected_lines
  end

  it "should read each byte of data" do
    subject.each_byte.to_a.should == expected_bytes
  end

  it "should read each char of data" do
    subject.each_char.to_a.should == expected_chars
  end

  it "should read each line of data" do
    subject.each_line.to_a.should == expected_lines
  end
end
