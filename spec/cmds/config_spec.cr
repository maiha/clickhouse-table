require "./spec_helper"

describe "clickhouse-client" do
  describe "config sample" do
    it "prints whole sample config written in config/config.toml" do
      run!("config sample").stdout.should eq(File.read("config/config.toml"))
    end
  end

  describe "config from" do
    it "prints config from a sql of the schema definition" do
      sql = File.join(WORK_DIR, "foo.sql")
      gen = File.join(WORK_DIR, "generated.toml")
      buf = "CREATE TABLE foo(d Date, k Int32)ENGINE = MergeTree(d, k, 8192)"
      File.write(sql, buf)
      run!("config from - < #{sql} > #{gen}")

      config = Cu::Config.load(gen)
      config.table.should eq("foo")
      config.column.chomp.should eq("d Date, k Int32")
      config.engine.should eq("MergeTree(d, k, 8192)")
    end
  end
end
