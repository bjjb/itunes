require 'test_helper'
require 'itunes/track'

describe ITunes::Track do
  include ITunes::Commands

  let(:track_class) do
    Class.new(ITunes::Track) do
      attr_reader :scripts

      def osascript(script)
        @scripts ||= []
        @scripts << script.split("\n").map(&:strip).join("\n").squeeze(' ').strip
        '{name:"foo", artist:"Foo", album: "FOO"}'
      end
    end
  end

  it "is created using real data from iTunes" do
    t = track_class.new("foo")
    t.name.must_equal "foo"
    t.artist.must_equal "Foo"
  end

  it "stores its changes in iTunes" do
    t = track_class.new("x")
    t.name = "BAR"
    t.scripts.last.must_equal (<<-APPLESCRIPT).strip
tell application "iTunes"
set name of x to "BAR"
end tell
    APPLESCRIPT
  end
end
