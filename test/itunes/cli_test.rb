require 'test_helper'
require 'itunes/cli'

describe ITunes::CLI do
  let(:bin) { File.expand_path("../../../bin/itunes", __FILE__) }
  let(:lib) { File.expand_path("../../../lib", __FILE__) }
  let(:sample) { File.expand_path("../../tmp/sample.mp3", __FILE__) }
  
  def execute(commandline)
    capture_subprocess_io do
      system "ruby -I#{lib} -rubygems #{bin} #{commandline}"
    end
  end

  it "prints help" do
    out, err = execute('help')
    out.must_include ITunes::CLI::PROGRAM[:description]
    err.must_be_empty
  end

  describe "common usage" do
    it "adds a file to iTunes with metadata set" do
      out, err = execute("add #{sample} --debug --name=\"Ace\" --description=\"Nice\"")
      err.must_be_empty
    end
  end
end
