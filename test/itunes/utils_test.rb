require 'test_helper'
require 'itunes/utils'

describe ITunes::Utils do

  include ITunes::Utils

  it "symbolizes strings" do
    symbolize("hello world").must_equal :hello_world
  end

  it "symbolizes symbols" do
    symbolize(:"hello world").must_equal :hello_world
  end

  it "stringifies symbols" do
    stringify(:hello_world).must_equal "hello world"
  end

  it "stringifies strings" do
    stringify("hello_world").must_equal "hello world"
  end

  it "symbolizes hash keys" do
    symbolize_keys("a" => 1, "b" => 2).must_equal(a: 1, b: 2)
  end

  it "stringifies hash keys" do
    stringify_keys(a: 1, b: 2).must_equal("a" => 1, "b" => 2)
  end
end
