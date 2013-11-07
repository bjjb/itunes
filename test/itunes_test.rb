require 'test_helper'
require 'itunes'

describe ITunes do
  it "has Commands" do
    ITunes::Commands.wont_be_nil
  end

  it "has a CLI" do
    ITunes::CLI.wont_be_nil
  end
end
