require 'test_helper'
require 'itunes/commands'

describe ITunes::Commands do
  let(:sample) { File.expand_path("../../tmp/sample.mp3", __FILE__) }

  include ITunes::Commands

  it "can add a file" do
    ref = add(sample)
    ref.must_match /^file track id \d+/
    tell("delete #{ref}")
    refs = add(sample, sample)
    refs.must_match /^{([^,]+), \1}/
    ref = refs.split(',').first[1..-1].strip
    tell("delete #{ref}")
  end

  it "can delete a file" do
    ref = tell("add POSIX FILE \"#{sample}\"")
    delete(ref)
    tell(try("get #{ref}")).must_equal ""
  end

  it "can search the library" do
    ref = tell("add POSIX FILE \"#{sample}\"")
    search("sample").must_match /^{#{ref}}$/
    search("sample", only: "artists").must_match /^{#{ref}}$/
    search("sample_artist", only: "artists").must_match /^{#{ref}}$/
    search("sample_artist", only: "songs").must_match /^{}$/
    tell("delete #{ref}")
  end

  it "can modify a track" do
    ref = tell("add POSIX FILE \"#{sample}\"")
    edit(ref, { "sort name" => "My Sample Track" })
    tell("get sort name of #{ref}").must_equal "\"My Sample Track\""
    edit(ref, { "bpm" => 1, :sort_album => "My Sample Album" })
    tell("get bpm of #{ref}").must_equal "1"
    tell("get sort album of #{ref}").must_equal "\"My Sample Album\""
    tell("delete #{ref}")
  end
end
