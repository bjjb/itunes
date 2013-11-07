require 'test_helper'
require 'itunes/cli'

describe ITunes::CLI do
  include ITunes::Commands

  let(:sample) { File.expand_path("../../tmp/sample.mp3", __FILE__) }

  it "can be used to add a track" do
    out, err = capture_io { ITunes::CLI.start(["add", sample]) }
    out.must_be_empty
    err.must_be_empty
    refs = tell("search first playlist for \"sample\"")
    refs.must_match /^{file track id \d+[^,]*}$/
    tell("delete #{refs[1...-1]}")
  end
end
