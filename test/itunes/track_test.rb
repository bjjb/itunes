require 'test_helper'
require 'itunes/track'

describe ITunes::Track do
  include ITunes::Commands

  let(:sample) { File.expand_path("../../tmp/sample.mp3", __FILE__) }

  it "can get and set its properties" do
    ref = tell("add POSIX file \"#{sample}\"")
    track = ITunes::Track.new(ref)
    track.album.must_equal "___sample_album___"
    track.name = "My New Name"
    track.name.must_equal 'My New Name'
    track = ITunes::Track.new(tell("add POSIX file \"#{sample}\""))
    track.name.must_equal 'My New Name'
    tell("delete #{ref}")
  end
end
