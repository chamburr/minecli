require "./spec_helper"

describe "minecli" do
  it "works" do
    `shards build minecli`
    output = `bin/minecli --help`
    output.should start_with "Minecraft CLI"
  end
end
