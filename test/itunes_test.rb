require 'test_helper'
require 'itunes'

describe ITunes do
  def sample
    File.expand_path("../tmp/sample.mp3", __FILE__)
  end

  it "can add files to iTunes" do
    ITunes.add([sample])
  end
end
