require 'test_helper'
require 'itunes/parser'

describe ITunes::Parser do

  def parser(s)
    ITunes::Parser.new(s)
  end

  [
    ['"Hello"', :string, 'Hello'],
    ['"\"Hello\"?"', :string, '\"Hello\"?'],
    ['date "Friday 4 May 2012 11:27:05"', :date, DateTime.new(2012,5,4,11,27,5)],
    ['123', :integer, 123],
    ['12.34', :float, 12.34],
    ['true', :boolean, true],
    ['false', :boolean, false],
    ['missing value', :missing_value, nil],
    ['{1, "Hello", false}', :list, [1, "Hello", false]],
    ['{1}', :list, [1]],
    ['{1, {"He}},"}}', :list, [1, ["He}},"]]],
    ['{foo: "Bar", x y: {"X", "Y"}}', :record, { "foo" => "Bar", "x y" => %w(X Y) }],
    ['{foo:{x y:{"X", "Y"}}}', :record, { "foo" => {"x y" => %w(X Y) }}],
    ['{class:file track, x:20}', :record, { "class" => "file track", "x" => 20 }]
  ].each do |test, type, expected|
    describe test do
      let(:parser) { ITunes::Parser.new(test) }

      it "recognizes a #{type}" do
        parser.must_be :"#{type}?"
      end

      it "can parse a #{type}" do
        parser.send(:"#{type}!").must_equal expected
        parser.reset
        parser.parse!.must_equal expected
      end
    end
  end

  it "can handle leftovers" do
    ITunes::Parser.new("foo bar").parse!.must_equal "foo bar"
  end
end
