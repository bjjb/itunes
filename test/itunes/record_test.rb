require 'test_helper'
require 'itunes/record'

describe ITunes::Record do
  it "acts like a hash with symbol keys" do
    record = ITunes::Record.new(:x => "X", "y" => "Y")
    record[:x].must_equal "X"
    record[:y].must_equal "Y"
  end

  it "has dynamic accessors" do
    record = ITunes::Record.new(:x => "X", "y" => "Y")
    record.x.must_equal "X"
    record.y.must_equal "Y"
    record.x = "Hello"
    record.x.must_equal "Hello"
    record.fetch(:x).must_equal "Hello"
  end
end
