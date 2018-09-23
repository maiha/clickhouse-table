require "./spec_helper"

describe "clickhouse-client" do
  describe "schema merge" do
    it "prints schema of creating merge table" do
      run!("schema merge").stdout.should eq <<-EOF
        CREATE TABLE IF NOT EXISTS logs
        (
          date Date,
          hour Int32,
          imp  Int64
          )
        ENGINE = Merge(currentDatabase(), '^logs_')

        EOF
    end
  end

  describe "schema date <ymd>" do
    it "prints schema of creating table for the <ymd>" do
      run!("schema date 20180924").stdout.should eq <<-EOF
        CREATE TABLE IF NOT EXISTS logs_20180924
        (
          date Date,
          hour Int32,
          imp  Int64
          )
        ENGINE = MergeTree(date, (date, hour), 8192)

        EOF
    end
  end

  describe "schema tmp <ymd>" do
    it "prints schema of creating tmp table for the <ymd>" do
      run!("schema tmp 20180924").stdout.should eq <<-EOF
        CREATE TABLE IF NOT EXISTS tmp_logs_20180924
        (
          date Date,
          hour Int32,
          imp  Int64
          )
        ENGINE = MergeTree(date, (date, hour), 8192)

        EOF
    end
  end
end
