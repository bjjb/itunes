require 'test_helper'
require 'itunes/application'

describe ITunes::Application do
  let(:app) { ITunes::Application.new }
  let(:sample) { File.expand_path("../../tmp/sample.mp3", __FILE__) }

  it "includes commands" do
    app.must_respond_to :osascript
  end

  it "can parse things" do
    app.parse('{}').must_equal []
  end

  it "automatically parses things" do
    app.osascript("2 + 4").must_equal 6
  end

  it "can talk to iTunes" do
    app.version.must_match /\d+\.\d+\.\d+/
  end

  it "can add a track to iTunes" do
    track = app.add_track(sample, { name: "The Box" })
    track.artist.must_equal "___sample_artist___"
    track.name.must_equal "The Box"
  end
end
