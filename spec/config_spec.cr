require "./spec_helper"

describe "clickhouse-client" do
  describe "config sample" do
    it "prints whole sample config written in config/config.toml" do
      run!("config sample").stdout.should eq(File.read("config/config.toml"))
    end
  end
end
