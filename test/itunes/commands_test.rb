require 'test_helper'
require 'itunes/commands'

describe ITunes::Commands do
  let(:sample) { File.expand_path("../../tmp/sample.mp3", __FILE__) }

  include ITunes::Commands

  describe "osa scripting and callbacks" do
    it "runs commands" do
      results = []
      @callback = lambda do |script, result, retval, t|
        results << [script, result]
      end
      osascript("2 + 9").must_equal("11")
      results.must_equal [["2 + 9", "11"]]
    end

    it "complains if the script didn't work" do
      out, err = capture_subprocess_io do
        lambda { osascript("junk") }.must_raise RuntimeError
      end
      err.must_match /execution error/
    end
  end

  describe "the interesting commands" do
    def osascript(script)
      script.squeeze("\n").split("\n").map(&:strip).join("\n")
    end

    it "can add files" do
      add('foo', 'bar').must_equal((<<-APPLESCRIPT).strip)
tell application "iTunes"
add {POSIX file "foo", POSIX file "bar"}
end tell
      APPLESCRIPT
    end

    it "can delete files" do
      delete('foo', 'bar').must_equal((<<-APPLESCRIPT).strip)
tell application "iTunes"
delete foo
delete bar
end tell
      APPLESCRIPT
    end

    it "can search the library" do
      search("foo").must_equal((<<-APPLESCRIPT).strip)
tell application "iTunes"
search the first playlist for "foo"
end tell
      APPLESCRIPT
      search("foo", only: "artists").must_equal((<<-APPLESCRIPT).strip)
tell application "iTunes"
search the first playlist for "foo" only artists
end tell
      APPLESCRIPT
      search("foo", playlist: "bar", only: :songs).must_equal (<<-APPLESCRIPT).strip
tell application "iTunes"
search bar for "foo" only songs
end tell
      APPLESCRIPT
    end

    it "can modify a track" do
      edit('foo', { "bar" => "BAR", "x y" => "BINGO" }).must_equal (<<-APPLESCRIPT).strip
tell application "iTunes"
tell foo
set its bar to "BAR"
set its x y to "BINGO"
end tell
end tell
      APPLESCRIPT
    end
  end
end
